
## torus_sampled20k

20000 points sampled uniformly by area on the trimesh2 torus (uneven spacing, normals from the faces), rho = 0.05 (5 x the median nearest-neighbour distance). Expected: closed, chi = 0, 40000 triangles.

input: `-i /Users/csilva/src/bpa/BPA.jl/compare/results/inputs/torus_sampled20k.off`, rho = 0.05, 20000 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 40000 | 40000 | 30279 |
| reconstruction time (s) | 0.13 | 0.217 | 0.06 |
| vertices used | 20000 | 20000 | 15197 |
| boundary edges | 0 | 0 | 425 |
| boundary loops | 0 | 0 | 94 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 40000 | 40000 | 30279 |
| Euler characteristic | 0 | 0 | -155 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | yes | yes | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 40000 | 40000 | 18941 |
| valid_reversed_winding | 0 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 11338 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 7.62e-01 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 2.41% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 2.41% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 40000 | 40000 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 18941 | 18941 | 21059 | 11338 | 4263/16568/211/17 | 755/4440/6044/99 |

renderings (`torus_sampled20k/render/`, view 40.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](torus_sampled20k/render/bpa.png) | ![](torus_sampled20k/render/open3d.png) | ![](torus_sampled20k/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](torus_sampled20k/render/bpa_depth.png) | ![](torus_sampled20k/render/open3d_depth.png) | ![](torus_sampled20k/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](torus_sampled20k/render/bpa_signed.png) | ![](torus_sampled20k/render/open3d_signed.png) | ![](torus_sampled20k/render/meshlab_signed.png) |

