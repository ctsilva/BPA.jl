
## bunny10_r0.00125

all ten bunny scans (362272 points), rho = 1.25 mm, the package's reference reconstruction.

input: `-l bun000,bun045,bun090,bun180,bun270,bun315,chin,ear_back,top2,top3 -d /Users/csilva/src/BPA.jl/data/bunny/data`, rho = 0.00125, 362272 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | bpa_rs | Schmehla | Giaccari | Extended Gruber |
|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 323934 | 317975 | 477737 | 323808 | 323783 | 323175 | 323175 | 0 | 540947 | 323920 |
| reconstruction time (s) | 1.61 | 36.63 | 294.74 | 81.82 | 38.681 | 1.401 | 1.757 | 2.321 | 1.013 | 1.115 |
| vertices used | 162289 | 161945 | 253390 | 168141 | 168134 | 162226 | 162226 | 0 | 283969 | 162289 |
| boundary edges | 806 | 8125 | 173875 | 10696 | 10733 | 1601 | 1601 | 0 | 30293 | 856 |
| boundary loops | 107 | 938 | 715 | 2572 | 2578 | 157 | 157 | 0 | 1777 | 121 |
| components | 17 | 97 | 1 | 1899 | 1898 | 1 | 1 | 0 | 77 | 17 |
| largest component (triangles) | 323910 | 317864 | 477737 | 321686 | 321665 | 323175 | 323175 | 0 | 540327 | 323896 |
| Euler characteristic | -81 | -1105 | -72416 | 889 | 876 | -162 | -162 | 0 | -1651 | -99 |
| orientable | yes | no | yes | no | yes | yes | yes | yes | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| vertex-manifold | no | no | no | no | no | no | no | yes | yes | no |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| valid | 323934 | 317918 | 186867 | 321745 | 321731 | 323109 | 323109 | 0 | 326730 | 323920 |
| valid_reversed_winding | 0 | 57 | 174 | 3 | 3 | 0 | 0 | 0 | 39 | 0 |
| ball_not_empty_tie | 0 | 0 | 12 | 0 | 0 | 15 | 15 | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 290684 | 8 | 8 | 51 | 51 | 0 | 214178 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 2052 | 2041 | 0 | 0 | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.89e-01 | 3.53e-01 | 3.53e-01 | 1.17e-01 | 1.17e-01 | 0.00e+00 | 9.91e-01 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 3.92% | 8.84% | 48.21% | 6.12% | 6.13% | 4.54% | 4.54% | n/a | 36.85% | 3.95% |
| render: pixels with front ≠ back | 3.97% | 8.98% | 59.27% | 6.20% | 6.22% | 4.60% | 4.60% | n/a | 37.06% | 4.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 317668 | 317610 | 6266 | 307 | 533/4395/833/505 | 86/7/214/0 |
| MeshLab | 186593 | 186475 | 137341 | 291144 | 27109/86878/19718/3636 | 209283/55330/25063/1468 |
| Digne | 321444 | 321443 | 2490 | 2364 | 97/938/805/650 | 2104/31/229/0 |
| Digne -p | 321441 | 321440 | 2493 | 2342 | 95/944/796/658 | 2099/26/217/0 |
| Gruber | 322865 | 322864 | 1069 | 310 | 46/549/447/27 | 0/17/272/21 |
| bpa_rs | 322863 | 322862 | 1071 | 312 | 46/549/449/27 | 0/17/274/21 |
| Schmehla | 0 | 0 | 323934 | 0 | 323934/0/0/0 | 0/0/0/0 |
| Giaccari | 323189 | 323160 | 745 | 217758 | 136/332/270/7 | 217074/351/311/22 |
| Extended Gruber | 323724 | 323720 | 210 | 196 | 0/3/207/0 | 0/5/191/0 |

renderings (`bunny10_r0.00125/render/`, view 30.0°):

**shaded, boundary edges in red**

