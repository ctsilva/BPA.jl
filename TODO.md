# TODO

Correctness-protection work, in priority order. Each item is independent of the others and
small enough to be one commit. Items marked done are kept for the record.

## 1. Continuous integration

No workflow exists. `Pkg.test()` runs in about one minute on Julia 1.12, needs no Python
(the comparison harness test runs with `--tools bpa --no-render`), and `Project.toml`
declares `julia = "1.10"`.

- [ ] Add `.github/workflows/ci.yml` running `julia-actions/setup-julia`, `julia-buildpkg`
      and `julia-runtest` on `ubuntu-latest` for Julia `1.10` (the declared minimum) and `1`
      (the latest release). Trigger on push to `main` and on pull requests.
- [ ] Cache the depot with `julia-actions/cache`.
- [ ] Add a CI badge to `README.md` under the title.

## 2. Front invariants checked during real reconstructions

The `Front` docstring in `src/types.jl` states the invariants; `loops` in `src/front.jl`
already verifies the `prev`/`next` links. The gap is that nothing checks the per-vertex
chains, the closed-edge records and the counts against an independent model while the
algorithm runs. Generating random *valid* operation sequences is hard; driving the checks
from real reconstructions of small random clouds is not.

- [ ] Write `check_front(f::Front)` in `test/test_front.jl` (or a new `test/front_oracle.jl`)
      that rebuilds from scratch, with `Dict`s and `Set`s, the state implied by `f.edges`:
      the set of live directed edges, `front_count[v]`, `used[v]`, `nlive`, and the set of
      closed undirected edges; then asserts
      - every live edge `(i, j)` is found by `edge_id(f, i, j)` exactly once and `(j, i)` is
        not live;
      - `out_head`/`out_next` chains contain exactly the live edges leaving each vertex and
        no tombstoned edge;
      - `front_count` and `nlive` equal the recount;
      - no closed edge is live, and no directed edge appears twice among live edges;
      - every live `ACTIVE` edge id appears in `queue` at or after `qhead`;
      - `loops(f)` succeeds.
- [ ] Add a test that reconstructs small random clouds (perturbed `fibonacci_sphere`,
      `torus`, `plane_patch` with a few hundred points, several radii, several seeds) with a
      `Front` wrapped so that `check_front` runs after every `join!`, `glue!` and
      `add_seed!`. Simplest mechanism: an `on_progress` callback with `progress_every = 1`
      calls `check_front(st.front)`, which covers every triangle insertion; `glue!` is
      always called from within `join!`/`add_seed!`, so this sees the state after each.
      Note: `on_progress` receives `(triangles, stats)`, not the state, so either extend
      the callback signature or run the check through a small wrapper that holds the
      `BPAState` and calls `run_pass!` directly, as the opposite-vertex test does.
- [ ] Also assert, at the end of each reconstruction, that the closed-edge records plus the
      live edges account for exactly the edges of `triangles` with the right multiplicity
      (the incidence agrees with the generated triangle set).

## 3. Scale and translation invariance

Every tolerance in `src/geometry.jl` and `src/grid.jl` is relative, so the output should
already be invariant. Locking that in is twenty lines.

- [ ] In `test/test_reconstruct.jl`, take a jittered `torus` and a `plane_patch`, reconstruct
      at the reference scale, then at scales `1e-3` and `1e3` and with offsets of
      `(1e4, -1e4, 1e4)` at each scale, with `rho` scaled the same way, and assert the
      triangle lists are identical.
- [ ] Include an exact lattice (`jitter = 0.0`) in the set: the cospherical tie-break is where
      a scale-dependent tolerance would first show.
- [ ] Add a one-line pointer in `docs/algorithm.md` Section 7 (Tolerances) saying the
      tolerances are relative and which test guards that.

## 4. Determinism statement

The algorithm has no randomness: FIFO queue, index tie-break in `tie_score`, fixed voxel
walk. The tests already compare exact triangle lists across input forms and across
`seed_neighbors` settings, so per-machine determinism is tested implicitly.

- [ ] Add a short "Determinism" paragraph to `README.md` (after "Reading the output" or in
      "Tests and performance"): identical input and parameters give identical triangle
      lists on a given machine and Julia version; across architectures or compilers,
      floating-point differences (fused multiply-add, libm) can flip near-tie decisions,
      so only topological and geometric equivalence is promised there.
- [ ] Add an explicit test: reconstruct the same cloud twice in one process and compare
      triangle lists with `==` (cheap and documents the intent).

## 5. More pivot regression variants

The opposite-vertex test in `test/test_reconstruct.jl` ("pivot rolling back to the
opposite vertex") is the template. Add, in the same style:

- [ ] Reversed front orientation: the mirror triangle `(i, o, j)` with normals `-z`, ball
      centre below the plane, same two cases (point reached before and after `θo`).
- [ ] Competing candidate: a point at `tip(θo - 0.6)` and another at `tip(θo - 0.5)`; the
      earlier one must win.
- [ ] Near-tie with `σ_o` excluded: a point at `tip(θo + 1e-8)`, within `TIE_TOLERANCE` of
      the return to `σ_o`. `ball_pivot` must not return `nothing` on the strength of the
      tie with `σ_o` alone; document in the test which outcome is the intended one.
- [ ] A second radius (e.g. `rho = 2.0`) for the original two cases, to make sure nothing
      depends on the unit ball.

## 6. Zero-allocation guard

`BPAState.buf` exists so that pivoting does not allocate. Nothing tests that, and an
accidental closure or boxed variable in `ball_pivot` would silently cost a large factor.

- [ ] Add a test that builds a `BPAState` on a small sphere, seeds it, calls
      `ball_pivot(st, id)` once to warm up, then asserts `@allocated ball_pivot(st, id) == 0`
      for a live active edge. Do the same for `join!` on a front with the vectors already
      grown (pre-`sizehint!` or run one join first), accepting that `push!` may occasionally
      reallocate: assert allocation is zero on at least one of several consecutive calls,
      or check `@allocated` for `pivot_contact` and `angle_less` in a loop, which must be
      exactly zero.
- [ ] Measure `empty_ball` and `neighbors!` the same way; both are on the hot path.
