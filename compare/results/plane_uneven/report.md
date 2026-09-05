
## plane_uneven

jittered plane, 50 x 100 points at 1 mm spacing on the left half and 12 x 25 at 4 mm on the right (5300 points), radii 1.5 mm then 6 mm. Expected: one disk, chi = 1, one boundary loop, every point used; a tool without multi-radius passes shows n/a.

input: `-i /Users/csilva/src/BPA.jl/compare/results/inputs/plane_uneven.off`, rho = 0.0015,0.006, 5300 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | bpa_rs | Schmehla | Giaccari | Extended Gruber |
|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 10405 | 10405 | n/a | 10405 | 10405 | n/a | n/a | n/a | n/a | 10405 |
| triangles per pass (one radius, then each further one) | 9771 + 634 | 9771 + 634 | n/a | 9771 + 634 | 9771 + 634 | n/a | n/a | n/a | n/a | 9771 + 634 |
| reconstruction time (s) | 0.01 | 0.032 | n/a | 0.058 | 0.033 | n/a | n/a | n/a | n/a | 0.008 |
| vertices used | 5300 | 5300 | n/a | 5300 | 5300 | n/a | n/a | n/a | n/a | 5300 |
| boundary edges | 193 | 193 | n/a | 193 | 193 | n/a | n/a | n/a | n/a | 193 |
| boundary loops | 1 | 1 | n/a | 1 | 1 | n/a | n/a | n/a | n/a | 1 |
| components | 1 | 1 | n/a | 1 | 1 | n/a | n/a | n/a | n/a | 1 |
| largest component (triangles) | 10405 | 10405 | n/a | 10405 | 10405 | n/a | n/a | n/a | n/a | 10405 |
| Euler characteristic | 1 | 1 | n/a | 1 | 1 | n/a | n/a | n/a | n/a | 1 |
| orientable | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | yes |
| edge-manifold | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | yes |
| vertex-manifold | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | yes |
| duplicate triangles | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| valid | 10405 | 10405 | n/a | 10405 | 10405 | n/a | n/a | n/a | n/a | 10405 |
| valid_reversed_winding | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty_tie | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| circumradius_too_large | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| degenerate | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | n/a | 0.00e+00 | 0.00e+00 | n/a | n/a | n/a | n/a | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 100.00% | 100.00% | n/a | 100.00% | 100.00% | n/a | n/a | n/a | n/a | 100.00% |
| render: pixels with front ≠ back | 100.00% | 100.00% | n/a | 100.00% | 100.00% | n/a | n/a | n/a | n/a | 100.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 10405 | 10405 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne | 10405 | 10405 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne -p | 10405 | 10405 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Extended Gruber | 10405 | 10405 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |

renderings (`plane_uneven/render/`, view 30.0°):

**shaded, boundary edges in red**

<table>
<tr><td align="center"><a href="plane_uneven/render/bpa.png"><img src="plane_uneven/render/bpa.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="plane_uneven/render/open3d.png"><img src="plane_uneven/render/open3d.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="plane_uneven/render/digne.png"><img src="plane_uneven/render/digne.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="plane_uneven/render/digne_par.png"><img src="plane_uneven/render/digne_par.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="plane_uneven/render/gruber_ext.png"><img src="plane_uneven/render/gruber_ext.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**triangles behind each pixel: warm = odd (a hole is seen through), cool = even**

<table>
<tr><td align="center"><a href="plane_uneven/render/bpa_depth.png"><img src="plane_uneven/render/bpa_depth.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="plane_uneven/render/open3d_depth.png"><img src="plane_uneven/render/open3d_depth.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="plane_uneven/render/digne_depth.png"><img src="plane_uneven/render/digne_depth.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="plane_uneven/render/digne_par_depth.png"><img src="plane_uneven/render/digne_par_depth.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="plane_uneven/render/gruber_ext_depth.png"><img src="plane_uneven/render/gruber_ext_depth.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**front-facing minus back-facing: grey 0, blue +, red −**

<table>
<tr><td align="center"><a href="plane_uneven/render/bpa_signed.png"><img src="plane_uneven/render/bpa_signed.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="plane_uneven/render/open3d_signed.png"><img src="plane_uneven/render/open3d_signed.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="plane_uneven/render/digne_signed.png"><img src="plane_uneven/render/digne_signed.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="plane_uneven/render/digne_par_signed.png"><img src="plane_uneven/render/digne_par_signed.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="plane_uneven/render/gruber_ext_signed.png"><img src="plane_uneven/render/gruber_ext_signed.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**coloured by the pass that built the triangle: blue rho = 0.0015, green 0.006**

<table>
<tr><td align="center"><a href="plane_uneven/render/bpa_passes.png"><img src="plane_uneven/render/bpa_passes.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="plane_uneven/render/open3d_passes.png"><img src="plane_uneven/render/open3d_passes.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="plane_uneven/render/digne_passes.png"><img src="plane_uneven/render/digne_passes.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="plane_uneven/render/digne_par_passes.png"><img src="plane_uneven/render/digne_par_passes.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="plane_uneven/render/gruber_ext_passes.png"><img src="plane_uneven/render/gruber_ext_passes.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**the same, with every triangle edge drawn**

<table>
<tr><td align="center"><a href="plane_uneven/render/bpa_wire.png"><img src="plane_uneven/render/bpa_wire.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="plane_uneven/render/open3d_wire.png"><img src="plane_uneven/render/open3d_wire.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="plane_uneven/render/digne_wire.png"><img src="plane_uneven/render/digne_wire.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="plane_uneven/render/digne_par_wire.png"><img src="plane_uneven/render/digne_par_wire.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="plane_uneven/render/gruber_ext_wire.png"><img src="plane_uneven/render/gruber_ext_wire.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

