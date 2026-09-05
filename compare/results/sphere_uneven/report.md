
## sphere_uneven

Fibonacci sphere of radius 25 mm, 1 mm spacing for y >= 0 and a 4 mm Fibonacci sampling for y < 0 (4172 points), radii 1.5 mm then 6 mm. Expected: closed, chi = 2, every point used, 2V - 4 triangles.

input: `-i /Users/csilva/src/BPA.jl/compare/results/inputs/sphere_uneven.off`, rho = 0.0015,0.006, 4172 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 8340 | 8340 | n/a | 8340 | 8340 | n/a | n/a | n/a | n/a | n/a | 8340 |
| triangles per pass (one radius, then each further one) | 7786 + 554 | 7786 + 554 | n/a | 7786 + 554 | 7786 + 554 | n/a | n/a | n/a | n/a | n/a | 7786 + 554 |
| reconstruction time (s) | 0.01 | 0.028 | n/a | 0.049 | 0.032 | n/a | n/a | n/a | n/a | n/a | 0.009 |
| vertices used | 4172 | 4172 | n/a | 4172 | 4172 | n/a | n/a | n/a | n/a | n/a | 4172 |
| boundary edges | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| boundary loops | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| components | 1 | 1 | n/a | 1 | 1 | n/a | n/a | n/a | n/a | n/a | 1 |
| largest component (triangles) | 8340 | 8340 | n/a | 8340 | 8340 | n/a | n/a | n/a | n/a | n/a | 8340 |
| Euler characteristic | 2 | 2 | n/a | 2 | 2 | n/a | n/a | n/a | n/a | n/a | 2 |
| orientable | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | n/a | yes |
| edge-manifold | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | n/a | yes |
| vertex-manifold | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | n/a | yes |
| duplicate triangles | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| valid | 8340 | 8340 | n/a | 8340 | 8340 | n/a | n/a | n/a | n/a | n/a | 8340 |
| valid_reversed_winding | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty_tie | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| circumradius_too_large | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| degenerate | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | n/a | 0.00e+00 | 0.00e+00 | n/a | n/a | n/a | n/a | n/a | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | n/a | 0.00% | 0.00% | n/a | n/a | n/a | n/a | n/a | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | n/a | 0.00% | 0.00% | n/a | n/a | n/a | n/a | n/a | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 8340 | 8340 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne | 8340 | 8340 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne -p | 8340 | 8340 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| bpa fork | 8340 | 8340 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |

renderings (`sphere_uneven/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| shaded, boundary edges in red | ![](sphere_uneven/render/bpa.png) | ![](sphere_uneven/render/open3d.png) | ![](sphere_uneven/render/meshlab.ppm) | ![](sphere_uneven/render/digne.png) | ![](sphere_uneven/render/digne_par.png) | ![](sphere_uneven/render/gruber.ppm) | ![](sphere_uneven/render/gruber_reseed.ppm) | ![](sphere_uneven/render/bpa_rs.ppm) | ![](sphere_uneven/render/schmehla.ppm) | ![](sphere_uneven/render/giaccari.ppm) | ![](sphere_uneven/render/bpafork.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](sphere_uneven/render/bpa_depth.png) | ![](sphere_uneven/render/open3d_depth.png) | ![](sphere_uneven/render/meshlab_depth.ppm) | ![](sphere_uneven/render/digne_depth.png) | ![](sphere_uneven/render/digne_par_depth.png) | ![](sphere_uneven/render/gruber_depth.ppm) | ![](sphere_uneven/render/gruber_reseed_depth.ppm) | ![](sphere_uneven/render/bpa_rs_depth.ppm) | ![](sphere_uneven/render/schmehla_depth.ppm) | ![](sphere_uneven/render/giaccari_depth.ppm) | ![](sphere_uneven/render/bpafork_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](sphere_uneven/render/bpa_signed.png) | ![](sphere_uneven/render/open3d_signed.png) | ![](sphere_uneven/render/meshlab_signed.ppm) | ![](sphere_uneven/render/digne_signed.png) | ![](sphere_uneven/render/digne_par_signed.png) | ![](sphere_uneven/render/gruber_signed.ppm) | ![](sphere_uneven/render/gruber_reseed_signed.ppm) | ![](sphere_uneven/render/bpa_rs_signed.ppm) | ![](sphere_uneven/render/schmehla_signed.ppm) | ![](sphere_uneven/render/giaccari_signed.ppm) | ![](sphere_uneven/render/bpafork_signed.png) |
| coloured by the pass that built the triangle: blue rho = 0.0015, green 0.006 | ![](sphere_uneven/render/bpa_passes.png) | ![](sphere_uneven/render/open3d_passes.png) | ![](sphere_uneven/render/meshlab_passes.ppm) | ![](sphere_uneven/render/digne_passes.png) | ![](sphere_uneven/render/digne_par_passes.png) | ![](sphere_uneven/render/gruber_passes.ppm) | ![](sphere_uneven/render/gruber_reseed_passes.ppm) | ![](sphere_uneven/render/bpa_rs_passes.ppm) | ![](sphere_uneven/render/schmehla_passes.ppm) | ![](sphere_uneven/render/giaccari_passes.ppm) | ![](sphere_uneven/render/bpafork_passes.png) |

