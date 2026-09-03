# Seed selection (Section 4.2).

"""
    BPAState(cloud, grid, rho, front, triangles, stats; max_seeds=-1, seed_neighbors=100,
             on_progress=nothing, progress_every=1000)

Working state of one BPA pass (one ball radius). The `front`, `triangles` and `stats` are
shared across passes; the `grid` and `rho` are specific to the pass. The scratch buffer
`buf` is filled by `neighbors!` and reused by every spatial query, so that pivoting does
not allocate. `seed_neighbors` bounds the pair search of `try_seed`.
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
    seed_neighbors::Int  # try_seed pairs only the nearest this many neighbours of a candidate
    on_progress::Any     # callback (triangles, stats) or nothing
    progress_every::Int  # call the callback whenever the triangle count is a multiple of this
end

BPAState(cloud::PointCloud, grid::VoxelGrid, rho::Real, front::Front, triangles::Vector{Tri},
         stats::BPAStats; max_seeds::Integer = -1, seed_neighbors::Integer = DEFAULT_SEED_NEIGHBORS,
         on_progress = nothing, progress_every::Integer = 1000) =
    BPAState(cloud, grid, Float64(rho), front, triangles, stats, 1, Int[],
             Int(max_seeds), Int(seed_neighbors), on_progress, Int(progress_every))

"""
Default for `seed_neighbors`: how many of the nearest neighbours of a seed candidate `σ` are
paired in `try_seed`. The paper's pair search is unbounded, and `-1` restores that; the
bound is a heuristic against candidates that cannot seed anything (points under an already
reconstructed sheet, whose every pair fails the empty-ball test) and whose quadratic pair
loop otherwise dominates the seed search. A valid seed triangle's other two vertices are
almost always among the closest points of `σ`, and this value reproduces the unbounded
output on every dataset in `data/`, the 62 dragon scans included (60 loses three stray
seed triangles there).
"""
const DEFAULT_SEED_NEIGHBORS = 100

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
outward half-space) contains no other data point. Only the nearest `state.seed_neighbors`
neighbours of `σ` are paired (all of them if that is negative).
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
    st.seed_neighbors >= 0 && length(buf) > st.seed_neighbors && resize!(buf, st.seed_neighbors)
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
