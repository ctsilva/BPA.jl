
## sphere_uneven

Fibonacci sphere of radius 25 mm, 1 mm spacing for y >= 0 and a 4 mm Fibonacci sampling for y < 0 (4172 points), radii 1.5 mm then 6 mm. Expected: closed, chi = 2, every point used, 2V - 4 triangles.

input: `-i /Users/csilva/src/BPA.jl/compare/results/inputs/sphere_uneven.off`, rho = 0.0015,0.006, 4172 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | bpa_rs | Schmehla | Giaccari | Extended Gruber |
|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 8340 | 8340 | n/a | 8340 | 8340 | n/a | n/a | n/a | n/a | 8340 |
| triangles per pass (one radius, then each further one) | 7786 + 554 | 7786 + 554 | n/a | 7786 + 554 | 7786 + 554 | n/a | n/a | n/a | n/a | 7786 + 554 |
| reconstruction time (s) | 0.01 | 0.028 | n/a | 0.049 | 0.032 | n/a | n/a | n/a | n/a | 0.009 |
| vertices used | 4172 | 4172 | n/a | 4172 | 4172 | n/a | n/a | n/a | n/a | 4172 |
| boundary edges | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| boundary loops | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| components | 1 | 1 | n/a | 1 | 1 | n/a | n/a | n/a | n/a | 1 |
| largest component (triangles) | 8340 | 8340 | n/a | 8340 | 8340 | n/a | n/a | n/a | n/a | 8340 |
| Euler characteristic | 2 | 2 | n/a | 2 | 2 | n/a | n/a | n/a | n/a | 2 |
| orientable | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | yes |
| edge-manifold | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | yes |
| vertex-manifold | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | yes |
| duplicate triangles | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| valid | 8340 | 8340 | n/a | 8340 | 8340 | n/a | n/a | n/a | n/a | 8340 |
| valid_reversed_winding | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty_tie | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| circumradius_too_large | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| degenerate | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | n/a | 0.00e+00 | 0.00e+00 | n/a | n/a | n/a | n/a | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | n/a | 0.00% | 0.00% | n/a | n/a | n/a | n/a | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | n/a | 0.00% | 0.00% | n/a | n/a | n/a | n/a | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 8340 | 8340 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne | 8340 | 8340 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne -p | 8340 | 8340 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Extended Gruber | 8340 | 8340 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |

renderings (`sphere_uneven/render/`, view 30.0°):

**shaded, boundary edges in red**

<table>
<tr><td align="center"><a href="sphere_uneven/render/bpa.png"><img src="sphere_uneven/render/bpa.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="sphere_uneven/render/open3d.png"><img src="sphere_uneven/render/open3d.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="sphere_uneven/render/digne.png"><img src="sphere_uneven/render/digne.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="sphere_uneven/render/digne_par.png"><img src="sphere_uneven/render/digne_par.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="sphere_uneven/render/gruber_ext.png"><img src="sphere_uneven/render/gruber_ext.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**triangles behind each pixel: warm = odd (a hole is seen through), cool = even**

<table>
<tr><td align="center"><a href="sphere_uneven/render/bpa_depth.png"><img src="sphere_uneven/render/bpa_depth.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="sphere_uneven/render/open3d_depth.png"><img src="sphere_uneven/render/open3d_depth.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="sphere_uneven/render/digne_depth.png"><img src="sphere_uneven/render/digne_depth.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="sphere_uneven/render/digne_par_depth.png"><img src="sphere_uneven/render/digne_par_depth.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="sphere_uneven/render/gruber_ext_depth.png"><img src="sphere_uneven/render/gruber_ext_depth.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**front-facing minus back-facing: grey 0, blue +, red −**

<table>
<tr><td align="center"><a href="sphere_uneven/render/bpa_signed.png"><img src="sphere_uneven/render/bpa_signed.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="sphere_uneven/render/open3d_signed.png"><img src="sphere_uneven/render/open3d_signed.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="sphere_uneven/render/digne_signed.png"><img src="sphere_uneven/render/digne_signed.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="sphere_uneven/render/digne_par_signed.png"><img src="sphere_uneven/render/digne_par_signed.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="sphere_uneven/render/gruber_ext_signed.png"><img src="sphere_uneven/render/gruber_ext_signed.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**coloured by the pass that built the triangle: blue rho = 0.0015, green 0.006**

<table>
<tr><td align="center"><a href="sphere_uneven/render/bpa_passes.png"><img src="sphere_uneven/render/bpa_passes.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="sphere_uneven/render/open3d_passes.png"><img src="sphere_uneven/render/open3d_passes.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="sphere_uneven/render/digne_passes.png"><img src="sphere_uneven/render/digne_passes.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="sphere_uneven/render/digne_par_passes.png"><img src="sphere_uneven/render/digne_par_passes.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="sphere_uneven/render/gruber_ext_passes.png"><img src="sphere_uneven/render/gruber_ext_passes.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**the same, with every triangle edge drawn**

<table>
<tr><td align="center"><a href="sphere_uneven/render/bpa_wire.png"><img src="sphere_uneven/render/bpa_wire.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="sphere_uneven/render/open3d_wire.png"><img src="sphere_uneven/render/open3d_wire.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="sphere_uneven/render/digne_wire.png"><img src="sphere_uneven/render/digne_wire.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="sphere_uneven/render/digne_par_wire.png"><img src="sphere_uneven/render/digne_par_wire.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="sphere_uneven/render/gruber_ext_wire.png"><img src="sphere_uneven/render/gruber_ext_wire.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

