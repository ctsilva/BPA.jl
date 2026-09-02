# Results

Default output directory of `bpa.jl`: without `-o`, `julia bpa.jl -i data/foo.off` writes
`results/foo_bpa.off` here (for scan lists, `<listfile>_bpa.off` or `merged_bpa.off`), and
`-p N` snapshots go next to it as `foo_bpa_<count>.off`. Everything in this directory is
regenerable from `data/` and is safe to delete.

| file | how it was made |
| --- | --- |
| `torus-120-80_bpa.off` | `julia bpa.jl -r 0.1 -i data/torus-120-80.off` |
| `torus-colored.ply` | same, with `--save-colored -p 2000`: one colour per 2000 triangles in creation order |
| `torus-sampled.obj` | `--sample 20000 -r 0.06,0.12`: 20,000 random surface samples of the torus mesh |
| `knot-300-100_bpa.off`, `knot-300-100_r0.05.ply` | the trefoil knot at radii 0.03 and 0.05 |
| `bun000_bpa.off` | one bunny range scan, `-r 0.00125` |
| `bunny_bpa.ply` | `julia bpa.jl -r 0.00125 -f data/bunny/data/bunny_scans.txt -o results/bunny_bpa.ply`: the 10 aligned scans merged (362,272 points), radius 1.25 mm |
| `merged_bpa.off` | `julia bpa.jl -r 0.00125 -l bun000,bun045,bun090,bun180 -d data/bunny/data --max-seeds 1`: four main scans, largest component only |

| `dragon_r0.7mm.off` | `julia bpa.jl -r 0.0007 -f data/dragon/dragon_scans_clean.txt -d data/dragon/scans -o results/dragon_r0.7mm.off`: 62 surface scans merged (1,826,038 points), 625,046 triangles, 172 components, 22 s |
| `dragon_bpa.ply` | same scans with the paper's radii `-r 0.0003,0.0005,0.001`: 1,826,343 triangles in 17 s, but 27,646 components and 567,255 boundary edges |

With the paper's radii the merged bunny (`-r 0.0003,0.0005,0.002`) and dragon are heavily
fragmented, because the raw scans overlap as layers a few tenths of a millimetre apart, the
same scale as the small radii (Section 3 of the paper). The authors ran a registration and
conformance step on the scans before BPA, which is not part of this package. Both dragon
files are large (about 250 MB each) and can be deleted.
