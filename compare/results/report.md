# BPA cross-check

Each output is checked on its own: every triangle should admit an empty rho-ball on its outward side (`valid`; the side its vertex normals point to, or either side when they do not all agree), and the mesh should be orientable and manifold. `ball_not_empty_tie` counts triangles whose ball contains a point within 1e-5 rho of its surface (cospherical ties, not errors). Then each triangle set is compared with the reference tool's as unordered vertex triples. The render rows come from `tools/render.jl`: the share of covered pixels behind which an odd number of triangles lie (a hole seen through, for a closed surface), and the share where front-facing and back-facing triangles do not cancel (holes and flipped patches).


## sphere2000

2000-point Fibonacci sphere, rho = 1.5 x mean spacing. Expected: closed, chi = 2, 3996 triangles, every point used.

input: `-i /Users/csilva/src/bpa/BPA.jl/compare/results/inputs/sphere2000.off`, rho = 0.119, 2000 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 3996 | 3996 | 3994 |
| reconstruction time (s) | 0.01 | 0.01 | 0.009 |
| vertices used | 2000 | 2000 | 1999 |
| boundary edges | 0 | 0 | 0 |
| boundary loops | 0 | 0 | 0 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 3996 | 3996 | 3994 |
| Euler characteristic | 2 | 2 | 2 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 |
| valid | 3996 | 3996 | 3991 |
| valid_reversed_winding | 0 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 3 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 2.26e-01 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 3996 | 3996 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 3991 | 3991 | 5 | 3 | 0/5/0/0 | 0/1/2/0 |

