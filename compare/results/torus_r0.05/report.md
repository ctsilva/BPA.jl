
## torus_r0.05

the same regular torus at rho = 0.05, the smallest radius that still closes it.

input: `-i /Users/csilva/src/bpa/BPA.jl/data/torus-120-80.off`, rho = 0.05, 9600 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 19200 | 19200 | 19196 |
| reconstruction time (s) | 0.03 | 0.048 | 0.035 |
| vertices used | 9600 | 9600 | 9599 |
| boundary edges | 0 | 0 | 4 |
| boundary loops | 0 | 0 | 1 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 19200 | 19200 | 19196 |
| Euler characteristic | 0 | 0 | -1 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 |
| valid | 18828 | 19200 | 19194 |
| valid_reversed_winding | 0 | 0 | 0 |
| ball_not_empty_tie | 372 | 0 | 0 |
| ball_not_empty | 0 | 0 | 2 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 9.16e-08 | 0.00e+00 | 9.17e-02 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.03% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.03% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 18822 | 18822 | 378 | 378 | 0/0/378/0 | 0/0/378/0 |
| MeshLab | 18816 | 18816 | 384 | 380 | 0/4/380/0 | 0/0/380/0 |

renderings (`torus_r0.05/render/`, view 40.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](torus_r0.05/render/bpa.png) | ![](torus_r0.05/render/open3d.png) | ![](torus_r0.05/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](torus_r0.05/render/bpa_depth.png) | ![](torus_r0.05/render/open3d_depth.png) | ![](torus_r0.05/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](torus_r0.05/render/bpa_signed.png) | ![](torus_r0.05/render/open3d_signed.png) | ![](torus_r0.05/render/meshlab_signed.png) |

