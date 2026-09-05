
## knot_r0.0188

trefoil knot, 30000 points, rho = 1.5 x the estimated spacing, deliberately too small for this anisotropic lattice: many boundaries, so the tools' seeding and stopping behaviour shows.

input: `-i /Users/csilva/src/BPA.jl/data/knot-300-100.off`, rho = 0.0188, 30000 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 36132 | 35952 | 36462 | 35944 | 35945 | 35889 | 35952 | 35889 | 0 | 35940 | 36070 |
| reconstruction time (s) | 0.11 | 0.081 | 0.121 | 0.111 | 0.052 | 0.029 | 0.033 | 0.04 | 0.155 | 0.028 | 0.028 |
| vertices used | 18615 | 18591 | 18780 | 18594 | 18596 | 18546 | 18654 | 18546 | 0 | 18633 | 18595 |
| boundary edges | 1176 | 1308 | 1340 | 1314 | 1319 | 1230 | 1329 | 1230 | 0 | 1334 | 1212 |
| boundary loops | 19 | 19 | 2 | 19 | 19 | 5 | 30 | 5 | 0 | 8 | 24 |
| components | 4 | 19 | 1 | 19 | 19 | 1 | 27 | 1 | 0 | 3 | 5 |
| largest component (triangles) | 36123 | 35934 | 36462 | 35926 | 35927 | 35889 | 35889 | 35889 | 0 | 35933 | 36066 |
| Euler characteristic | -39 | -39 | -121 | -35 | -36 | -12 | 15 | -12 | 0 | -4 | -46 |
| orientable | yes | no | yes | yes | yes | no | no | no | yes | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | no | no | no | yes | yes | yes |
| vertex-manifold | no | no | no | no | no | no | no | no | yes | yes | no |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| valid | 36132 | 35952 | 36235 | 35944 | 35945 | 35883 | 35943 | 35883 | 0 | 28337 | 36070 |
| valid_reversed_winding | 0 | 0 | 22 | 0 | 0 | 0 | 0 | 0 | 0 | 7488 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 205 | 0 | 0 | 6 | 9 | 6 | 0 | 113 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 7.38e-01 | 0.00e+00 | 0.00e+00 | 5.41e-02 | 3.19e-01 | 5.41e-02 | 0.00e+00 | 6.73e-01 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 60.97% | 61.07% | 60.94% | 61.06% | 61.06% | 61.18% | 61.18% | 61.18% | n/a | 60.65% | 61.01% |
| render: pixels with front ≠ back | 62.23% | 62.41% | 62.34% | 62.41% | 62.40% | 62.51% | 62.53% | 62.51% | n/a | 62.02% | 62.27% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 35862 | 35862 | 270 | 90 | 81/132/31/26 | 21/42/18/9 |
| MeshLab | 35914 | 35907 | 218 | 548 | 46/95/64/13 | 376/106/60/6 |
| Digne | 35853 | 35853 | 279 | 91 | 84/140/29/26 | 26/38/18/9 |
| Digne -p | 35852 | 35852 | 280 | 93 | 84/140/29/27 | 27/39/18/9 |
| Gruber | 35809 | 35809 | 323 | 80 | 142/129/49/3 | 10/39/24/7 |
| Gruber reseeded | 35818 | 35818 | 314 | 134 | 126/134/49/5 | 59/43/25/7 |
| bpa_rs | 35809 | 35809 | 323 | 80 | 142/129/49/3 | 10/39/24/7 |
| Schmehla | 0 | 0 | 36132 | 0 | 36132/0/0/0 | 0/0/0/0 |
| Giaccari | 35453 | 27989 | 679 | 487 | 290/365/24/0 | 329/106/41/11 |
| bpa fork | 35967 | 35967 | 165 | 103 | 73/54/37/1 | 30/51/18/4 |

renderings (`knot_r0.0188/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| shaded, boundary edges in red | ![](knot_r0.0188/render/bpa.png) | ![](knot_r0.0188/render/open3d.png) | ![](knot_r0.0188/render/meshlab.png) | ![](knot_r0.0188/render/digne.png) | ![](knot_r0.0188/render/digne_par.png) | ![](knot_r0.0188/render/gruber.png) | ![](knot_r0.0188/render/gruber_reseed.png) | ![](knot_r0.0188/render/bpa_rs.png) | ![](knot_r0.0188/render/schmehla.png) | ![](knot_r0.0188/render/giaccari.png) | ![](knot_r0.0188/render/bpafork.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](knot_r0.0188/render/bpa_depth.png) | ![](knot_r0.0188/render/open3d_depth.png) | ![](knot_r0.0188/render/meshlab_depth.png) | ![](knot_r0.0188/render/digne_depth.png) | ![](knot_r0.0188/render/digne_par_depth.png) | ![](knot_r0.0188/render/gruber_depth.png) | ![](knot_r0.0188/render/gruber_reseed_depth.png) | ![](knot_r0.0188/render/bpa_rs_depth.png) | ![](knot_r0.0188/render/schmehla_depth.png) | ![](knot_r0.0188/render/giaccari_depth.png) | ![](knot_r0.0188/render/bpafork_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](knot_r0.0188/render/bpa_signed.png) | ![](knot_r0.0188/render/open3d_signed.png) | ![](knot_r0.0188/render/meshlab_signed.png) | ![](knot_r0.0188/render/digne_signed.png) | ![](knot_r0.0188/render/digne_par_signed.png) | ![](knot_r0.0188/render/gruber_signed.png) | ![](knot_r0.0188/render/gruber_reseed_signed.png) | ![](knot_r0.0188/render/bpa_rs_signed.png) | ![](knot_r0.0188/render/schmehla_signed.png) | ![](knot_r0.0188/render/giaccari_signed.png) | ![](knot_r0.0188/render/bpafork_signed.png) |