renderings (`sphere2000/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](sphere2000/render/bpa.png) | ![](sphere2000/render/open3d.png) | ![](sphere2000/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](sphere2000/render/bpa_depth.png) | ![](sphere2000/render/open3d_depth.png) | ![](sphere2000/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](sphere2000/render/bpa_signed.png) | ![](sphere2000/render/open3d_signed.png) | ![](sphere2000/render/meshlab_signed.png) |


## plane40

40 x 40 jittered grid on a plane. Expected: a disk, chi = 1, one clean boundary loop, every point used.

input: `-i /Users/csilva/src/bpa/BPA.jl/compare/results/inputs/plane40.off`, rho = 0.15, 1600 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 3042 | 3042 | 3041 |
| reconstruction time (s) | 0.0 | 0.006 | 0.006 |
| vertices used | 1600 | 1600 | 1599 |
| boundary edges | 156 | 156 | 155 |
| boundary loops | 1 | 1 | 1 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 3042 | 3042 | 3041 |
| Euler characteristic | 1 | 1 | 1 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 |
| valid | 3042 | 3042 | 0 |
| valid_reversed_winding | 0 | 0 | 3040 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 1 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 6.62e-04 |
| render: odd-parity pixels (holes seen through) | 100.00% | 100.00% | 100.00% |
| render: pixels with front ≠ back | 100.00% | 100.00% | 100.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 3042 | 3042 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 3040 | 0 | 2 | 1 | 0/2/0/0 | 0/0/1/0 |

renderings (`plane40/render/`, view 20.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](plane40/render/bpa.png) | ![](plane40/render/open3d.png) | ![](plane40/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](plane40/render/bpa_depth.png) | ![](plane40/render/open3d_depth.png) | ![](plane40/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](plane40/render/bpa_signed.png) | ![](plane40/render/open3d_signed.png) | ![](plane40/render/meshlab_signed.png) |


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


## torus_r0.05

the same regular torus at rho = 0.05, the smallest radius that still closes it.

input: `-i /Users/csilva/src/bpa/BPA.jl/data/torus-120-80.off`, rho = 0.05, 9600 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 19200 | 19200 | 19196 |
| reconstruction time (s) | 0.03 | 0.048 | 0.035 |
| vertices used | 9600 | 9600 | 9599 |
| boundary edges | 0 | 0 | 4 |
| boundary loops | 0 | 0 | 1 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 19200 | 19200 | 19196 |
| Euler characteristic | 0 | 0 | -1 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 |
| valid | 18828 | 19200 | 19194 |
| valid_reversed_winding | 0 | 0 | 0 |
| ball_not_empty_tie | 372 | 0 | 0 |
| ball_not_empty | 0 | 0 | 2 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 9.16e-08 | 0.00e+00 | 9.17e-02 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.03% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.03% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 18822 | 18822 | 378 | 378 | 0/0/378/0 | 0/0/378/0 |
| MeshLab | 18816 | 18816 | 384 | 380 | 0/4/380/0 | 0/0/380/0 |

renderings (`torus_r0.05/render/`, view 40.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](torus_r0.05/render/bpa.png) | ![](torus_r0.05/render/open3d.png) | ![](torus_r0.05/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](torus_r0.05/render/bpa_depth.png) | ![](torus_r0.05/render/open3d_depth.png) | ![](torus_r0.05/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](torus_r0.05/render/bpa_signed.png) | ![](torus_r0.05/render/open3d_signed.png) | ![](torus_r0.05/render/meshlab_signed.png) |


## torus_jitter

parametric torus (R = 1, r = 0.4) on a 120 x 80 grid jittered by 30 % of the spacing, so no four points are cospherical and the answer is unique. rho = 0.06 (2 x the median spacing). Expected: closed, chi = 0, 19200 triangles.

input: `-i /Users/csilva/src/bpa/BPA.jl/compare/results/inputs/torus_jitter.off`, rho = 0.06, 9600 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 19200 | 19200 | 19196 |
| reconstruction time (s) | 0.02 | 0.053 | 0.035 |
| vertices used | 9600 | 9600 | 9598 |
| boundary edges | 0 | 0 | 0 |
| boundary loops | 0 | 0 | 0 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 19200 | 19200 | 19196 |
| Euler characteristic | 0 | 0 | 0 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | yes | yes | yes |
| duplicate triangles | 0 | 0 | 0 |
| valid | 19200 | 19200 | 19189 |
| valid_reversed_winding | 0 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 7 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 2.90e-01 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 0.00% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 0.00% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 19200 | 19200 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 19189 | 19189 | 11 | 7 | 0/11/0/0 | 1/1/5/0 |

renderings (`torus_jitter/render/`, view 40.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](torus_jitter/render/bpa.png) | ![](torus_jitter/render/open3d.png) | ![](torus_jitter/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](torus_jitter/render/bpa_depth.png) | ![](torus_jitter/render/open3d_depth.png) | ![](torus_jitter/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](torus_jitter/render/bpa_signed.png) | ![](torus_jitter/render/open3d_signed.png) | ![](torus_jitter/render/meshlab_signed.png) |


## torus_sampled20k

20000 points sampled uniformly by area on the trimesh2 torus (uneven spacing, normals from the faces), rho = 0.05 (5 x the median nearest-neighbour distance). Expected: closed, chi = 0, 40000 triangles.

input: `-i /Users/csilva/src/bpa/BPA.jl/compare/results/inputs/torus_sampled20k.off`, rho = 0.05, 20000 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 40000 | 40000 | 30279 |
| reconstruction time (s) | 0.13 | 0.217 | 0.06 |
| vertices used | 20000 | 20000 | 15197 |
| boundary edges | 0 | 0 | 425 |
| boundary loops | 0 | 0 | 94 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 40000 | 40000 | 30279 |
| Euler characteristic | 0 | 0 | -155 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | yes | yes | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 40000 | 40000 | 18941 |
| valid_reversed_winding | 0 | 0 | 0 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 11338 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 7.62e-01 |
| render: odd-parity pixels (holes seen through) | 0.00% | 0.00% | 2.41% |
| render: pixels with front ≠ back | 0.00% | 0.00% | 2.41% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 40000 | 40000 | 0 | 0 | 0/0/0/0 | 0/0/0/0 |
| MeshLab | 18941 | 18941 | 21059 | 11338 | 4263/16568/211/17 | 755/4440/6044/99 |

renderings (`torus_sampled20k/render/`, view 40.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](torus_sampled20k/render/bpa.png) | ![](torus_sampled20k/render/open3d.png) | ![](torus_sampled20k/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](torus_sampled20k/render/bpa_depth.png) | ![](torus_sampled20k/render/open3d_depth.png) | ![](torus_sampled20k/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](torus_sampled20k/render/bpa_signed.png) | ![](torus_sampled20k/render/open3d_signed.png) | ![](torus_sampled20k/render/meshlab_signed.png) |


## knot_r0.0188

trefoil knot, 30000 points, rho = 1.5 x the estimated spacing, deliberately too small for this anisotropic lattice: many boundaries, so the tools' seeding and stopping behaviour shows.

input: `-i /Users/csilva/src/bpa/BPA.jl/data/knot-300-100.off`, rho = 0.0188, 30000 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 36132 | 35952 | 36462 |
| reconstruction time (s) | 0.03 | 0.064 | 0.095 |
| vertices used | 18615 | 18591 | 18780 |
| boundary edges | 1176 | 1308 | 1340 |
| boundary loops | 19 | 19 | 2 |
| components | 4 | 19 | 1 |
| largest component (triangles) | 36123 | 35934 | 36462 |
| Euler characteristic | -39 | -39 | -121 |
| orientable | yes | no | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 36132 | 35952 | 36235 |
| valid_reversed_winding | 0 | 0 | 22 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 205 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 7.38e-01 |
| render: odd-parity pixels (holes seen through) | 60.97% | 61.07% | 60.94% |
| render: pixels with front ≠ back | 62.23% | 62.41% | 62.34% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 35862 | 35862 | 270 | 90 | 81/132/31/26 | 21/42/18/9 |
| MeshLab | 35914 | 35907 | 218 | 548 | 46/95/64/13 | 376/106/60/6 |

renderings (`knot_r0.0188/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](knot_r0.0188/render/bpa.png) | ![](knot_r0.0188/render/open3d.png) | ![](knot_r0.0188/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](knot_r0.0188/render/bpa_depth.png) | ![](knot_r0.0188/render/open3d_depth.png) | ![](knot_r0.0188/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](knot_r0.0188/render/bpa_signed.png) | ![](knot_r0.0188/render/open3d_signed.png) | ![](knot_r0.0188/render/meshlab_signed.png) |


