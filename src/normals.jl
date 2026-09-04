# Normal estimation and orientation for point clouds that come without usable normals,
# after Hoppe, DeRose, Duchamp, McDonald and Stuetzle, "Surface reconstruction from
# unorganized points", SIGGRAPH 1992, Section 3.2. Not part of the BPA paper, which assumes
# oriented normals: the BPA needs them for the seed test and to keep the ball on the outside
# of the surface, and inconsistently signed normals fragment the output into many pieces.
#
# Two steps, usable separately:
#   * `estimate_normals`: the normal at a point is the direction of least variance of its k
#     nearest neighbours (the eigenvector of the smallest eigenvalue of their covariance),
#     which fixes the line of the normal but not its sign;
#   * `orient_normals!`: the signs are propagated over the minimum spanning tree of the
#     k-nearest-neighbour graph with edge weights 1 - |n_i · n_j|, so that the propagation
#     runs along flat regions first and crosses creases and thin sheets last, starting at the
#     highest point of each connected piece of the graph with its normal pointing up.
#
# Both use `nearest_neighbors`, which finds the k nearest neighbours of every point with the
# same `VoxelGrid` the reconstruction uses.

"""
    nearest_neighbors(positions, k; spacing) -> Matrix{Int32}

The `k` nearest neighbours of every point, the point itself excluded, as a `k × n` matrix of
indices in order of increasing distance; a column is padded with zeros when fewer than `k`
other points exist. Radius queries on a `VoxelGrid` are used, the radius starting at
`spacing * sqrt(k)` (`spacing` defaults to `estimate_spacing(positions)`) and doubling for
the points that did not find `k` neighbours within it.
"""
function nearest_neighbors(P::Vector{Vec3}, k::Integer; spacing::Union{Nothing,Real} = nothing)
    n = length(P)
    k = min(Int(k), max(n - 1, 0))
    nb = zeros(Int32, k, n)
    k == 0 && return nb
    spacing === nothing && (spacing = estimate_spacing(P))
    lo = reduce((a, b) -> min.(a, b), P)
    hi = reduce((a, b) -> max.(a, b), P)
    diag = norm(hi - lo)
    r = spacing > 0 ? spacing * sqrt(k) : diag > 0 ? diag / 2 : 1.0
    todo = collect(1:n)
    buf = Int[]
    d2 = Float64[]
    perm = Int[]
    while !isempty(todo)
        final = r >= diag                  # every point is within reach: the last round
        g = VoxelGrid(P, r)
        still = Int[]
        for i in todo
            neighbors!(buf, g, P[i], r)
            filter!(!=(i), buf)
            if length(buf) < k && !final
                push!(still, i)
                continue
            end
            m = length(buf)
            resize!(d2, m)
            resize!(perm, m)
            pi = P[i]
            for (t, j) in enumerate(buf)
                d2[t] = sum(abs2, P[j] - pi)
            end
            kk = min(k, m)
            partialsortperm!(perm, d2, 1:kk)
            for t in 1:kk
                nb[t, i] = buf[perm[t]]
            end
        end
        todo = still
        r *= 2
    end
    nb
end

