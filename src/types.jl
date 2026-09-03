# Core data types (Section 4 of the paper).
#
# Vertices are referred to everywhere by their 1-based index into `PointCloud.positions`;
# the paper's σ_i is `cloud.positions[i]` and n_i is `cloud.normals[i]`.

"A 3-D point or vector (stack-allocated, so vectors of them are contiguous)."
const Vec3 = SVector{3,Float64}

"A triangle as three vertex indices, ordered counter-clockwise seen from outside."
const Tri = SVector{3,Int}

"Normalise `v`, leaving a zero vector unchanged (a zero normal disables the orientation tests)."
_unit(v::Vec3) = (l = norm(v); l > 0 ? v / l : v)

"""
    PointCloud(positions, normals)

Input to the BPA: sample points `σ_i` with an (outward oriented) unit normal `n_i` each.
`positions` and `normals` may be vectors of 3-element containers, or `3×N` / `N×3` matrices.
Normals are normalised on construction.
"""
struct PointCloud
    positions::Vector{Vec3}
    normals::Vector{Vec3}

    function PointCloud(positions::AbstractVector, normals::AbstractVector)
        length(positions) == length(normals) ||
            throw(ArgumentError("positions and normals must have the same length"))
        p = Vec3[Vec3(x[1], x[2], x[3]) for x in positions]
        n = Vec3[_unit(Vec3(x[1], x[2], x[3])) for x in normals]
        new(p, n)
    end
end

function PointCloud(P::AbstractMatrix, N::AbstractMatrix)
    size(P) == size(N) || throw(ArgumentError("positions and normals must have the same size"))
    if size(P, 1) == 3
        return PointCloud(collect(eachcol(P)), collect(eachcol(N)))
    elseif size(P, 2) == 3
        return PointCloud(collect(eachrow(P)), collect(eachrow(N)))
    else
        throw(ArgumentError("expected a 3×N or N×3 matrix"))
    end
end

Base.length(c::PointCloud) = length(c.positions)
Base.show(io::IO, c::PointCloud) = print(io, "PointCloud with ", length(c), " points")

"""
Status of a front edge. `ACTIVE` edges are waiting to be pivoted; `BOUNDARY` edges could not
be pivoted; `FROZEN` is reserved for the out-of-core extension (Section 4.5), which is not
implemented, and is never assigned.
"""
@enum EdgeStatus ACTIVE BOUNDARY FROZEN

"""
An edge `e(i,j)` of the advancing front, oriented like the half-edge `i → j` of the single
mesh triangle `(i, j, o)` that owns it. Keeping the opposite vertex `o` and the ball centre
with the edge is what makes a pivot self-contained: nothing else about the mesh needs to be
consulted to start the ball rolling (Section 4, "Keeping all this information with each edge
makes it simpler to pivot the ball around it").

Edges are never deleted from `Front.edges`; a removed edge is tombstoned with `alive = false`
so that ids stored in the queue and in the loop links stay valid.
"""
mutable struct FrontEdge
    i::Int              # first endpoint σ_i
    j::Int              # second endpoint σ_j (the edge is the half-edge i → j of its triangle)
    o::Int              # opposite vertex σ_o of the triangle (i, j, o) that owns the edge
    center::Vec3        # centre c_ijo of the ρ-ball touching σ_i, σ_j, σ_o
    prev::Int           # previous edge in the same front loop (ends at σ_i)
    next::Int           # next edge in the same front loop (starts at σ_j)
    status::EdgeStatus
    alive::Bool         # false once the edge has been removed by `join!` or `glue!`
end

