
## torus_uneven

jittered torus (R = 20 mm, r = 8 mm), a 126 x 50 lattice at 1 mm for y >= 0 and 63 x 25 at 2 mm for y < 0 (3942 points), radii 1.5 mm then 3 mm. Expected: closed, chi = 0, every point used.

input: `-i /Users/csilva/src/BPA.jl/compare/results/inputs/torus_uneven.off`, rho = 0.0015,0.003, 3942 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 7884 | 7878 | n/a | 7878 | 7874 | n/a | n/a | n/a | n/a | n/a | 7884 |
| triangles per pass (one radius, then each further one) | 7364 + 520 | 7360 + 518 | n/a | 7362 + 516 | 7360 + 514 | n/a | n/a | n/a | n/a | n/a | 7360 + 524 |
| reconstruction time (s) | 0.01 | 0.025 | n/a | 0.038 | 0.021 | n/a | n/a | n/a | n/a | n/a | 0.008 |
| vertices used | 3942 | 3942 | n/a | 3942 | 3942 | n/a | n/a | n/a | n/a | n/a | 3942 |
| boundary edges | 0 | 18 | n/a | 18 | 30 | n/a | n/a | n/a | n/a | n/a | 0 |
| boundary loops | 0 | 2 | n/a | 2 | 6 | n/a | n/a | n/a | n/a | n/a | 0 |
| components | 1 | 1 | n/a | 1 | 1 | n/a | n/a | n/a | n/a | n/a | 1 |
| largest component (triangles) | 7884 | 7878 | n/a | 7878 | 7874 | n/a | n/a | n/a | n/a | n/a | 7884 |
| Euler characteristic | 0 | -6 | n/a | -6 | -10 | n/a | n/a | n/a | n/a | n/a | 0 |
| orientable | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | n/a | yes |
| edge-manifold | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | n/a | yes |
| vertex-manifold | yes | no | n/a | no | no | n/a | n/a | n/a | n/a | n/a | yes |
| duplicate triangles | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| valid | 7884 | 7878 | n/a | 7878 | 7874 | n/a | n/a | n/a | n/a | n/a | 7884 |
| valid_reversed_winding | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty_tie | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| circumradius_too_large | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| degenerate | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | n/a | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | n/a | 0.00e+00 | 0.00e+00 | n/a | n/a | n/a | n/a | n/a | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.50% | n/a | 0.50% | 0.81% | n/a | n/a | n/a | n/a | n/a | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.50% | n/a | 0.50% | 0.81% | n/a | n/a | n/a | n/a | n/a | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 7878 | 7878 | 6 | 0 | 0/0/0/6 | 0/0/0/0 |
| Digne | 7878 | 7878 | 6 | 0 | 0/0/0/6 | 0/0/0/0 |
| Digne -p | 7874 | 7874 | 10 | 0 | 0/0/0/10 | 0/0/0/0 |
| bpa fork | 7884 | 7884 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |

renderings (`torus_uneven/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| shaded, boundary edges in red | ![](torus_uneven/render/bpa.png) | ![](torus_uneven/render/open3d.png) | ![](torus_uneven/render/meshlab.ppm) | ![](torus_uneven/render/digne.png) | ![](torus_uneven/render/digne_par.png) | ![](torus_uneven/render/gruber.ppm) | ![](torus_uneven/render/gruber_reseed.ppm) | ![](torus_uneven/render/bpa_rs.ppm) | ![](torus_uneven/render/schmehla.ppm) | ![](torus_uneven/render/giaccari.ppm) | ![](torus_uneven/render/bpafork.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](torus_uneven/render/bpa_depth.png) | ![](torus_uneven/render/open3d_depth.png) | ![](torus_uneven/render/meshlab_depth.ppm) | ![](torus_uneven/render/digne_depth.png) | ![](torus_uneven/render/digne_par_depth.png) | ![](torus_uneven/render/gruber_depth.ppm) | ![](torus_uneven/render/gruber_reseed_depth.ppm) | ![](torus_uneven/render/bpa_rs_depth.ppm) | ![](torus_uneven/render/schmehla_depth.ppm) | ![](torus_uneven/render/giaccari_depth.ppm) | ![](torus_uneven/render/bpafork_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](torus_uneven/render/bpa_signed.png) | ![](torus_uneven/render/open3d_signed.png) | ![](torus_uneven/render/meshlab_signed.ppm) | ![](torus_uneven/render/digne_signed.png) | ![](torus_uneven/render/digne_par_signed.png) | ![](torus_uneven/render/gruber_signed.ppm) | ![](torus_uneven/render/gruber_reseed_signed.ppm) | ![](torus_uneven/render/bpa_rs_signed.ppm) | ![](torus_uneven/render/schmehla_signed.ppm) | ![](torus_uneven/render/giaccari_signed.ppm) | ![](torus_uneven/render/bpafork_signed.png) |
| coloured by the pass that built the triangle: blue rho = 0.0015, green 0.003 | ![](torus_uneven/render/bpa_passes.png) | ![](torus_uneven/render/open3d_passes.png) | ![](torus_uneven/render/meshlab_passes.ppm) | ![](torus_uneven/render/digne_passes.png) | ![](torus_uneven/render/digne_par_passes.png) | ![](torus_uneven/render/gruber_passes.ppm) | ![](torus_uneven/render/gruber_reseed_passes.ppm) | ![](torus_uneven/render/bpa_rs_passes.ppm) | ![](torus_uneven/render/schmehla_passes.ppm) | ![](torus_uneven/render/giaccari_passes.ppm) | ![](torus_uneven/render/bpafork_passes.png) |

