# Comparing Ball-Pivoting implementations

A harness that runs several Ball-Pivoting implementations on the same inputs and audits
every output the same way: does each triangle admit an empty ball, is the mesh orientable
and manifold, where are the holes, and which triangles does one tool build that another
does not. BPA.jl, Open3D and MeshLab's VCG filter are registered; adding your own
implementation is one entry in `tools.jl`. `REPORT.md` is the write-up of the comparison
made with it on 2026-09-02/03.

## Setup

The harness uses the package's own environment and no other Julia dependency. The Python
tools need a Python with `open3d` and `pymeshlab`, in `compare/.venv` or wherever
`BPA_COMPARE_PYTHON` points; without one their columns show `n/a`.

```
cd BPA.jl/compare
uv venv --python 3.11 && uv pip install open3d pymeshlab numpy      # once, optional
julia -t 3 --project=.. compare.jl --list                             # cases, tools, missing data
julia -t 3 --project=.. compare.jl synthetic                          # the synthetic group
julia -t 3 --project=.. compare.jl                                    # everything (see Runtime below)
open results/index.html
```

`-t 3` (or the number of tools) lets the per-triangle audits of the outputs run in
parallel; the tools themselves run one after the other so that their timings are those of
an idle machine. Renderings are converted to PNG with `sips` (macOS) or ImageMagick when
either is installed, and stay PPM otherwise.

## Usage

```
julia -t 3 --project=.. compare.jl [case|group ...] [options]

  --list                  the built-in cases and whether their data is present
  --tools STEMS|none      rerun only these tools; the others keep their output. none: re-analyse only
  --reference STEM        the tool the others are compared with (default: the first in tools.jl)
  --tools-file FILE       tool registry (default: tools.jl)
  --out DIR               results directory (default: compare/results)
  --input FILE --rho R [--name NAME] [--angle DEG]   an ad-hoc case (NOFF, .xyz, .ply or a mesh)
  --no-render             skip the renderings
  --parallel              run the tools of a case at once (spoils the timings)
  --assemble              rebuild results/report.md and results/index.html only

julia --project=.. flip.jl [STEM] [case ...]          diagonal switching toward the reference
julia --project=.. remaining.jl [STEM] [case ...]     what survives it, classified
julia --project=.. diagnose.jl <case> [STEM]          the failing triangles, one line each
julia --project=.. replay.jl <case> [n] [STEM]        re-roll the ball for the worst ones
```

Groups are `synthetic` and `scans`. Cases whose data is not downloaded are skipped with a
note (`scripts/download_bunny.sh` and `download_dragon.sh` fetch the Stanford scans).

Every case writes `results/<case>/`: the merged input as `input.off` (NOFF), each tool's
`<stem>.off` and `<stem>.log`, the triangle lists `only_in_<stem>.txt` and
`only_in_<reference>_vs_<stem>.txt`, the renderings under `render/`, and the report
fragments `report.md` and `report.html`. `results/report.md` and the gallery
`results/index.html` are assembled from whatever case directories exist, so cases can be
rerun one at a time and a tool can be rerun alone with `--tools`.

## Adding an implementation

Append a `Tool` to the vector in `tools.jl`:

```julia
Tool("mine", "mine",
     (input, rho, output) -> `mybpa --radius $rho $input $output`,
     r"reconstructed in ([\d.]+) s")
```

The contract: the command reads `input`, a NOFF file (`x y z nx ny nz` per vertex, the
normals already oriented), pivots a ball of radius `rho`, and writes `output` as an OFF
whose vertices are the input points in the same order, with the triangles as `3 i j k`
(0-based). The harness checks the vertex count and positions, because triangle indices are
compared across tools. Return `nothing` from the function when the tool is not installed.
The regex captures the tool's own reconstruction time in seconds from its log, excluding
start-up and file loading; when it does not match, the wall time of the process is used.
`run_py.py` is the wrapper the Open3D and MeshLab entries use and a template for tools
with Python bindings; anything that can be run from the command line works the same way.

A tool that writes a different format can be wrapped in a script that converts; a tool that
reorders or drops vertices must be wrapped to map its output back onto the input indices.

## What is measured

**Per output, without any reference.**

- *Empty-ball test.* For each triangle, the ball of radius ρ through its three vertices on
  its outward side (the side all three vertex normals agree on; when they do not, both
  sides are tried, the winding side first) is queried for other samples. Classes: `valid`;
  `valid_reversed_winding` (wound against the normals, but the outward ball is empty);
  `ball_not_empty`, with the deepest intruder's depth as a fraction of ρ;
  `ball_not_empty_tie` for depths below 1e-5 ρ (cospherical ties, not errors);
  `circumradius_too_large`; `degenerate`. The paper's algorithm never produces a
  `ball_not_empty` triangle, so this row is the correctness test.
