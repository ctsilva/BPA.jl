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

# ------------------------------------------------------------------ the empty-ball audit

"""
The classes `audit_triangles` sorts triangles into. `:valid` is what the BPA produces; the
others are, in order, a triangle wound against its normals but whose outward ball is empty,
one whose ball holds another point by less than the tie tolerance (a cospherical tie, not an
error), one whose ball holds another point (not a BPA triangle), one too large for the ball,
and one with a repeated vertex.
"""
const AUDIT_CLASSES = (:valid, :valid_reversed_winding, :ball_not_empty_tie, :ball_not_empty,
                       :circumradius_too_large, :degenerate)

"""
    classify_triangle(positions, normals, grid, rho, t) -> (class, depth)

Classify a triangle by the defining BPA property: the `rho`-ball through its three vertices
on the outward side contains no other sample point. The outward side is the one all three
vertex normals agree on when they do; when they do not (a vertex without a normal, or a
normal at right angles to a steep triangle between two scan layers) both sides are tried,
the winding side first, which is where a pivoting ball sits, then the reverse. Returns the
class (`:valid`, `:valid_reversed_winding`, `:ball_not_empty`, `:circumradius_too_large`
or `:degenerate`) and, for `:ball_not_empty`, how deep the most intruding point sits in the
ball as a fraction of `rho` (the shallower side when both were tried). `grid` is a
`VoxelGrid` of the positions with voxel side `2rho`.
"""
function classify_triangle(P, N, grid::VoxelGrid, rho, t)
    a, b, c = t
    (a == b || b == c || a == c) && return :degenerate, 0.0
    n = triangle_normal(P[a], P[b], P[c])
    sides = if orientation_consistent(n, N[a], N[b], N[c])
        (1,)
    elseif orientation_consistent(-n, N[a], N[b], N[c])
        (-1,)
    else
        (1, -1)
    end
    worst = Inf
    buf = Int[]
    for side in sides
        bb, cc = side > 0 ? (b, c) : (c, b)
        ctr = ball_center(P[a], P[bb], P[cc], rho)
        ctr === nothing && return :circumradius_too_large, 0.0
        empty_ball(grid, ctr, rho, a, b, c) && return (side > 0 ? :valid : :valid_reversed_winding), 0.0
        neighbors!(buf, grid, ctr, rho)
        depth = maximum((rho - sqrt(sum(abs2, P[id] - ctr))) / rho
                        for id in buf if !(id == a || id == b || id == c); init = 0.0)
        worst = min(worst, depth)
    end
    return :ball_not_empty, worst
end

"""
Result of [`audit_triangles`](@ref): the number of triangles in each class of
`AUDIT_CLASSES` (absent classes count zero), the class of each triangle, and the deepest
intrusion among the `:ball_not_empty` triangles as a fraction of `rho`.
"""
struct BallAudit
    classes::Dict{Symbol,Int}
    per_triangle::Vector{Symbol}
    max_depth::Float64
end

Base.getindex(a::BallAudit, k::Symbol) = get(a.classes, k, 0)

"""
    audit_triangles(cloud, rho, triangles; grid, tie=1e-5) -> BallAudit

Classify every triangle by the empty-ball property for the ball radius `rho` (see
[`classify_triangle`](@ref)). Intrusions of at most `tie` times `rho` are reported as
`:ball_not_empty_tie`: on regularly sampled data four cospherical points make the fourth
lie on the ball within rounding, and either diagonal is a legitimate BPA triangle. This is
the correctness test of the comparison harness in `compare/`, and `tools/check.jl` runs it
on any mesh. A BPA output has every triangle `:valid`; a mesh from another tool, or one
completed by [`fill_small_loops`](@ref), shows where it departs from the algorithm.
"""
function audit_triangles(cloud::PointCloud, rho::Real, tris;
                         grid::VoxelGrid = VoxelGrid(cloud.positions, 2rho), tie::Real = 1e-5)
    P, N = cloud.positions, cloud.normals
    classes = Dict{Symbol,Int}()
    per = Vector{Symbol}(undef, length(tris))
    max_depth = 0.0
    for (i, t) in enumerate(tris)
        k, d = classify_triangle(P, N, grid, rho, t)
        k == :ball_not_empty && d <= tie && (k = :ball_not_empty_tie)
        classes[k] = get(classes, k, 0) + 1
        per[i] = k
        k == :ball_not_empty && (max_depth = max(max_depth, d))
    end
    BallAudit(classes, per, max_depth)
