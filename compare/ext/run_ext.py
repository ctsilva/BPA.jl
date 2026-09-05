#!/usr/bin/env python
"""Run a third-party Ball-Pivoting implementation on a NOFF point cloud and write a plain OFF.

    python run_ext.py TOOL input.noff radius output.off

TOOL is one of digne, digne_par, gruber, bpa_rs, schmehla, giaccari. Each tool is
converted to and from its own file format here, so that compare.jl sees the contract it
expects: the output OFF has the input vertices in the input order and 0-based triangles.
The binaries are built by build.sh into $BPA_EXTERNAL (default compare/external); the
script exits with status 2 when the binary is missing.

The last line printed is `time: T s`, the tool's own reconstruction time when it reports
one with sub-second resolution, else the wall time of the subprocess.
"""
import os, struct, subprocess, sys, time
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
EXT = os.environ.get("BPA_EXTERNAL", os.path.join(HERE, "..", "external"))


def read_noff(path):
    with open(path) as f:
        tokens = f.read().split()
    assert tokens[0] in ("NOFF", "OFF"), tokens[0]
    nv = int(tokens[1])
    data = np.array(tokens[4:4 + 6 * nv], dtype=float).reshape(nv, 6)
    return data[:, :3].copy(), data[:, 3:].copy()


def write_off(path, P, F):
    with open(path, "w") as f:
        f.write(f"OFF\n{len(P)} {len(F)} 0\n")
        for p in P:
            f.write(f"{float(p[0])!r} {float(p[1])!r} {float(p[2])!r}\n")
        for t in F:
            f.write(f"3 {t[0]} {t[1]} {t[2]}\n")


def index_by_position(P, Q, single=False):
    """Map each row of Q to the index of the equal row of P. When `single`, both sides are
    compared at float32 precision (tools that store positions as float)."""
    # double: rounded to 1e-10 absolute, since Digne re-prints with 16 significant digits
    key = (lambda r: tuple(np.float32(r).tolist())) if single else (lambda r: tuple(np.round(np.asarray(r) * 1e10).astype(np.int64).tolist()))
    lookup = {}
    for i, p in enumerate(P):
        lookup.setdefault(key(p), i)
    idx = np.empty(len(Q), dtype=int)
    misses = 0
    for j, q in enumerate(Q):
        k = key(q)
        if k in lookup:
            idx[j] = lookup[k]
        else:
            misses += 1
            # nearest input point; only reached when the tool re-printed with fewer digits
            d = ((P - q) ** 2).sum(1)
            idx[j] = int(d.argmin())
    if misses:
        print(f"warning: {misses} output vertices matched by nearest neighbour", file=sys.stderr)
    return idx


TIMEOUT = float(os.environ.get("BPA_EXT_TIMEOUT", 3600))   # seconds; a hung tool counts as no output
TEMP = []                                                   # intermediate files, removed at the end unless BPA_EXT_KEEP is set


def temp(path):
    TEMP.append(path)
    return path


def run(cmd, cwd=None):
    t0 = time.perf_counter()
    try:
        r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=TIMEOUT)
    except subprocess.TimeoutExpired:
        sys.exit(f"{cmd[0]} killed after {TIMEOUT:.0f} s")
    wall = time.perf_counter() - t0
    sys.stdout.write(r.stdout)
    sys.stderr.write(r.stderr)
    if r.returncode != 0:
        sys.exit(f"{cmd[0]} exited with status {r.returncode}")
    return r.stdout, wall


def grab(text, prefix, suffix=""):
    """The number between `prefix` and `suffix` in `text`, or None."""
    i = text.find(prefix)
    if i < 0:
        return None
    rest = text[i + len(prefix):].lstrip()
    num = ""
    for ch in rest:
        if ch.isdigit() or ch in ".eE-+":
            num += ch
        else:
            break
    try:
        return float(num)
    except ValueError:
        return None


def need(path):
    if not os.path.isfile(path):
        sys.exit(2)
    return path


