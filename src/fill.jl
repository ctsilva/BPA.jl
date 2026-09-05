# Filling small holes by ear clipping. Not part of the BPA: the paper leaves a hole wherever
# no ball of radius ρ fits, and the triangles added here have no empty ball by definition.
# The filling is a separate, optional step on the output (`--fill-loops` in the command-line
# tool), kept apart from the reconstruction so that the empty-ball property of every BPA
# triangle and the statistics of the run stay as they were: the added triangles are appended
# after the BPA triangles and counted in `stats.filled_triangles`.
#
# A greedy ear clipping in the spirit of Silva and Mitchell, "Greedy cuts: an advancing
# front terrain triangulation algorithm" (ACM GIS 1998): the boundary loop is a polygon in
# space, and an ear, three consecutive loop vertices, is cut off as a triangle when it is
# well formed and agrees with the vertex normals.

"""
    fill_small_loops(mesh; max_edges=10) -> BPAMesh

Close the boundary loops of `mesh` that have at most `max_edges` edges by greedy ear
clipping, and return a new mesh with the added triangles appended after the original ones;
in the copy of the statistics `stats.filled_loops` and `stats.filled_triangles` are
increased and `stats.boundary_edges` is recounted from the result.

A boundary loop is followed along the half-edges that have no opposite. An ear, three
consecutive loop vertices `a, b, c`, is clipped as the triangle `(c, b, a)`, wound against
the loop so that it matches the triangles across the loop's edges, when

- the triangle is not degenerate,
- its normal agrees with the normals of all three vertices (the seed test of the BPA),
- no other vertex of the loop lies inside it, in the projection onto its plane, and
- the edge `{a, c}` it creates is not already in the mesh.

Among the valid ears the best shaped one, with the largest smallest angle, is clipped
first; the loop shrinks by one vertex per clip and closes with its last three. A loop that
passes twice through a vertex, or whose remaining ears all fail the tests, is left as it
is, possibly partly filled. The mesh stays orientable and edge-manifold, and no two loops
are joined. The added triangles are not BPA triangles: their ball is not empty, which is why
the loop was open, and the comparison harness classifies them accordingly.
"""
function fill_small_loops(mesh::BPAMesh; max_edges::Integer = 10)
    max_edges >= 3 || throw(ArgumentError("max_edges must be at least 3"))
    P = mesh.cloud.positions
    N = mesh.cloud.normals
    tris = copy(mesh.triangles)
    directed = Set{Tuple{Int,Int}}()
    ecount = Dict{Tuple{Int,Int},Int}()
    for t in tris, e in ((t[1], t[2]), (t[2], t[3]), (t[3], t[1]))
        push!(directed, e)
        u = minmax(e...)
        ecount[u] = get(ecount, u, 0) + 1
    end
    loops = boundary_loops(directed)
    closed = 0
    added = 0
    for loop in loops
        3 <= length(loop) <= max_edges || continue
        L = copy(loop)
        while length(L) >= 3
            n = length(L)
            best = 0
            bestq = -1.0
            for i in 1:n
                a, b, c = L[mod1(i - 1, n)], L[i], L[mod1(i + 1, n)]
                q = ear_quality(P, N, ecount, L, i)
                if q > bestq
                    best = i; bestq = q
                end
            end
            best == 0 && break
            a, b, c = L[mod1(best - 1, n)], L[best], L[mod1(best + 1, n)]
            push!(tris, Tri(c, b, a))
            added += 1
            for e in ((c, b), (b, a), (a, c))
                u = minmax(e...)
                ecount[u] = get(ecount, u, 0) + 1
            end
            if n == 3
                closed += 1
                break
            end
            deleteat!(L, best)
        end
    end
    stats = deepcopy(mesh.stats)
    stats.filled_loops += closed
    stats.filled_triangles += added
    stats.boundary_edges = count(==(1), values(ecount))
    BPAMesh(mesh.cloud, tris, stats)
end

"""
    boundary_loops(directed) -> Vector{Vector{Int}}

The boundary loops of a mesh given as the set of its half-edges: vertex lists in the order
of the half-edges that have no opposite. Loops through a vertex that starts more than one
boundary half-edge (a pinched vertex) are not returned.
"""
function boundary_loops(directed::Set{Tuple{Int,Int}})
    next = Dict{Int,Int}()
    pinched = Set{Int}()
    for (a, b) in directed
        (b, a) in directed && continue
        haskey(next, a) ? push!(pinched, a) : (next[a] = b)
    end
    loops = Vector{Int}[]
    seen = Set{Int}()
    for a0 in sort!(collect(keys(next)))
        a0 in seen && continue
        loop = Int[]
        a = a0
        ok = true
        while true
            if a in seen || a in pinched || !haskey(next, a)
                ok = false
                break
            end
            push!(seen, a)
            push!(loop, a)
            a = next[a]
            a == a0 && break
        end
        ok && push!(loops, loop)
    end
    loops
end

"""
    ear_quality(P, N, ecount, L, i) -> Float64

Quality of the ear at position `i` of loop `L`, the sine of the smallest angle of the
triangle, or `-1` if the ear may not be clipped (see [`fill_small_loops`](@ref)).
"""
function ear_quality(P, N, ecount, L, i)
    n = length(L)
    a, b, c = L[mod1(i - 1, n)], L[i], L[mod1(i + 1, n)]
    pa, pb, pc = P[a], P[b], P[c]
    circumcircle(pc, pb, pa) === nothing && return -1.0
    tn = triangle_normal(pc, pb, pa)
    orientation_consistent(tn, N[a], N[b], N[c]) || return -1.0
    if n > 3
        get(ecount, minmax(a, c), 0) == 0 || return -1.0
        for j in 1:n
            (j == i || j == mod1(i - 1, n) || j == mod1(i + 1, n)) && continue
            inside_triangle(P[L[j]], pa, pb, pc) && return -1.0
        end
    end
    # sine of the smallest angle: twice the area over the product of the two longest sides
    lab, lbc, lca = norm(pb - pa), norm(pc - pb), norm(pa - pc)
    s = sort(SVector(lab, lbc, lca))
    norm(tn) / (s[2] * s[3])
end

"""
    inside_triangle(p, a, b, c) -> Bool

`true` if the projection of `p` onto the plane of the triangle `(a, b, c)` lies inside it
or on its boundary (barycentric coordinates).
"""
function inside_triangle(p::Vec3, a::Vec3, b::Vec3, c::Vec3)
    v0 = b - a; v1 = c - a; v2 = p - a
    d00 = dot(v0, v0); d01 = dot(v0, v1); d11 = dot(v1, v1)
    d02 = dot(v0, v2); d12 = dot(v1, v2)
    den = d00 * d11 - d01 * d01
    den > 0 || return false
    u = (d11 * d02 - d01 * d12) / den
    v = (d00 * d12 - d01 * d02) / den
    u >= 0 && v >= 0 && u + v <= 1
end
