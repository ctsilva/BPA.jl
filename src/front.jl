# The advancing front and its topological operators `join` and `glue` (Section 4.4).
#
# Orientation convention used throughout:
#   * a mesh triangle (a, b, c) is counter-clockwise seen from outside, i.e. its normal
#     (b - a) × (c - a) points along the vertex normals;
#   * a front edge e(i,j) has the same direction as the half-edge i → j of the triangle
#     (i, j, o) that owns it;
#   * pivoting e(i,j) onto a point k creates the triangle (i, k, j), whose half-edges are
#     i → k, k → j and j → i. The last one is the reverse of the front edge, so the two
#     triangles sharing {i, j} are consistently oriented, and the two new front edges are
#     e(i,k) and e(k,j) exactly as in Fig. 6.
#   * `glue` therefore only ever has to remove pairs of *opposite* edges e(i,k) / e(k,i);
#     a pair with the same orientation would be a non-orientable configuration and is
#     prevented beforehand by `can_add_triangle` / `can_add_seed`.
#
# See the `Front` docstring in types.jl for the data-structure invariants.

"Canonical key of the undirected edge {i, j}."
@inline undirected(i::Int, j::Int) = i < j ? (i, j) : (j, i)

"Vertex `k` is not yet part of the triangulation (the paper's `not_used`)."
not_used(f::Front, k::Int) = !f.used[k]

"Vertex `k` is an endpoint of at least one live front edge (the paper's `on_front`)."
on_front(f::Front, k::Int) = f.front_count[k] > 0

"Vertex `k` is in the mesh with a complete fan of triangles: no more triangles may touch it."
is_interior(f::Front, k::Int) = f.used[k] && f.front_count[k] == 0

"""
    edge_id(front, i, j) -> edge id or 0

Id of the live front edge `e(i,j)`, found by walking the chain of edges leaving `i`.
"""
@inline function edge_id(f::Front, i::Int, j::Int)
    id = f.out_head[i]
    while id != 0
        f.edges[id].j == j && return id
        id = f.out_next[id]
    end
    0
end

"`true` if the front holds the directed edge `e(i,j)`."
@inline has_edge(f::Front, i::Int, j::Int) = edge_id(f, i, j) != 0

"""
    is_closed(front, i, j) -> Bool

`true` if the undirected edge `{i, j}` already has two triangles, found by walking the
closed records of the smaller endpoint.
"""
@inline function is_closed(f::Front, i::Int, j::Int)
    a, b = undirected(i, j)
    r = f.closed_head[a]
    while r != 0
        f.closed_to[r] == b && return true
        r = f.closed_next[r]
    end
    false
end

"Record that the undirected edge `{i, j}` now has two triangles."
function close_edge!(f::Front, i::Int, j::Int)
    a, b = undirected(i, j)
    push!(f.closed_to, b)
    push!(f.closed_next, f.closed_head[a])
    f.closed_head[a] = length(f.closed_to)
    nothing
end

"""
    insert_edge!(front, i, j, o, center) -> edge id

Add the active edge `e(i,j)` with opposite vertex `o` and ball centre `center` to the front,
to the chain of edges leaving `i` and to the queue of active edges. Loop links are left for
the caller to set.
"""
function insert_edge!(f::Front, i::Int, j::Int, o::Int, center::Vec3)
    has_edge(f, i, j) && error("front already contains edge ($i, $j)")
    push!(f.edges, FrontEdge(i, j, o, center, 0, 0, ACTIVE, true))
    id = length(f.edges)
    push!(f.out_next, f.out_head[i])       # chain the new edge in front of the others at i
    f.out_head[i] = id
    f.front_count[i] += 1
    f.front_count[j] += 1
    f.used[i] = true
    f.used[j] = true
    f.nlive += 1
    push!(f.queue, id)
    id
end

