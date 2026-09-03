
## knot_r0.03

the same knot at rho = 0.03, the radius the package recommends: nearly closed, with small holes where the tube almost touches itself.

input: `-i /Users/csilva/src/bpa/BPA.jl/data/knot-300-100.off`, rho = 0.03, 30000 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 58400 | 58326 | 59570 |
| reconstruction time (s) | 0.11 | 0.162 | 0.164 |
| vertices used | 29208 | 29202 | 29993 |
| boundary edges | 62 | 214 | 1770 |
| boundary loops | 16 | 35 | 7 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 58400 | 58326 | 59570 |
| Euler characteristic | -23 | -68 | -677 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 58400 | 58326 | 53170 |
| valid_reversed_winding | 0 | 0 | 4506 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 1894 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.15e-01 |
| render: odd-parity pixels (holes seen through) | 0.22% | 0.56% | 3.33% |
| render: pixels with front ≠ back | 0.22% | 0.57% | 16.40% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 58292 | 58292 | 108 | 34 | 6/41/30/31 | 0/21/13/0 |
| MeshLab | 57629 | 53128 | 771 | 1941 | 11/306/167/287 | 1602/265/74/0 |

renderings (`knot_r0.03/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](knot_r0.03/render/bpa.png) | ![](knot_r0.03/render/open3d.png) | ![](knot_r0.03/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](knot_r0.03/render/bpa_depth.png) | ![](knot_r0.03/render/open3d_depth.png) | ![](knot_r0.03/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](knot_r0.03/render/bpa_signed.png) | ![](knot_r0.03/render/open3d_signed.png) | ![](knot_r0.03/render/meshlab_signed.png) |

