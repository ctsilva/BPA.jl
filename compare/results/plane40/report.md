
## plane40

40 x 40 jittered grid on a plane. Expected: a disk, chi = 1, one clean boundary loop, every point used.

input: `-i /Users/csilva/src/bpa/BPA.jl/compare/results/inputs/plane40.off`, rho = 0.15, 1600 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 3042 | 3042 | 3041 |
| reconstruction time (s) | 0.0 | 0.006 | 0.006 |
| vertices used | 1600 | 1600 | 1599 |
| boundary edges | 156 | 156 | 155 |
| boundary loops | 1 | 1 | 1 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 3042 | 3042 | 3041 |
| Euler characteristic | 1 | 1 | 1 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 |
| valid | 3042 | 3042 | 0 |
| valid_reversed_winding | 0 | 0 | 3040 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 1 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 6.62e-04 |
| render: odd-parity pixels (holes seen through) | 100.00% | 100.00% | 100.00% |
| render: pixels with front ≠ back | 100.00% | 100.00% | 100.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 3042 | 3042 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 3040 | 0 | 2 | 1 | 0/2/0/0 | 0/0/1/0 |

renderings (`plane40/render/`, view 20.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](plane40/render/bpa.png) | ![](plane40/render/open3d.png) | ![](plane40/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](plane40/render/bpa_depth.png) | ![](plane40/render/open3d_depth.png) | ![](plane40/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](plane40/render/bpa_signed.png) | ![](plane40/render/open3d_signed.png) | ![](plane40/render/meshlab_signed.png) |

