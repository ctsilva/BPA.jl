diagonal switching of open3d towards BPA.jl

| case | common before | only BPA.jl / other | diagonal flips | common after flips | only BPA.jl / other | patch swaps | common after swaps | only BPA.jl / other | remaining other-only: edges in BPA.jl (0/1/2/3) | remaining on points the other never uses (BPA.jl-only / other-only) | edge-manifold |
|---|---|---|---|---|---|---|---|---|---|---|---|
| sphere2000 | 3996 | 0 / 0 | 0 | 3996 | 0 / 0 | 0 patches (0 tri) | 3996 | 0 / 0 | 0/0/0/0 | 0 / 0 | yes |
| plane40 | 3042 | 0 / 0 | 0 | 3042 | 0 / 0 | 0 patches (0 tri) | 3042 | 0 / 0 | 0/0/0/0 | 0 / 0 | yes |
| torus_r0.10 | 18670 | 530 / 530 | 265 | 19200 | 0 / 0 | 0 patches (0 tri) | 19200 | 0 / 0 | 0/0/0/0 | 0 / 0 | yes |
| torus_r0.05 | 18822 | 378 / 378 | 189 | 19200 | 0 / 0 | 0 patches (0 tri) | 19200 | 0 / 0 | 0/0/0/0 | 0 / 0 | yes |
| torus_jitter | 19200 | 0 / 0 | 0 | 19200 | 0 / 0 | 0 patches (0 tri) | 19200 | 0 / 0 | 0/0/0/0 | 0 / 0 | yes |
| torus_sampled20k | 40000 | 0 / 0 | 0 | 40000 | 0 / 0 | 0 patches (0 tri) | 40000 | 0 / 0 | 0/0/0/0 | 0 / 0 | yes |
| knot_r0.0188 | 35862 | 270 / 90 | 0 | 35862 | 270 / 90 | 0 patches (0 tri) | 35862 | 270 / 90 | 21/42/18/9 | 2 / 1 | yes |
| knot_r0.03 | 58292 | 108 / 34 | 0 | 58292 | 108 / 34 | 0 patches (0 tri) | 58292 | 108 / 34 | 0/21/13/0 | 0 / 0 | yes |
| bun000 | 77804 | 348 / 190 | 65 | 77934 | 218 / 60 | 0 patches (0 tri) | 77934 | 218 / 60 | 15/0/45/0 | 0 / 12 | yes |
| bunny4_r0.0008 | 236959 | 2082 / 245 | 2 | 236963 | 2078 / 241 | 0 patches (0 tri) | 236963 | 2078 / 241 | 68/30/141/2 | 0 / 40 | yes |
| bunny4_r0.0015 | 200634 | 2324 / 490 | 190 | 201014 | 1944 / 110 | 0 patches (0 tri) | 201014 | 1944 / 110 | 37/6/67/0 | 3 / 30 | yes |
| bunny10_r0.00125 | 317668 | 6266 / 307 | 73 | 317814 | 6120 / 161 | 0 patches (0 tri) | 317814 | 6120 / 161 | 86/7/68/0 | 0 / 82 | yes |
| dragon62_r0.0007 | 623277 | 26241 / 1574 | 0 | 623277 | 26241 / 1574 | 0 patches (0 tri) | 623277 | 26241 / 1574 | 509/198/847/20 | 10 / 440 | yes |
