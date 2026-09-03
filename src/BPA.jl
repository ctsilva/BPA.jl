"""
    BPA

A Julia implementation of the Ball-Pivoting Algorithm for surface reconstruction:

> F. Bernardini, J. Mittleman, H. Rushmeier, C. Silva, G. Taubin,
> "The Ball-Pivoting Algorithm for Surface Reconstruction",
> IEEE Transactions on Visualization and Computer Graphics 5(4), 1999.

The main entry point is [`reconstruct`](@ref), which takes a [`PointCloud`](@ref)
(positions plus oriented normals) and one or more ball radii and returns a
[`BPAMesh`](@ref) interpolating the input points.

# Public API

- `PointCloud(positions, normals)`: input container; accepts vectors of 3-vectors or 3×N /
  N×3 matrices.
- `reconstruct(cloud, rho)`, `reconstruct(cloud, radii)`, `reconstruct(positions, normals, r)`:
  run the algorithm; `verbose = true` prints a line per pass.
- `BPAMesh`: result with `triangles` (vector of `SVector{3,Int}`), the `cloud` they index,
  and `stats::BPAStats`.
- `read_xyz`, `read_ply`, `read_off`, `write_off`, `write_ply`, `write_obj`: file I/O.
- `vertex_normals`, `sample_surface`: turn a triangle mesh into a point cloud with normals
  (for experiments with meshes that have no normals of their own).
- `estimate_spacing`: median nearest-neighbour distance, to choose a radius.
- `check_mesh`: topology of a triangle list (orientable, manifold, boundary loops, components,
  Euler characteristic), for checking a result.
- `fibonacci_sphere`, `torus`, `plane_patch` (not exported): synthetic point clouds with
  analytic normals, for tests and the comparison harness in `compare/`.
- `main(args)`: the command-line tool behind `bpa.jl` (`julia bpa.jl -h`). Its helpers
  `read_xf` and `transform` (not exported) apply the 4×4 `.xf` matrices of registered
  range scans to a point cloud.

# Source layout

| file | contents | paper section |
| --- | --- | --- |
| `types.jl` | `PointCloud`, `FrontEdge`, `Front`, `BPAMesh`, `BPAStats` | 4 |
| `grid.jl` | voxel grid and the two spatial queries | 4.1 |
| `geometry.jl` | ball centres, pivot trajectory and first-contact angle | 4.2, 4.3 |
| `front.jl` | front bookkeeping, `join!`, `glue!`, manifold tests | 4.4 |
| `seed.jl` | seed triangle search | 4.2 |
| `pivot.jl` | `ball_pivot` | 4.3 |
| `reconstruct.jl` | the main loop (Fig. 5) and multiple passes | 4, 4.6 |
| `io.jl` | XYZ / PLY / OFF input, OBJ / PLY output, mesh sampling | — |
| `spacing.jl` | sample spacing estimate | — |
| `check.jl` | `check_mesh`: topology of a triangle list | — |
| `synthetic.jl` | synthetic point clouds with analytic normals | — |
| `cli.jl` | command-line interface | — |

`docs/algorithm.md` walks through the algorithm, the conventions and the invariants.
"""
module BPA

using LinearAlgebra
using StaticArrays
using Random

export PointCloud, BPAMesh, BPAStats, reconstruct, estimate_spacing
export read_xyz, read_ply, read_off, write_ply, write_obj, write_off, vertex_normals, sample_surface
export MeshCheck, check_mesh

include("types.jl")
include("grid.jl")
include("geometry.jl")
include("front.jl")
include("seed.jl")
include("pivot.jl")
include("reconstruct.jl")
include("io.jl")
include("spacing.jl")
include("check.jl")
include("synthetic.jl")
include("cli.jl")

end # module
