# Seed selection (Section 4.2).

"""
Working state of one BPA pass (one ball radius). The `front`, `triangles` and `stats` are
shared across passes; the `grid` and `rho` are specific to the pass.
"""
mutable struct BPAState
    cloud::PointCloud
    grid::VoxelGrid      # voxel grid with δ = 2ρ for this pass
    rho::Float64         # ball radius of this pass
    front::Front
    triangles::Vector{Tri}   # output, appended to as triangles are created
    stats::BPAStats
    cursor::Int          # next voxel slot to examine for seeds (persists across seed searches)
    buf::Vector{Int}     # scratch neighbour buffer reused by every spatial query
    max_seeds::Int       # stop after this many seeds in total; -1 for no limit
    on_progress::Any     # callback (triangles, stats) or nothing
    progress_every::Int  # call the callback whenever the triangle count is a multiple of this
end

"""
    find_seed_triangle!(state) -> ((a, b, c), center) or nothing

Walk the non-empty voxels from the persistent cursor. Voxels containing a point that is
already part of the triangulation are skipped, and a single candidate point per voxel is
tried: the point whose projection onto the voxel's average normal is largest, so the ball can
sit on it from the outside. The search resumes where it stopped on the next call.
"""
function find_seed_triangle!(st::BPAState)
    g = st.grid
    f = st.front
    P = st.cloud.positions
    N = st.cloud.normals
    while st.cursor <= nslots(g)
        rng = slot_range(g, st.cursor)
        if !isempty(rng) && !any(t -> f.used[g.sorted[t]], rng)
            navg = zero(Vec3)
            centroid = zero(Vec3)
            for t in rng
                id = g.sorted[t]
                navg += N[id]
                centroid += P[id]
            end
            centroid /= length(rng)
            best = 0
            bestproj = -Inf
            for t in rng
                id = g.sorted[t]
                proj = dot(P[id] - centroid, navg)
                if proj > bestproj
                    bestproj = proj
                    best = id
                end
            end
            res = try_seed(st, best)
            # On success the cursor stays: this voxel now contains used points and is skipped
            # on the next call.
            res !== nothing && return res
        end
        st.cursor += 1
    end
    return nothing
end

"""
    try_seed(state, σ) -> ((σ, a, b), center) or nothing

Consider neighbour pairs `(a, b)` of `σ` in order of distance, orient each candidate triangle
consistently with the vertex normals, and accept the first one whose ρ-ball (centred in the
outward half-space) contains no other data point.
"""
function try_seed(st::BPAState, σ::Int)
    g = st.grid
    f = st.front
    P = st.cloud.positions
    N = st.cloud.normals
    rho = st.rho
    buf = st.buf
    neighbors!(buf, g, P[σ], 2 * rho)
    filter!(id -> id != σ && !is_interior(f, id), buf)
    pσ = P[σ]
    sort!(buf, by = id -> sum(abs2, P[id] - pσ))
    nσ = N[σ]
    for ia in 1:length(buf), ib in (ia + 1):length(buf)
        a = buf[ia]
        b = buf[ib]
        n = triangle_normal(pσ, P[a], P[b])
        if orientation_consistent(n, nσ, N[a], N[b])
            tri = (σ, a, b)
        elseif orientation_consistent(-n, nσ, N[a], N[b])
            tri = (σ, b, a)
        else
            continue
        end
        can_add_seed(f, tri...) || continue
        c = ball_center(P[tri[1]], P[tri[2]], P[tri[3]], rho)
        c === nothing && continue
        empty_ball(g, c, rho, tri...) || continue
        return tri, c
    end
    return nothing
end
