# The main loop (Fig. 5) and the multiple-pass extension (Section 4.6).

"""
    reconstruct(cloud::PointCloud, radii; verbose=false) -> BPAMesh
    reconstruct(cloud::PointCloud, rho::Real; kwargs...)
    reconstruct(positions, normals, radii_or_rho; kwargs...)

Run the Ball-Pivoting Algorithm on `cloud` with the ball radius `rho`, or with each radius of
`radii` in increasing order (Section 4.6: after each pass, boundary edges that admit an empty
ball of the next radius are re-activated before the pivoting restarts).

`rho` should be somewhat larger than the typical spacing between neighbouring samples and
smaller than the features to be captured.

Keyword arguments:

- `verbose`: print a summary line per pass.
- `max_seeds`: stop after this many seed triangles have been found (over all passes);
  `-1` for no limit. Useful to reconstruct only the largest components or to watch the
  front grow from a single seed.
- `seed_neighbors`: when looking for a seed triangle around a candidate point, pair only
  its nearest this many neighbours (default `DEFAULT_SEED_NEIGHBORS`; `-1` pairs all
  points within `2ρ`, as the paper describes). A bound the paper does not specify; see
  `docs/algorithm.md`, Section 4.2.
- `on_progress`, `progress_every`: if `on_progress` is given, it is called as
  `on_progress(triangles, stats)` each time the number of triangles reaches a multiple of
  `progress_every`. `triangles` is the live output vector; copy it if it is to be kept.
"""
function reconstruct(cloud::PointCloud, radii::AbstractVector{<:Real}; verbose::Bool = false,
                     max_seeds::Integer = -1, seed_neighbors::Integer = DEFAULT_SEED_NEIGHBORS,
                     on_progress = nothing, progress_every::Integer = 1000)
    isempty(radii) && throw(ArgumentError("at least one radius is required"))
    all(r -> r > 0, radii) || throw(ArgumentError("radii must be positive"))
    progress_every > 0 || throw(ArgumentError("progress_every must be positive"))
    radii = sort(Float64.(radii))
    n = length(cloud)
    front = Front(n)
    triangles = Tri[]
    stats = BPAStats()

    for (pass, rho) in enumerate(radii)
        t0 = time()
        grid = VoxelGrid(cloud.positions, 2 * rho)
        st = BPAState(cloud, grid, rho, front, triangles, stats; max_seeds = max_seeds,
                      seed_neighbors = seed_neighbors, on_progress = on_progress,
                      progress_every = progress_every)
        ntri0 = length(triangles)
        nreact = pass > 1 ? reactivate!(st) : 0
        push!(stats.reactivated_per_pass, nreact)
        n >= 3 && run_pass!(st)
        push!(stats.triangles_per_pass, length(triangles) - ntri0)
        if verbose
            println("pass $pass: rho = $rho, reactivated $nreact edges, ",
                    length(triangles) - ntri0, " new triangles, ",
                    boundary_edge_count(front), " boundary edges, ",
                    round(time() - t0, digits = 2), " s")
        end
    end
    stats.boundary_edges = boundary_edge_count(front)
    BPAMesh(cloud, triangles, stats)
end

reconstruct(cloud::PointCloud, rho::Real; kwargs...) = reconstruct(cloud, [rho]; kwargs...)
reconstruct(positions, normals, r; kwargs...) = reconstruct(PointCloud(positions, normals), r; kwargs...)

"""
    output_triangle!(state, a, b, c)

Append a triangle to the output (the paper's `output_triangle`) and fire the progress
callback when the count reaches a multiple of `progress_every`.
"""
function output_triangle!(st::BPAState, a::Int, b::Int, c::Int)
    push!(st.triangles, Tri(a, b, c))
    if st.on_progress !== nothing && length(st.triangles) % st.progress_every == 0
        st.on_progress(st.triangles, st.stats)
    end
    nothing
end

"""
    run_pass!(state)

The BPA loop of Fig. 5 for one radius: pivot every active edge, and when none is left search
for a new seed triangle; stop when no seed can be found (or the seed limit is reached). The
comments below give the corresponding line numbers of Fig. 5.
"""
function run_pass!(st::BPAState)
    f = st.front
    P = st.cloud.positions
    N = st.cloud.normals
    stats = st.stats
    while true                                                   # 1. while (true)
        while (id = get_active_edge!(f)) != 0                    # 2. while e(i,j) = get_active_edge(F)
            e = f.edges[id]
            stats.pivots += 1
            res = ball_pivot(st, id)                             # 3. σ_k = ball_pivot(e(i,j))
            if res === nothing
                stats.rejected_no_hit += 1
            else
                k, c = res
                i, j = e.i, e.j
                # "Edge orientation checks" left out of Fig. 5 for readability: the new
                # triangle must not face against the normal of the point hit, and must keep
                # the mesh a manifold.
                ntri = triangle_normal(P[i], P[k], P[j])
                if !pivot_orientation_consistent(ntri, N[k])
                    stats.rejected_normal += 1
                elseif !(not_used(f, k) || on_front(f, k))       # 3. not_used(σ_k) || on_front(σ_k)
                    stats.rejected_used += 1
                elseif !can_add_triangle(f, i, k, j)
                    stats.rejected_manifold += 1
                else
                    output_triangle!(st, i, k, j)                # 4. output_triangle(σ_i, σ_k, σ_j)
                    stats.joins += 1
                    stats.glues += join!(f, id, k, c)            # 5–7. join, then glue
                    continue
                end
            end
            e.status = BOUNDARY                                  # 8–9. else mark_as_boundary
        end
        st.max_seeds >= 0 && stats.seeds >= st.max_seeds && return   # seed limit reached
        seed = find_seed_triangle!(st)                           # 10. find_seed_triangle()
        seed === nothing && return                               # 15–16. else return
        (a, b, c), center = seed
        output_triangle!(st, a, b, c)                            # 11. output_triangle
        stats.seeds += 1
        stats.glues += add_seed!(f, a, b, c, center)             # 12–14. insert the three edges
    end
end

"""
    reactivate!(state) -> number of re-activated edges

Section 4.6: for every edge left in the front, test whether it forms, with its opposite
vertex, a valid seed triangle for a ball of the current (larger) radius; if so make it active
again with the new ball centre.
"""
function reactivate!(st::BPAState)
    f = st.front
    P = st.cloud.positions
    n = 0
    for (id, e) in enumerate(f.edges)
        (e.alive && e.status != ACTIVE) || continue
        c = ball_center(P[e.i], P[e.j], P[e.o], st.rho)
        c === nothing && continue
        empty_ball(st.grid, c, st.rho, e.i, e.j, e.o) || continue
        activate!(f, id, c)
        n += 1
    end
    n
end
