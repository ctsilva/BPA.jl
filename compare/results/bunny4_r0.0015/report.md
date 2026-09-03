
## bunny4_r0.0015

the same four scans at rho = 1.5 mm, where the ball rides over the overlap layers.

input: `-l bun000,bun045,bun090,bun180 -d /Users/csilva/src/bpa/BPA.jl/data/bunny/data`, rho = 0.0015, 150983 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 202958 | 201124 | 218720 |
| reconstruction time (s) | 0.53 | 5.104 | 8.558 |
| vertices used | 102271 | 102125 | 113527 |
| boundary edges | 1732 | 3918 | 28558 |
| boundary loops | 60 | 315 | 512 |
| components | 3 | 30 | 5 |
| largest component (triangles) | 202898 | 201009 | 218664 |
| Euler characteristic | -74 | -396 | -10112 |
| orientable | yes | no | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 202958 | 201104 | 148442 |
| valid_reversed_winding | 0 | 20 | 4146 |
| ball_not_empty_tie | 0 | 0 | 3 |
| ball_not_empty | 0 | 0 | 66129 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.80e-01 |
| render: odd-parity pixels (holes seen through) | 19.20% | 21.56% | 35.36% |
| render: pixels with front ≠ back | 19.34% | 21.80% | 44.67% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 200634 | 200595 | 2324 | 490 | 169/1275/718/162 | 37/6/447/0 |
| MeshLab | 151975 | 147789 | 50983 | 66745 | 7140/34350/8518/975 | 35428/15275/15062/980 |

renderings (`bunny4_r0.0015/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](bunny4_r0.0015/render/bpa.png) | ![](bunny4_r0.0015/render/open3d.png) | ![](bunny4_r0.0015/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](bunny4_r0.0015/render/bpa_depth.png) | ![](bunny4_r0.0015/render/open3d_depth.png) | ![](bunny4_r0.0015/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](bunny4_r0.0015/render/bpa_signed.png) | ![](bunny4_r0.0015/render/open3d_signed.png) | ![](bunny4_r0.0015/render/meshlab_signed.png) |

input scans: ![](bunny4_r0.0015/render/input.png)