"""
The advancing front `F` (Section 4): the set of mesh edges that have exactly one triangle,
organised in loops, plus the per-vertex bookkeeping needed for the `not_used`/`on_front`
tests, for `glue` and for the manifoldness test.

Edges are found from their origin vertex without hashing: `out_head[v]` is the first live
edge leaving `v` and `out_next[id]` the next one with the same origin, a chain that is a few
edges long at most (a vertex has as many live edges leaving it as front loops passing
through it). Closed edges are recorded the same way from their smaller endpoint:
`closed_head[a]` starts the chain of records `(closed_to[r], closed_next[r])` for the
closed edges `{a, w}` with `a < w`.

Invariants maintained by the operations in `front.jl`:

- A live edge `(i,j)` is in the chain of `i` exactly once (`edge_id`), and the mesh contains
  the half-edge `i → j` exactly once and `j → i` not at all.
- `front_count[v]` is the number of live edges with `v` as an endpoint. A vertex with
  `used[v] && front_count[v] == 0` is *interior*: its fan of triangles is complete and no
  further triangle may use it.
- The closed records hold every undirected edge that has two triangles (`is_closed`).
  Together with `edge_id` they decide whether adding a half-edge would make the mesh
  non-manifold or non-orientable (`can_add_triangle`).
- Following `next` from any live edge returns to it, and `edges[e.next].prev == e`.
  Loops are only needed for diagnostics (`loops`) and for the out-of-core extension; the
  in-core algorithm's correctness does not depend on them.
- Every live active edge appears in `queue` at or after `qhead`. Removed or boundary edges
  may still appear there and are skipped when popped.
"""
mutable struct Front
    edges::Vector{FrontEdge}
    queue::Vector{Int}                   # FIFO of active edge ids (stale ids skipped on pop)
    qhead::Int                           # index of the next queue entry to pop
    out_head::Vector{Int}                # per vertex: first live edge leaving it, 0 if none
    out_next::Vector{Int}                # per edge: next live edge with the same origin, 0 at the end
    front_count::Vector{Int}             # number of live front edges incident on each vertex
    used::BitVector                      # vertex is part of the triangulation
    closed_head::Vector{Int}             # per vertex a: first record of a closed edge {a, w}, a < w
    closed_to::Vector{Int}               # per record: the larger endpoint w
    closed_next::Vector{Int}             # per record: next record with the same smaller endpoint
    nlive::Int                           # number of live edges
end

Front(n::Integer) = Front(FrontEdge[], Int[], 1, zeros(Int, n), Int[], zeros(Int, n), falses(n),
                          zeros(Int, n), Int[], Int[], 0)

"""
Counters collected while running the algorithm. Every pivot ends in exactly one of `joins`,
`rejected_no_hit`, `rejected_normal`, `rejected_used` or `rejected_manifold`; the last four
each leave a boundary edge behind, so a large count of one of them explains where holes in
the output come from.
"""
mutable struct BPAStats
    seeds::Int                  # seed triangles found (= connected components started)
    pivots::Int                 # ball_pivot calls
    joins::Int                  # successful pivots (one triangle each)
    glues::Int                  # coincident edge pairs removed from the front
    rejected_no_hit::Int        # pivot found no point (edge became boundary)
    rejected_normal::Int        # first hit point's normal points against the triangle
    rejected_used::Int          # first hit point is an interior vertex
    rejected_manifold::Int      # triangle would create a non-manifold / non-orientable edge
    boundary_edges::Int         # boundary edges left in the front at the end
    triangles_per_pass::Vector{Int}    # triangles created by each radius
    reactivated_per_pass::Vector{Int}  # boundary edges re-activated at the start of each pass
end

BPAStats() = BPAStats(0, 0, 0, 0, 0, 0, 0, 0, 0, Int[], Int[])

"""
    BPAMesh

Result of [`reconstruct`](@ref). `triangles` index into `cloud.positions` (1-based) and are
oriented counter-clockwise when seen from the outside (along the vertex normals).
"""
struct BPAMesh
    cloud::PointCloud
    triangles::Vector{Tri}
    stats::BPAStats
end

Base.show(io::IO, m::BPAMesh) =
    print(io, "BPAMesh: ", length(m.triangles), " triangles on ", length(m.cloud), " points")
