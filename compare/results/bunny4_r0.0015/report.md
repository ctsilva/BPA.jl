
## bunny4_r0.0015

the same four scans at rho = 1.5 mm, where the ball rides over the overlap layers.

input: `-l bun000,bun045,bun090,bun180 -d /Users/csilva/src/BPA.jl/data/bunny/data`, rho = 0.0015, 150983 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | bpa_rs | Schmehla | Giaccari | Extended Gruber |
|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 202958 | 201124 | 218720 | 202474 | 202440 | 202501 | 202517 | 201 | 245099 | 202968 |
| reconstruction time (s) | 0.74 | 7.083 | 15.871 | 14.627 | 5.657 | 0.669 | 0.768 | 0.762 | 0.344 | 0.506 |
| vertices used | 102271 | 102125 | 113527 | 103541 | 103551 | 102199 | 102200 | 108 | 129371 | 102285 |
| boundary edges | 1732 | 3918 | 28558 | 4772 | 4932 | 2077 | 2055 | 32 | 15259 | 1758 |
| boundary loops | 60 | 315 | 512 | 727 | 736 | 89 | 85 | 5 | 746 | 62 |
| components | 3 | 30 | 5 | 420 | 417 | 1 | 1 | 1 | 107 | 4 |
| largest component (triangles) | 202898 | 201009 | 218664 | 201946 | 201917 | 202501 | 202517 | 201 | 244464 | 202907 |
| Euler characteristic | -74 | -396 | -10112 | -82 | -135 | -90 | -86 | 60 | -808 | -78 |
| orientable | yes | no | yes | no | no | yes | yes | no | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | yes | no | yes | yes |
| vertex-manifold | no | no | no | no | no | no | no | no | yes | no |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 50 | 0 | 0 |
| valid | 202958 | 201104 | 148442 | 202020 | 201972 | 202480 | 202496 | 110 | 195984 | 202968 |
| valid_reversed_winding | 0 | 20 | 4146 | 2 | 2 | 0 | 0 | 51 | 1232 | 0 |
| ball_not_empty_tie | 0 | 0 | 3 | 0 | 0 | 6 | 6 | 0 | 1 | 0 |
| ball_not_empty | 0 | 0 | 66129 | 5 | 6 | 15 | 15 | 40 | 47874 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 447 | 460 | 0 | 0 | 0 | 8 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.80e-01 | 1.21e-01 | 1.21e-01 | 1.91e-01 | 1.91e-01 | 6.91e-01 | 9.72e-01 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 19.20% | 21.56% | 35.36% | 20.53% | 20.58% | 19.89% | 19.87% | 14.74% | 42.34% | 19.16% |
| render: pixels with front ≠ back | 19.34% | 21.80% | 44.67% | 20.71% | 20.76% | 20.05% | 20.04% | 14.74% | 44.66% | 19.30% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 200634 | 200595 | 2324 | 490 | 169/1275/718/162 | 37/6/447/0 |
| MeshLab | 151975 | 147789 | 50983 | 66745 | 7140/34350/8518/975 | 35428/15275/15062/980 |
| Digne | 201518 | 201502 | 1440 | 956 | 41/371/704/324 | 475/11/470/0 |
| Digne -p | 201452 | 201436 | 1506 | 988 | 31/372/739/364 | 476/22/490/0 |
| Gruber | 202065 | 202060 | 893 | 436 | 99/259/531/4 | 0/6/428/2 |
| bpa_rs | 202076 | 202070 | 882 | 441 | 99/246/533/4 | 0/6/433/2 |
| Schmehla | 109 | 78 | 202849 | 42 | 202784/50/14/1 | 2/6/33/1 |
| Giaccari | 196230 | 194971 | 6728 | 48869 | 1792/3494/1384/58 | 46580/975/1295/19 |
| Extended Gruber | 202544 | 202543 | 414 | 424 | 0/1/410/3 | 9/4/411/0 |

renderings (`bunny4_r0.0015/render/`, view 30.0°):