## knot_r0.03

the same knot at rho = 0.03, the radius the package recommends: nearly closed, with small holes where the tube almost touches itself.

input: `-i /Users/csilva/src/bpa/BPA.jl/data/knot-300-100.off`, rho = 0.03, 30000 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 58400 | 58326 | 59570 |
| reconstruction time (s) | 0.11 | 0.162 | 0.164 |
| vertices used | 29208 | 29202 | 29993 |
| boundary edges | 62 | 214 | 1770 |
| boundary loops | 16 | 35 | 7 |
| components | 1 | 1 | 1 |
| largest component (triangles) | 58400 | 58326 | 59570 |
| Euler characteristic | -23 | -68 | -677 |
| orientable | yes | yes | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 58400 | 58326 | 53170 |
| valid_reversed_winding | 0 | 0 | 4506 |
| ball_not_empty_tie | 0 | 0 | 0 |
| ball_not_empty | 0 | 0 | 1894 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.15e-01 |
| render: odd-parity pixels (holes seen through) | 0.22% | 0.56% | 3.33% |
| render: pixels with front ≠ back | 0.22% | 0.57% | 16.40% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 58292 | 58292 | 108 | 34 | 6/41/30/31 | 0/21/13/0 |
| MeshLab | 57629 | 53128 | 771 | 1941 | 11/306/167/287 | 1602/265/74/0 |

renderings (`knot_r0.03/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](knot_r0.03/render/bpa.png) | ![](knot_r0.03/render/open3d.png) | ![](knot_r0.03/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](knot_r0.03/render/bpa_depth.png) | ![](knot_r0.03/render/open3d_depth.png) | ![](knot_r0.03/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](knot_r0.03/render/bpa_signed.png) | ![](knot_r0.03/render/open3d_signed.png) | ![](knot_r0.03/render/meshlab_signed.png) |


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


## bunny4_r0.0008

four registered bunny body scans (150983 points), rho = 0.8 mm, close to the layer separation of the overlapping scans: the hardest case for the empty-ball property.

input: `-l bun000,bun045,bun090,bun180 -d /Users/csilva/src/bpa/BPA.jl/data/bunny/data`, rho = 0.0008, 150983 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 239041 | 237204 | 256474 |
| reconstruction time (s) | 0.37 | 0.914 | 4.816 |
| vertices used | 122478 | 122347 | 133234 |
| boundary edges | 6475 | 8818 | 15692 |
| boundary loops | 357 | 632 | 424 |
| components | 109 | 151 | 87 |
| largest component (triangles) | 237586 | 235749 | 255142 |
| Euler characteristic | -280 | -664 | -2849 |
| orientable | yes | no | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 239041 | 237193 | 20356 |
| valid_reversed_winding | 0 | 11 | 83630 |
| ball_not_empty_tie | 0 | 0 | 1 |
| ball_not_empty | 0 | 0 | 152487 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.84e-01 |
| render: odd-parity pixels (holes seen through) | 26.28% | 27.59% | 38.13% |
| render: pixels with front ≠ back | 26.93% | 28.27% | 44.51% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 236959 | 236935 | 2082 | 245 | 238/1155/405/284 | 68/30/145/2 |
| MeshLab | 102553 | 18738 | 136488 | 153921 | 42744/58737/34612/395 | 68537/46040/39022/322 |

renderings (`bunny4_r0.0008/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](bunny4_r0.0008/render/bpa.png) | ![](bunny4_r0.0008/render/open3d.png) | ![](bunny4_r0.0008/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](bunny4_r0.0008/render/bpa_depth.png) | ![](bunny4_r0.0008/render/open3d_depth.png) | ![](bunny4_r0.0008/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](bunny4_r0.0008/render/bpa_signed.png) | ![](bunny4_r0.0008/render/open3d_signed.png) | ![](bunny4_r0.0008/render/meshlab_signed.png) |

