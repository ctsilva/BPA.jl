
## torus_r0.10

trimesh2 torus, a regular 120 x 80 lattice (spacing 0.0196), rho = 0.10: many cospherical quads, so the diagonal is a free choice. Expected: closed, chi = 0, 19200 triangles.

input: `-i /Users/csilva/src/bpa/BPA.jl/data/torus-120-80.off`, rho = 0.1, 9600 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 19200 | 19200 | 9600 |
| reconstruction time (s) | 0.04 | 0.157 | 0.015 |
| vertices used | 9600 | 9600 | 4800 |
| boundary edges | 0 | 0 | 0 |
| boundary loops | 0 | 0 | 0 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 19200 | 19200 | 9600 |
| Euler characteristic | 0 | 0 | 0 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 |
| valid | 18698 | 19200 | 0 |
| valid_reversed_winding | 0 | 0 | 0 |
| ball_not_empty_tie | 502 | 0 | 0 |
| ball_not_empty | 0 | 0 | 9600 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 5.51e-08 | 0.00e+00 | 2.71e-02 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 18670 | 18670 | 530 | 530 | 0/0/530/0 | 0/0/530/0 |
| MeshLab | 0 | 0 | 19200 | 9600 | 9250/9950/0/0 | 3052/3146/3402/0 |

renderings (`torus_r0.10/render/`, view 40.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](torus_r0.10/render/bpa.png) | ![](torus_r0.10/render/open3d.png) | ![](torus_r0.10/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](torus_r0.10/render/bpa_depth.png) | ![](torus_r0.10/render/open3d_depth.png) | ![](torus_r0.10/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](torus_r0.10/render/bpa_signed.png) | ![](torus_r0.10/render/open3d_signed.png) | ![](torus_r0.10/render/meshlab_signed.png) |

