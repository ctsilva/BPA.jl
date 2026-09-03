
## sphere2000

2000-point Fibonacci sphere, rho = 1.5 x mean spacing. Expected: closed, chi = 2, 3996 triangles, every point used.

input: `-i /Users/csilva/src/bpa/BPA.jl/compare/results/inputs/sphere2000.off`, rho = 0.119, 2000 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 3996 | 3996 | 3994 |
| reconstruction time (s) | 0.01 | 0.01 | 0.009 |
| vertices used | 2000 | 2000 | 1999 |
| boundary edges | 0 | 0 | 0 |
| boundary loops | 0 | 0 | 0 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 3996 | 3996 | 3994 |
| Euler characteristic | 2 | 2 | 2 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 |
| valid | 3996 | 3996 | 3991 |
| valid_reversed_winding | 0 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 3 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 2.26e-01 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 3996 | 3996 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 3991 | 3991 | 5 | 3 | 0/5/0/0 | 0/1/2/0 |

renderings (`sphere2000/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](sphere2000/render/bpa.png) | ![](sphere2000/render/open3d.png) | ![](sphere2000/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](sphere2000/render/bpa_depth.png) | ![](sphere2000/render/open3d_depth.png) | ![](sphere2000/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](sphere2000/render/bpa_signed.png) | ![](sphere2000/render/open3d_signed.png) | ![](sphere2000/render/meshlab_signed.png) |

