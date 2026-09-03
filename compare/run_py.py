#!/usr/bin/env python
"""Run Open3D's or PyMeshLab's ball pivoting on a NOFF point cloud and write a plain OFF.

    python run_py.py open3d|meshlab input.off radius output.off
"""
import sys, time
import numpy as np


def read_noff(path):
    with open(path) as f:
        tokens = f.read().split()
    assert tokens[0] in ("NOFF", "OFF"), tokens[0]
    nv, nf = int(tokens[1]), int(tokens[2])
    data = np.array(tokens[4:4 + 6 * nv], dtype=float).reshape(nv, 6)
    return data[:, :3].copy(), data[:, 3:].copy()


def write_off(path, P, F):
    with open(path, "w") as f:
        f.write(f"OFF\n{len(P)} {len(F)} 0\n")
        for p in P:
            f.write(f"{float(p[0])!r} {float(p[1])!r} {float(p[2])!r}\n")
        for t in F:
            f.write(f"3 {t[0]} {t[1]} {t[2]}\n")


def run_open3d(P, N, rho):
    import open3d as o3d
    pcd = o3d.geometry.PointCloud()
    pcd.points = o3d.utility.Vector3dVector(P)
    pcd.normals = o3d.utility.Vector3dVector(N)
    t0 = time.perf_counter()
    mesh = o3d.geometry.TriangleMesh.create_from_point_cloud_ball_pivoting(
        pcd, o3d.utility.DoubleVector([rho]))
    t = time.perf_counter() - t0
    return np.asarray(mesh.vertices), np.asarray(mesh.triangles), t


def run_meshlab(P, N, rho):
    import pymeshlab
    ms = pymeshlab.MeshSet()
    ms.add_mesh(pymeshlab.Mesh(vertex_matrix=P, v_normals_matrix=N))
    t0 = time.perf_counter()
    ms.generate_surface_reconstruction_ball_pivoting(ballradius=pymeshlab.PureValue(rho))
    t = time.perf_counter() - t0
    m = ms.current_mesh()
    return m.vertex_matrix(), m.face_matrix(), t


tool, inp, rho, out = sys.argv[1], sys.argv[2], float(sys.argv[3]), sys.argv[4]
P, N = read_noff(inp)
V, F, t = {"open3d": run_open3d, "meshlab": run_meshlab}[tool](P, N, rho)
write_off(out, V, F)
print(f"{tool}: {len(V)} vertices, {len(F)} triangles, time: {t:.3f} s")
