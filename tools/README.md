# Tools

Small standalone scripts for looking at reconstructions. They need only Julia's standard
library and run from the package directory without `--project`.

## render.jl

Renders a mesh to an image and, alongside it, two images that count what lies behind each
pixel. Useful for finding the holes and duplicate layers that the summary numbers only hint at.

```
julia tools/render.jl mesh.off [out.ppm] [ANGLE] [--no-edges] [--size WxH]
julia tools/render.jl -f scans.txt [-d DIR] [out.ppm] [ANGLE] [--size WxH]
```

- `mesh.off`: an OFF, NOFF or COFF file. A COFF file's per-vertex colours (as `bpa.jl`
  writes with `--save-colored` or `-p`) are used for the shading, each triangle taking the
  colour of its first vertex; otherwise the mesh is drawn in a single colour.
- `--no-edges`: leave the boundary edges undrawn, for a picture rather than a diagnosis.
- `--size WxH`: image size, default 1400x1000; a larger size lets a detail be cropped at
  full resolution afterwards (the dragon pictures in the package README are a 2800x2000
  rendering cropped to the figure, since its bounding box includes the turntable).
- `-f scans.txt`: instead of one mesh, the range scans named in a list file (one per line,
  `#` comments), merged into one mesh. Each `<name>.off` is read with its faces from `DIR`
  (`-d`, default: the list file's directory) and moved by `<name>.xf` when that file exists.
  This is the same list format the command line tool takes.
- `out.ppm`: default is the mesh's (or list's) name with a `.ppm` extension, next to it.
- `ANGLE`: rotation about the vertical axis in degrees, default 30. The elevation is fixed
  at 15 degrees, and the projection is orthographic.

Three images are written, binary PPM, 1400×1000 unless `--size` says otherwise:

| file | contents |
|---|---|
| `out.ppm` | flat-shaded mesh with boundary edges drawn in red on top |
| `out_depth.ppm` | number of triangles behind each pixel |
| `out_signed.ppm` | front-facing minus back-facing triangles behind each pixel |

On macOS `sips -s format png out.ppm --out out.png` converts them for viewing.

**Reading the depth image.** A closed surface covers every pixel an even number of times,
so for a reconstruction the image colours odd counts on a warm ramp (yellow to dark red) and
even counts on a cool one (light blue to navy). Odd pixels are holes seen through, including
holes on the far side that the red edges hide; a local jump of one or two is a patch
sitting on a second layer of points. For a scan list every sheet is open and parity means
nothing, so a single ramp (pale yellow, orange, dark purple) shows how many scans cover each
part of the surface. The reconstruction ramp saturates at 16 layers, so colours mean the same
across meshes; the scan ramp saturates at the 99th percentile of the counts present (the
dragon stacks up to 98 layers), and the value used is printed with the histogram.

**Reading the signed image.** For a closed, consistently oriented surface seen from outside
the difference is zero everywhere (grey). Through a hole in the near wall one sees the inside
of the far wall, giving −1 (red); through a hole in the far wall one sees the near wall
alone, giving +1 (blue). A flipped patch shows as ±2. For a scan list it is the number of
scans that saw the near side minus the number that saw the far side.

The terminal gets a histogram of the counts, the total of odd pixels, and the nonzero
signed values, so two meshes can be compared without opening the images.

Pixel centres are sampled exactly, with a top-left rule for centres that fall on a shared
edge, so a pixel is counted once per triangle and the counts are exact. The shaded image
uses a painter's sort by triangle centroid, which is good enough for viewing but is not a
depth buffer.

**Example.** The merged bunny at radius 0.00125 and the ten scans that went into it:

```
$ julia tools/render.jl results/bunny_bpa.off
  odd pixels (holes seen through): 15771 (3.92%)
$ julia tools/render.jl -f data/bunny/data/bunny_scans.txt
  odd pixels (holes seen through): 201286 (50.11%)
```

The dragon's list files sit one directory above its scans, so that one needs `-d`:

```
julia tools/render.jl -f data/dragon/dragon_scans_clean.txt -d data/dragon/scans
```