"""
    smallest_eigenvector(xx, xy, xz, yy, yz, zz) -> Vec3

Unit eigenvector of the smallest eigenvalue of the symmetric matrix with the given upper
triangle, in closed form (the eigenvalues by the trigonometric formula for a 3×3 symmetric
matrix, the eigenvector as the cross product of two rows of `A - λI`). When the two smallest
eigenvalues coincide (points on a line) any unit vector of the eigenspace is returned; when
all three do (no spread at all) the zero vector.
"""
function smallest_eigenvector(xx::Float64, xy::Float64, xz::Float64, yy::Float64, yz::Float64, zz::Float64)
    scale = max(abs(xx), abs(xy), abs(xz), abs(yy), abs(yz), abs(zz))
    scale > 0 || return zero(Vec3)
    q = (xx + yy + zz) / 3
    p2 = (xx - q)^2 + (yy - q)^2 + (zz - q)^2 + 2 * (xy^2 + xz^2 + yz^2)
    p2 <= (1e-14 * scale)^2 && return zero(Vec3)     # a multiple of the identity
    p = sqrt(p2 / 6)
    b11, b22, b33 = (xx - q) / p, (yy - q) / p, (zz - q) / p
    b12, b13, b23 = xy / p, xz / p, yz / p
    detb = b11 * (b22 * b33 - b23 * b23) - b12 * (b12 * b33 - b23 * b13) + b13 * (b12 * b23 - b22 * b13)
    φ = acos(clamp(detb / 2, -1.0, 1.0)) / 3
    λ = q + 2 * p * cos(φ + 2π / 3)                    # the smallest eigenvalue
    r1 = Vec3(xx - λ, xy, xz)
    r2 = Vec3(xy, yy - λ, yz)
    r3 = Vec3(xz, yz, zz - λ)
    c1 = cross(r1, r2); c2 = cross(r2, r3); c3 = cross(r3, r1)
    n1, n2, n3 = dot(c1, c1), dot(c2, c2), dot(c3, c3)
    best = n1 >= n2 && n1 >= n3 ? c1 : n2 >= n3 ? c2 : c3
    nb = sqrt(max(n1, n2, n3))
    if nb > 1e-10 * scale^2
        return best / nb
    end
    # rank one: the rows are parallel; any direction perpendicular to them is an eigenvector
    m1, m2, m3 = dot(r1, r1), dot(r2, r2), dot(r3, r3)
    r = m1 >= m2 && m1 >= m3 ? r1 : m2 >= m3 ? r2 : r3
    a = abs(r[1]) <= abs(r[2]) && abs(r[1]) <= abs(r[3]) ? Vec3(1, 0, 0) :
        abs(r[2]) <= abs(r[3]) ? Vec3(0, 1, 0) : Vec3(0, 0, 1)
    _unit(cross(r, a))
end

"""
    pca_normal(positions, i, neighbors) -> Vec3

Unit normal at point `i` from the covariance of the point and its neighbours (indices,
zero-padded) about their centroid: the direction of least variance. Zero if fewer than two
neighbours exist.
"""
function pca_normal(P::Vector{Vec3}, i::Int, nb)
    c = P[i]
    m = 0
    for j in nb
        j == 0 && break
        c += P[j]
        m += 1
    end
    m >= 2 || return zero(Vec3)
    c /= m + 1
    xx = xy = xz = yy = yz = zz = 0.0
    d = P[i] - c
    xx += d[1] * d[1]; xy += d[1] * d[2]; xz += d[1] * d[3]; yy += d[2] * d[2]; yz += d[2] * d[3]; zz += d[3] * d[3]
    for j in nb
        j == 0 && break
        d = P[j] - c
        xx += d[1] * d[1]; xy += d[1] * d[2]; xz += d[1] * d[3]; yy += d[2] * d[2]; yz += d[2] * d[3]; zz += d[3] * d[3]
    end
    smallest_eigenvector(xx, xy, xz, yy, yz, zz)
end

"""
    estimate_normals(positions; k=10, orient=true, spacing) -> Vector{Vec3}

Unit normals for a point cloud from its positions alone: at each point the direction of
least variance of its `k` nearest neighbours (`pca_normal`), then, with `orient`, the signs
made consistent by [`orient_normals!`](@ref) over the same neighbours. Points with fewer
than two neighbours get a zero normal, which the reconstruction treats as "no normal".

`k` around 10 suits clean, evenly sampled data; noisy data wants more. The result is only as
good as the sampling: at creases and on thin sheets the least-variance direction is a
compromise between the sides, and any orientation can be wrong across a gap. Range scans
that come as meshes are better served by [`vertex_normals`](@ref).
"""
function estimate_normals(P::Vector{Vec3}; k::Integer = 10, orient::Bool = true,
                          spacing::Union{Nothing,Real} = nothing)
    k >= 1 || throw(ArgumentError("k must be positive"))
    nb = nearest_neighbors(P, k; spacing = spacing)
    N = [pca_normal(P, i, view(nb, :, i)) for i in eachindex(P)]
    orient && orient_normals!(N, P; neighbors = nb)
    N
