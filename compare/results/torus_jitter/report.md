
## torus_jitter

parametric torus (R = 1, r = 0.4) on a 120 x 80 grid jittered by 30 % of the spacing, so no four points are cospherical and the answer is unique. rho = 0.06 (2 x the median spacing). Expected: closed, chi = 0, 19200 triangles.

input: `-i /Users/csilva/src/BPA.jl/compare/results/inputs/torus_jitter.off`, rho = 0.06, 9600 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 19200 | 19200 | 19196 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 |
| reconstruction time (s) | 0.03 | 0.067 | 0.046 | 0.094 | 0.022 | 0.024 | 0.023 | 0.028 | 0.96 | 0.011 | 0.02 |
| vertices used | 9600 | 9600 | 9598 | 9600 | 9600 | 9600 | 9600 | 9600 | 9600 | 9600 | 9600 |
| boundary edges | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| boundary loops | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| components | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| largest component (triangles) | 19200 | 19200 | 19196 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 |
| Euler characteristic | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| orientable | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| vertex-manifold | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| valid | 19200 | 19200 | 19189 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 | 19200 |
| valid_reversed_winding | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 7 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 2.90e-01 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 19189 | 19189 | 11 | 7 | 0/11/0/0 | 1/1/5/0 |
| Digne | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne -p | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Gruber | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Gruber reseeded | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| bpa_rs | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Schmehla | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Giaccari | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| bpa fork | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |

renderings (`torus_jitter/render/`, view 40.0°):

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| shaded, boundary edges in red | ![](torus_jitter/render/bpa.png) | ![](torus_jitter/render/open3d.png) | ![](torus_jitter/render/meshlab.png) | ![](torus_jitter/render/digne.png) | ![](torus_jitter/render/digne_par.png) | ![](torus_jitter/render/gruber.png) | ![](torus_jitter/render/gruber_reseed.png) | ![](torus_jitter/render/bpa_rs.png) | ![](torus_jitter/render/schmehla.png) | ![](torus_jitter/render/giaccari.png) | ![](torus_jitter/render/bpafork.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](torus_jitter/render/bpa_depth.png) | ![](torus_jitter/render/open3d_depth.png) | ![](torus_jitter/render/meshlab_depth.png) | ![](torus_jitter/render/digne_depth.png) | ![](torus_jitter/render/digne_par_depth.png) | ![](torus_jitter/render/gruber_depth.png) | ![](torus_jitter/render/gruber_reseed_depth.png) | ![](torus_jitter/render/bpa_rs_depth.png) | ![](torus_jitter/render/schmehla_depth.png) | ![](torus_jitter/render/giaccari_depth.png) | ![](torus_jitter/render/bpafork_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](torus_jitter/render/bpa_signed.png) | ![](torus_jitter/render/open3d_signed.png) | ![](torus_jitter/render/meshlab_signed.png) | ![](torus_jitter/render/digne_signed.png) | ![](torus_jitter/render/digne_par_signed.png) | ![](torus_jitter/render/gruber_signed.png) | ![](torus_jitter/render/gruber_reseed_signed.png) | ![](torus_jitter/render/bpa_rs_signed.png) | ![](torus_jitter/render/schmehla_signed.png) | ![](torus_jitter/render/giaccari_signed.png) | ![](torus_jitter/render/bpafork_signed.png) |

