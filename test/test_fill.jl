using BPA: boundary_loops, inside_triangle, triangle_normal

tset(tris) = Set(Tuple(sort(collect(t))) for t in tris)
tnormal(P, t) = triangle_normal(P[t[1]], P[t[2]], P[t[3]])

@testset "fill_small_loops" begin
    n = 2000
    P, N = fibonacci_sphere(n)
    full = reconstruct(P, N, 1.5 * sphere_spacing(n))
    @test check_mesh(full.triangles).boundary_edges == 0

    # one triangle removed: the loop of three edges is closed by the same triangle
    hole = BPAMesh(full.cloud, full.triangles[2:end], deepcopy(full.stats))
    hole.stats.boundary_edges = 3
    filled = fill_small_loops(hole)
    @test filled.stats.filled_loops == 1 && filled.stats.filled_triangles == 1
    @test filled.stats.boundary_edges == 0
    @test length(filled.triangles) == length(full.triangles)
    @test filled.triangles[1:end-1] == hole.triangles             # appended, not reordered
    @test tset(filled.triangles) == tset(full.triangles)
    t = filled.triangles[end]
    @test dot(tnormal(P, t), P[t[1]]) > 0                           # outward winding
    c = check_mesh(filled.triangles)
    @test c.chi == 2 && c.boundary_edges == 0 && c.orientable && c.edge_manifold && c.vertex_manifold
    @test hole.stats.filled_triangles == 0                          # the input is untouched
    @test length(hole.triangles) == length(full.triangles) - 1

    # the fan of a vertex removed: a loop of its valence, filled with valence - 2 triangles
    v = 777
    fan = filter(t -> !(v in t), full.triangles)
    valence = length(full.triangles) - length(fan)
    @test valence >= 5
    hole = BPAMesh(full.cloud, fan, deepcopy(full.stats))
    filled = fill_small_loops(hole)
    @test filled.stats.filled_loops == 1 && filled.stats.filled_triangles == valence - 2
    @test filled.stats.boundary_edges == 0
    c = check_mesh(filled.triangles)
    @test c.chi == 2 && c.boundary_edges == 0 && c.orientable && c.edge_manifold && c.vertex_manifold
    @test c.nverts == n - 1                                          # v itself stays unused
    @test all(dot(tnormal(P, t), P[t[1]]) > 0 for t in filled.triangles[length(fan)+1:end])

    # the size limit is respected, and a filled mesh is a fixed point
    @test fill_small_loops(hole; max_edges = valence - 1).triangles == fan
    @test fill_small_loops(hole; max_edges = valence).stats.filled_loops == 1
    again = fill_small_loops(filled)
    @test again.triangles == filled.triangles && again.stats.filled_triangles == valence - 2
    @test fill_small_loops(full).triangles == full.triangles
    @test_throws ArgumentError fill_small_loops(hole; max_edges = 2)

    # two separate holes are both closed, and never joined
    v2 = 1500
    fan2 = filter(t -> !(v in t) && !(v2 in t), full.triangles)
    hole2 = BPAMesh(full.cloud, fan2, deepcopy(full.stats))
    filled2 = fill_small_loops(hole2)
    @test filled2.stats.filled_loops == 2
    c = check_mesh(filled2.triangles)
    @test c.chi == 2 && c.boundary_edges == 0 && c.orientable && c.edge_manifold && c.vertex_manifold

    # a loop whose triangles would face against the normals is left alone
    ring = unique(vcat([collect(t) for t in full.triangles if v in t]...))
    Nflip = copy(N)
    for r in ring
        Nflip[r] = -Nflip[r]
    end
    hole3 = BPAMesh(PointCloud(P, Nflip), fan, deepcopy(full.stats))
    @test fill_small_loops(hole3).triangles == fan
end

@testset "boundary_loops and inside_triangle" begin
    # two triangles sharing an edge: one boundary loop of four vertices, in half-edge order
    tris = [Tri(1, 2, 3), Tri(1, 3, 4)]
    directed = Set{Tuple{Int,Int}}()
    for t in tris, e in ((t[1], t[2]), (t[2], t[3]), (t[3], t[1]))
        push!(directed, e)
    end
    loops = boundary_loops(directed)
    @test length(loops) == 1 && length(loops[1]) == 4
    l = loops[1]
    @test all(((l[i], l[mod1(i + 1, 4)]) in directed) for i in 1:4)
    @test isempty(boundary_loops(Set{Tuple{Int,Int}}()))
    # two triangles touching at a vertex: pinched, no loop is returned
    tris = [Tri(1, 2, 3), Tri(1, 4, 5)]
    directed = Set{Tuple{Int,Int}}()
    for t in tris, e in ((t[1], t[2]), (t[2], t[3]), (t[3], t[1]))
        push!(directed, e)
    end
    @test isempty(boundary_loops(directed))

    a, b, c = Vec3(0, 0, 0), Vec3(1, 0, 0), Vec3(0, 1, 0)
    @test inside_triangle(Vec3(0.2, 0.2, 5.0), a, b, c)             # projected onto the plane
    @test inside_triangle(Vec3(0.5, 0.5, 0), a, b, c)               # on the boundary counts
    @test !inside_triangle(Vec3(0.6, 0.6, 0), a, b, c)
    @test !inside_triangle(Vec3(-0.1, 0.5, 0), a, b, c)
    @test !inside_triangle(a, a, a, b)                              # degenerate triangle
end