input scans: ![](bunny4_r0.0008/render/input.png)


## bunny4_r0.0015

the same four scans at rho = 1.5 mm, where the ball rides over the overlap layers.

input: `-l bun000,bun045,bun090,bun180 -d /Users/csilva/src/bpa/BPA.jl/data/bunny/data`, rho = 0.0015, 150983 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 202958 | 201124 | 218720 |
| reconstruction time (s) | 0.53 | 5.104 | 8.558 |
| vertices used | 102271 | 102125 | 113527 |
| boundary edges | 1732 | 3918 | 28558 |
| boundary loops | 60 | 315 | 512 |
| components | 3 | 30 | 5 |
| largest component (triangles) | 202898 | 201009 | 218664 |
| Euler characteristic | -74 | -396 | -10112 |
| orientable | yes | no | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 202958 | 201104 | 148442 |
| valid_reversed_winding | 0 | 20 | 4146 |
| ball_not_empty_tie | 0 | 0 | 3 |
| ball_not_empty | 0 | 0 | 66129 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.80e-01 |
| render: odd-parity pixels (holes seen through) | 19.20% | 21.56% | 35.36% |
| render: pixels with front ≠ back | 19.34% | 21.80% | 44.67% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 200634 | 200595 | 2324 | 490 | 169/1275/718/162 | 37/6/447/0 |
| MeshLab | 151975 | 147789 | 50983 | 66745 | 7140/34350/8518/975 | 35428/15275/15062/980 |

renderings (`bunny4_r0.0015/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](bunny4_r0.0015/render/bpa.png) | ![](bunny4_r0.0015/render/open3d.png) | ![](bunny4_r0.0015/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](bunny4_r0.0015/render/bpa_depth.png) | ![](bunny4_r0.0015/render/open3d_depth.png) | ![](bunny4_r0.0015/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](bunny4_r0.0015/render/bpa_signed.png) | ![](bunny4_r0.0015/render/open3d_signed.png) | ![](bunny4_r0.0015/render/meshlab_signed.png) |

input scans: ![](bunny4_r0.0015/render/input.png)


## bunny10_r0.00125

all ten bunny scans (362272 points), rho = 1.25 mm, the package's reference reconstruction.

input: `-l bun000,bun045,bun090,bun180,bun270,bun315,chin,ear_back,top2,top3 -d /Users/csilva/src/bpa/BPA.jl/data/bunny/data`, rho = 0.00125, 362272 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 323934 | 317975 | 477737 |
| reconstruction time (s) | 1.12 | 26.809 | 165.515 |
| vertices used | 162289 | 161945 | 253390 |
| boundary edges | 806 | 8125 | 173875 |
| boundary loops | 107 | 938 | 715 |
| components | 17 | 97 | 1 |
| largest component (triangles) | 323910 | 317864 | 477737 |
| Euler characteristic | -81 | -1105 | -72416 |
| orientable | yes | no | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 323934 | 317918 | 186867 |
| valid_reversed_winding | 0 | 57 | 174 |
| ball_not_empty_tie | 0 | 0 | 12 |
| ball_not_empty | 0 | 0 | 290684 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.89e-01 |
| render: odd-parity pixels (holes seen through) | 3.92% | 8.84% | 48.21% |
| render: pixels with front ≠ back | 3.97% | 8.98% | 59.27% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 317668 | 317610 | 6266 | 307 | 533/4395/833/505 | 86/7/214/0 |
| MeshLab | 186593 | 186475 | 137341 | 291144 | 27109/86878/19718/3636 | 209283/55330/25063/1468 |

renderings (`bunny10_r0.00125/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](bunny10_r0.00125/render/bpa.png) | ![](bunny10_r0.00125/render/open3d.png) | ![](bunny10_r0.00125/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](bunny10_r0.00125/render/bpa_depth.png) | ![](bunny10_r0.00125/render/open3d_depth.png) | ![](bunny10_r0.00125/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](bunny10_r0.00125/render/bpa_signed.png) | ![](bunny10_r0.00125/render/open3d_signed.png) | ![](bunny10_r0.00125/render/meshlab_signed.png) |

input scans: ![](bunny10_r0.00125/render/input.png)


## dragon62_r0.0007