"""
    remove_edge!(front, id)

Tombstone edge `id`: drop it from the chain of its origin and from the vertex counts. The loop links of its
neighbours are left for the caller to repair (`join!` splices replacements in, `glue!`
bypasses the pair).
"""
function remove_edge!(f::Front, id::Int)
    e = f.edges[id]
    e.alive || error("edge $id is already removed")
    e.alive = false
    if f.out_head[e.i] == id                # unchain it from the edges leaving e.i
        f.out_head[e.i] = f.out_next[id]
    else
        p = f.out_head[e.i]
        while f.out_next[p] != id
            p = f.out_next[p]
        end
        f.out_next[p] = f.out_next[id]
    end
    f.front_count[e.i] -= 1
    f.front_count[e.j] -= 1
    f.nlive -= 1
    nothing
end

"Make `b` follow `a` in a front loop (`a.next = b`, `b.prev = a`)."
@inline function link!(f::Front, a::Int, b::Int)
    f.edges[a].next = b
    f.edges[b].prev = a
    nothing
end

"""
    get_active_edge!(front) -> edge id or 0

Pop the queue until an edge that is still alive and active is found (the paper's
`get_active_edge(F)`). Returns 0 when the queue is exhausted, which is the signal to look for
a new seed triangle. The queue is FIFO, so the front grows breadth-first around each seed.
"""
function get_active_edge!(f::Front)
    while f.qhead <= length(f.queue)
        id = f.queue[f.qhead]
        f.qhead += 1
        e = f.edges[id]
        if e.alive && e.status == ACTIVE
            return id
        end
    end
    empty!(f.queue)
    f.qhead = 1
    return 0
end

"""
    activate!(front, id, center)

Re-activate a boundary edge with a new ball centre (multiple passes, Section 4.6).
"""
function activate!(f::Front, id::Int, center::Vec3)
    e = f.edges[id]
    e.alive || error("cannot activate a removed edge")
    e.center = center
    e.status = ACTIVE
    push!(f.queue, id)
    nothing
end

"""
    can_add_triangle(front, i, k, j) -> Bool

Manifoldness test for the candidate triangle `(i, k, j)` produced by pivoting `e(i,j)`
(Section 4.4, case 2). Rejects if `k` is an interior vertex, if either new half-edge `(i,k)`,
`(k,j)` already exists on the front with the same orientation, or if either undirected edge
already has two triangles.
"""
function can_add_triangle(f::Front, i::Int, k::Int, j::Int)
    is_interior(f, k) && return false
    has_edge(f, i, k) && return false
    has_edge(f, k, j) && return false
    is_closed(f, i, k) && return false
    is_closed(f, k, j) && return false
    true
end

"""
    can_add_seed(front, a, b, c) -> Bool

Same test for a seed triangle `(a, b, c)`, all of whose vertices may already be in the mesh.
"""
function can_add_seed(f::Front, a::Int, b::Int, c::Int)
    (is_interior(f, a) || is_interior(f, b) || is_interior(f, c)) && return false
    for (p, q) in ((a, b), (b, c), (c, a))
        has_edge(f, p, q) && return false
        is_closed(f, p, q) && return false
    end
    true
end

"""
    add_seed!(front, a, b, c, center)

Insert the three edges of the seed triangle `(a, b, c)` as one loop, gluing any that coincide
with existing front edges of opposite orientation.
"""
function add_seed!(f::Front, a::Int, b::Int, c::Int, center::Vec3)
    e1 = insert_edge!(f, a, b, c, center)
    e2 = insert_edge!(f, b, c, a, center)
    e3 = insert_edge!(f, c, a, b, center)
    link!(f, e1, e2)
    link!(f, e2, e3)
    link!(f, e3, e1)
    glue_opposites!(f, (e1, e2, e3))
end

