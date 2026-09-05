
## dragon62_r0.0007

the 62 Stanford dragon surface scans (1.83 million points), rho = 0.7 mm: the largest input, with up to 98 overlapping layers.

input: `-l dragonBottomFill1_0,dragonBottomFill2_0,dragonKnee_0,dragonMouth1_0,dragonMouth2_0,dragonMouth3_0,dragonMouth4_0,dragonMouth5_0,dragonMouth6_0,dragonMouth7_0,dragonMouth8_0,dragonNook1_0,dragonNook2_0,dragonSideRight_0,dragonSideRight_120,dragonSideRight_144,dragonSideRight_168,dragonSideRight_192,dragonSideRight_216,dragonSideRight_24,dragonSideRight_240,dragonSideRight_264,dragonSideRight_288,dragonSideRight_312,dragonSideRight_336,dragonSideRight_48,dragonSideRight_72,dragonSideRight_96,dragonStandRight_0,dragonStandRight_120,dragonStandRight_144,dragonStandRight_168,dragonStandRight_192,dragonStandRight_216,dragonStandRight_24,dragonStandRight_240,dragonStandRight_264,dragonStandRight_288,dragonStandRight_312,dragonStandRight_336,dragonStandRight_48,dragonStandRight_72,dragonStandRight_96,dragonToes_0,dragonToes3_0,dragonTopFill1_0,dragonTopFill2_0,dragonUpRight_0,dragonUpRight_120,dragonUpRight_144,dragonUpRight_168,dragonUpRight_192,dragonUpRight_216,dragonUpRight_24,dragonUpRight_240,dragonUpRight_264,dragonUpRight_288,dragonUpRight_312,dragonUpRight_336,dragonUpRight_48,dragonUpRight_72,dragonUpRight_96 -d /Users/csilva/src/BPA.jl/data/dragon/scans`, rho = 0.0007, 1826038 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 649518 | 624851 | 2545632 | 631174 | 631171 | 1 | 639668 | 1 | 5 | 1368343 | 649459 |
| reconstruction time (s) | 6.59 | 830.594 | 19355.382 | 1986.91 | 1382.47 | 0.086 | 4.906 | 0.48 | 9.38 | 4.315 | 4.51 |
| vertices used | 329013 | 328647 | 1376106 | 329732 | 329736 | 3 | 329247 | 3 | 6 | 690586 | 329005 |
| boundary edges | 13434 | 53205 | 1707330 | 47656 | 47687 | 3 | 24103 | 3 | 5 | 16195 | 13757 |
| boundary loops | 2257 | 6804 | 398 | 6459 | 6454 | 1 | 3011 | 1 | 1 | 1383 | 2320 |
| components | 101 | 536 | 34 | 549 | 550 | 1 | 291 | 1 | 1 | 69 | 103 |
| largest component (triangles) | 617351 | 592274 | 2513633 | 598551 | 598544 | 1 | 607187 | 1 | 5 | 1368184 | 617285 |
| Euler characteristic | -2463 | -10381 | -750375 | -9683 | -9693 | 1 | -2632 | 1 | 1 | -1683 | -2603 |
| orientable | yes | no | yes | no | no | yes | no | yes | yes | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | no | yes | yes | yes | yes |
| vertex-manifold | no | no | no | no | no | yes | no | yes | yes | yes | no |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| valid | 649518 | 624774 | 112449 | 631160 | 631157 | 1 | 639164 | 1 | 5 | 611502 | 649459 |
| valid_reversed_winding | 0 | 77 | 20840 | 0 | 0 | 0 | 0 | 0 | 0 | 817 | 0 |
| ball_not_empty_tie | 0 | 0 | 6 | 0 | 0 | 0 | 19 | 0 | 0 | 7 | 0 |
| ball_not_empty | 0 | 0 | 2412337 | 0 | 0 | 0 | 485 | 0 | 0 | 755987 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 14 | 14 | 0 | 0 | 0 | 0 | 30 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.97e-01 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 8.81e-01 | 0.00e+00 | 0.00e+00 | 9.94e-01 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 22.21% | 29.60% | 59.08% | 27.59% | 27.60% | 100.00% | 25.10% | 100.00% | 100.00% | 10.78% | 22.28% |
| render: pixels with front ≠ back | 22.31% | 30.04% | 83.89% | 27.94% | 27.94% | 100.00% | 25.30% | 100.00% | 100.00% | 11.12% | 22.39% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 623277 | 623198 | 26241 | 1574 | 2143/11582/6881/5635 | 509/198/847/20 |
| MeshLab | 131273 | 110512 | 518245 | 2414359 | 220005/217097/75491/5652 | 2186987/175392/51352/628 |
| Digne | 629747 | 629746 | 19771 | 1427 | 1208/5975/7011/5577 | 508/187/713/19 |
| Digne -p | 629703 | 629702 | 19815 | 1468 | 1205/5983/7021/5606 | 511/182/756/19 |
| Gruber | 1 | 1 | 649517 | 0 | 649517/0/0/0 | 0/0/0/0 |
| Gruber reseeded | 637819 | 637791 | 11699 | 1849 | 1147/6446/3559/547 | 270/294/1113/172 |
| bpa_rs | 1 | 1 | 649517 | 0 | 649517/0/0/0 | 0/0/0/0 |
| Schmehla | 5 | 5 | 649513 | 0 | 649513/0/0/0 | 0/0/0/0 |
| Giaccari | 603829 | 603041 | 45689 | 764514 | 35742/8317/1555/75 | 754865/5426/2943/1280 |
| bpa fork | 648371 | 648311 | 1147 | 1088 | 21/157/911/58 | 24/196/843/25 |