# --- the tools --------------------------------------------------------------------------

def run_digne(P, N, rho, work, parallel):
    """Digne's IPOL 2014 parallel BPA (C++, octree). Input: `x y z nx ny nz` per line, no
    header. Output: ASCII PLY whose vertices are renumbered in order of first use, so they
    are matched back by position (16 significant digits, exact for our inputs). Built with
    digne_main.patch: -n skips its unconditional hole filling, timers are sub-second."""
    exe = need(os.path.join(EXT, "ipol_digne", "BallPivoting", "build", "ballpivoting"))
    xyz = temp(os.path.join(work, "digne_in.xyz"))
    ply = temp(os.path.join(work, "digne_out.ply"))
    np.savetxt(xyz, np.hstack([P, N]), fmt="%.17g")
    radii = rho if isinstance(rho, list) else [rho]
    cmd = [exe, "-i", xyz, "-o", ply, "-n"] + [a for r in radii for a in ("-r", repr(r))] + (["-p"] if parallel else [])
    out, wall = run(cmd)
    t = grab(out, "Reconstructing the mesh took")
    with open(ply) as f:
        nv = nf = 0
        for line in f:
            if line.startswith("element vertex"):
                nv = int(line.split()[2])
            elif line.startswith("element face"):
                nf = int(line.split()[2])
            elif line.startswith("end_header"):
                break
        V = np.array([f.readline().split()[:3] for _ in range(nv)], dtype=float).reshape(nv, 3)
        F = np.array([f.readline().split()[1:4] for _ in range(nf)], dtype=int).reshape(nf, 3)
    idx = index_by_position(P, V)
    return idx[F], t if t is not None else wall


def scaled_noff(P, N, rho, work):
    """The input rescaled so that the ball radius is 1, for Gruber and its Rust port: both
    keep float32 positions and test emptiness against `rho^2 - 1e-4` in absolute units,
    which is vacuous below rho = 0.01 (the scans use 0.0007 to 0.0015). The triangles come
    back as indices, so no unscaling is needed."""
    path = temp(os.path.join(work, "scaled_in.noff"))
    with open(path, "w") as f:
        f.write(f"NOFF\n{len(P)} 0 0\n")
        for p, n in zip(P / rho, N):
            f.write(f"{float(p[0])!r} {float(p[1])!r} {float(p[2])!r} {float(n[0])!r} {float(n[1])!r} {float(n[2])!r}\n")
    return path


def run_gruber(P, N, rho, work):
    """bernhardmgruber/bpa (C++20, float). gruber_noff2off.cpp reads the NOFF directly,
    calls bpa::reconstruct and maps the returned positions back to input indices."""
    exe = need(os.path.join(EXT, "bernhardmgruber_bpa", "build", "gruber_noff2off"))
    off = temp(os.path.join(work, "gruber_out.off"))
    out, wall = run([exe, scaled_noff(P, N, rho, work), "1.0", off])
    t = grab(out, "time:")
    return read_off_faces(off), t if t is not None else wall


def run_bpa_rs(P, N, rho, work):
    """martinfrances107/bpa_rs (Rust port of Gruber). bpa_rs_noff2off does the same as the
    Gruber driver."""
    exe = need(os.path.join(EXT, "martinfrances107_bpa_rs", "target", "release", "bpa_rs_noff2off"))
    off = temp(os.path.join(work, "bpa_rs_out.off"))
    out, wall = run([exe, scaled_noff(P, N, rho, work), "1.0", off])
    t = grab(out, "time:")
    return read_off_faces(off), t if t is not None else wall


