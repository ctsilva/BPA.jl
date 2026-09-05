
## torus_uneven

jittered torus (R = 20 mm, r = 8 mm), a 126 x 50 lattice at 1 mm for y >= 0 and 32 x 13 at 4 mm for y < 0 (3362 points), radii 1.5 mm then 6 mm. Expected: closed, chi = 0, every point used, but for a triangle or two missing on the seam where the passes meet: the large ball's first contact next to the fine mesh is often a vertex already interior to it, and no choice of lattice seed avoids that at 4:1 on a curved tube.

input: `-i /Users/csilva/src/BPA.jl/compare/results/inputs/torus_uneven.off`, rho = 0.0015,0.006, 3362 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | bpa_rs | Schmehla | Giaccari | Extended Gruber |
|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 6723 | 6716 | n/a | 6716 | 6716 | n/a | n/a | n/a | n/a | 6723 |
| triangles per pass (one radius, then each further one) | 6262 + 461 | 6262 + 454 | n/a | 6262 + 454 | 6262 + 454 | n/a | n/a | n/a | n/a | 6262 + 461 |
| reconstruction time (s) | 0.01 | 0.027 | n/a | 0.043 | 0.034 | n/a | n/a | n/a | n/a | 0.008 |
| vertices used | 3362 | 3362 | n/a | 3362 | 3362 | n/a | n/a | n/a | n/a | 3362 |
| boundary edges | 3 | 24 | n/a | 24 | 24 | n/a | n/a | n/a | n/a | 3 |
| boundary loops | 1 | 7 | n/a | 7 | 7 | n/a | n/a | n/a | n/a | 1 |
| components | 1 | 1 | n/a | 1 | 1 | n/a | n/a | n/a | n/a | 1 |
| largest component (triangles) | 6723 | 6716 | n/a | 6716 | 6716 | n/a | n/a | n/a | n/a | 6723 |
| Euler characteristic | -1 | -8 | n/a | -8 | -8 | n/a | n/a | n/a | n/a | -1 |
| orientable | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | yes |
| edge-manifold | yes | yes | n/a | yes | yes | n/a | n/a | n/a | n/a | yes |
| vertex-manifold | yes | no | n/a | no | no | n/a | n/a | n/a | n/a | yes |
| duplicate triangles | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| valid | 6723 | 6716 | n/a | 6716 | 6716 | n/a | n/a | n/a | n/a | 6723 |
| valid_reversed_winding | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty_tie | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| ball_not_empty | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| circumradius_too_large | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| degenerate | 0 | 0 | n/a | 0 | 0 | n/a | n/a | n/a | n/a | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | n/a | 0.00e+00 | 0.00e+00 | n/a | n/a | n/a | n/a | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 0.03% | 0.53% | n/a | 0.53% | 0.53% | n/a | n/a | n/a | n/a | 0.03% |
| render: pixels with front ≠ back | 0.03% | 0.53% | n/a | 0.53% | 0.53% | n/a | n/a | n/a | n/a | 0.03% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 6716 | 6716 | 7 | 0 | 0/0/0/7 | 0/0/0/0 |
| Digne | 6716 | 6716 | 7 | 0 | 0/0/0/7 | 0/0/0/0 |
| Digne -p | 6716 | 6716 | 7 | 0 | 0/0/0/7 | 0/0/0/0 |
| Extended Gruber | 6723 | 6723 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |

renderings (`torus_uneven/render/`, view 30.0°):

**shaded, boundary edges in red**

<table>
<tr><td align="center"><a href="torus_uneven/render/bpa.png"><img src="torus_uneven/render/bpa.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_uneven/render/open3d.png"><img src="torus_uneven/render/open3d.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_uneven/render/digne.png"><img src="torus_uneven/render/digne.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="torus_uneven/render/digne_par.png"><img src="torus_uneven/render/digne_par.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="torus_uneven/render/gruber_ext.png"><img src="torus_uneven/render/gruber_ext.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**triangles behind each pixel: warm = odd (a hole is seen through), cool = even**

<table>
<tr><td align="center"><a href="torus_uneven/render/bpa_depth.png"><img src="torus_uneven/render/bpa_depth.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_uneven/render/open3d_depth.png"><img src="torus_uneven/render/open3d_depth.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_uneven/render/digne_depth.png"><img src="torus_uneven/render/digne_depth.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="torus_uneven/render/digne_par_depth.png"><img src="torus_uneven/render/digne_par_depth.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="torus_uneven/render/gruber_ext_depth.png"><img src="torus_uneven/render/gruber_ext_depth.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**front-facing minus back-facing: grey 0, blue +, red −**

<table>
<tr><td align="center"><a href="torus_uneven/render/bpa_signed.png"><img src="torus_uneven/render/bpa_signed.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_uneven/render/open3d_signed.png"><img src="torus_uneven/render/open3d_signed.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_uneven/render/digne_signed.png"><img src="torus_uneven/render/digne_signed.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="torus_uneven/render/digne_par_signed.png"><img src="torus_uneven/render/digne_par_signed.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="torus_uneven/render/gruber_ext_signed.png"><img src="torus_uneven/render/gruber_ext_signed.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**coloured by the pass that built the triangle: blue rho = 0.0015, green 0.006**

<table>
<tr><td align="center"><a href="torus_uneven/render/bpa_passes.png"><img src="torus_uneven/render/bpa_passes.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_uneven/render/open3d_passes.png"><img src="torus_uneven/render/open3d_passes.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_uneven/render/digne_passes.png"><img src="torus_uneven/render/digne_passes.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="torus_uneven/render/digne_par_passes.png"><img src="torus_uneven/render/digne_par_passes.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="torus_uneven/render/gruber_ext_passes.png"><img src="torus_uneven/render/gruber_ext_passes.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

**the same, with every triangle edge drawn**

<table>
<tr><td align="center"><a href="torus_uneven/render/bpa_wire.png"><img src="torus_uneven/render/bpa_wire.png" width="260"></a><br><sub>BPA.jl</sub></td><td align="center"><a href="torus_uneven/render/open3d_wire.png"><img src="torus_uneven/render/open3d_wire.png" width="260"></a><br><sub>Open3D</sub></td><td align="center"><a href="torus_uneven/render/digne_wire.png"><img src="torus_uneven/render/digne_wire.png" width="260"></a><br><sub>Digne</sub></td><td align="center"><a href="torus_uneven/render/digne_par_wire.png"><img src="torus_uneven/render/digne_par_wire.png" width="260"></a><br><sub>Digne -p</sub></td></tr>
<tr><td align="center"><a href="torus_uneven/render/gruber_ext_wire.png"><img src="torus_uneven/render/gruber_ext_wire.png" width="260"></a><br><sub>Extended Gruber</sub></td></tr>
</table>

