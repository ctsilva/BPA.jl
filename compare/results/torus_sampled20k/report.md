
## torus_sampled20k

20000 points sampled uniformly by area on the trimesh2 torus (uneven spacing, normals from the faces), rho = 0.05 (5 x the median nearest-neighbour distance). Expected: closed, chi = 0, 40000 triangles.

input: `-i /Users/csilva/src/BPA.jl/compare/results/inputs/torus_sampled20k.off`, rho = 0.05, 20000 points

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| triangles | 40000 | 40000 | 30279 | 40000 | 40000 | 40000 | 40000 | 40000 | 40000 | 39962 | 40000 |
| reconstruction time (s) | 0.1 | 0.274 | 0.077 | 0.417 | 0.071 | 0.092 | 0.091 | 0.11 | 0.724 | 0.027 | 0.075 |
| vertices used | 20000 | 20000 | 15197 | 20000 | 20000 | 20000 | 20000 | 20000 | 20000 | 19981 | 20000 |
| boundary edges | 0 | 0 | 425 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| boundary loops | 0 | 0 | 94 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| components | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| largest component (triangles) | 40000 | 40000 | 30279 | 40000 | 40000 | 40000 | 40000 | 40000 | 40000 | 39962 | 40000 |
| Euler characteristic | 0 | 0 | -155 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| orientable | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| edge-manifold | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes | yes |
| vertex-manifold | yes | yes | no | yes | yes | yes | yes | yes | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| valid | 40000 | 40000 | 18941 | 40000 | 40000 | 40000 | 40000 | 39998 | 40000 | 39890 | 40000 |
| valid_reversed_winding | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 4 | 0 |
| ball_not_empty | 0 | 0 | 11338 | 0 | 0 | 0 | 0 | 1 | 0 | 68 | 0 |
| circumradius_too_large | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 7.62e-01 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 0.00e+00 | 2.42e-05 | 0.00e+00 | 4.78e-03 | 0.00e+00 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 2.41% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 2.41% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 40000 | 40000 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 18941 | 18941 | 21059 | 11338 | 4263/16568/211/17 | 755/4440/6044/99 |
| Digne | 40000 | 40000 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Digne -p | 40000 | 40000 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Gruber | 40000 | 40000 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Gruber reseeded | 40000 | 40000 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| bpa_rs | 39998 | 39998 | 2 | 2 | 0/0/2/0 | 0/0/2/0 |
| Schmehla | 40000 | 40000 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| Giaccari | 39890 | 39890 | 110 | 72 | 0/106/4/0 | 0/31/40/1 |
| bpa fork | 40000 | 40000 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |

renderings (`torus_sampled20k/render/`, view 40.0°):

|  | BPA.jl | Open3D | MeshLab | Digne | Digne -p | Gruber | Gruber reseeded | bpa_rs | Schmehla | Giaccari | bpa fork |
|---|---|---|---|---|---|---|---|---|---|---|---|
| shaded, boundary edges in red | ![](torus_sampled20k/render/bpa.png) | ![](torus_sampled20k/render/open3d.png) | ![](torus_sampled20k/render/meshlab.png) | ![](torus_sampled20k/render/digne.png) | ![](torus_sampled20k/render/digne_par.png) | ![](torus_sampled20k/render/gruber.png) | ![](torus_sampled20k/render/gruber_reseed.png) | ![](torus_sampled20k/render/bpa_rs.png) | ![](torus_sampled20k/render/schmehla.png) | ![](torus_sampled20k/render/giaccari.png) | ![](torus_sampled20k/render/bpafork.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](torus_sampled20k/render/bpa_depth.png) | ![](torus_sampled20k/render/open3d_depth.png) | ![](torus_sampled20k/render/meshlab_depth.png) | ![](torus_sampled20k/render/digne_depth.png) | ![](torus_sampled20k/render/digne_par_depth.png) | ![](torus_sampled20k/render/gruber_depth.png) | ![](torus_sampled20k/render/gruber_reseed_depth.png) | ![](torus_sampled20k/render/bpa_rs_depth.png) | ![](torus_sampled20k/render/schmehla_depth.png) | ![](torus_sampled20k/render/giaccari_depth.png) | ![](torus_sampled20k/render/bpafork_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](torus_sampled20k/render/bpa_signed.png) | ![](torus_sampled20k/render/open3d_signed.png) | ![](torus_sampled20k/render/meshlab_signed.png) | ![](torus_sampled20k/render/digne_signed.png) | ![](torus_sampled20k/render/digne_par_signed.png) | ![](torus_sampled20k/render/gruber_signed.png) | ![](torus_sampled20k/render/gruber_reseed_signed.png) | ![](torus_sampled20k/render/bpa_rs_signed.png) | ![](torus_sampled20k/render/schmehla_signed.png) | ![](torus_sampled20k/render/giaccari_signed.png) | ![](torus_sampled20k/render/bpafork_signed.png) |

