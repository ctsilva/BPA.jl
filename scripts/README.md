# Test data scripts

Shell scripts that generate the synthetic meshes and download and convert the Stanford
range scans in `data/`. They are thin wrappers around `curl`, `tar` and the trimesh2
tools; the geometry (PLY to OFF conversion, quaternion to matrix) is done by trimesh2.

## Requirements

- **trimesh2** (`mesh_make`, `mesh_filter`, `mesh_shade`, `mesh_cat`, `xf`), from
  http://gfx.cs.princeton.edu/proj/trimesh2/ , with its build directory on `PATH`
- **curl** and **tar**

## Quick start

```bash
cd BPA.jl
export PATH=/path/to/trimesh2/build:$PATH

./scripts/generate_test_meshes.sh                     # data/torus-120-80.off, data/knot-300-100.off

./scripts/download_bunny.sh                           # prints the download and conversion steps
cd data/bunny/data && ../../../scripts/convert_bunny_scans.sh bun.conf && cd -

./scripts/download_dragon.sh                          # interactive: reconstruction, scans, or both
cd data/dragon/scans && ../../../scripts/convert_dragon_scans.sh && cd -
```

## Scripts

### generate_test_meshes.sh

Runs `mesh_make torus 120 80` and `mesh_make knot 300 100`, writing

- `data/torus-120-80.off`: 9,600 vertices, 19,200 triangles
- `data/knot-300-100.off`: trefoil knot, 30,000 vertices, 60,000 triangles

### download_bunny.sh

Prints the steps to fetch `bunny.tar.gz` (4.9 MB) from the Stanford 3D Scanning
Repository, extract it, and run `convert_bunny_scans.sh` on `bunny/data/bun.conf`.
Place the result under `data/bunny/` so that the scans are in `data/bunny/data/` and the
reference reconstruction in `data/bunny/reconstruction/`.

### download_dragon.sh

Downloads the Stanford dragon into `data/dragon/`. Interactive choice of the vripped
reconstruction (`dragon_recon.tar.gz`, 11 MB), the range scans (five archives, about
34 MB), or both. Scans and `.conf` files end up in `data/dragon/scans/`, the
reconstruction PLYs in `data/dragon/`. To run it unattended: `echo 3 | ./scripts/download_dragon.sh`.

### convert_bunny_scans.sh and convert_dragon_scans.sh

Run inside the directory holding the scans and `.conf` files. For every `bmesh` line of a
`.conf` file (`bmesh name.ply tx ty tz qx qy qz qw`) they

1. convert `name.ply` to `name.off` with `mesh_filter` (range scans keep their triangles,
   so `bpa.jl` derives vertex normals from them);
2. write `name.xf`, the 4×4 matrix mapping the scan into the common frame, with
   `xf -trans tx ty tz -v qx qy qz qw`. The effective convention is `v' = Rᵀ v + t` with `R`
   built from the VRIP quaternion; the resulting alignment was checked against Stanford's
   own reconstructions (median distance 0.5 mm for the bunny, 0.3 mm for the dragon);
3. produce a per-scan coloured, transformed copy and merge them all with `mesh_cat` into
   `combined.ply` / `dragon_combined.ply`, for checking the alignment in a viewer;
4. write the scan list files that `bpa.jl -f` reads.

The bunny script takes the conf file as its argument (`bun.conf`); the dragon script
processes every `.conf` in the directory, or the one given as argument. The header
comment of `convert_bunny_scans.sh` documents the `.xf` file format.

Output files:

| | bunny (`data/bunny/data/`) | dragon (`data/dragon/scans/`, lists in `data/dragon/`) |
| --- | --- | --- |
| scans | `bun*.off`, `chin.off`, `ear_back.off`, `top*.off` + `.xf` | `dragon*.off` + `.xf` (71) |
| combined view | `combined.ply` | `dragon_combined.ply` |
| lists | `bunny_scans.txt` (all 10), `bunny_main.txt` (4 body scans) | `dragon_scans.txt` (all 71), `dragon_scans_clean.txt` (62 surface scans, without the backdrop and clear-space carvers of `carvers.conf`), `dragon_subset.txt` (10) |

The `*_colored.ply` and `*_xformed.ply` intermediates are left in place and can be deleted.

## Datasets

| dataset | points | notes | radius |
| --- | --- | --- | --- |
| torus | 9,600 | closed, regular lattice | 0.1 |
| knot | 30,000 | tube nearly touches itself | 0.03 to 0.05 |
| bunny | 362,272 in 10 scans | real range scans, registered | 0.00125 |
| dragon | 1,826,038 in 62 clean scans | 71 scans; `carvers.conf` holds backdrop and clear-space planes that are not surface data | 0.0007 |

The Stanford scans overlap as layers a few tenths of a millimetre apart, so radii as small
as the paper's (0.3 to 0.5 mm) fragment the reconstruction; the paper's results came from
scans that had first been through a registration and conformance step.

## Running BPA on the converted data

```bash
julia bpa.jl -r 0.1 -i data/torus-120-80.off
julia bpa.jl -r 0.03 -i data/knot-300-100.off
julia bpa.jl -r 0.00125 -f data/bunny/data/bunny_scans.txt -o results/bunny_bpa.ply
julia bpa.jl -r 0.00125 -l bun000,bun045,bun090,bun180 -d data/bunny/data --max-seeds 1
julia bpa.jl -r 0.0007 -f data/dragon/dragon_scans_clean.txt -d data/dragon/scans -o results/dragon_r0.7mm.off
julia bpa.jl -r 0.1 -i data/torus-120-80.off -p 1000            # partial mesh every 1000 triangles
julia bpa.jl -r 0.1 -i data/torus-120-80.off --save-colored     # final mesh coloured by creation order
```

## Manual download

If the scripts fail, fetch the archives from the
[Stanford 3D Scanning Repository](http://graphics.stanford.edu/data/3Dscanrep/) and place
them as above: bunny scans in `data/bunny/data/`, dragon scans in `data/dragon/scans/`.
