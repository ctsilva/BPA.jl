
## torus_r0.10

trimesh2 torus, a regular 120 x 80 lattice (spacing 0.0196), rho = 0.10: many cospherical quads, so the diagonal is a free choice. Expected: closed, chi = 0, 19200 triangles.

input: `-i /Users/csilva/src/BPA.jl/data/torus-120-80.off`, rho = 0.1, 9600 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | bpa_rs | Schmehla | Giaccari | Extended Gruber |
|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 19200 | 19200 | 9600 | 19200 | 19200 | 19083 | 19138 | n/a | 19200 | 19200 |
| reconstruction time (s) | 0.06 | 0.207 | 0.019 | 0.423 | 0.087 | 0.063 | 0.077 | n/a | 0.014 | 0.044 |
| vertices used | 9600 | 9600 | 4800 | 9600 | 9600 | 9600 | 9600 | n/a | 9600 | 9600 |
| boundary edges | 0 | 0 | 0 | 0 | 0 | 177 | 98 | n/a | 0 | 0 |
| boundary loops | 0 | 0 | 0 | 0 | 0 | 30 | 18 | n/a | 0 | 0 |
| components | 1 | 1 | 1 | 1 | 1 | 1 | 1 | n/a | 1 | 1 |
| largest component (triangles) | 19200 | 19200 | 9600 | 19200 | 19200 | 19083 | 19138 | n/a | 19200 | 19200 |
| Euler characteristic | 0 | 0 | 0 | 0 | 0 | -30 | -18 | n/a | 0 | 0 |
| orientable | yes | yes | yes | yes | yes | yes | yes | n/a | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | yes | n/a | yes | yes |
| vertex-manifold | yes | yes | yes | yes | yes | yes | yes | n/a | yes | yes |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | n/a | 0 | 0 |
| valid | 18698 | 19200 | 0 | 19200 | 19200 | 16745 | 16815 | n/a | 14195 | 18764 |
| valid_reversed_winding | 0 | 0 | 0 | 0 | 0 | 0 | 0 | n/a | 0 | 0 |
| ball_not_empty_tie | 502 | 0 | 0 | 0 | 0 | 2338 | 2323 | n/a | 5001 | 436 |
| ball_not_empty | 0 | 0 | 9600 | 0 | 0 | 0 | 0 | n/a | 2 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 0 | 0 | 0 | 0 | n/a | 2 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | n/a | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 2.71e-02 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | n/a | 2.71e-02 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 1.37% | 0.69% | n/a | 0.00% | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 1.37% | 0.69% | n/a | 0.00% | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 18670 | 18670 | 530 | 530 | 0/0/530/0 | 0/0/530/0 |
| MeshLab | 0 | 0 | 19200 | 9600 | 9250/9950/0/0 | 3052/3146/3402/0 |
| Digne | 18670 | 18670 | 530 | 530 | 0/0/530/0 | 0/0/530/0 |
| Digne -p | 18670 | 18670 | 530 | 530 | 0/0/530/0 | 0/0/530/0 |
| Gruber | 16719 | 16719 | 2481 | 2364 | 4/93/2384/0 | 0/0/2364/0 |
| bpa_rs | 16799 | 16799 | 2401 | 2339 | 4/43/2354/0 | 0/0/2339/0 |
| Giaccari | 14085 | 14085 | 5115 | 5115 | 0/3/5112/0 | 1/1/5113/0 |
| Extended Gruber | 18614 | 18614 | 586 | 586 | 0/0/586/0 | 0/0/586/0 |

renderings (`torus_r0.10/render/`, view 40.0°):

**shaded, boundary edges in red**

<table>
<tr><td align="center"><a href="torus_r0.10/render/bpa.png"><img src="torus_r0.10/render/bpa.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_r0.10/render/open3d.png"><img src="torus_r0.10/render/open3d.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_r0.10/render/meshlab.png"><img src="torus_r0.10/render/meshlab.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="torus_r0.10/render/digne.png"><img src="torus_r0.10/render/digne.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="torus_r0.10/render/digne_par.png"><img src="torus_r0.10/render/digne_par.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="torus_r0.10/render/gruber.png"><img src="torus_r0.10/render/gruber.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="torus_r0.10/render/bpa_rs.png"><img src="torus_r0.10/render/bpa_rs.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="torus_r0.10/render/giaccari.png"><img src="torus_r0.10/render/giaccari.png" width="260"></a><br><sub>Giaccari</sub></td></tr>
<tr><td align="center"><a href="torus_r0.10/render/gruber_ext.png"><img src="torus_r0.10/render/gruber_ext.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**triangles behind each pixel: warm = odd (a hole is seen through), cool = even**

<table>
<tr><td align="center"><a href="torus_r0.10/render/bpa_depth.png"><img src="torus_r0.10/render/bpa_depth.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_r0.10/render/open3d_depth.png"><img src="torus_r0.10/render/open3d_depth.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_r0.10/render/meshlab_depth.png"><img src="torus_r0.10/render/meshlab_depth.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="torus_r0.10/render/digne_depth.png"><img src="torus_r0.10/render/digne_depth.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="torus_r0.10/render/digne_par_depth.png"><img src="torus_r0.10/render/digne_par_depth.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="torus_r0.10/render/gruber_depth.png"><img src="torus_r0.10/render/gruber_depth.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="torus_r0.10/render/bpa_rs_depth.png"><img src="torus_r0.10/render/bpa_rs_depth.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="torus_r0.10/render/giaccari_depth.png"><img src="torus_r0.10/render/giaccari_depth.png" width="260"></a><br><sub>Giaccari</sub></td></tr>
<tr><td align="center"><a href="torus_r0.10/render/gruber_ext_depth.png"><img src="torus_r0.10/render/gruber_ext_depth.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**front-facing minus back-facing: grey 0, blue +, red −**

<table>
<tr><td align="center"><a href="torus_r0.10/render/bpa_signed.png"><img src="torus_r0.10/render/bpa_signed.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_r0.10/render/open3d_signed.png"><img src="torus_r0.10/render/open3d_signed.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_r0.10/render/meshlab_signed.png"><img src="torus_r0.10/render/meshlab_signed.png" width="260"></a><br><sub>MeshLab</sub></td><td align="center"><a href="torus_r0.10/render/digne_signed.png"><img src="torus_r0.10/render/digne_signed.png" width="260"></a><br><sub>Digne</sub></td></tr>
<tr><td align="center"><a href="torus_r0.10/render/digne_par_signed.png"><img src="torus_r0.10/render/digne_par_signed.png" width="260"></a><br><sub>Digne -p</sub></td><td align="center"><a href="torus_r0.10/render/gruber_signed.png"><img src="torus_r0.10/render/gruber_signed.png" width="260"></a><br><sub>Gruber</sub></td><td align="center"><a href="torus_r0.10/render/bpa_rs_signed.png"><img src="torus_r0.10/render/bpa_rs_signed.png" width="260"></a><br><sub>bpa_rs</sub></td><td align="center"><a href="torus_r0.10/render/giaccari_signed.png"><img src="torus_r0.10/render/giaccari_signed.png" width="260"></a><br><sub>Giaccari</sub></td></tr>
<tr><td align="center"><a href="torus_r0.10/render/gruber_ext_signed.png"><img src="torus_r0.10/render/gruber_ext_signed.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

