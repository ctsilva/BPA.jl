
## plane40

40 x 40 jittered grid on a plane. Expected: a disk, chi = 1, one clean boundary loop, every point used.

input: `-i /Users/csilva/src/BPA.jl/compare/results/inputs/plane40.off`, rho = 0.15, 1600 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | bpa_rs | Schmehla | Giaccari | Extended Gruber |
|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 3042 | 3042 | 3041 | 3042 | 3042 | 3042 | 3042 | 3042 | n/a | 3042 |
| reconstruction time (s) | 0.0 | 0.008 | 0.007 | 0.011 | 0.004 | 0.003 | 0.003 | 0.082 | n/a | 0.002 |
| vertices used | 1600 | 1600 | 1599 | 1600 | 1600 | 1600 | 1600 | 1600 | n/a | 1600 |
| boundary edges | 156 | 156 | 155 | 156 | 156 | 156 | 156 | 156 | n/a | 156 |
| boundary loops | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | n/a | 1 |
| components | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | n/a | 1 |
| largest component (triangles) | 3042 | 3042 | 3041 | 3042 | 3042 | 3042 | 3042 | 3042 | n/a | 3042 |
| Euler characteristic | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | n/a | 1 |
| orientable | yes | yes | yes | yes | yes | yes | yes | yes | n/a | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | yes | yes | n/a | yes |
| vertex-manifold | yes | yes | yes | yes | yes | yes | yes | yes | n/a | yes |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | n/a | 0 |
| valid | 3042 | 3042 | 0 | 3042 | 3042 | 3042 | 3042 | 3042 | n/a | 3042 |
| valid_reversed_winding | 0 | 0 | 3040 | 0 | 0 | 0 | 0 | 0 | n/a | 0 |
| ball_not_empty_tie | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | n/a | 0 |
| ball_not_empty | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | n/a | 0 |
| circumradius_too_large | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | n/a | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | n/a | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 6.62e-04 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | n/a | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 100.00% | 100.00% | 100.00% | 100.00% | 100.00% | 100.00% | 100.00% | 100.00% | n/a | 100.00% |
| render: pixels with front ≠ back | 100.00% | 100.00% | 100.00% | 100.00% | 100.00% | 100.00% | 100.00% | 100.00% | n/a | 100.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 3042 | 3042 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 3040 | 0 | 2 | 1 | 0/2/0/0 | 0/0/1/0 |
| Digne | 3042 | 3042 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne -p | 3042 | 3042 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Gruber | 3042 | 3042 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| bpa_rs | 3042 | 3042 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Schmehla | 3042 | 3042 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Extended Gruber | 3042 | 3042 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |

renderings (`plane40/render/`, view 20.0°):

**shaded, boundary edges in red**

<table>
<tr><td align="center"><a href="plane40/render/bpa.png"><img src="plane40/render/bpa.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="plane40/render/open3d.png"><img src="plane40/render/open3d.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="plane40/render/meshlab.png"><img src="plane40/render/meshlab.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="plane40/render/digne.png"><img src="plane40/render/digne.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="plane40/render/digne_par.png"><img src="plane40/render/digne_par.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="plane40/render/gruber.png"><img src="plane40/render/gruber.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="plane40/render/bpa_rs.png"><img src="plane40/render/bpa_rs.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="plane40/render/schmehla.png"><img src="plane40/render/schmehla.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="plane40/render/gruber_ext.png"><img src="plane40/render/gruber_ext.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**triangles behind each pixel: warm = odd (a hole is seen through), cool = even**

<table>
<tr><td align="center"><a href="plane40/render/bpa_depth.png"><img src="plane40/render/bpa_depth.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="plane40/render/open3d_depth.png"><img src="plane40/render/open3d_depth.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="plane40/render/meshlab_depth.png"><img src="plane40/render/meshlab_depth.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="plane40/render/digne_depth.png"><img src="plane40/render/digne_depth.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="plane40/render/digne_par_depth.png"><img src="plane40/render/digne_par_depth.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="plane40/render/gruber_depth.png"><img src="plane40/render/gruber_depth.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="plane40/render/bpa_rs_depth.png"><img src="plane40/render/bpa_rs_depth.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="plane40/render/schmehla_depth.png"><img src="plane40/render/schmehla_depth.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="plane40/render/gruber_ext_depth.png"><img src="plane40/render/gruber_ext_depth.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**front-facing minus back-facing: grey 0, blue +, red −**

<table>
<tr><td align="center"><a href="plane40/render/bpa_signed.png"><img src="plane40/render/bpa_signed.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="plane40/render/open3d_signed.png"><img src="plane40/render/open3d_signed.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="plane40/render/meshlab_signed.png"><img src="plane40/render/meshlab_signed.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="plane40/render/digne_signed.png"><img src="plane40/render/digne_signed.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="plane40/render/digne_par_signed.png"><img src="plane40/render/digne_par_signed.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="plane40/render/gruber_signed.png"><img src="plane40/render/gruber_signed.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="plane40/render/bpa_rs_signed.png"><img src="plane40/render/bpa_rs_signed.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="plane40/render/schmehla_signed.png"><img src="plane40/render/schmehla_signed.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="plane40/render/gruber_ext_signed.png"><img src="plane40/render/gruber_ext_signed.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