end

# ------------------------------------------------------------------ sizes, and a report

"""
    boundary_loop_sizes(triangles) -> Vector{Int}

Number of edges in each boundary loop, ascending: the connected components of the graph of
edges with a single triangle (a pinched loop counts as one).
"""
function boundary_loop_sizes(tris)
    count = Dict{Tuple{Int,Int},Int}()
    for t in tris, e in ((t[1], t[2]), (t[2], t[3]), (t[3], t[1]))
        u = minmax(e...)
        count[u] = get(count, u, 0) + 1
    end
    boundary = [e for (e, c) in count if c == 1]
    isempty(boundary) && return Int[]
    maxv = maximum(max(e[1], e[2]) for e in boundary)
    parent = collect(1:maxv)
    for (a, b) in boundary
        _union!(parent, a, b)
    end
    sizes = Dict{Int,Int}()
    for (a, b) in boundary
        r = _find(parent, a)
        sizes[r] = get(sizes, r, 0) + 1
    end
    sort!(collect(values(sizes)))
end

"""
    component_sizes(triangles) -> Vector{Int}

Number of triangles in each connected component (triangles joined by a shared vertex),
descending.
"""
function component_sizes(tris)
    isempty(tris) && return Int[]
    maxv = maximum(maximum(t) for t in tris)
    parent = collect(1:maxv)
    for t in tris
        _union!(parent, t[1], t[2])
        _union!(parent, t[2], t[3])
    end
    sizes = Dict{Int,Int}()
    for t in tris
        r = _find(parent, t[1])
        sizes[r] = get(sizes, r, 0) + 1
    end
    sort!(collect(values(sizes)); rev = true)
end

"Buckets of the boundary loop histogram in `report_mesh`: loops of at most 10 edges, 11–50, 51–200, larger."
const LOOP_BUCKETS = (10, 50, 200)

"""
    report_mesh(io, triangles; cloud=nothing, rho=nothing, npoints=nothing)

Print what `check_mesh`, `component_sizes` and `boundary_loop_sizes` say about a triangle
list, and, when both the point `cloud` and the ball radius `rho` are given, the
[`audit_triangles`](@ref) counts. `npoints` (the size of the cloud, if no cloud is given)
lets the "vertices used" line show a fraction. This is the report of `--check` and of
`tools/check.jl`.
"""
function report_mesh(io::IO, tris; cloud = nothing, rho = nothing, npoints = nothing)
    c = check_mesh(tris)
    n = cloud === nothing ? npoints : length(cloud)
    println(io, "triangles: ", length(tris), ", vertices used: ", c.nverts,
            n === nothing ? "" : " of $n")
    yn(b) = b ? "yes" : "no"
    println(io, "orientable: ", yn(c.orientable), ", edge-manifold: ", yn(c.edge_manifold),
            ", vertex-manifold: ", yn(c.vertex_manifold), ", Euler characteristic: ", c.chi)
    cs = component_sizes(tris)
    small = count(<(10), cs)
    println(io, "components: ", length(cs), isempty(cs) ? "" :
            " (largest $(cs[1]) triangles" * (small > 0 ? ", $small of fewer than 10)" : ")"))
    ls = boundary_loop_sizes(tris)
    if isempty(ls)
        println(io, "boundary edges: 0")
    else
        b1, b2, b3 = LOOP_BUCKETS
        h = (count(<=(b1), ls), count(x -> b1 < x <= b2, ls), count(x -> b2 < x <= b3, ls), count(>(b3), ls))
        println(io, "boundary edges: ", sum(ls), " in ", length(ls), " loops (", h[1], " of at most $b1 edges, ",
                h[2], " of $(b1+1)-$b2, ", h[3], " of $(b2+1)-$b3, ", h[4], " larger; largest ", ls[end], " edges)",
                c.boundary_clean ? "" : ", some loops pinched")
    end
    if cloud !== nothing && rho !== nothing
        au = audit_triangles(cloud, rho, tris)
        parts = ["$k $(au[k])" for k in AUDIT_CLASSES if au[k] > 0]
        print(io, "empty-ball audit at rho = ", rho, ": ", join(parts, ", "))
        au[:ball_not_empty] > 0 && print(io, "; deepest intrusion ", round(au.max_depth; sigdigits = 3), " rho")
        println(io)
    end
    c
end
