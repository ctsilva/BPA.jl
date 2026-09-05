
## plane_uneven

jittered plane, 50 x 100 points at 1 mm spacing on the left half and 25 x 50 at 2 mm on the right (6250 points), radii 1.5 mm then 3 mm. Expected: one disk, chi = 1, one boundary loop, every point used; a tool without multi-radius passes shows n/a.

input: `-i /Users/csilva/src/BPA.jl/compare/results/inputs/plane_uneven.off`, rho = 0.0015,0.003, 6250 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 12214 | 12214 | n/a | 12214 | 12213 | n/a | n/a | n/a | n/a | n/a | 12214 |
| triangles per pass (one radius, then each further one) | 11982 + 232 | 11982 + 232 | n/a | 11982 + 232 | 11982 + 231 | n/a | n/a | n/a | n/a | n/a | 11982 + 232 |
| reconstruction time (s) | 0.01 | 0.032 | n/a | 0.047 | 0.023 | n/a | n/a | n/a | n/a | n/a | 0.009 |
| vertices used | 6250 | 6250 | n/a | 6250 | 6250 | n/a | n/a | n/a | n/a | n/a | 6250 |
| boundary edges | 284 | 284 | n/a | 284 | 287 | n/a | n/a | n/a | n/a | n/a | 284 |
| boundary loops | 1 | 1 | n/a | 1 | 2 | n/a | n/a | n/a | n/a | n/a | 1 |
| components | 1 | 1 | n/a | 1 | 1 | n/a | n/a | n/a | n/a | n/a | 1 |
| largest component (triangles) | 12214 | 12214 | n/a | 12214 | 12213 | n/a | n/a | n/a | n/a | n/a | 12214 |
| Euler characteristic | 1 | 1 | n/a | 1 | 0 | n/a | n/a | n/a | n/a | n/a | 1 |
| orientable | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | n/a | yes |
| edge-manifold | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | n/a | yes |
| vertex-manifold | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | n/a | yes |
| duplicate triangles | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| valid | 12214 | 12214 | n/a | 12214 | 12213 | n/a | n/a | n/a | n/a | n/a | 12214 |
| valid_reversed_winding | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty_tie | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| circumradius_too_large | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| degenerate | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | n/a | 0.00e+00 | 0.00e+00 | n/a | n/a | n/a | n/a | n/a | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 100.00% | 100.00% | n/a | 100.00% | 100.00% | n/a | n/a | n/a | n/a | n/a | 100.00% |
| render: pixels with front ≠ back | 100.00% | 100.00% | n/a | 100.00% | 100.00% | n/a | n/a | n/a | n/a | n/a | 100.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 12214 | 12214 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne | 12214 | 12214 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne -p | 12213 | 12213 | 1 | 0 | 0/0/0/1 | 0/0/0/0 |
| bpa fork | 12214 | 12214 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |

renderings (`plane_uneven/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| shaded, boundary edges in red | ![](plane_uneven/render/bpa.png) | ![](plane_uneven/render/open3d.png) | ![](plane_uneven/render/meshlab.ppm) | ![](plane_uneven/render/digne.png) | ![](plane_uneven/render/digne_par.png) | ![](plane_uneven/render/gruber.ppm) | ![](plane_uneven/render/gruber_reseed.ppm) | ![](plane_uneven/render/bpa_rs.ppm) | ![](plane_uneven/render/schmehla.ppm) | ![](plane_uneven/render/giaccari.ppm) | ![](plane_uneven/render/bpafork.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](plane_uneven/render/bpa_depth.png) | ![](plane_uneven/render/open3d_depth.png) | ![](plane_uneven/render/meshlab_depth.ppm) | ![](plane_uneven/render/digne_depth.png) | ![](plane_uneven/render/digne_par_depth.png) | ![](plane_uneven/render/gruber_depth.ppm) | ![](plane_uneven/render/gruber_reseed_depth.ppm) | ![](plane_uneven/render/bpa_rs_depth.ppm) | ![](plane_uneven/render/schmehla_depth.ppm) | ![](plane_uneven/render/giaccari_depth.ppm) | ![](plane_uneven/render/bpafork_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](plane_uneven/render/bpa_signed.png) | ![](plane_uneven/render/open3d_signed.png) | ![](plane_uneven/render/meshlab_signed.ppm) | ![](plane_uneven/render/digne_signed.png) | ![](plane_uneven/render/digne_par_signed.png) | ![](plane_uneven/render/gruber_signed.ppm) | ![](plane_uneven/render/gruber_reseed_signed.ppm) | ![](plane_uneven/render/bpa_rs_signed.ppm) | ![](plane_uneven/render/schmehla_signed.ppm) | ![](plane_uneven/render/giaccari_signed.ppm) | ![](plane_uneven/render/bpafork_signed.png) |
| coloured by the pass that built the triangle: blue rho = 0.0015, green 0.003 | ![](plane_uneven/render/bpa_passes.png) | ![](plane_uneven/render/open3d_passes.png) | ![](plane_uneven/render/meshlab_passes.ppm) | ![](plane_uneven/render/digne_passes.png) | ![](plane_uneven/render/digne_par_passes.png) | ![](plane_uneven/render/gruber_passes.ppm) | ![](plane_uneven/render/gruber_reseed_passes.ppm) | ![](plane_uneven/render/bpa_rs_passes.ppm) | ![](plane_uneven/render/schmehla_passes.ppm) | ![](plane_uneven/render/giaccari_passes.ppm) | ![](plane_uneven/render/bpafork_passes.png) |

