
## bunny10_r0.00125

all ten bunny scans (362272 points), rho = 1.25 mm, the package's reference reconstruction.

input: `-l bun000,bun045,bun090,bun180,bun270,bun315,chin,ear_back,top2,top3 -d /Users/csilva/src/bpa/BPA.jl/data/bunny/data`, rho = 0.00125, 362272 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 323934 | 317975 | 477737 |
| reconstruction time (s) | 1.12 | 26.809 | 165.515 |
| vertices used | 162289 | 161945 | 253390 |
| boundary edges | 806 | 8125 | 173875 |
| boundary loops | 107 | 938 | 715 |
| components | 17 | 97 | 1 |
| largest component (triangles) | 323910 | 317864 | 477737 |
| Euler characteristic | -81 | -1105 | -72416 |
| orientable | yes | no | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 323934 | 317918 | 186867 |
| valid_reversed_winding | 0 | 57 | 174 |
| ball_not_empty_tie | 0 | 0 | 12 |
| ball_not_empty | 0 | 0 | 290684 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.89e-01 |
| render: odd-parity pixels (holes seen through) | 3.92% | 8.84% | 48.21% |
| render: pixels with front ≠ back | 3.97% | 8.98% | 59.27% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 317668 | 317610 | 6266 | 307 | 533/4395/833/505 | 86/7/214/0 |
| MeshLab | 186593 | 186475 | 137341 | 291144 | 27109/86878/19718/3636 | 209283/55330/25063/1468 |

renderings (`bunny10_r0.00125/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](bunny10_r0.00125/render/bpa.png) | ![](bunny10_r0.00125/render/open3d.png) | ![](bunny10_r0.00125/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](bunny10_r0.00125/render/bpa_depth.png) | ![](bunny10_r0.00125/render/open3d_depth.png) | ![](bunny10_r0.00125/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](bunny10_r0.00125/render/bpa_signed.png) | ![](bunny10_r0.00125/render/open3d_signed.png) | ![](bunny10_r0.00125/render/meshlab_signed.png) |

input scans: ![](bunny10_r0.00125/render/input.png)