- *Topology*, with `check_mesh`: orientable (no directed half-edge used twice),
  edge-manifold (at most two triangles per edge), vertex-manifold, boundary edges and loops,
  components and the size of the largest, Euler characteristic. On the closed synthetic
  surfaces the answer is known: sphere χ = 2, torus χ = 0, two triangles per vertex.
- *Renderings*, with `tools/render.jl`: the mesh flat-shaded with its boundary edges in
  red; the number of triangles behind each pixel, warm colours for odd counts and cool for
  even, so that on a closed surface every warm pixel is a hole seen through, including
  holes on the far side; and front-facing minus back-facing triangles per pixel, grey where
  they cancel, blue or red at holes and flipped patches. The share of odd-parity and of
  non-cancelling pixels goes into the table; it depends on the view and, for open inputs,
  includes the unscanned regions, so compare tools on the same case, not cases with each
  other. For scan lists the input scans are rendered too, showing the overlap.

**Against the reference.** Triangle sets are compared as unordered vertex triples: common,
only in the reference, only in the other, and how many common triangles have the same
winding. For each triangle on one side only, the number of its edges the other mesh also
has is recorded: 2 or 3 means the same region triangulated differently, 0 or 1 means one
front advanced where the other stopped.

**Diagonal switching** (`flip.jl`) separates free choices from real disagreement: where
two adjacent triangles of the other tool form a quad whose other diagonal the reference
uses, they are replaced by the reference's pair, to a fixed point; then any connected patch
of differing triangles with exactly the same boundary as a reference patch is swapped.
Whatever survives is a triangle one tool built and the other did not; `remaining.jl` says
what those are (their empty-ball class, one-triangle holes, and whether they pass the
all-three-normals test that some implementations apply).

## Cases

Synthetic, with a known answer (generated into `results/inputs/`):

| case | input | ρ | expected |
|---|---|---|---|
| `sphere2000` | Fibonacci sphere, 2000 points | 1.5 × mean spacing | closed, χ = 2, 3996 triangles |
| `plane40` | 40 × 40 jittered grid | 0.15 | disk, χ = 1, one boundary loop |
| `torus_r0.10`, `torus_r0.05` | `data/torus-120-80.off`, a regular lattice | 0.10, 0.05 | closed, χ = 0, 19200 triangles; cospherical quads, so diagonals are a free choice |
| `torus_jitter` | parametric torus, 120 × 80 grid jittered by 30 % | 0.06 | closed, χ = 0, unique answer |
| `torus_sampled20k` | 20000 points sampled by area on the trimesh2 torus | 0.05 | closed, χ = 0, 40000 triangles; uneven spacing |
| `knot_r0.0188` | `data/knot-300-100.off`, 30000 points | 1.5 × estimated spacing, too small | many boundaries: seeding and stopping behaviour |
| `knot_r0.03` | the same knot | 0.03 | nearly closed; small holes where the tube touches itself |

Stanford range scans (normals from each scan's own triangles, moved by its `.xf`):

| case | input | ρ |
|---|---|---|
| `bun000` | one bunny scan, 40256 points | 1.25 mm |
| `bunny4_r0.0008`, `bunny4_r0.0015` | four body scans, 150983 points | 0.8 mm (the layer separation of the overlap), 1.5 mm |
| `bunny10_r0.00125` | all ten bunny scans, 362272 points | 1.25 mm |
| `dragon62_r0.0007` | 62 dragon surface scans, 1.83 million points | 0.7 mm |

The sphere, plane, jittered torus and sampled torus should come out identical from every
faithful implementation; the regular torus identical after diagonal switching; and the
`ball_not_empty` row should be zero everywhere. After a change to the pivot, the front or
the seed search, run `compare.jl synthetic` first, then `scans`, then `flip.jl` to see
whether a new difference is a free choice or real.

## Runtime

The synthetic cases and the smaller scans take seconds. The ten-scan bunny takes about
half a minute for Open3D and three minutes for MeshLab; the dragon eleven minutes and four
hours respectively (their pivots are quadratic in the neighbourhood size, and the dragon
scans stack up to 98 layers). A full run is an overnight job; on a laptop keep it awake
(`caffeinate -i julia ...` on macOS). Timings inflate 2 to 4 times when tools run
concurrently, which is why `--parallel` is off by default.
