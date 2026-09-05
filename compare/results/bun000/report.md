
## bun000

a single Stanford bunny range scan (40256 points, normals from the scan's own triangles), rho = 1.25 mm: real data without overlapping layers. Expected: one open sheet with the scan's outline as boundary.

input: `-l bun000 -d /Users/csilva/src/BPA.jl/data/bunny/data`, rho = 0.00125, 40256 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 78152 | 77994 | 78203 | 77941 | 77933 | 1631 | 78093 | 1631 | 134 | 75613 | 78162 |
| reconstruction time (s) | 0.12 | 0.35 | 0.276 | 0.51 | 0.308 | 0.003 | 0.128 | 0.005 | 0.206 | 0.048 | 0.091 |
| vertices used | 39759 | 39748 | 39838 | 39785 | 39785 | 883 | 39773 | 883 | 66 | 38325 | 39780 |
| boundary edges | 1418 | 1692 | 1921 | 2095 | 2137 | 137 | 1459 | 137 | 9 | 1061 | 1440 |
| boundary loops | 26 | 97 | 86 | 146 | 151 | 3 | 37 | 3 | 4 | 10 | 32 |
| components | 9 | 15 | 12 | 14 | 14 | 1 | 17 | 1 | 1 | 1 | 14 |
| largest component (triangles) | 75638 | 75473 | 75716 | 75425 | 75415 | 1631 | 75566 | 1631 | 134 | 75613 | 75637 |
| Euler characteristic | -26 | -95 | -224 | -233 | -250 | -1 | -3 | -1 | 43 | -12 | -21 |
| orientable | yes | no | yes | no | no | yes | yes | yes | no | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | yes | yes | no | yes | yes |
| vertex-manifold | no | no | no | no | no | yes | yes | yes | no | yes | no |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 41 | 0 | 0 |
| valid | 78152 | 77994 | 77754 | 77937 | 77923 | 1631 | 78085 | 1631 | 68 | 75564 | 78162 |
| valid_reversed_winding | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 46 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 449 | 1 | 1 | 0 | 8 | 0 | 20 | 46 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 3 | 9 | 0 | 0 | 0 | 0 | 3 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 7.80e-01 | 1.82e-01 | 1.82e-01 | 0.00e+00 | 2.97e-01 | 0.00e+00 | 8.67e-01 | 7.79e-01 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 98.92% | 98.92% | 98.58% | 98.91% | 98.91% | 99.47% | 98.93% | 99.47% | 11.82% | 98.88% | 98.91% |
| render: pixels with front ≠ back | 99.22% | 99.25% | 99.21% | 99.22% | 99.22% | 99.56% | 99.23% | 99.56% | 11.82% | 99.17% | 99.21% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 77804 | 77795 | 348 | 190 | 17/64/233/34 | 15/0/175/0 |
| MeshLab | 77580 | 77580 | 572 | 623 | 26/189/304/53 | 183/194/244/2 |
| Digne | 77742 | 77737 | 410 | 199 | 0/6/210/194 | 16/2/181/0 |
| Digne -p | 77725 | 77720 | 427 | 208 | 0/6/216/205 | 16/7/185/0 |
| Gruber | 1631 | 1631 | 76521 | 0 | 76520/1/0/0 | 0/0/0/0 |
| Gruber reseeded | 77867 | 77865 | 285 | 226 | 14/54/217/0 | 14/0/211/1 |
| bpa_rs | 1631 | 1631 | 76521 | 0 | 76520/1/0/0 | 0/0/0/0 |
| Schmehla | 70 | 34 | 78082 | 23 | 78057/13/9/3 | 2/7/14/0 |
| Giaccari | 75358 | 75358 | 2794 | 255 | 2534/58/202/0 | 18/28/205/4 |
| bpa fork | 77974 | 77974 | 178 | 188 | 0/1/177/0 | 11/0/177/0 |

renderings (`bun000/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| shaded, boundary edges in red | ![](bun000/render/bpa.png) | ![](bun000/render/open3d.png) | ![](bun000/render/meshlab.png) | ![](bun000/render/digne.png) | ![](bun000/render/digne_par.png) | ![](bun000/render/gruber.png) | ![](bun000/render/gruber_reseed.png) | ![](bun000/render/bpa_rs.png) | ![](bun000/render/schmehla.png) | ![](bun000/render/giaccari.png) | ![](bun000/render/bpafork.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](bun000/render/bpa_depth.png) | ![](bun000/render/open3d_depth.png) | ![](bun000/render/meshlab_depth.png) | ![](bun000/render/digne_depth.png) | ![](bun000/render/digne_par_depth.png) | ![](bun000/render/gruber_depth.png) | ![](bun000/render/gruber_reseed_depth.png) | ![](bun000/render/bpa_rs_depth.png) | ![](bun000/render/schmehla_depth.png) | ![](bun000/render/giaccari_depth.png) | ![](bun000/render/bpafork_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](bun000/render/bpa_signed.png) | ![](bun000/render/open3d_signed.png) | ![](bun000/render/meshlab_signed.png) | ![](bun000/render/digne_signed.png) | ![](bun000/render/digne_par_signed.png) | ![](bun000/render/gruber_signed.png) | ![](bun000/render/gruber_reseed_signed.png) | ![](bun000/render/bpa_rs_signed.png) | ![](bun000/render/schmehla_signed.png) | ![](bun000/render/giaccari_signed.png) | ![](bun000/render/bpafork_signed.png) |

input scans: ![](bun000/render/input.png)

