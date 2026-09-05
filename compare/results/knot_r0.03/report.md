
## knot_r0.03

the same knot at rho = 0.03, the radius the package recommends: nearly closed, with small holes where the tube almost touches itself.

input: `-i /Users/csilva/src/BPA.jl/data/knot-300-100.off`, rho = 0.03, 30000 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 58400 | 58326 | 59570 | 58326 | 58325 | 58370 | 58389 | 58370 | 58401 | 58432 | 58418 |
| reconstruction time (s) | 0.16 | 0.209 | 0.222 | 0.33 | 0.132 | 0.075 | 0.07 | 0.082 | 6.508 | 0.045 | 0.059 |
| vertices used | 29208 | 29202 | 29993 | 29202 | 29202 | 29208 | 29265 | 29208 | 29208 | 29213 | 29208 |
| boundary edges | 62 | 214 | 1770 | 210 | 217 | 112 | 169 | 112 | 63 | 12 | 58 |
| boundary loops | 16 | 35 | 7 | 35 | 35 | 18 | 37 | 18 | 15 | 3 | 17 |
| components | 1 | 1 | 1 | 1 | 1 | 1 | 20 | 1 | 1 | 1 | 1 |
| largest component (triangles) | 58400 | 58326 | 59570 | 58326 | 58325 | 58370 | 58370 | 58370 | 58401 | 58432 | 58418 |
| Euler characteristic | -23 | -68 | -677 | -66 | -69 | -33 | -14 | -33 | -21 | -9 | -30 |
| orientable | yes | yes | yes | yes | yes | yes | yes | yes | no | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | yes | yes | no | yes | yes |
| vertex-manifold | no | no | no | no | no | no | no | no | no | yes | no |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| valid | 58400 | 58326 | 53170 | 58326 | 58325 | 58366 | 58366 | 58366 | 58398 | 58419 | 58418 |
| valid_reversed_winding | 0 | 0 | 4506 | 0 | 0 | 0 | 0 | 0 | 3 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 1894 | 0 | 0 | 4 | 23 | 4 | 0 | 13 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.15e-01 | 0.00e+00 | 0.00e+00 | 1.31e-03 | 8.56e-01 | 1.31e-03 | 0.00e+00 | 1.85e-02 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 0.22% | 0.56% | 3.33% | 0.54% | 0.54% | 0.39% | 0.49% | 0.39% | 0.27% | 0.06% | 0.08% |
| render: pixels with front ≠ back | 0.22% | 0.57% | 16.40% | 0.55% | 0.55% | 0.39% | 0.49% | 0.39% | 0.27% | 0.06% | 0.08% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 58292 | 58292 | 108 | 34 | 6/41/30/31 | 0/21/13/0 |
| MeshLab | 57629 | 53128 | 771 | 1941 | 11/306/167/287 | 1602/265/74/0 |
| Digne | 58293 | 58293 | 107 | 33 | 6/42/30/29 | 0/21/12/0 |
| Digne -p | 58294 | 58294 | 106 | 31 | 6/41/27/32 | 0/21/10/0 |
| Gruber | 58328 | 58328 | 72 | 42 | 5/35/22/10 | 0/24/16/2 |
| Gruber reseeded | 58328 | 58328 | 72 | 61 | 5/35/22/10 | 19/24/16/2 |
| bpa_rs | 58328 | 58328 | 72 | 42 | 5/35/22/10 | 0/24/16/2 |
| Schmehla | 58363 | 58361 | 37 | 38 | 0/21/16/0 | 0/18/18/2 |
| Giaccari | 58363 | 58363 | 37 | 69 | 0/15/21/1 | 4/35/29/1 |
| bpa fork | 58378 | 58378 | 22 | 40 | 0/5/9/8 | 0/24/16/0 |

renderings (`knot_r0.03/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| shaded, boundary edges in red | ![](knot_r0.03/render/bpa.png) | ![](knot_r0.03/render/open3d.png) | ![](knot_r0.03/render/meshlab.png) | ![](knot_r0.03/render/digne.png) | ![](knot_r0.03/render/digne_par.png) | ![](knot_r0.03/render/gruber.png) | ![](knot_r0.03/render/gruber_reseed.png) | ![](knot_r0.03/render/bpa_rs.png) | ![](knot_r0.03/render/schmehla.png) | ![](knot_r0.03/render/giaccari.png) | ![](knot_r0.03/render/bpafork.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](knot_r0.03/render/bpa_depth.png) | ![](knot_r0.03/render/open3d_depth.png) | ![](knot_r0.03/render/meshlab_depth.png) | ![](knot_r0.03/render/digne_depth.png) | ![](knot_r0.03/render/digne_par_depth.png) | ![](knot_r0.03/render/gruber_depth.png) | ![](knot_r0.03/render/gruber_reseed_depth.png) | ![](knot_r0.03/render/bpa_rs_depth.png) | ![](knot_r0.03/render/schmehla_depth.png) | ![](knot_r0.03/render/giaccari_depth.png) | ![](knot_r0.03/render/bpafork_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](knot_r0.03/render/bpa_signed.png) | ![](knot_r0.03/render/open3d_signed.png) | ![](knot_r0.03/render/meshlab_signed.png) | ![](knot_r0.03/render/digne_signed.png) | ![](knot_r0.03/render/digne_par_signed.png) | ![](knot_r0.03/render/gruber_signed.png) | ![](knot_r0.03/render/gruber_reseed_signed.png) | ![](knot_r0.03/render/bpa_rs_signed.png) | ![](knot_r0.03/render/schmehla_signed.png) | ![](knot_r0.03/render/giaccari_signed.png) | ![](knot_r0.03/render/bpafork_signed.png) |

