
## knot_r0.0188

trefoil knot, 30000 points, rho = 1.5 x the estimated spacing, deliberately too small for this anisotropic lattice: many boundaries, so the tools' seeding and stopping behaviour shows.

input: `-i /Users/csilva/src/bpa/BPA.jl/data/knot-300-100.off`, rho = 0.0188, 30000 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 36132 | 35952 | 36462 |
| reconstruction time (s) | 0.03 | 0.064 | 0.095 |
| vertices used | 18615 | 18591 | 18780 |
| boundary edges | 1176 | 1308 | 1340 |
| boundary loops | 19 | 19 | 2 |
| components | 4 | 19 | 1 |
| largest component (triangles) | 36123 | 35934 | 36462 |
| Euler characteristic | -39 | -39 | -121 |
| orientable | yes | no | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 36132 | 35952 | 36235 |
| valid_reversed_winding | 0 | 0 | 22 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 205 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 7.38e-01 |
| render: odd-parity pixels (holes seen through) | 60.97% | 61.07% | 60.94% |
| render: pixels with front ≠ back | 62.23% | 62.41% | 62.34% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 35862 | 35862 | 270 | 90 | 81/132/31/26 | 21/42/18/9 |
| MeshLab | 35914 | 35907 | 218 | 548 | 46/95/64/13 | 376/106/60/6 |

renderings (`knot_r0.0188/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](knot_r0.0188/render/bpa.png) | ![](knot_r0.0188/render/open3d.png) | ![](knot_r0.0188/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](knot_r0.0188/render/bpa_depth.png) | ![](knot_r0.0188/render/open3d_depth.png) | ![](knot_r0.0188/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](knot_r0.0188/render/bpa_signed.png) | ![](knot_r0.0188/render/open3d_signed.png) | ![](knot_r0.0188/render/meshlab_signed.png) |

