# Tools

Small standalone scripts for looking at reconstructions. They need only Julia's standard
library and run from the package directory without `--project`.

## render.jl

Renders a mesh to an image and, alongside it, two images that count what lies behind each
pixel. Useful for finding the holes and duplicate layers that the summary numbers only hint at.

```
julia tools/render.jl mesh.off [out.ppm] [ANGLE]
julia tools/render.jl -f scans.txt [-d DIR] [out.ppm] [ANGLE]
```

- `mesh.off`: an OFF, NOFF or COFF file; only the positions and faces are used.
- `-f scans.txt`: instead of one mesh, the range scans named in a list file (one per line,
  `#` comments), merged into one mesh. Each `<name>.off` is read with its faces from `DIR`
  (`-d`, default: the list file's directory) and moved by `<name>.xf` when that file exists.
  This is the same list format the command line tool takes.
- `out.ppm`: default is the mesh's (or list's) name with a `.ppm` extension, next to it.
- `ANGLE`: rotation about the vertical axis in degrees, default 30. The elevation is fixed
  at 15 degrees, and the projection is orthographic.

Three images are written, all 1400×1000 binary PPM:

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
