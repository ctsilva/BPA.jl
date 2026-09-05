
## sphere2000

2000-point Fibonacci sphere, rho = 1.5 x mean spacing. Expected: closed, chi = 2, 3996 triangles, every point used.

input: `-i /Users/csilva/src/BPA.jl/compare/results/inputs/sphere2000.off`, rho = 0.119, 2000 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | bpa_rs | Schmehla | Giaccari | Extended Gruber |
|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 3996 | 3996 | 3994 | 3996 | 3996 | 3996 | 3996 | 3996 | 3996 | 3996 |
| reconstruction time (s) | 0.01 | 0.012 | 0.01 | 0.018 | 0.008 | 0.005 | 0.005 | 0.054 | 0.002 | 0.004 |
| vertices used | 2000 | 2000 | 1999 | 2000 | 2000 | 2000 | 2000 | 2000 | 2000 | 2000 |
| boundary edges | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| boundary loops | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| components | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| largest component (triangles) | 3996 | 3996 | 3994 | 3996 | 3996 | 3996 | 3996 | 3996 | 3996 | 3996 |
| Euler characteristic | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 | 2 |
| orientable | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| vertex-manifold | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| valid | 3996 | 3996 | 3991 | 3996 | 3996 | 3996 | 3996 | 3996 | 3996 | 3996 |
| valid_reversed_winding | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 3 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 2.26e-01 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 3996 | 3996 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 3991 | 3991 | 5 | 3 | 0/5/0/0 | 0/1/2/0 |
| Digne | 3996 | 3996 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne -p | 3996 | 3996 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Gruber | 3996 | 3996 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| bpa_rs | 3996 | 3996 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Schmehla | 3996 | 3996 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Giaccari | 3996 | 3996 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Extended Gruber | 3996 | 3996 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |

renderings (`sphere2000/render/`, view 30.0°):

**shaded, boundary edges in red**

<table>
<tr><td align="center"><a href="sphere2000/render/bpa.png"><img src="sphere2000/render/bpa.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="sphere2000/render/open3d.png"><img src="sphere2000/render/open3d.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="sphere2000/render/meshlab.png"><img src="sphere2000/render/meshlab.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="sphere2000/render/digne.png"><img src="sphere2000/render/digne.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="sphere2000/render/digne_par.png"><img src="sphere2000/render/digne_par.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="sphere2000/render/gruber.png"><img src="sphere2000/render/gruber.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="sphere2000/render/bpa_rs.png"><img src="sphere2000/render/bpa_rs.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="sphere2000/render/schmehla.png"><img src="sphere2000/render/schmehla.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="sphere2000/render/giaccari.png"><img src="sphere2000/render/giaccari.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="sphere2000/render/gruber_ext.png"><img src="sphere2000/render/gruber_ext.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**triangles behind each pixel: warm = odd (a hole is seen through), cool = even**

<table>
<tr><td align="center"><a href="sphere2000/render/bpa_depth.png"><img src="sphere2000/render/bpa_depth.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="sphere2000/render/open3d_depth.png"><img src="sphere2000/render/open3d_depth.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="sphere2000/render/meshlab_depth.png"><img src="sphere2000/render/meshlab_depth.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="sphere2000/render/digne_depth.png"><img src="sphere2000/render/digne_depth.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="sphere2000/render/digne_par_depth.png"><img src="sphere2000/render/digne_par_depth.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="sphere2000/render/gruber_depth.png"><img src="sphere2000/render/gruber_depth.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="sphere2000/render/bpa_rs_depth.png"><img src="sphere2000/render/bpa_rs_depth.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="sphere2000/render/schmehla_depth.png"><img src="sphere2000/render/schmehla_depth.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="sphere2000/render/giaccari_depth.png"><img src="sphere2000/render/giaccari_depth.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="sphere2000/render/gruber_ext_depth.png"><img src="sphere2000/render/gruber_ext_depth.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**front-facing minus back-facing: grey 0, blue +, red −**

<table>
<tr><td align="center"><a href="sphere2000/render/bpa_signed.png"><img src="sphere2000/render/bpa_signed.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="sphere2000/render/open3d_signed.png"><img src="sphere2000/render/open3d_signed.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="sphere2000/render/meshlab_signed.png"><img src="sphere2000/render/meshlab_signed.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="sphere2000/render/digne_signed.png"><img src="sphere2000/render/digne_signed.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="sphere2000/render/digne_par_signed.png"><img src="sphere2000/render/digne_par_signed.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="sphere2000/render/gruber_signed.png"><img src="sphere2000/render/gruber_signed.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="sphere2000/render/bpa_rs_signed.png"><img src="sphere2000/render/bpa_rs_signed.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="sphere2000/render/schmehla_signed.png"><img src="sphere2000/render/schmehla_signed.png" width="260"></a><br><sub>Schmehla</sub></td></tr>
<tr><td align="center"><a href="sphere2000/render/giaccari_signed.png"><img src="sphere2000/render/giaccari_signed.png" width="260"></a><br><sub>Giaccari</sub></td><td align="center"><a href="sphere2000/render/gruber_ext_signed.png"><img src="sphere2000/render/gruber_ext_signed.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