**shaded, boundary edges in red**

<table>
<tr><td align="center"><a href="bunny4_r0.0015/render/bpa.png"><img src="bunny4_r0.0015/render/bpa.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="bunny4_r0.0015/render/open3d.png"><img src="bunny4_r0.0015/render/open3d.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="bunny4_r0.0015/render/meshlab.png"><img src="bunny4_r0.0015/render/meshlab.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="bunny4_r0.0015/render/digne.png"><img src="bunny4_r0.0015/render/digne.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0015/render/digne_par.png"><img src="bunny4_r0.0015/render/digne_par.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="bunny4_r0.0015/render/gruber.png"><img src="bunny4_r0.0015/render/gruber.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="bunny4_r0.0015/render/bpa_rs.png"><img src="bunny4_r0.0015/render/bpa_rs.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="bunny4_r0.0015/render/schmehla.png"><img src="bunny4_r0.0015/render/schmehla.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0015/render/giaccari.png"><img src="bunny4_r0.0015/render/giaccari.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="bunny4_r0.0015/render/gruber_ext.png"><img src="bunny4_r0.0015/render/gruber_ext.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**triangles behind each pixel: warm = odd (a hole is seen through), cool = even**

<table>
<tr><td align="center"><a href="bunny4_r0.0015/render/bpa_depth.png"><img src="bunny4_r0.0015/render/bpa_depth.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="bunny4_r0.0015/render/open3d_depth.png"><img src="bunny4_r0.0015/render/open3d_depth.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="bunny4_r0.0015/render/meshlab_depth.png"><img src="bunny4_r0.0015/render/meshlab_depth.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="bunny4_r0.0015/render/digne_depth.png"><img src="bunny4_r0.0015/render/digne_depth.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0015/render/digne_par_depth.png"><img src="bunny4_r0.0015/render/digne_par_depth.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="bunny4_r0.0015/render/gruber_depth.png"><img src="bunny4_r0.0015/render/gruber_depth.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="bunny4_r0.0015/render/bpa_rs_depth.png"><img src="bunny4_r0.0015/render/bpa_rs_depth.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="bunny4_r0.0015/render/schmehla_depth.png"><img src="bunny4_r0.0015/render/schmehla_depth.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0015/render/giaccari_depth.png"><img src="bunny4_r0.0015/render/giaccari_depth.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="bunny4_r0.0015/render/gruber_ext_depth.png"><img src="bunny4_r0.0015/render/gruber_ext_depth.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**front-facing minus back-facing: grey 0, blue +, red −**

<table>
<tr><td align="center"><a href="bunny4_r0.0015/render/bpa_signed.png"><img src="bunny4_r0.0015/render/bpa_signed.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="bunny4_r0.0015/render/open3d_signed.png"><img src="bunny4_r0.0015/render/open3d_signed.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="bunny4_r0.0015/render/meshlab_signed.png"><img src="bunny4_r0.0015/render/meshlab_signed.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="bunny4_r0.0015/render/digne_signed.png"><img src="bunny4_r0.0015/render/digne_signed.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0015/render/digne_par_signed.png"><img src="bunny4_r0.0015/render/digne_par_signed.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="bunny4_r0.0015/render/gruber_signed.png"><img src="bunny4_r0.0015/render/gruber_signed.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="bunny4_r0.0015/render/bpa_rs_signed.png"><img src="bunny4_r0.0015/render/bpa_rs_signed.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="bunny4_r0.0015/render/schmehla_signed.png"><img src="bunny4_r0.0015/render/schmehla_signed.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0015/render/giaccari_signed.png"><img src="bunny4_r0.0015/render/giaccari_signed.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="bunny4_r0.0015/render/gruber_ext_signed.png"><img src="bunny4_r0.0015/render/gruber_ext_signed.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

input scans, with their boundaries:

<a href="bunny4_r0.0015/render/input.png"><img src="bunny4_r0.0015/render/input.png" width="260"></a>