The frame is set by the bounding box of everything rendered, so a scan that includes the
turntable or stray points shrinks the object in the image; `dragonToes3_0` does this for the
dragon, and a list without it gives a larger view.

The reconstruction is two layers almost everywhere, four where the ears cross the head; its
odd pixels are the four unscanned patches under the feet plus a scattering of single
missing triangles. The scans have seven or eight layers behind a typical pixel, which is the
overlap that the reconstruction collapses into one surface and the reason fewer than half
of the input points end up in the mesh.

## check.jl

Topology report and empty-ball audit of a mesh file, from this package or any other tool:

```
julia tools/check.jl mesh.off [-i cloud] [-r RADIUS]
```

Prints the triangle and vertex counts, whether the mesh is orientable, edge-manifold and
vertex-manifold, its Euler characteristic, the components with the size of the largest and
the number of tiny ones, and the boundary edges with a histogram of the loops by size (at
most 10 edges, 11–50, 51–200, larger), which is what tells a mesh with a few large holes
from one riddled with small ones. With `-r`, the ball radius of the reconstruction, every
triangle is audited for the defining property of the BPA, an empty ball of that radius
through its vertices on the outward side, and counted as `valid`, `valid_reversed_winding`,
`ball_not_empty_tie` (a cospherical tie), `ball_not_empty` (with the deepest intrusion),
`circumradius_too_large` or `degenerate`. A BPA output is all `valid`; the triangles that
`--fill-loops` adds, or another tool's departures from the algorithm, show up in the other
classes. The outward side is taken from the normals of `-i`, a point cloud with the same
vertices in the same order (`.off`, `.xyz` or `.ply`), or from the mesh itself when it is a
NOFF file; a mesh with no normals is audited on both sides of each triangle.

`bpa.jl --check` prints the same report on a fresh reconstruction.

```
$ julia tools/check.jl results/knot-300-100_bpa.off -i data/knot-300-100.off -r 0.03
mesh: results/knot-300-100_bpa.off (30000 vertices, 58400 triangles)
cloud: data/knot-300-100.off
triangles: 58400, vertices used: 29208 of 30000
orientable: yes, edge-manifold: yes, vertex-manifold: no, Euler characteristic: -23
components: 1 (largest 58400 triangles)
boundary edges: 62 in 16 loops (16 of at most 10 edges, 0 of 11-50, 0 of 51-200, 0 larger; largest 7 edges)
empty-ball audit at rho = 0.03: valid 58400
```

## sweep.jl

One reconstruction per radius, as a table, for choosing the radius by measurement rather
than by guessing from the sample spacing:

```
julia tools/sweep.jl -i cloud.off -r 0.05,0.1,0.2
julia tools/sweep.jl -f scans.txt -d DIR
```

The input options are those of `bpa.jl` (`-i`, `-l`, `-f`, `-d`, `--estimate-normals`,
`--orient-normals`, `--knn`, `--max-seeds`, `--seed-neighbors`, `--min-component`,
`--sample`, `--seed`). Without `-r` the radii are 1.5, 2, 3 and 4 times the estimated
spacing. Each radius is a separate single-pass run; no mesh is written. The columns are the
time, the triangles, the points used, the seeds, the connected components, the boundary
edges and the pivots rejected by the normal test. Read it as: the radius where the points
used stop rising and the components stop falling is the smallest one that walks the whole
surface; past it the boundary edges keep falling while detail is lost.

```
$ julia tools/sweep.jl -i armadillo_o3d.off
input: armadillo_o3d.off (20000 points)
estimated sample spacing: 0.6505034783508097; radii at 1.5, 2.0, 3.0, 4.0 times it
      radius   time s  triangles       used  seeds  comps  boundary  rej.norm
    0.975755     0.03      17526      17782   2013    871     16782      1941
     1.30101     0.04      28351      19279    285     27     12883      3592
     1.95151     0.07      34585      18969     35      5      5989      4748
     2.60201     0.08      32588      17768     24      8      5202      4647
```
