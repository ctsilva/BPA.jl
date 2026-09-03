# Topological checks on a triangle list (1-based vertex ids), for tests and for auditing any
# reconstruction, this package's or another's (see compare/).
#
# `check_mesh(triangles)` returns a `MeshCheck`. For a correct BPA output one expects
# `orientable`, `edge_manifold` and `vertex_manifold` to hold; for a closed surface
# `boundary_edges == 0` and `chi` to be 2 (sphere) or 0 (torus); for a disk `chi == 1` with
# one clean boundary loop.

"Summary of the topology of a triangle mesh; see the file header for what to expect."
struct MeshCheck
    nverts::Int
    nedges::Int
    nfaces::Int
    chi::Int                 # Euler characteristic V - E + F
    orientable::Bool         # no directed half-edge appears twice
    edge_manifold::Bool      # every undirected edge has at most two triangles
    vertex_manifold::Bool    # the link of every vertex is a single path or cycle
    boundary_edges::Int
    boundary_loops::Int      # connected components of the boundary edge graph
    boundary_clean::Bool     # every boundary vertex has exactly two boundary edges
    components::Int          # edge-connected components of the triangle set
end

function _find(parent, x)
    while parent[x] != x
        parent[x] = parent[parent[x]]
        x = parent[x]
    end
    x
end
_union!(parent, a, b) = (ra = _find(parent, a); rb = _find(parent, b); ra != rb && (parent[ra] = rb); nothing)

"""
    check_mesh(triangles) -> MeshCheck

Compute half-edge multiplicities, Euler characteristic, boundary loops, connected components
and per-vertex link topology of a triangle list. Brute force; intended for test sizes.
"""
function check_mesh(tris)
    directed = Dict{Tuple{Int,Int},Int}()
    undirected = Dict{Tuple{Int,Int},Int}()
    verts = Set{Int}()
    for t in tris
        for (a, b) in ((t[1], t[2]), (t[2], t[3]), (t[3], t[1]))
            directed[(a, b)] = get(directed, (a, b), 0) + 1
            u = minmax(a, b)
            undirected[u] = get(undirected, u, 0) + 1
            push!(verts, a)
        end
    end
    orientable = all(==(1), values(directed))
    edge_manifold = all(<=(2), values(undirected))
    boundary = [e for (e, c) in undirected if c == 1]
    V, E, F = length(verts), length(undirected), length(tris)

    # boundary loops
    maxv = isempty(verts) ? 0 : maximum(verts)
    parent = collect(1:maxv)
    bdeg = zeros(Int, maxv)
    for (a, b) in boundary
        _union!(parent, a, b)
        bdeg[a] += 1
        bdeg[b] += 1
    end
    bverts = Set(v for e in boundary for v in e)
    boundary_loops = length(Set(_find(parent, v) for v in bverts))
    boundary_clean = all(v -> bdeg[v] == 2, bverts)

    # connected components (vertices joined by mesh edges)
    parent = collect(1:maxv)
    for (a, b) in keys(undirected)
        _union!(parent, a, b)
    end
    components = length(Set(_find(parent, v) for v in verts))

    # vertex manifoldness: link of each vertex is a single path or cycle
    link = Dict{Int,Vector{Tuple{Int,Int}}}()
    for t in tris
        for (v, b, c) in ((t[1], t[2], t[3]), (t[2], t[3], t[1]), (t[3], t[1], t[2]))
            push!(get!(link, v, Tuple{Int,Int}[]), (b, c))
        end
    end
    vertex_manifold = true
    for (v, edges) in link
        deg = Dict{Int,Int}()
        lp = Dict{Int,Int}()
        for (b, c) in edges
            deg[b] = get(deg, b, 0) + 1
            deg[c] = get(deg, c, 0) + 1
            get!(lp, b, b); get!(lp, c, c)
        end
        if any(>(2), values(deg))
            vertex_manifold = false
            break
        end
        # count components of the link graph
        function lfind(x)
            while lp[x] != x
                lp[x] = lp[lp[x]]
                x = lp[x]
            end
            x
        end
        for (b, c) in edges
            rb, rc = lfind(b), lfind(c)
            rb != rc && (lp[rb] = rc)
        end
        if length(Set(lfind(x) for x in keys(lp))) != 1
            vertex_manifold = false
            break
        end
    end

    MeshCheck(V, E, F, V - E + F, orientable, edge_manifold, vertex_manifold,
              length(boundary), boundary_loops, boundary_clean, components)
end

"""
    outward(tris, positions, center) -> Bool

`true` if every triangle normal points away from `center` (for star-shaped closed surfaces).
"""
function outward(tris, positions, center)
    for t in tris
        a, b, c = positions[t[1]], positions[t[2]], positions[t[3]]
        n = cross(b - a, c - a)
        dot(n, (a + b + c) / 3 - center) > 0 || return false
    end
    true
end