renderings (`dragon62_r0.0007/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| shaded, boundary edges in red | ![](dragon62_r0.0007/render/bpa.png) | ![](dragon62_r0.0007/render/open3d.png) | ![](dragon62_r0.0007/render/meshlab.png) | ![](dragon62_r0.0007/render/digne.png) | ![](dragon62_r0.0007/render/digne_par.png) | ![](dragon62_r0.0007/render/gruber.png) | ![](dragon62_r0.0007/render/gruber_reseed.png) | ![](dragon62_r0.0007/render/bpa_rs.png) | ![](dragon62_r0.0007/render/schmehla.png) | ![](dragon62_r0.0007/render/giaccari.png) | ![](dragon62_r0.0007/render/bpafork.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](dragon62_r0.0007/render/bpa_depth.png) | ![](dragon62_r0.0007/render/open3d_depth.png) | ![](dragon62_r0.0007/render/meshlab_depth.png) | ![](dragon62_r0.0007/render/digne_depth.png) | ![](dragon62_r0.0007/render/digne_par_depth.png) | ![](dragon62_r0.0007/render/gruber_depth.png) | ![](dragon62_r0.0007/render/gruber_reseed_depth.png) | ![](dragon62_r0.0007/render/bpa_rs_depth.png) | ![](dragon62_r0.0007/render/schmehla_depth.png) | ![](dragon62_r0.0007/render/giaccari_depth.png) | ![](dragon62_r0.0007/render/bpafork_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](dragon62_r0.0007/render/bpa_signed.png) | ![](dragon62_r0.0007/render/open3d_signed.png) | ![](dragon62_r0.0007/render/meshlab_signed.png) | ![](dragon62_r0.0007/render/digne_signed.png) | ![](dragon62_r0.0007/render/digne_par_signed.png) | ![](dragon62_r0.0007/render/gruber_signed.png) | ![](dragon62_r0.0007/render/gruber_reseed_signed.png) | ![](dragon62_r0.0007/render/bpa_rs_signed.png) | ![](dragon62_r0.0007/render/schmehla_signed.png) | ![](dragon62_r0.0007/render/giaccari_signed.png) | ![](dragon62_r0.0007/render/bpafork_signed.png) |

input scans: ![](dragon62_r0.0007/render/input.png)