the 62 Stanford dragon surface scans (1.83 million points), rho = 0.7 mm: the largest input, with up to 98 overlapping layers.

input: `-l dragonBottomFill1_0,dragonBottomFill2_0,dragonKnee_0,dragonMouth1_0,dragonMouth2_0,dragonMouth3_0,dragonMouth4_0,dragonMouth5_0,dragonMouth6_0,dragonMouth7_0,dragonMouth8_0,dragonNook1_0,dragonNook2_0,dragonSideRight_0,dragonSideRight_120,dragonSideRight_144,dragonSideRight_168,dragonSideRight_192,dragonSideRight_216,dragonSideRight_24,dragonSideRight_240,dragonSideRight_264,dragonSideRight_288,dragonSideRight_312,dragonSideRight_336,dragonSideRight_48,dragonSideRight_72,dragonSideRight_96,dragonStandRight_0,dragonStandRight_120,dragonStandRight_144,dragonStandRight_168,dragonStandRight_192,dragonStandRight_216,dragonStandRight_24,dragonStandRight_240,dragonStandRight_264,dragonStandRight_288,dragonStandRight_312,dragonStandRight_336,dragonStandRight_48,dragonStandRight_72,dragonStandRight_96,dragonToes_0,dragonToes3_0,dragonTopFill1_0,dragonTopFill2_0,dragonUpRight_0,dragonUpRight_120,dragonUpRight_144,dragonUpRight_168,dragonUpRight_192,dragonUpRight_216,dragonUpRight_24,dragonUpRight_240,dragonUpRight_264,dragonUpRight_288,dragonUpRight_312,dragonUpRight_336,dragonUpRight_48,dragonUpRight_72,dragonUpRight_96 -d /Users/csilva/src/bpa/BPA.jl/data/dragon/scans`, rho = 0.0007, 1826038 points

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| triangles | 649518 | 624851 | 2545632 |
| reconstruction time (s) | 5.16 | 670.566 | 14850.425 |
| vertices used | 329013 | 328647 | 1376106 |
| boundary edges | 13434 | 53205 | 1707330 |
| boundary loops | 2257 | 6804 | 398 |
| components | 101 | 536 | 34 |
| largest component (triangles) | 617351 | 592274 | 2513633 |
| Euler characteristic | -2463 | -10381 | -750375 |
| orientable | yes | no | yes |
| edge-manifold | yes | yes | yes |
| vertex-manifold | no | no | no |
| duplicate triangles | 0 | 0 | 0 |
| valid | 649518 | 624774 | 112449 |
| valid_reversed_winding | 0 | 77 | 20840 |
| ball_not_empty_tie | 0 | 0 | 6 |
| ball_not_empty | 0 | 0 | 2412337 |
| circumradius_too_large | 0 | 0 | 0 |
| degenerate | 0 | 0 | 0 |
| deepest intrusion / rho | 0.00e+00 | 0.00e+00 | 9.97e-01 |
| render: odd-parity pixels (holes seen through) | 22.21% | 29.60% | 59.08% |
| render: pixels with front ≠ back | 22.31% | 30.04% | 83.89% |

triangle sets against BPA.jl:

|  | common | same winding | only in BPA.jl | only in the other | edges of only-in-BPA.jl triangles present in the other (0/1/2/3) | edges of only-in-other triangles present in BPA.jl (0/1/2/3) |
|---|---|---|---|---|---|---|
| Open3D | 623277 | 623198 | 26241 | 1574 | 2143/11582/6881/5635 | 509/198/847/20 |
| MeshLab | 131273 | 110512 | 518245 | 2414359 | 220005/217097/75491/5652 | 2186987/175392/51352/628 |

renderings (`dragon62_r0.0007/render/`, view 30.0°):

|  | BPA.jl | Open3D | MeshLab |
|---|---|---|---|
| shaded, boundary edges in red | ![](dragon62_r0.0007/render/bpa.png) | ![](dragon62_r0.0007/render/open3d.png) | ![](dragon62_r0.0007/render/meshlab.png) |
| triangles behind each pixel: warm = odd (a hole is seen through), cool = even | ![](dragon62_r0.0007/render/bpa_depth.png) | ![](dragon62_r0.0007/render/open3d_depth.png) | ![](dragon62_r0.0007/render/meshlab_depth.png) |
| front-facing minus back-facing: grey 0, blue +, red − | ![](dragon62_r0.0007/render/bpa_signed.png) | ![](dragon62_r0.0007/render/open3d_signed.png) | ![](dragon62_r0.0007/render/meshlab_signed.png) |

input scans: ![](dragon62_r0.0007/render/input.png)

