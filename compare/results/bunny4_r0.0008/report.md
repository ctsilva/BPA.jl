
## bunny4_r0.0008

four registered bunny body scans (150983 points), rho = 0.8 mm, close to the layer separation of the overlapping scans: the hardest case for the empty-ball property.

input: `-l bun000,bun045,bun090,bun180 -d /Users/csilva/src/BPA.jl/data/bunny/data`, rho = 0.0008, 150983 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | bpa_rs | Schmehla | Giaccari | Extended Gruber |
|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 239041 | 237204 | 256474 | 238054 | 238061 | 236662 | 236662 | 10 | 244053 | 239022 |
| reconstruction time (s) | 0.47 | 1.158 | 10.239 | 1.751 | 0.569 | 0.337 | 0.384 | 0.754 | 0.209 | 0.297 |
| vertices used | 122478 | 122347 | 133234 | 122802 | 122808 | 120826 | 120826 | 11 | 125428 | 122473 |
| boundary edges | 6475 | 8818 | 15692 | 8690 | 8681 | 5455 | 5455 | 10 | 7305 | 6432 |
| boundary loops | 357 | 632 | 424 | 727 | 716 | 219 | 219 | 1 | 229 | 365 |
| components | 109 | 151 | 87 | 241 | 240 | 1 | 1 | 1 | 29 | 123 |
| largest component (triangles) | 237586 | 235749 | 255142 | 236482 | 236486 | 236662 | 236662 | 10 | 243902 | 237554 |
| Euler characteristic | -280 | -664 | -2849 | -570 | -563 | -232 | -232 | 1 | -251 | -254 |
| orientable | yes | no | yes | yes | yes | no | no | yes | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | no | no | yes | yes | yes |
| vertex-manifold | no | no | no | no | no | no | no | yes | yes | no |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| valid | 239041 | 237193 | 20356 | 237920 | 237938 | 236572 | 236572 | 0 | 235599 | 239022 |
| valid_reversed_winding | 0 | 11 | 83630 | 0 | 0 | 0 | 0 | 10 | 283 | 0 |
| ball_not_empty_tie | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 152487 | 5 | 6 | 90 | 90 | 0 | 8145 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 129 | 117 | 0 | 0 | 0 | 26 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.84e-01 | 2.33e-01 | 2.33e-01 | 5.12e-01 | 5.12e-01 | 0.00e+00 | 9.66e-01 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 26.28% | 27.59% | 38.13% | 27.03% | 27.01% | 27.65% | 27.65% | 92.31% | 30.18% | 26.29% |
| render: pixels with front ≠ back | 26.93% | 28.27% | 44.51% | 27.68% | 27.67% | 28.41% | 28.41% | 92.31% | 31.98% | 26.94% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 236959 | 236935 | 2082 | 245 | 238/1155/405/284 | 68/30/145/2 |
| MeshLab | 102553 | 18738 | 136488 | 153921 | 42744/58737/34612/395 | 68537/46040/39022/322 |
| Digne | 237697 | 237697 | 1344 | 357 | 100/449/462/333 | 169/28/158/2 |
| Digne -p | 237722 | 237722 | 1319 | 339 | 93/446/447/333 | 167/30/140/2 |
| Gruber | 236407 | 236404 | 2634 | 255 | 1840/511/269/14 | 6/30/192/27 |
| bpa_rs | 236407 | 236404 | 2634 | 255 | 1840/511/269/14 | 6/30/192/27 |
| Schmehla | 10 | 0 | 239031 | 0 | 239031/0/0/0 | 0/0/0/0 |
| Giaccari | 235377 | 235096 | 3664 | 8676 | 2210/1087/352/15 | 7584/591/432/69 |
| Extended Gruber | 238835 | 238826 | 206 | 187 | 40/17/147/2 | 27/10/147/3 |

renderings (`bunny4_r0.0008/render/`, view 30.0°):

**shaded, boundary edges in red**

