
## torus_jitter

parametric torus (R = 1, r = 0.4) on a 120 x 80 grid jittered by 30 % of the spacing, so no four points are cospherical and the answer is unique. rho = 0.06 (2 x the median spacing). Expected: closed, chi = 0, 19200 triangles.

input: `-i /Users/csilva/src/BPA.jl/compare/results/inputs/torus_jitter.off`, rho = 0.06, 9600 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | bpa_rs | Schmehla | Giaccari | Extended Gruber |
|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 19200 | 19200 | 19196 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 |
| reconstruction time (s) | 0.03 | 0.067 | 0.046 | 0.094 | 0.022 | 0.024 | 0.028 | 0.96 | 0.011 | 0.02 |
| vertices used | 9600 | 9600 | 9598 | 9600 | 9600 | 9600 | 9600 | 9600 | 9600 | 9600 |
| boundary edges | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| boundary loops | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| components | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| largest component (triangles) | 19200 | 19200 | 19196 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 |
| Euler characteristic | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| orientable | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| vertex-manifold | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| valid | 19200 | 19200 | 19189 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 |
| valid_reversed_winding | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 7 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 2.90e-01 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 19189 | 19189 | 11 | 7 | 0/11/0/0 | 1/1/5/0 |
| Digne | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne -p | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Gruber | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| bpa_rs | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Schmehla | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Giaccari | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Extended Gruber | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |

renderings (`torus_jitter/render/`, view 40.0°):

**shaded, boundary edges in red**

<table>
<tr><td align="center"><a href="torus_jitter/render/bpa.png"><img src="torus_jitter/render/bpa.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_jitter/render/open3d.png"><img src="torus_jitter/render/open3d.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_jitter/render/meshlab.png"><img src="torus_jitter/render/meshlab.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="torus_jitter/render/digne.png"><img src="torus_jitter/render/digne.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="torus_jitter/render/digne_par.png"><img src="torus_jitter/render/digne_par.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="torus_jitter/render/gruber.png"><img src="torus_jitter/render/gruber.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="torus_jitter/render/bpa_rs.png"><img src="torus_jitter/render/bpa_rs.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="torus_jitter/render/schmehla.png"><img src="torus_jitter/render/schmehla.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="torus_jitter/render/giaccari.png"><img src="torus_jitter/render/giaccari.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="torus_jitter/render/gruber_ext.png"><img src="torus_jitter/render/gruber_ext.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**triangles behind each pixel: warm = odd (a hole is seen through), cool = even**

<table>
<tr><td align="center"><a href="torus_jitter/render/bpa_depth.png"><img src="torus_jitter/render/bpa_depth.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_jitter/render/open3d_depth.png"><img src="torus_jitter/render/open3d_depth.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_jitter/render/meshlab_depth.png"><img src="torus_jitter/render/meshlab_depth.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="torus_jitter/render/digne_depth.png"><img src="torus_jitter/render/digne_depth.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="torus_jitter/render/digne_par_depth.png"><img src="torus_jitter/render/digne_par_depth.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="torus_jitter/render/gruber_depth.png"><img src="torus_jitter/render/gruber_depth.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="torus_jitter/render/bpa_rs_depth.png"><img src="torus_jitter/render/bpa_rs_depth.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="torus_jitter/render/schmehla_depth.png"><img src="torus_jitter/render/schmehla_depth.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="torus_jitter/render/giaccari_depth.png"><img src="torus_jitter/render/giaccari_depth.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="torus_jitter/render/gruber_ext_depth.png"><img src="torus_jitter/render/gruber_ext_depth.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**front-facing minus back-facing: grey 0, blue +, red −**

<table>
<tr><td align="center"><a href="torus_jitter/render/bpa_signed.png"><img src="torus_jitter/render/bpa_signed.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_jitter/render/open3d_signed.png"><img src="torus_jitter/render/open3d_signed.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_jitter/render/meshlab_signed.png"><img src="torus_jitter/render/meshlab_signed.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="torus_jitter/render/digne_signed.png"><img src="torus_jitter/render/digne_signed.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="torus_jitter/render/digne_par_signed.png"><img src="torus_jitter/render/digne_par_signed.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="torus_jitter/render/gruber_signed.png"><img src="torus_jitter/render/gruber_signed.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="torus_jitter/render/bpa_rs_signed.png"><img src="torus_jitter/render/bpa_rs_signed.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="torus_jitter/render/schmehla_signed.png"><img src="torus_jitter/render/schmehla_signed.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="torus_jitter/render/giaccari_signed.png"><img src="torus_jitter/render/giaccari_signed.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="torus_jitter/render/gruber_ext_signed.png"><img src="torus_jitter/render/gruber_ext_signed.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

