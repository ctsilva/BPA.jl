
## bun000

a single Stanford bunny range scan (40256 points, normals from the scan's own triangles), rho = 1.25 mm: real data without overlapping layers. Expected: one open sheet with the scan's outline as boundary.

input: `-l bun000 -d /Users/csilva/src/bpa/BPA.jl/data/bunny/data`, rho = 0.00125, 40256 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 78152 | 77994 | 78203 |
| reconstruction time (s) | 0.1 | 0.281 | 0.198 |
| vertices used | 39759 | 39748 | 39838 |
| boundary edges | 1418 | 1692 | 1921 |
| boundary loops | 26 | 97 | 86 |
| components | 9 | 15 | 12 |
| largest component (triangles) | 75638 | 75473 | 75716 |
| Euler characteristic | -26 | -95 | -224 |
| orientable | yes | no | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 78152 | 77994 | 77754 |
| valid_reversed_winding | 0 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 449 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 7.80e-01 |
| render: odd-parity pixels (holes seen through) | 98.92% | 98.92% | 98.58% |
| render: pixels with front ≠ back | 99.22% | 99.25% | 99.21% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 77804 | 77795 | 348 | 190 | 17/64/233/34 | 15/0/175/0 |
| MeshLab | 77580 | 77580 | 572 | 623 | 26/189/304/53 | 183/194/244/2 |

renderings (`bun000/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](bun000/render/bpa.png) | ![](bun000/render/open3d.png) | ![](bun000/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](bun000/render/bpa_depth.png) | ![](bun000/render/open3d_depth.png) | ![](bun000/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](bun000/render/bpa_signed.png) | ![](bun000/render/open3d_signed.png) | ![](bun000/render/meshlab_signed.png) |

input scans: ![](bun000/render/input.png)