def run_schmehla(P, N, rho, work):
    """schmehla/ball-pivoting-algorithm (C++, thesis). Input: OBJ with `v`, `vn` and
    `p i//i` lines; output OBJ keeps every input vertex in order. Its own timer prints
    whole seconds, so the wall time is used."""
    exe = need(os.path.join(EXT, "schmehla_ball-pivoting-algorithm", "build", "BPA"))
    obj = temp(os.path.join(work, "schmehla_in.obj"))
    res = temp(os.path.join(work, "schmehla_out.obj"))
    with open(obj, "w") as f:
        for p, n in zip(P, N):
            f.write(f"v {float(p[0])!r} {float(p[1])!r} {float(p[2])!r}\nvn {float(n[0])!r} {float(n[1])!r} {float(n[2])!r}\n")
        for i in range(len(P)):
            f.write(f"p {i + 1}//{i + 1}\n")
    out, wall = run([exe, repr(rho), obj, res])
    F = []
    with open(res) as f:
        for line in f:
            if line.startswith("f "):
                F.append([int(tok.split("/")[0]) - 1 for tok in line.split()[1:4]])
    return np.array(F, dtype=int).reshape(-1, 3), wall


def run_giaccari(P, N, rho, work):
    """Giaccari's Surface Reconstruction Toolbox `ballpivoting` (C++). Input: `.cgo`, a
    count then `x y z` per line; normals are not read. Output: binary STL, matched back by
    float32 position. -pa 0 stops it waiting for a key press at the end."""
    exe = need(os.path.join(EXT, "LuigiGiaccari_Surface-Reconstruction-Toolbox", "build", "ballpivoting"))
    cgo = temp(os.path.join(work, "giaccari_in.cgo"))
    stl = temp(os.path.join(work, "giaccari_out.stl"))
    with open(cgo, "w") as f:
        f.write(f"{len(P)}\n")
        for p in P:
            f.write(f"{float(p[0])!r} {float(p[1])!r} {float(p[2])!r}\n")
    # relative names: its extension check takes the first dot of the whole path ("BPA.jl")
    out, wall = run([exe, "-in", os.path.basename(cgo), "-out", os.path.basename(stl), "-r", repr(rho), "-pa", "0"], cwd=work)
    t = grab(out, "Total Time:")
    with open(stl, "rb") as f:
        data = f.read()
    nt = struct.unpack("<I", data[80:84])[0]
    tri = np.frombuffer(data[84:84 + 50 * nt], dtype=np.dtype([("n", "<f4", 3), ("v", "<f4", (3, 3)), ("a", "<u2")]))
    V = tri["v"].reshape(-1, 3).astype(float)
    idx = index_by_position(P, V, single=True)
    return idx.reshape(-1, 3), t if t is not None else wall


def read_off_faces(path):
    with open(path) as f:
        assert f.readline().strip() == "OFF"
        nv, nf, _ = map(int, f.readline().split())
        for _ in range(nv):
            f.readline()
        return np.array([f.readline().split()[1:4] for _ in range(nf)], dtype=int).reshape(nf, 3)


TOOLS = {
    "digne": lambda P, N, rho, w: run_digne(P, N, rho, w, False),
    "digne_par": lambda P, N, rho, w: run_digne(P, N, rho, w, True),
    "gruber": run_gruber,
    "bpa_rs": run_bpa_rs,
    "schmehla": run_schmehla,
    "giaccari": run_giaccari,
}

if __name__ == "__main__":
    tool, INPUT, output = sys.argv[1], os.path.abspath(sys.argv[2]), sys.argv[4]
    radii = sorted(float(r) for r in sys.argv[3].split(","))
    if len(radii) > 1 and not tool.startswith("digne"):
        sys.exit(f"{tool}: one radius only")
    rho = radii if tool.startswith("digne") else radii[0]
    work = os.path.dirname(os.path.abspath(output))
    P, N = read_noff(INPUT)
    try:
        F, t = TOOLS[tool](P, N, rho, work)
        write_off(output, P, F)
    finally:
        if not os.environ.get("BPA_EXT_KEEP"):
            for path in TEMP:
                if os.path.exists(path):
                    os.remove(path)
    print(f"{tool}: {len(P)} vertices, {len(F)} triangles, time: {t:.3f} s")
