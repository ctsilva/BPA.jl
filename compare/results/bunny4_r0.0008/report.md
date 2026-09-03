
## bunny4_r0.0008

four registered bunny body scans (150983 points), rho = 0.8 mm, close to the layer separation of the overlapping scans: the hardest case for the empty-ball property.

input: `-l bun000,bun045,bun090,bun180 -d /Users/csilva/src/bpa/BPA.jl/data/bunny/data`, rho = 0.0008, 150983 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 239041 | 237204 | 256474 |
| reconstruction time (s) | 0.37 | 0.914 | 4.816 |
| vertices used | 122478 | 122347 | 133234 |
| boundary edges | 6475 | 8818 | 15692 |
| boundary loops | 357 | 632 | 424 |
| components | 109 | 151 | 87 |
| largest component (triangles) | 237586 | 235749 | 255142 |
| Euler characteristic | -280 | -664 | -2849 |
| orientable | yes | no | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 239041 | 237193 | 20356 |
| valid_reversed_winding | 0 | 11 | 83630 |
| ball_not_empty_tie | 0 | 0 | 1 |
| ball_not_empty | 0 | 0 | 152487 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.84e-01 |
| render: odd-parity pixels (holes seen through) | 26.28% | 27.59% | 38.13% |
| render: pixels with front ≠ back | 26.93% | 28.27% | 44.51% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 236959 | 236935 | 2082 | 245 | 238/1155/405/284 | 68/30/145/2 |
| MeshLab | 102553 | 18738 | 136488 | 153921 | 42744/58737/34612/395 | 68537/46040/39022/322 |

renderings (`bunny4_r0.0008/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](bunny4_r0.0008/render/bpa.png) | ![](bunny4_r0.0008/render/open3d.png) | ![](bunny4_r0.0008/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](bunny4_r0.0008/render/bpa_depth.png) | ![](bunny4_r0.0008/render/open3d_depth.png) | ![](bunny4_r0.0008/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](bunny4_r0.0008/render/bpa_signed.png) | ![](bunny4_r0.0008/render/open3d_signed.png) | ![](bunny4_r0.0008/render/meshlab_signed.png) |

input scans: ![](bunny4_r0.0008/render/input.png)