end

"""
    orient_normals!(normals, positions; k=10, neighbors) -> (components, flipped)
    orient_normals!(cloud::PointCloud; k=10) -> (components, flipped)

Make the signs of `normals` consistent in place, keeping their directions: Hoppe's method.
The `k`-nearest-neighbour graph (`neighbors`, a `k × n` matrix as returned by
[`nearest_neighbors`](@ref)) is weighted by `1 - |n_i · n_j|`, its minimum spanning tree is
built, and from the highest point of each connected component, its normal turned upward, the
sign is propagated along the tree, each normal flipped to agree with its parent. Returns the
number of components of the graph and of normals flipped. A zero normal is left alone.

Two sides of a thin sheet, or two surfaces closer than the neighbour distance, share
neighbours; the tree crosses between them only where every flatter path is exhausted, which
is what makes this better than a breadth-first walk, but it can still be wrong there.
"""
function orient_normals!(N::Vector{Vec3}, P::Vector{Vec3}; k::Integer = 10,
                         neighbors::AbstractMatrix{<:Integer} = nearest_neighbors(P, k))
    n = length(P)
    length(N) == n || throw(ArgumentError("normals and positions must have the same length"))
    size(neighbors, 2) == n || throw(ArgumentError("neighbors must have one column per point"))
    kk = size(neighbors, 1)
    # Edges of the neighbour graph, each unordered pair once, weighted by disagreement.
    ei = Int32[]; ej = Int32[]; w = Float32[]
    for i in 1:n, s in 1:kk
        j = Int(neighbors[s, i])
        j == 0 && break
        (j > i || !(i in view(neighbors, :, j))) || continue
        push!(ei, i); push!(ej, j)
        push!(w, Float32(1 - abs(dot(N[i], N[j]))))
    end
    # Kruskal: the lightest edges first, joining trees.
    parent = collect(Int32(1):Int32(n))
    function root(x)
        while parent[x] != x
            parent[x] = parent[parent[x]]
            x = parent[x]
        end
        x
    end
    deg = zeros(Int32, n)
    mi = Int32[]; mj = Int32[]
    for e in sortperm(w)
        a, b = root(ei[e]), root(ej[e])
        a == b && continue
        parent[a] = b
        push!(mi, ei[e]); push!(mj, ej[e])
        deg[ei[e]] += 1; deg[ej[e]] += 1
    end
    # The tree as adjacency lists in one array.
    start = Vector{Int}(undef, n + 1)
    start[1] = 1
    for v in 1:n
        start[v + 1] = start[v] + deg[v]
    end
    fillpos = copy(start)
    adj = Vector{Int32}(undef, 2 * length(mi))
    for (a, b) in zip(mi, mj)
        adj[fillpos[a]] = b; fillpos[a] += 1
        adj[fillpos[b]] = a; fillpos[b] += 1
    end
    # Propagate from the highest point of each component, depth first.
    seen = falses(n)
    components = 0
    flipped = 0
    stack = Int[]
    for s in sortperm(P; by = p -> p[3], rev = true)
        seen[s] && continue
        components += 1
        seen[s] = true
        if N[s][3] < 0
            N[s] = -N[s]; flipped += 1
        end
        push!(stack, s)
        while !isempty(stack)
            i = pop!(stack)
            for t in start[i]:start[i + 1] - 1
                j = Int(adj[t])
                seen[j] && continue
                seen[j] = true
                if dot(N[i], N[j]) < 0
                    N[j] = -N[j]; flipped += 1
                end
                push!(stack, j)
            end
        end
    end
    components, flipped
end

orient_normals!(cloud::PointCloud; k::Integer = 10) = orient_normals!(cloud.normals, cloud.positions; k = k)
