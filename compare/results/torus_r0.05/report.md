
## torus_r0.05

the same regular torus at rho = 0.05, the smallest radius that still closes it.

input: `-i /Users/csilva/src/BPA.jl/data/torus-120-80.off`, rho = 0.05, 9600 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | bpa_rs | Schmehla | Giaccari | Extended Gruber |
|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 19200 | 19200 | 19196 | 19200 | 19200 | 19036 | 19094 | 19200 | 19200 | 19200 |
| reconstruction time (s) | 0.03 | 0.061 | 0.043 | 0.096 | 0.025 | 0.024 | 0.028 | 1.008 | 0.014 | 0.019 |
| vertices used | 9600 | 9600 | 9599 | 9600 | 9600 | 9598 | 9600 | 9600 | 9600 | 9600 |
| boundary edges | 0 | 0 | 4 | 0 | 0 | 234 | 162 | 0 | 0 | 0 |
| boundary loops | 0 | 0 | 1 | 0 | 0 | 37 | 28 | 0 | 0 | 0 |
| components | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| largest component (triangles) | 19200 | 19200 | 19196 | 19200 | 19200 | 19036 | 19094 | 19200 | 19200 | 19200 |
| Euler characteristic | 0 | 0 | -1 | 0 | 0 | -37 | -28 | 0 | 0 | 0 |
| orientable | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| vertex-manifold | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| valid | 18828 | 19200 | 19194 | 19200 | 19200 | 16901 | 16924 | 17232 | 16636 | 18862 |
| valid_reversed_winding | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty_tie | 372 | 0 | 0 | 0 | 0 | 2135 | 2170 | 1968 | 2564 | 338 |
| ball_not_empty | 0 | 0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.17e-02 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.03% | 0.00% | 0.00% | 1.80% | 1.18% | 0.00% | 0.00% | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.03% | 0.00% | 0.00% | 1.80% | 1.18% | 0.00% | 0.00% | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 18822 | 18822 | 378 | 378 | 0/0/378/0 | 0/0/378/0 |
| MeshLab | 18816 | 18816 | 384 | 380 | 0/4/380/0 | 0/0/380/0 |
| Digne | 18822 | 18822 | 378 | 378 | 0/0/378/0 | 0/0/378/0 |
| Digne -p | 18822 | 18822 | 378 | 378 | 0/0/378/0 | 0/0/378/0 |
| Gruber | 16888 | 16888 | 2312 | 2148 | 13/122/2177/0 | 0/0/2148/0 |
| bpa_rs | 16925 | 16925 | 2275 | 2169 | 1/89/2185/0 | 0/0/2169/0 |
| Schmehla | 17192 | 17192 | 2008 | 2008 | 0/0/2008/0 | 0/0/2008/0 |
| Giaccari | 16548 | 16548 | 2652 | 2652 | 0/0/2652/0 | 0/0/2652/0 |
| Extended Gruber | 18750 | 18750 | 450 | 450 | 0/0/450/0 | 0/0/450/0 |

renderings (`torus_r0.05/render/`, view 40.0°):

**shaded, boundary edges in red**

<table>
<tr><td align="center"><a href="torus_r0.05/render/bpa.png"><img src="torus_r0.05/render/bpa.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_r0.05/render/open3d.png"><img src="torus_r0.05/render/open3d.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_r0.05/render/meshlab.png"><img src="torus_r0.05/render/meshlab.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="torus_r0.05/render/digne.png"><img src="torus_r0.05/render/digne.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="torus_r0.05/render/digne_par.png"><img src="torus_r0.05/render/digne_par.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="torus_r0.05/render/gruber.png"><img src="torus_r0.05/render/gruber.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="torus_r0.05/render/bpa_rs.png"><img src="torus_r0.05/render/bpa_rs.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="torus_r0.05/render/schmehla.png"><img src="torus_r0.05/render/schmehla.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="torus_r0.05/render/giaccari.png"><img src="torus_r0.05/render/giaccari.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="torus_r0.05/render/gruber_ext.png"><img src="torus_r0.05/render/gruber_ext.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**triangles behind each pixel: warm = odd (a hole is seen through), cool = even**

<table>
<tr><td align="center"><a href="torus_r0.05/render/bpa_depth.png"><img src="torus_r0.05/render/bpa_depth.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_r0.05/render/open3d_depth.png"><img src="torus_r0.05/render/open3d_depth.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_r0.05/render/meshlab_depth.png"><img src="torus_r0.05/render/meshlab_depth.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="torus_r0.05/render/digne_depth.png"><img src="torus_r0.05/render/digne_depth.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="torus_r0.05/render/digne_par_depth.png"><img src="torus_r0.05/render/digne_par_depth.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="torus_r0.05/render/gruber_depth.png"><img src="torus_r0.05/render/gruber_depth.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="torus_r0.05/render/bpa_rs_depth.png"><img src="torus_r0.05/render/bpa_rs_depth.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="torus_r0.05/render/schmehla_depth.png"><img src="torus_r0.05/render/schmehla_depth.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="torus_r0.05/render/giaccari_depth.png"><img src="torus_r0.05/render/giaccari_depth.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="torus_r0.05/render/gruber_ext_depth.png"><img src="torus_r0.05/render/gruber_ext_depth.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**front-facing minus back-facing: grey 0, blue +, red −**

<table>
<tr><td align="center"><a href="torus_r0.05/render/bpa_signed.png"><img src="torus_r0.05/render/bpa_signed.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_r0.05/render/open3d_signed.png"><img src="torus_r0.05/render/open3d_signed.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_r0.05/render/meshlab_signed.png"><img src="torus_r0.05/render/meshlab_signed.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="torus_r0.05/render/digne_signed.png"><img src="torus_r0.05/render/digne_signed.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="torus_r0.05/render/digne_par_signed.png"><img src="torus_r0.05/render/digne_par_signed.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="torus_r0.05/render/gruber_signed.png"><img src="torus_r0.05/render/gruber_signed.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="torus_r0.05/render/bpa_rs_signed.png"><img src="torus_r0.05/render/bpa_rs_signed.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="torus_r0.05/render/schmehla_signed.png"><img src="torus_r0.05/render/schmehla_signed.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="torus_r0.05/render/giaccari_signed.png"><img src="torus_r0.05/render/giaccari_signed.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="torus_r0.05/render/gruber_ext_signed.png"><img src="torus_r0.05/render/gruber_ext_signed.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