"""
    join!(front, id, k, center) -> number of glue operations performed

The `join` operation (Fig. 6): the triangle `(i, k, j)` has been created by pivoting
`e(i,j)`; remove `e(i,j)` from the front and add `e(i,k)` and `e(k,j)` in its place in the
loop. Then `glue` each new edge against a coincident opposite edge, if one exists (Fig. 7).
"""
function join!(f::Front, id::Int, k::Int, center::Vec3)
    e = f.edges[id]
    i, j = e.i, e.j
    prev, next = e.prev, e.next
    remove_edge!(f, id)
    close_edge!(f, i, j)
    e1 = insert_edge!(f, i, k, j, center)
    e2 = insert_edge!(f, k, j, i, center)
    link!(f, prev, e1)
    link!(f, e1, e2)
    link!(f, e2, next)
    glue_opposites!(f, (e1, e2))
end

"""
    glue_opposites!(front, ids) -> number of glue operations

For each of the freshly inserted edges `ids`, look for the oppositely oriented edge on the
front and `glue!` the pair if it exists (lines 6–7 of Fig. 5). An edge may already have been
removed by an earlier glue in the same call, hence the `alive` check.
"""
function glue_opposites!(f::Front, ids)
    n = 0
    for id in ids
        e = f.edges[id]
        e.alive || continue
        other = edge_id(f, e.j, e.i)
        if other != 0
            glue!(f, id, other)
            n += 1
        end
    end
    n
end

"""
    glue!(front, id1, id2)

Remove the coincident, oppositely oriented pair `e(i,k)`, `e(k,i)` from the front and relink
the loops. The four cases of Fig. 7 (two-edge loop, consecutive edges, same loop, different
loops) are all handled by the pointer surgery below.
"""
function glue!(f::Front, id1::Int, id2::Int)
    e1 = f.edges[id1]
    e2 = f.edges[id2]
    (e1.i == e2.j && e1.j == e2.i) || error("glue! requires coincident edges of opposite orientation")
    # Write e1 = (i,k) and e2 = (k,i). prev(e1) ends at i, next(e1) starts at k,
    # prev(e2) ends at k, next(e2) starts at i.
    if e1.next == id2 && e2.next == id1
        # (a) the two edges form a loop by themselves: the loop disappears, nothing to relink.
    elseif e1.next == id2
        # (b) consecutive: … → prev(e1) → e1 → e2 → next(e2) → …  becomes  … → prev(e1) → next(e2) → …
        link!(f, e1.prev, e2.next)
    elseif e2.next == id1
        # (b) mirrored: … → prev(e2) → e2 → e1 → next(e1) → …
        link!(f, e2.prev, e1.next)
    else
        # (c) same loop, not consecutive: the loop splits into two, or
        # (d) different loops: they merge into one.
        # Both are the same surgery: prev(e1) → next(e2) continues at i, prev(e2) → next(e1)
        # continues at k.
        p1, n1, p2, n2 = e1.prev, e1.next, e2.prev, e2.next
        link!(f, p1, n2)
        link!(f, p2, n1)
    end
    remove_edge!(f, id1)
    remove_edge!(f, id2)
    close_edge!(f, e1.i, e1.j)
    nothing
end

"""
    loops(front) -> Vector{Vector{Int}}

Enumerate the loops of the front by following `next` links. Diagnostic only.
"""
function loops(f::Front)
    seen = falses(length(f.edges))
    out = Vector{Vector{Int}}()
    for start in eachindex(f.edges)
        (f.edges[start].alive && !seen[start]) || continue
        loop = Int[]
        id = start
        while true
            seen[id] && break
            seen[id] = true
            push!(loop, id)
            e = f.edges[id]
            e.alive || error("loop passes through removed edge $id")
            f.edges[e.next].prev == id || error("inconsistent prev/next links at edge $id")
            id = e.next
        end
        id == start || error("loop starting at $start does not close")
        push!(out, loop)
    end
    out
end

"Number of live edges marked `BOUNDARY` (edges of the output mesh with a single triangle)."
boundary_edge_count(f::Front) = count(e -> e.alive && e.status == BOUNDARY, f.edges)
