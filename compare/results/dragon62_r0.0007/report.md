
## dragon62_r0.0007

the 62 Stanford dragon surface scans (1.83 million points), rho = 0.7 mm: the largest input, with up to 98 overlapping layers.

input: `-l dragonBottomFill1_0,dragonBottomFill2_0,dragonKnee_0,dragonMouth1_0,dragonMouth2_0,dragonMouth3_0,dragonMouth4_0,dragonMouth5_0,dragonMouth6_0,dragonMouth7_0,dragonMouth8_0,dragonNook1_0,dragonNook2_0,dragonSideRight_0,dragonSideRight_120,dragonSideRight_144,dragonSideRight_168,dragonSideRight_192,dragonSideRight_216,dragonSideRight_24,dragonSideRight_240,dragonSideRight_264,dragonSideRight_288,dragonSideRight_312,dragonSideRight_336,dragonSideRight_48,dragonSideRight_72,dragonSideRight_96,dragonStandRight_0,dragonStandRight_120,dragonStandRight_144,dragonStandRight_168,dragonStandRight_192,dragonStandRight_216,dragonStandRight_24,dragonStandRight_240,dragonStandRight_264,dragonStandRight_288,dragonStandRight_312,dragonStandRight_336,dragonStandRight_48,dragonStandRight_72,dragonStandRight_96,dragonToes_0,dragonToes3_0,dragonTopFill1_0,dragonTopFill2_0,dragonUpRight_0,dragonUpRight_120,dragonUpRight_144,dragonUpRight_168,dragonUpRight_192,dragonUpRight_216,dragonUpRight_24,dragonUpRight_240,dragonUpRight_264,dragonUpRight_288,dragonUpRight_312,dragonUpRight_336,dragonUpRight_48,dragonUpRight_72,dragonUpRight_96 -d /Users/csilva/src/bpa/BPA.jl/data/dragon/scans`, rho = 0.0007, 1826038 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 649518 | 624851 | 2545632 |
| reconstruction time (s) | 5.16 | 670.566 | 14850.425 |
| vertices used | 329013 | 328647 | 1376106 |
| boundary edges | 13434 | 53205 | 1707330 |
| boundary loops | 2257 | 6804 | 398 |
| components | 101 | 536 | 34 |
| largest component (triangles) | 617351 | 592274 | 2513633 |
| Euler characteristic | -2463 | -10381 | -750375 |
| orientable | yes | no | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 649518 | 624774 | 112449 |
| valid_reversed_winding | 0 | 77 | 20840 |
| ball_not_empty_tie | 0 | 0 | 6 |
| ball_not_empty | 0 | 0 | 2412337 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.97e-01 |
| render: odd-parity pixels (holes seen through) | 22.21% | 29.60% | 59.08% |
| render: pixels with front ≠ back | 22.31% | 30.04% | 83.89% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 623277 | 623198 | 26241 | 1574 | 2143/11582/6881/5635 | 509/198/847/20 |
| MeshLab | 131273 | 110512 | 518245 | 2414359 | 220005/217097/75491/5652 | 2186987/175392/51352/628 |

renderings (`dragon62_r0.0007/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](dragon62_r0.0007/render/bpa.png) | ![](dragon62_r0.0007/render/open3d.png) | ![](dragon62_r0.0007/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](dragon62_r0.0007/render/bpa_depth.png) | ![](dragon62_r0.0007/render/open3d_depth.png) | ![](dragon62_r0.0007/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](dragon62_r0.0007/render/bpa_signed.png) | ![](dragon62_r0.0007/render/open3d_signed.png) | ![](dragon62_r0.0007/render/meshlab_signed.png) |

input scans: ![](dragon62_r0.0007/render/input.png)