<table>
<tr><td align="center"><a href="bunny4_r0.0008/render/bpa.png"><img src="bunny4_r0.0008/render/bpa.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="bunny4_r0.0008/render/open3d.png"><img src="bunny4_r0.0008/render/open3d.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="bunny4_r0.0008/render/meshlab.png"><img src="bunny4_r0.0008/render/meshlab.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="bunny4_r0.0008/render/digne.png"><img src="bunny4_r0.0008/render/digne.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0008/render/digne_par.png"><img src="bunny4_r0.0008/render/digne_par.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="bunny4_r0.0008/render/gruber.png"><img src="bunny4_r0.0008/render/gruber.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="bunny4_r0.0008/render/bpa_rs.png"><img src="bunny4_r0.0008/render/bpa_rs.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="bunny4_r0.0008/render/schmehla.png"><img src="bunny4_r0.0008/render/schmehla.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0008/render/giaccari.png"><img src="bunny4_r0.0008/render/giaccari.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="bunny4_r0.0008/render/gruber_ext.png"><img src="bunny4_r0.0008/render/gruber_ext.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**triangles behind each pixel: warm = odd (a hole is seen through), cool = even**

<table>
<tr><td align="center"><a href="bunny4_r0.0008/render/bpa_depth.png"><img src="bunny4_r0.0008/render/bpa_depth.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="bunny4_r0.0008/render/open3d_depth.png"><img src="bunny4_r0.0008/render/open3d_depth.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="bunny4_r0.0008/render/meshlab_depth.png"><img src="bunny4_r0.0008/render/meshlab_depth.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="bunny4_r0.0008/render/digne_depth.png"><img src="bunny4_r0.0008/render/digne_depth.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0008/render/digne_par_depth.png"><img src="bunny4_r0.0008/render/digne_par_depth.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="bunny4_r0.0008/render/gruber_depth.png"><img src="bunny4_r0.0008/render/gruber_depth.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="bunny4_r0.0008/render/bpa_rs_depth.png"><img src="bunny4_r0.0008/render/bpa_rs_depth.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="bunny4_r0.0008/render/schmehla_depth.png"><img src="bunny4_r0.0008/render/schmehla_depth.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0008/render/giaccari_depth.png"><img src="bunny4_r0.0008/render/giaccari_depth.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="bunny4_r0.0008/render/gruber_ext_depth.png"><img src="bunny4_r0.0008/render/gruber_ext_depth.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**front-facing minus back-facing: grey 0, blue +, red −**

<table>
<tr><td align="center"><a href="bunny4_r0.0008/render/bpa_signed.png"><img src="bunny4_r0.0008/render/bpa_signed.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="bunny4_r0.0008/render/open3d_signed.png"><img src="bunny4_r0.0008/render/open3d_signed.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="bunny4_r0.0008/render/meshlab_signed.png"><img src="bunny4_r0.0008/render/meshlab_signed.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="bunny4_r0.0008/render/digne_signed.png"><img src="bunny4_r0.0008/render/digne_signed.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0008/render/digne_par_signed.png"><img src="bunny4_r0.0008/render/digne_par_signed.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="bunny4_r0.0008/render/gruber_signed.png"><img src="bunny4_r0.0008/render/gruber_signed.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="bunny4_r0.0008/render/bpa_rs_signed.png"><img src="bunny4_r0.0008/render/bpa_rs_signed.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="bunny4_r0.0008/render/schmehla_signed.png"><img src="bunny4_r0.0008/render/schmehla_signed.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="bunny4_r0.0008/render/giaccari_signed.png"><img src="bunny4_r0.0008/render/giaccari_signed.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="bunny4_r0.0008/render/gruber_ext_signed.png"><img src="bunny4_r0.0008/render/gruber_ext_signed.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

input scans, with their boundaries:

<a href="bunny4_r0.0008/render/input.png"><img src="bunny4_r0.0008/render/input.png" width="260"></a>

