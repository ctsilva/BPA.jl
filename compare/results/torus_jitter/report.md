
## torus_jitter

parametric torus (R = 1, r = 0.4) on a 120 x 80 grid jittered by 30 % of the spacing, so no four points are cospherical and the answer is unique. rho = 0.06 (2 x the median spacing). Expected: closed, chi = 0, 19200 triangles.

input: `-i /Users/csilva/src/bpa/BPA.jl/compare/results/inputs/torus_jitter.off`, rho = 0.06, 9600 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 19200 | 19200 | 19196 |
| reconstruction time (s) | 0.02 | 0.053 | 0.035 |
| vertices used | 9600 | 9600 | 9598 |
| boundary edges | 0 | 0 | 0 |
| boundary loops | 0 | 0 | 0 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 19200 | 19200 | 19196 |
| Euler characteristic | 0 | 0 | 0 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 |
| valid | 19200 | 19200 | 19189 |
| valid_reversed_winding | 0 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 7 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 2.90e-01 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 19189 | 19189 | 11 | 7 | 0/11/0/0 | 1/1/5/0 |

renderings (`torus_jitter/render/`, view 40.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](torus_jitter/render/bpa.png) | ![](torus_jitter/render/open3d.png) | ![](torus_jitter/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](torus_jitter/render/bpa_depth.png) | ![](torus_jitter/render/open3d_depth.png) | ![](torus_jitter/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](torus_jitter/render/bpa_signed.png) | ![](torus_jitter/render/open3d_signed.png) | ![](torus_jitter/render/meshlab_signed.png) |

