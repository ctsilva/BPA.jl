# BPA.jl: design and algorithm notes

This document explains how the package implements the Ball-Pivoting Algorithm (BPA) of
Bernardini, Mittleman, Rushmeier, Silva and Taubin (IEEE TVCG 5(4), 1999). It is written for
someone who wants to read or modify the code; the README covers usage. Section numbers and
figure numbers refer to the paper.

Contents

1. [Overview and data flow](#1-overview-and-data-flow)
2. [Conventions](#2-conventions)
3. [Data structures](#3-data-structures)
4. [The algorithm step by step](#4-the-algorithm-step-by-step)
5. [Why the output is an orientable manifold](#5-why-the-output-is-an-orientable-manifold)
6. [Complexity and memory](#6-complexity-and-memory)
7. [Choices the paper leaves open](#7-choices-the-paper-leaves-open)
8. [Map from the paper to the code](#8-map-from-the-paper-to-the-code)
9. [Extending the implementation](#9-extending-the-implementation)
10. [Glossary](#10-glossary)

## 1. Overview and data flow

The input is a `PointCloud`: sample positions `σ_i` and unit normals `n_i`, the normals
pointing to the outside of the surface. The output is a `BPAMesh`: a list of triangles, each
a triple of point indices, interpolating a subset of the points.

```
reconstruct(cloud, radii)
  for each radius ρ (ascending):
      VoxelGrid(positions, 2ρ)              grid.jl       spatial index for this pass
      reactivate!(state)                    reconstruct.jl  (passes 2..n only)
      run_pass!(state)                      reconstruct.jl  the loop of Fig. 5
          get_active_edge!                  front.jl
          ball_pivot                        pivot.jl + geometry.jl
          join! / glue!                     front.jl
          find_seed_triangle!               seed.jl + geometry.jl
```

The `Front`, the triangle list and the statistics survive across passes; the grid and the
radius are rebuilt for each pass.

## 2. Conventions

**Indices.** Points are referred to by their 1-based index into `cloud.positions`. The
paper's `σ_i` is `P[i]` and `n_i` is `N[i]` in the code.

**Triangle orientation.** A triangle `(a, b, c)` is stored counter-clockwise when seen from
outside, i.e. `(P[b] - P[a]) × (P[c] - P[a])` has a positive dot product with the vertex
normals. A seed triangle has passed this test against all three of its vertex normals
(`orientation_consistent` in `geometry.jl`); a pivot triangle inherits its winding from the
front edge and is tested only against the normal of the new point, with a zero dot product
accepted (`pivot_orientation_consistent`), so that points without a normal and the steep
triangles joining overlapping scans are not refused.

**Front edge orientation.** A front edge `e(i,j)` has the same direction as the half-edge
`i → j` of the single triangle `(i, j, o)` that owns it. Pivoting `e(i,j)` onto a point `k`
creates the triangle `(i, k, j)`, whose half-edges are `i → k`, `k → j` and `j → i`. The last
one is the reverse of the front edge, so the two triangles sharing the edge `{i, j}` are
consistently oriented, and the two new front edges are `e(i,k)` and `e(k,j)`. This is exactly
the `join` of Fig. 6, and it means `glue` only ever meets pairs of *opposite* edges.

**Ball side.** For a triangle `(a, b, c)` with outward normal `n`, the ball centre is
`circumcentre + h n` with `h = sqrt(ρ² - R²)`, `R` the circumradius (`ball_center`). The ball
therefore always sits on the outside of the surface, which is where a ball rolling on the
outside of a solid object would be.

## 3. Data structures

### `PointCloud` (`types.jl`)

Two vectors of `SVector{3,Float64}`. Normals are normalised on construction. Nothing is
ever removed or reordered, so indices in the output refer to the input as given.

### `VoxelGrid` (`grid.jl`, Section 4.1)

A uniform grid of cubic cells of side `δ = 2ρ`. The point indices are bucket-sorted so that
the points of one cell are contiguous in `sorted`, and `cell_start[s]:cell_start[s+1]-1`
delimits cell (slot) `s`. The positions are copied into the same order
(`sorted_positions[t] == positions[sorted[t]]`), so that scanning a cell reads memory
sequentially; the queries take distances from that copy and touch `sorted` only for the
points that pass, which matters once the point array no longer fits in cache. Two queries
are built on this:

- `neighbors!(buf, grid, p, r)`: all points within `r ≤ δ` of `p`, scanning the 27 cells
  around `p`'s cell. With `r ≤ δ` any point within `r` of `p` is at most one cell away
  along each axis, so the 3×3×3 block is exhaustive.
- `empty_ball(grid, c, ρ, e1, e2, e3)`: is the open ball of radius `ρ` at `c` free of points
  other than `e1, e2, e3`? Same 27-cell scan with early exit; the cell containing `c` is
  scanned first (`SCAN_ORDER`), because an intruding point is most likely there.

When `ρ` is so small that the bounding box would need many more cells than there are points,
the grid becomes *sparse*: only non-empty cells receive a slot, looked up through a
dictionary keyed by integer cell coordinates. Both layouts are hidden behind `slot`,
`slot_range` and `cell_range`.

### `FrontEdge` and `Front` (`types.jl`, `front.jl`, Section 4)

A `FrontEdge` stores the endpoints `i, j`, the opposite vertex `o`, the ball centre
`c_ijo`, the loop links `prev`/`next`, a status (`ACTIVE`, `BOUNDARY`, `FROZEN`) and an
`alive` flag. Edges are never deleted from the `edges` vector; removal sets `alive = false`
so that ids stored in the queue and in loop links remain valid.

The `Front` adds:

| field | purpose |
| --- | --- |
| `queue`, `qhead` | FIFO of active edge ids; stale ids are skipped on pop |
| `out_head[v]`, `out_next[id]` | chain of the live edges leaving `v`: `edge_id(v, w)` walks it, a scan of the one or two edges a front vertex has |
| `front_count[v]` | number of live edges at vertex `v`; `on_front(v)` is `> 0` |
| `used[v]` | `v` belongs to the mesh; `not_used(v)` is its negation |
| `closed_head[a]`, `closed_to[r]`, `closed_next[r]` | chain, per smaller endpoint `a`, of the undirected edges `{a, w}` that already have two triangles: `is_closed(a, w)` walks it |

The chains replace a dictionary of directed edges and a set of closed edges. On the merged
bunny that is 8% of the running time, but on the 62 dragon scans it is 30%: with 1.8
million points the hash tables no longer fit in cache, and every insertion, removal and
manifoldness test stalled on memory, whereas a chain walk touches one or two entries next
to data the pivot has just used.

A vertex with `used[v]` and `front_count[v] == 0` is *interior*: its fan of triangles is
closed and no further triangle may use it (Section 4.4, case 1).

The loop links are maintained faithfully (Fig. 7) but the in-core algorithm never reads
them; they exist for diagnostics (`loops`) and as the hook for the out-of-core extension.

### `BPAState` (`seed.jl`)

The working state of a pass: the cloud, the grid, `ρ`, the shared front, triangle list and
statistics, the persistent seed-search cursor, a scratch buffer reused by every spatial
query so that pivoting does not allocate, and the option `seed_neighbors` (Section 4.2).

## 4. The algorithm step by step

### 4.1 Main loop (`run_pass!`, Fig. 5)

```
loop
    while an active edge e(i,j) can be popped from the queue
        (k, c) = ball_pivot(e)                                  Section 4.3
        if k found, the triangle (i,k,j) agrees with the normals,
           k is unused or on the front, and the triangle keeps the mesh a manifold
            output (i, k, j); join!(e, k, c)                    Section 4.4
        else
            mark e as boundary
    seed = find_seed_triangle!()                                Section 4.2
    seed found ? output it and add its three edges : return
```

The comments in `run_pass!` give the line numbers of Fig. 5 for each statement. The three
tests between `ball_pivot` and `join!` are the "necessary error tests" the figure omits for
readability. Each failure is counted separately in `BPAStats`, so the origin of holes in an
output can be diagnosed.

### 4.2 Seed selection (`find_seed_triangle!`, `try_seed`, Section 4.2)

The search walks the grid cells from a cursor that persists between calls, so cells are
examined once per pass in total. A cell is skipped if it is empty or if any of its points is
already used (the paper's heuristic against spawning small spurious components next to the
main surface, Fig. 4c). Otherwise a single candidate point is taken from the cell: the point
that projects furthest along the average normal of the cell's points, so that the ball can
be seated on it from the outside.

`try_seed(σ)` gathers the points within `2ρ` of `σ`, drops interior vertices, sorts by
distance, keeps the nearest `seed_neighbors` of them (100 by default; `-1` keeps all, which
is the paper's unbounded search), and tries pairs `(a, b)` in that order:

1. Orient `(σ, a, b)` so that its normal agrees with all three vertex normals; if neither
   winding agrees, skip the pair.
2. `can_add_seed`: none of the vertices is interior, none of the three half-edges already
   exists on the front with the same orientation, and none of the undirected edges is closed.
3. `ball_center` must exist (circumradius `≤ ρ`) and `empty_ball` must hold.

The first pair that passes yields the seed. On success the cursor stays on the same cell,
which now contains used points and will be skipped at the next call. If no cell yields a
seed the pass ends.

The bound on the pair loop is a heuristic the paper does not specify. Almost all of the
seed search's work is spent on probes that fail: on the merged bunny scans 733 of 739
probes are points lying under a sheet that is already reconstructed, where every pair fails
the empty-ball test, and each probe pairs about 140 neighbours quadratically. A valid seed
triangle's other two vertices are almost always among the closest points of `σ`: keeping
the nearest 100 reproduces the unbounded output triangle for triangle on every dataset in
`data/` (bunny, all 62 dragon scans, torus, knot, sphere), at 5.0 s instead of 7.6 s for
the dragon; 60 loses three isolated seed triangles on the dragon, 30 changes three on the
bunny and 15 changes eight. A stronger heuristic, rejecting a probe when the ball tangent to
`σ` along its normal contains used points, was measured and dropped: it rejects 733 of the
739 probes but also 12 of the 17 genuine seeds.

### 4.3 Ball pivoting (`ball_pivot`, `pivot_frame`, `pivot_angle`, Section 4.3, Fig. 2)

Given the edge `e(i,j)` with ball centre `c_ijo`, the ball is constrained to stay in contact
with `σ_i` and `σ_j`, so its centre moves on the circle `γ` of radius `r = |c_ijo - m|`
around the edge midpoint `m = (σ_i + σ_j)/2`, in the plane perpendicular to the edge.
`pivot_frame` builds an orthonormal frame for that plane:

- `a = (σ_j - σ_i) / |σ_j - σ_i|`, the edge direction (rotation axis),
- `u = (c_ijo - m) / r`, pointing at the current centre,
- `v = a × u`, the direction in which the centre starts to move.

With the orientation convention of Section 2 the choice `v = a × u` moves the ball *away*
from the opposite vertex `o`: the tests check `dot(c_ijo - σ_o, v) > 0` on random
triangles. The trajectory is `γ(θ) = m + r (cos θ u + sin θ v)`.

For a candidate point `x`, `pivot_angle` finds the smallest `θ ≥ 0` with `|γ(θ) - x| = ρ`.
Writing `d = x - m` with components `d_u = d·u`, `d_v = d·v` (the component along `a` only
shifts the constant), expanding `|γ(θ) - x|² = ρ²` gives

```
d_u cos θ + d_v sin θ = K,     K = (r² + |d|² - ρ²) / (2r).
```

With `(d_u, d_v) = R (cos φ, sin φ)` this is `cos(θ - φ) = K / R`, so there is no contact
if `|K| > R`, and otherwise `θ = φ ± arccos(K/R)` (mod 2π). The smaller of the two angles is
the first contact. Because the initial ball is empty, `x` starts outside the ball, so the
first contact is also the moment the ball's surface reaches `x`. A solution with `θ ≈ 0`
means `x` touches the initial ball already: it is an immediate hit if the ball is moving
into `x` (`dot(γ(0) - x, v) < 0`) and is ignored otherwise, in which case the other root,
where the ball comes back to `x` from the far side, is used. This is what happens for the
opposite vertex `o`: the ball returns to it when it reaches the mirror-image ball through
`σ_i, σ_j, σ_o` on the other side of the surface, after roughly half a turn when the ball
starts well above the triangle, and only close to a full turn when the triangle's
circumradius is near `ρ`. `o` therefore stays a candidate in `ball_pivot`; if it is the
first point reached the pivot fails, since accepting any later point would leave `o`
inside the new ball.

Both roots have to be tested for "touching": a root that is mathematically 0 can come out
of `mod2pi` as a tiny negative number wrapped to just below 2π. Testing only the smaller
root let the ball pass through a touching point and produce a triangle whose ball was not
empty; the regular-lattice tests in `test/test_reconstruct.jl` guard against this.

**Without trigonometry.** `pivot_angle` is the reference formulation and is what the tests
check against brute force, but `ball_pivot` never needs the angle itself, only the order of
the candidates' first contacts. `pivot_contact` solves the same equation as the
intersection of a line with the circle of the centre, in the 2-D coordinates `(x, y)` of
the pivot plane (centre `= m + x u + y v`): the contact condition is the line
`d_u x + d_v y = r K`, whose intersections with the circle of radius `r` are
`F ± h (-d_v, d_u) / R` with `F = (r K / R²)(d_u, d_v)` the foot of the perpendicular from
the origin and `h = r sqrt(1 - (K/R)²)` the half-chord. The `+` root is `θ = φ + α` and the
`-` root `θ = φ - α`; the touching rule above is applied to the same roots
(`touching(c, r)` is `x > 0` and `|y| < r sin θeps`), and the result is a `Vec2` contact.
Two contacts are ordered by `angle_less`: an angle in `[0, π)` precedes one in `[π, 2π)`
(`lower_half` reads the sign of `y`), and within one half the sign of the cross product
`p × q` decides. `angle_tie` bounds the angular difference through
`r² sin Δ = p × q` and `r² cos Δ = p · q`, and refuses to pair two contacts on either side
of angle 0, which are numerically 2π apart just as in the angle formulation. On the bunny
this halves the time of the pivot loop, with identical output.

`ball_pivot` evaluates this for every point within `r + ρ` of `m` except `i` and `j` (a
point farther away is never touched; the query radius carries a relative margin of `1e-8`
so that the `1e-9` tolerance of the contact test cannot admit a point the query excludes)
and returns the point with the smallest angle together with its centre, `m + x u + y v`.

**Simultaneous hits.** On regularly sampled data several points are hit at exactly the same
angle: the four corners of a quad on a lattice are cospherical (on a torus lattice each quad
is an isosceles trapezoid). All of them are legitimately "first", but the choice must be
made so that later pivots into the same cospherical polygon agree with it. `ball_pivot`
therefore collects every candidate within `TIE_TOLERANCE` of the smallest angle and ranks
them with `tie_score`: candidates whose triangle would be rejected (normal test, interior
vertex, non-manifold edge) score 0, the others score 1 plus the number of new edges that
glue to an existing front edge; the lowest index breaks remaining ties. The first pivot into
a cospherical polygon fixes a diagonal; every later pivot into it then has exactly one
valid candidate.

### 4.4 Join and glue (`join!`, `glue!`, Section 4.4, Figs. 6 and 7)

`join!(e(i,j), k, c)`:

1. remove `e(i,j)` from the front and record `{i, j}` in `closed`;
2. insert `e(i,k)` (opposite vertex `j`) and `e(k,j)` (opposite vertex `i`), both with the
   new centre `c`, and splice them into the loop where `e(i,j)` was;
3. for each new edge, if the front holds the opposite edge `e(k,i)` or `e(j,k)`, `glue!`
   the pair.

`glue!(e1 = (i,k), e2 = (k,i))` removes both edges, records `{i, k}` in `closed`, and
repairs the loop links. Writing `p1, n1` for the neighbours of `e1` and `p2, n2` for those
of `e2`:

| case (Fig. 7) | condition | relink |
| --- | --- | --- |
| (a) two-edge loop | `n1 == e2` and `n2 == e1` | nothing (the loop vanishes) |
| (b) consecutive | `n1 == e2` (or `n2 == e1`) | `p1 → n2` (or `p2 → n1`) |
| (c) same loop, apart | otherwise | `p1 → n2`, `p2 → n1` (the loop splits) |
| (d) different loops | otherwise | `p1 → n2`, `p2 → n1` (the loops merge) |

Cases (c) and (d) need the same surgery; whether it splits or merges depends only on
whether the two edges were on the same loop, which the code does not need to know.

`can_add_triangle(i, k, j)` is evaluated before the join and rejects the triangle if `k` is
interior, if `(i,k)` or `(k,j)` already exists on the front with the same orientation, or if
`{i,k}` or `{k,j}` is closed.

### 4.5 Multiple passes (`reactivate!`, Section 4.6)

For each radius after the first, every live edge (they are all boundary edges at that point)
is tested as a seed for the new radius: the ball of the new radius touching `σ_i, σ_j, σ_o`
on the outside must exist and be empty. If so, the edge gets the new centre, becomes active
and is queued. Pivoting then resumes, and the seed search for the new radius follows once
the queue empties. Rebuilding the grid with the larger `δ = 2ρ` keeps the 27-cell queries
valid.

### 4.6 Dropping small components (`drop_small_components!`)

With `min_component = n > 1`, after the last pass every connected component with fewer than
`n` triangles is removed from the output. A seed whose front dies at once leaves a fragment
of three to seven triangles, typically a triangle seated on a second layer of an
overlapping scan; on the merged bunny 16 of the 17 components are such fragments, on the 62
dragon scans 81 of 98. The components are found by union-find over the triangles' vertices,
and the boundary count is corrected without recounting: a boundary edge belongs to exactly
one triangle, so the live front edges whose origin lies in a dropped component are exactly
the boundary edges that disappear. Off by default; the paper keeps everything.

## 5. Why the output is an orientable manifold

- **Orientable.** A half-edge `i → j` enters the mesh only through `join!` (as `j → i`,
  `i → k`, `k → j`) or `add_seed!`. `can_add_triangle`/`can_add_seed` refuse a half-edge that
  is already on the front with the same direction, and refuse any edge that is already
  closed. Hence every undirected edge carries at most two half-edges and they are opposite.
- **Edge-manifold.** The same test bounds the number of triangles per edge by two.
- **Vertex-manifold at the end.** An interior vertex is never reused (`is_interior`), and the
  `outward` normal test keeps the ball on one side of the surface. A vertex may temporarily
  belong to several front loops (the paper's "constant number of loops"); the checks in
  `check_mesh` (`src/check.jl`) confirm that on the test surfaces every vertex ends with a single
  fan.
- **Termination.** Each pivot either removes an edge (join) or marks it boundary; each seed
  uses at least one new point. Both are finite.

## 6. Complexity and memory

With bounded sampling density (a bounded number of points per voxel), a pivot scans 27
voxels, i.e. O(1) points, and each edge is pivoted once per pass, so a pass is O(n) plus the
grid construction, which is a counting sort. The measured times on a uniformly sampled
sphere (README) scale linearly.

Memory is O(n + L): the grid (`sorted`, `sorted_positions` and `cell_start`), the point
arrays, and the front. The front's `edges` vector keeps tombstoned edges, so it grows to the
total number of edges ever created, about `3F` for `F` triangles; the queue likewise. Both
could be compacted between passes if needed. On the merged bunny (362,272 points, 323,934
triangles) a run allocates about 250 MB in total and spends about 4% of its time in garbage
collection.

Where the time goes on the bunny, after the optimisations described in this document:
about 65% in `ball_pivot` (roughly half of it the 27-cell scan, half the contact loop),
12% in the seed search, 7% in `join!`, and 6% building the grid. One further change was
measured and left out for the sake of readability: storing the edges as an immutable
struct inline in the vector saved 650,000 allocations but no time, since garbage
collection is only 4% of the run, and made every update a copy.

## 7. Choices the paper leaves open

- **First hit wins.** `ball_pivot` returns the single first point hit. If the resulting
  triangle fails the normal or manifold tests, the edge becomes a boundary edge, as lines 3
  and 8–9 of Fig. 5 say. Some later implementations instead skip incompatible points and
  keep rolling; that produces fewer holes on noisy data but the ball is then allowed to pass
  through a point, which the paper's description does not do. That variant was
  implemented and measured, with the ball skipping candidates that fail the tests and the
  chosen ball re-checked for emptiness: on the merged bunny it gave 794 boundary edges
  instead of 806, with every ball still empty and the mesh manifold, for 10% more time.
  The gain is small because once the ball has rolled past a point, that point is inside it
  until the ball has rolled far enough to let it out again, so 1235 of the skipped pivots
  were rejected by the re-check. It was not kept (Section 9).
- **Normal test on the new point only.** A seed triangle must agree with the normals of all
  three of its vertices, as the paper states for seeds. A pivot triangle is tested only
  against the normal of the point the ball landed on, with a zero dot product accepted: the
  front edge fixes its winding, and testing the two edge vertices strictly refused every
  point without a normal (a scan vertex belonging to no face) and the steep triangles
  joining overlapping scans, leaving ten times as many boundary edges on the merged bunny.
- **Seed candidates.** One point per voxel, chosen by projection on the voxel's average
  normal; voxels containing used points are skipped. The paper describes exactly these
  heuristics but leaves the details (which point, how to order neighbours) informal. The
  pair search around the candidate is bounded to its nearest `seed_neighbors` points
  (Section 4.2).
- **Small components.** Kept, as the paper does, unless `min_component` is given
  (Section 4.6).
- **Seeds may reuse mesh vertices.** The paper only requires `σ` itself to be unused. The
  implementation allows `a` and `b` to be front vertices, subject to `can_add_seed`, and
  glues seed edges that coincide with opposite front edges.
- **Tolerances.** `empty_ball` treats points within a relative `1e-9` of the sphere as
  outside; `pivot_angle` treats angles below `1e-6` rad as "touching now"; `ball_pivot`
  treats hits within `1e-7` rad of each other as simultaneous. Exactly cospherical inputs
  (regular lattices) are covered by dedicated tests.
- **Seed limit and progress callback.** `reconstruct` accepts `max_seeds` (stop after that
  many components have been started) and `on_progress`/`progress_every` (a callback fired
  each time the triangle count reaches a multiple of `progress_every`). Neither is in the
  paper; they serve the command-line tool's `--max-seeds` and `--progress` options.

## 8. Map from the paper to the code

| paper | code |
| --- | --- |
| `BPA(S, ρ)` loop, Fig. 5 | `run_pass!` in `reconstruct.jl` |
| `get_active_edge(F)` | `get_active_edge!` in `front.jl` |
| `ball_pivot(e)` | `ball_pivot` in `pivot.jl`; `pivot_frame`, `pivot_contact` (and the reference `pivot_angle`), `angle_less`, `angle_tie` in `geometry.jl` |
| `not_used`, `on_front` | `not_used`, `on_front`, `is_interior` in `front.jl` |
| `join(e, σ_k, F)` | `join!` |
| `glue(e1, e2, F)` | `glue!`, called through `glue_opposites!` |
| `mark_as_boundary(e)` | `e.status = BOUNDARY` in `run_pass!` |
| `find_seed_triangle()` | `find_seed_triangle!`, `try_seed` in `seed.jl` |
| `insert_edge(e, F)` | `insert_edge!`, `add_seed!` |
| voxel grid, Section 4.1 | `VoxelGrid`, `neighbors!`, `empty_ball` in `grid.jl` |
| ball touching three points | `ball_center`, `circumcircle` in `geometry.jl` |
| Fig. 7 cases | branches of `glue!`; tests in `test/test_front.jl` |
| Section 4.5 out-of-core | not implemented; `FROZEN` status reserved |
| Section 4.6 multiple passes | `reactivate!` and the pass loop in `reconstruct` |
| (not in the paper) simultaneous hits | `tie_score` in `pivot.jl` |
| (not in the paper) `seed_neighbors`, `min_component` | `try_seed`, `drop_small_components!` |
| (not in the paper) command-line tool | `cli.jl`, `bpa.jl`; mesh sampling and OFF I/O in `io.jl`; radius estimate in `spacing.jl` |

## 9. Extending the implementation

- **Skipping incompatible candidates.** In `ball_pivot`, test a candidate against the
  normal and manifold conditions (`tie_score`) when it would take the lead, instead of only
  the winner, and re-check the empty-ball property for the chosen centre in `run_pass!`,
  since a skipped point may lie inside the final ball. Measured and not kept (Section 7).
  Rolling on past a failed re-check to the next candidate is what the implementations that
  report fewer holes do, at the price of the empty-ball property.
- **Out-of-core slicing (Section 4.5).** Add two sweeping planes to `BPAState`; in
  `insert_edge!` mark edges above the upper plane `FROZEN` instead of `ACTIVE`; when the
  queue empties, advance the planes, load/unload points and turn frozen edges active. The
  loop links are already maintained for this purpose.
- **Hole filling.** Boundary loops can be read from `loops(front)` at the end of a run
  (return the front from `reconstruct` or expose it through `BPAState`).
- **Normal estimation.** The package requires normals. For range scans they come from the
  scanner geometry; for raw clouds a PCA of the neighbourhood plus a consistent orientation
  step would be needed before calling `reconstruct`.

## 10. Glossary

| term | meaning |
| --- | --- |
| ρ (rho) | ball radius of a pass |
| δ (delta) | voxel side, `2ρ` |
| `σ_i`, `n_i` | sample point and its normal |
| `e(i,j)` | front edge from `σ_i` to `σ_j` |
| `c_ijo` | centre of the ball touching `σ_i, σ_j, σ_o` |
| `m`, `γ`, `r` | edge midpoint, trajectory circle of the ball centre, its radius |
| contact | position of the centre on `γ` when the ball first touches a candidate, as 2-D coordinates in the pivot plane |
| active / boundary / frozen | edge waiting to be pivoted / could not be pivoted / out-of-core state |
| interior vertex | used vertex with no front edge: its triangle fan is complete |
| join / glue | add a triangle across a front edge / remove a coincident opposite edge pair |
| seed | first triangle of a new connected component |
| pass | one run of the Fig. 5 loop with a fixed radius |