<table>
<tr><td align="center"><a href="bunny10_r0.00125/render/bpa.png"><img src="bunny10_r0.00125/render/bpa.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="bunny10_r0.00125/render/open3d.png"><img src="bunny10_r0.00125/render/open3d.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="bunny10_r0.00125/render/meshlab.png"><img src="bunny10_r0.00125/render/meshlab.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="bunny10_r0.00125/render/digne.png"><img src="bunny10_r0.00125/render/digne.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="bunny10_r0.00125/render/digne_par.png"><img src="bunny10_r0.00125/render/digne_par.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="bunny10_r0.00125/render/gruber.png"><img src="bunny10_r0.00125/render/gruber.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="bunny10_r0.00125/render/bpa_rs.png"><img src="bunny10_r0.00125/render/bpa_rs.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="bunny10_r0.00125/render/schmehla.png"><img src="bunny10_r0.00125/render/schmehla.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="bunny10_r0.00125/render/giaccari.png"><img src="bunny10_r0.00125/render/giaccari.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="bunny10_r0.00125/render/gruber_ext.png"><img src="bunny10_r0.00125/render/gruber_ext.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**triangles behind each pixel: warm = odd (a hole is seen through), cool = even**

<table>
<tr><td align="center"><a href="bunny10_r0.00125/render/bpa_depth.png"><img src="bunny10_r0.00125/render/bpa_depth.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="bunny10_r0.00125/render/open3d_depth.png"><img src="bunny10_r0.00125/render/open3d_depth.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="bunny10_r0.00125/render/meshlab_depth.png"><img src="bunny10_r0.00125/render/meshlab_depth.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="bunny10_r0.00125/render/digne_depth.png"><img src="bunny10_r0.00125/render/digne_depth.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="bunny10_r0.00125/render/digne_par_depth.png"><img src="bunny10_r0.00125/render/digne_par_depth.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="bunny10_r0.00125/render/gruber_depth.png"><img src="bunny10_r0.00125/render/gruber_depth.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="bunny10_r0.00125/render/bpa_rs_depth.png"><img src="bunny10_r0.00125/render/bpa_rs_depth.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="bunny10_r0.00125/render/schmehla_depth.png"><img src="bunny10_r0.00125/render/schmehla_depth.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="bunny10_r0.00125/render/giaccari_depth.png"><img src="bunny10_r0.00125/render/giaccari_depth.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="bunny10_r0.00125/render/gruber_ext_depth.png"><img src="bunny10_r0.00125/render/gruber_ext_depth.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**front-facing minus back-facing: grey 0, blue +, red −**

<table>
<tr><td align="center"><a href="bunny10_r0.00125/render/bpa_signed.png"><img src="bunny10_r0.00125/render/bpa_signed.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="bunny10_r0.00125/render/open3d_signed.png"><img src="bunny10_r0.00125/render/open3d_signed.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="bunny10_r0.00125/render/meshlab_signed.png"><img src="bunny10_r0.00125/render/meshlab_signed.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="bunny10_r0.00125/render/digne_signed.png"><img src="bunny10_r0.00125/render/digne_signed.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="bunny10_r0.00125/render/digne_par_signed.png"><img src="bunny10_r0.00125/render/digne_par_signed.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="bunny10_r0.00125/render/gruber_signed.png"><img src="bunny10_r0.00125/render/gruber_signed.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="bunny10_r0.00125/render/bpa_rs_signed.png"><img src="bunny10_r0.00125/render/bpa_rs_signed.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="bunny10_r0.00125/render/schmehla_signed.png"><img src="bunny10_r0.00125/render/schmehla_signed.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="bunny10_r0.00125/render/giaccari_signed.png"><img src="bunny10_r0.00125/render/giaccari_signed.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="bunny10_r0.00125/render/gruber_ext_signed.png"><img src="bunny10_r0.00125/render/gruber_ext_signed.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

input scans, with their boundaries:

<a href="bunny10_r0.00125/render/input.png"><img src="bunny10_r0.00125/render/input.png" width="260"></a>

