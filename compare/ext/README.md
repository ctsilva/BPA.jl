# Other Ball-Pivoting implementations

A survey of the Ball-Pivoting implementations that could be found on GitHub and the web
(2026-09-03), what each one actually does, and the wrappers that let the ones worth
running take part in the comparison in `compare/`. The code itself is fetched into
`compare/external/` (gitignored) by `build.sh`; `run_ext.py` converts the harness's NOFF
input into each tool's format and its output back into an OFF with the input vertex order.

```
cd BPA.jl/compare
sh ext/build.sh                          # clones, patches, builds into external/
julia -t 9 --project=.. compare.jl synthetic --tools digne,digne_par,gruber,gruber_reseed,bpa_rs,schmehla,giaccari
```

Needs cmake, a C++20 compiler, `cargo` (rustup.rs), Homebrew `glm`, and Homebrew `gcc` for
the OpenMP build of Digne (without it the serial build is used for both Digne entries).
`BPA_EXTERNAL` points the scripts elsewhere than `compare/external`.

## What was found

Every implementation was read against the paper (Bernardini et al. 1999): how seeds are
found, whether the pivot picks the candidate of smallest rotation angle, whether the
empty-ball test is enforced, how the front is managed, and whether it builds. Verdicts:

| implementation | language, license | the algorithm | verdict |
|---|---|---|---|
| [Digne, IPOL 2014](https://www.ipol.im/pub/art/2014/81/) | C++, GPL-3 | Octree; every orphan vertex is a seed candidate; exact reach radius for pivot candidates; smallest angle with the empty-ball test on each improving candidate (`rho^2 - 1e-16`); normals must agree; multi-radius; OpenMP over octree cells with a merge step. Always fills 3-cycles of border edges afterwards (no ball test), which the wrapper switches off. | **faithful, benchmarked** |
| [bernhardmgruber/bpa](https://github.com/bernhardmgruber/bpa) | C++20, BSL-1.0 | Uniform grid of 2ρ cells; the paper's front with join/glue; smallest angle, but the empty-ball test runs only on the winner (a non-empty winner makes the edge a boundary); one seed only, so one connected component; float32; the emptiness tolerance is an absolute `rho^2 - 1e-4`, vacuous below ρ = 0.01; far-side angles reflected as α+π instead of 2π−α. | runs, benchmarked with caveats |
| Gruber, reseeded (`gruber_reseed.patch`) | the same, patched here | Gruber's library with the seed search resumed after each front is exhausted, so that it grows one component per seed as the paper does. The search probes as BPA.jl's does: cells holding a used point are skipped (the paper's fig. 4c heuristic), one candidate per cell, nearest 100 neighbours paired. The pivot, the front and the float32 emptiness test are upstream's. | **faithful, benchmarked** |
| [martinfrances107/bpa_rs](https://github.com/martinfrances107/bpa_rs) | Rust, MIT | Port of Gruber, same behaviour and the same caveats. | runs, benchmarked with caveats |
| [schmehla/ball-pivoting-algorithm](https://github.com/schmehla/ball-pivoting-algorithm) | C++, MIT | Thesis code. The pivot intersects the circle of ball centres around the edge with a sphere of radius ρ about each neighbour and keeps the first contact over the full turn, which is the paper's pivot done geometrically; cospherical ties are kept together ("multi-rolling"); the empty-ball test is only an assertion, the neighbourhood (2ρ) makes it hold; the vertex-normal filter is commented out. Its post-processing overruns a stack buffer and is skipped by the build. | faithful pivot, no normal test, benchmarked |
| [Giaccari, Surface Reconstruction Toolbox](https://github.com/LuigiGiaccari/Surface-Reconstruction-Toolbox) | C++, GPL-3 | The author's mesh-growing framework (Di Angelo, Di Stefano, Giaccari 2011) in a "classical ball pivoting without point normals" mode: a priority-queue front; the candidate with the largest ball-centre angle inside a window around the current ball wins, among points inside the pivot torus; a dihedral cap (dot > −0.5) and a manifold-vertex check; points closer than mean spacing / 20 are removed first; post-processing (3-cycle filling, non-manifold repair) on by default. See "How Giaccari's code works" below. Its stopwatch ignored whole seconds, so `build.sh` patches it. | runs, benchmarked, not the paper's algorithm |
| [VCG `ball_pivoting.h`](https://github.com/cnr-isti-vclab/vcglib/blob/main/vcg/complex/algorithms/create/ball_pivoting.h) (MeshLab, PyMeshLab, Rvcg) | C++, GPL | Already in the comparison as MeshLab. 16-nearest-neighbour candidates, 0.2ρ clustering, seed edge lengths in [0.2ρ, 1.8ρ], no empty-ball test in the pivot, 90° dihedral cap, half-turn cap at π − 0.1. | in the comparison |
| [Open3D](https://github.com/isl-org/Open3D/blob/main/cpp/open3d/geometry/SurfaceReconstructionBallPivoting.cpp) | C++, MIT | Already in the comparison. Smallest angle with the empty-ball test (`< rho - 1e-16`), ball on the side of the summed vertex normals only, all three normals must agree. | in the comparison |
| [MATLAB `pc2surfacemesh`](https://www.mathworks.com/help/lidar/ref/pc2surfacemesh.html) | closed | Lidar Toolbox, ball-pivot method with automatic radii. | not available here |
| [rodschulz/BPA](https://github.com/rodschulz/BPA) (and its forks t-lou/bpa_remake, Tonsty) | C++/PCL, GPL-3 | Candidates within 2ρ, explicit empty-ball test, but the winner is the one with the smallest *unsigned angle to the opposite vertex* (`Pivoter.cpp:111-117`, marked `TODO fix point selection`), not the pivot angle. Needs PCL. | not the paper's pivot |
| [Sam-Schiffer/UnityBPA](https://github.com/Sam-Schiffer/UnityBPA) | C#, MIT | Port of rodschulz with a majority-vote normal test; same wrong selection. | not the paper's pivot |
| [Chen-Si-An/Mesh-Reconstruction](https://github.com/Chen-Si-An/Mesh-Reconstruction) | C++/CUDA, Visual Studio | rodschulz's code with GPU seed search. | not buildable here |
| [MIPAV `BallPivoting.java`](https://github.com/JaneliaSciComp/mipav) | Java | Line-by-line port of an older, grid-based VCG; the seed test was changed to `<= radius` including the triple itself, one seed, stops after 8192 faces. | incomplete |
| [K4ugummi/t00ls `ball-pivoting.ts`](https://github.com/K4ugummi/t00ls) | TypeScript, MIT | Empty-ball candidates, but the one nearest the edge axis wins, 1 % emptiness slack, no glue, triangle-soup output. | not the paper's algorithm |
| [Lotemn102/Ball-Pivoting-Algorithm](https://github.com/Lotemn102/Ball-Pivoting-Algorithm) (and DanniBot, ivyn, which derive from it) | Python | On the 2000-point sphere: 3142 of 3996 triangles, 1914 boundary edges, half the windings flipped. | not faithful |
| [Bend1031/BallPivotingPy](https://github.com/Bend1031/BallPivotingPy) | Python | A Python port of Digne's code (same octree, mesher, hole filling). Closed sphere; 10 000 points in 2.6 s. | works, slow, redundant with Digne |
| [EthanZyh/Ball-Pivoting](https://github.com/EthanZyh/Ball-Pivoting) | Python | 145 lines: smallest dihedral angle over grid neighbours, empty-ball test on seeds only, five-candidate seed truncation. Closed sphere; 2000 points in 3.7 s. | not faithful, slow |
| [rajgandhi1/threecrate](https://github.com/rajgandhi1/threecrate) | Rust | "Ball pivoting" with no ball: candidates within ρ of both edge ends, scored by triangle quality; each point can be a third vertex once. 1998 triangles on the sphere, all boundary. | not ball pivoting |
| [apluquet/Ball-Pivoting-Algorithm](https://github.com/apluquet/Ball-Pivoting-Algorithm) | C++ | Course project; scans all points per pivot, no empty-ball test; 316 triangles on the sphere. | toy |
| [tanmaybinaykiya/...](https://github.com/tanmaybinaykiya/Surface-Reconstruction-from-Point-Cloud-Data) | Processing | One hard-coded seed and radius, no empty-ball test in the pivot, no glue. | toy |
| [TasitenREL/High-performance-parallel...](https://github.com/TasitenREL/High-performance-parallel-processing-implementation-of-Ball-Pivoting-Algorithm-) | C | Enumerates all triples with a small circumradius on a 2-D projection, OpenMP/MPI over the outer loop, writes no mesh. | not ball pivoting |
| danielway, KapDecy (Rust), StarLxc3 (Python) | | Empty stubs. | stubs |

No other Julia implementation exists. CGAL, PCL, libigl, Geogram, trimesh, PyVista and
CloudCompare do not ship a ball pivot.

## Results

`summary.py` condenses the per-case reports into [`RESULTS.md`](RESULTS.md) (triangles,
times, components, boundary edges and empty-ball failures for every tool and case); the
full tables and renderings are in `../results/`. Run on 2026-09-04 on the same Apple
Silicon laptop as the rest of the comparison, one tool at a time. What they show:

- **Digne is the one external implementation that behaves like BPA.jl and Open3D
  everywhere.** Its triangle counts are within a few hundred of theirs on every case
  (631 174 on the dragon against 649 518 and 624 851) and it never produces a non-empty
  ball. It is slow: 82 s on the ten-scan bunny and 33 min on the dragon serially, 39 s
  and 23 min with 16 threads, against 1.6 s and 6.6 s for BPA.jl. The parallel version
  only gains 1.4× on the dragon because the merge and the border re-pivoting are serial.
  Like Open3D it fragments the scans into hundreds of components (1899 on the ten-scan
  bunny, 549 on the dragon) where BPA.jl has 17 and 101.
- **Gruber, reseeded, is the second faithful implementation and the closest to BPA.jl.**
  With the seed search resumed after every front (`gruber_reseed.patch`) it grows
  78 093 triangles on the single bunny scan against BPA.jl's 78 152, 323 224 against
  323 934 on the ten-scan bunny and 639 668 against 649 518 on the dragon, in the same
  time as upstream and as BPA.jl (1.4 s and 4.9 s against 1.6 s and 6.6 s). It leaves
  about twice the boundary edges of BPA.jl on the scans (1 718 against 806 on the
  ten-scan bunny, 24 103 against 13 434 on the dragon) and two to three times the
  components (35 against 17, 291 against 101), where Open3D and Digne leave ten times
  the edges and hundreds or thousands of components. Its non-empty balls, 52 on the
  ten-scan bunny and 485 on the dragon, are upstream's float32 absolute emptiness
  tolerance and shallow: BPA.jl, Open3D and Digne have none or single digits.
- **The fork of Gruber's code** (`~/src/bpa`, the "bpa fork" column; see its README for
  what changed: reseeding, the paper's pivot, seeds oriented by their vertex normals,
  double precision) matches BPA.jl on every case: identical triangle sets on the eight
  synthetic inputs, within 0.1 % on the scans (649 459 against 649 518 on the dragon),
  no non-empty ball anywhere, the same components on the ten-scan bunny and 103
  against 101 on the dragon, boundary edges within 6 %, and 4.4 s against 6.6 s on the
  dragon.
- **Several radii** (the `uneven` cases, 1 mm spacing on one half of a plane, a sphere and
  a torus and 2 mm on the other, radii 1.5 mm then 3 mm). Only BPA.jl, Open3D, Digne and
  the fork take a radius list; the others show n/a. All four close the sphere and cover
  the plane as one disk. On the torus BPA.jl and the fork close it with every point used,
  while Open3D and Digne leave 18 boundary edges along the seam and Digne's parallel mode
  30: their second pass does not resume everywhere the first one stopped.
- **Gruber and bpa_rs as published are as fast as BPA.jl but seed once.** On the synthetic surfaces
  and the four-scan bunny their single front reaches nearly everything and the output
  matches; on the single bunny scan it stops at 1631 triangles and on the dragon at one.
  Their absolute float32 emptiness tolerance shows as a handful of shallow non-empty
  balls on the scans even with the input rescaled.
- **Schmehla** is a correct pivot on clean data (every synthetic case except the regular
  torus lattice, where it hangs on the cospherical quads) but its seed search fails on
  scans: 134, 10, 201, 0 and 5 triangles on the bunny and dragon cases.
- **Giaccari** is the fastest (1.0 s on the ten-scan bunny, 4.3 s on the dragon) and
  fine on single surfaces, but without normals it meshes every overlapping scan layer as
  its own sheet: 541 000 triangles on the ten-scan bunny and 1.37 million on the dragon,
  of which 214 000 and 756 000 fail the outward empty-ball test.

## How Giaccari's code works

`MeshGrowing.cpp` is the advancing-front framework of the SCB mesher (Di Angelo, Di Stefano
and Giaccari, CAD 2011) with a ball-pivoting mode bolted on, and it is built for speed:

- Everything is flat arrays of ints and doubles, preallocated once (`3.2 N` edges), with a
  point-to-edge map instead of edge objects, sets or lists. The search structure is a
  uniform bucket grid with cell size ρ and linked-list buckets, so a query touches a
  handful of cells and allocates nothing; its empty-ball query returns at the first
  violator (`SDS3D.cpp`).
- Two-level priority queue of front edges. Every edge is first tried with the *search
  radius* strategy (`GetTriangle_BPA_SR`): a sphere of about 0.8 edge lengths is placed
  where the third vertex of a near-equilateral triangle would be, and the **first** point
  in it whose ρ-ball through the edge is empty is accepted, with no angle computation and
  no ordering of candidates. That resolves 97 % of the edges on the ten-scan bunny
  (555 054 of 574 446 pivots). Only the edges it fails are pushed back at lower priority
  and retried with the *torus* strategy (`SelectCandidate_BPA_Torus`): all points inside
  the pivot torus, the largest ball-centre angle inside a window around the current ball
  wins, and there the empty-ball test is compiled only in debug builds.
- Acceptance is a check that the two other edges are not already closed and are
  consistently oriented (`CheckEdgeConformity`), a dihedral cap (dot with the previous
  triangle normal above −0.5 for torus pivots, above 0 for search-radius ones), and a
  non-manifold-vertex counter. There is no glue step and no normal input.
- Pre-processing removes points closer than mean spacing / 20; post-processing fills
  3-cycles of boundary edges and deletes triangles at non-manifold vertices.

The consequence is what the tables show: on the ten-scan bunny it builds 541 000
triangles in 1.0 s where BPA.jl builds 324 000 in 1.6 s, but 214 000 of them fail the
harness's empty-ball test on the outward side, with intrusions up to 0.99 ρ. Without
normals the ball can only be placed on the side of the triangle's winding, which the
propagation decides, so between overlapping scan layers it accepts balls that are empty on
the inner side while the outward ball is full; and the torus fallback does not test
emptiness at all.

## Licenses

This repository is MIT-licensed, but the patch files here inherit the license of the code
they modify, since they quote it: `digne_main.patch` is GPL-3 like Digne's IPOL code, and
`gruber_reseed.patch` is BSL-1.0 like Gruber's. The wrappers (`run_ext.py`,
`gruber_noff2off.cpp`, `bpa_rs_noff2off/`) are ours and MIT. No third-party source is
committed: `build.sh` fetches it into the gitignored `external/`, and the outputs in
`../results/` are data, not covered by the tools' licenses.

## The wrappers

`run_ext.py TOOL input.noff rho output.off` handles the conversions:

- **digne, digne_par**: the input body as `x y z nx ny nz` lines; the PLY output renumbers
  vertices in order of first use, so they are matched back to the input by position (the
  16-digit output round-trips exactly). `digne_main.patch` replaces the whole-second
  timers with `std::chrono` and adds `-n`, which skips the hole filling so that the
  output is the pivot's alone. `-p` is the OpenMP mode.
- **gruber, bpa_rs**: `gruber_noff2off.cpp` and `bpa_rs_noff2off/` read the NOFF, call the
  library and map the returned positions to input indices by their float bit patterns.
  Both are given the input scaled so that ρ = 1, because their emptiness tolerance is
  absolute (`rho^2 - 1e-4` in float32).
- **gruber_reseed**: the same driver linked against a copy of `bpa.cpp` with
  `gruber_reseed.patch` applied (`build.sh` makes the copy; the upstream binary is
  untouched). The patch replaces `findSeedTriangle` and wraps the main loop of
  `reconstruct` in `while (seed = findSeedTriangle(...))`; nothing else changes. The
  first version of the patch kept upstream's seed probe (every unused point of every
  cell, all pairs of its 2ρ neighbourhood) and took 34.5 s on the ten-scan bunny, all of
  it in probes of points under already reconstructed sheets; bounding the pairs to the
  nearest 100 halved that, and skipping cells with used points brought it to 1.4 s.
- **schmehla**: OBJ with `v`, `vn` and `p i//i` lines; its output OBJ keeps the input
  vertices in order. Its timer prints whole seconds, so the wall time is used.
- **giaccari**: `.cgo` (a count, then `x y z` lines; normals are not read); binary STL
  back, matched by float32 position. `-pa 0` stops it waiting for a key press.

The time captured is the tool's own reconstruction time where it reports one below a
second (Digne after the patch, Gruber, bpa_rs, Giaccari), else the process wall time.
