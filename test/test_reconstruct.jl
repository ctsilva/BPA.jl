@testset "sphere" begin
    n = 2000
    P, N = fibonacci_sphere(n)
    rho = 1.5 * sphere_spacing(n)
    mesh = reconstruct(P, N, rho)
    c = check_mesh(mesh.triangles)
    @test c.nverts == n                     # every point interpolated
    @test c.orientable && c.edge_manifold && c.vertex_manifold
    @test c.boundary_edges == 0
    @test c.components == 1
    @test c.chi == 2
    @test c.nfaces == 2n - 4
    @test outward(mesh.triangles, P, zero(P[1]))
    @test mesh.stats.seeds == 1
    @test mesh.stats.boundary_edges == 0
    @test mesh.stats.triangles_per_pass == [c.nfaces]

    # Matrix inputs and PointCloud inputs give the same result
    Pm = reduce(hcat, P); Nm = reduce(hcat, N)
    @test reconstruct(Pm, Nm, rho).triangles == mesh.triangles
    @test reconstruct(PointCloud(Pm', Nm'), rho).triangles == mesh.triangles
    @test reconstruct(PointCloud(P, N), [rho]).triangles == mesh.triangles
end

@testset "torus" begin
    P, N = torus(120, 48)
    rho = 0.09
    mesh = reconstruct(P, N, rho)
    c = check_mesh(mesh.triangles)
    @test c.nverts == length(P)
    @test c.orientable && c.edge_manifold && c.vertex_manifold
    @test c.boundary_edges == 0
    @test c.components == 1
    @test c.chi == 0
    for t in mesh.triangles
        a, b, d = P[t[1]], P[t[2]], P[t[3]]
        @test dot(cross(b - a, d - a), N[t[1]] + N[t[2]] + N[t[3]]) > 0
    end
end

@testset "plane patch" begin
    nx = 40
    P, N = plane_patch(nx, nx)
    rho = 1.3 / nx
    mesh = reconstruct(P, N, rho)
    c = check_mesh(mesh.triangles)
    @test c.nverts == length(P)
    @test c.orientable && c.edge_manifold && c.vertex_manifold
    @test c.components == 1
    @test c.chi == 1
    @test c.boundary_loops == 1
    @test c.boundary_clean
    @test mesh.stats.boundary_edges == c.boundary_edges
    @test all(t -> cross(P[t[2]] - P[t[1]], P[t[3]] - P[t[1]])[3] > 0, mesh.triangles)
end

@testset "regular lattices (cospherical quads)" begin
    # Every quad of an unjittered lattice has four cospherical corners, so the ball hits two
    # points at the same angle; the tie-break must pick the same diagonal from every side.
    P, N = torus(60, 24; jitter = 0.0)
    for rho in (0.15, 0.2, 0.3)
        mesh = reconstruct(P, N, rho)
        c = check_mesh(mesh.triangles)
        @test c.nverts == length(P)
        @test c.orientable && c.edge_manifold && c.vertex_manifold
        @test c.boundary_edges == 0
        @test c.chi == 0
        @test c.nfaces == 2 * length(P)
    end
    P, N = plane_patch(30, 30; jitter = 0.0)
    mesh = reconstruct(P, N, 1.3 / 30)
    c = check_mesh(mesh.triangles)
    @test c.nverts == length(P)
    @test c.orientable && c.edge_manifold && c.vertex_manifold
    @test c.chi == 1 && c.boundary_loops == 1 && c.boundary_clean
    @test c.nfaces == 2 * 29 * 29
end

@testset "multiple passes on uneven sampling" begin
    h = 1 / 40
    Pd, Nd = plane_patch(20, 40; spacing = h, rng = Random.Xoshiro(3))
    Ps, Ns = plane_patch(8, 16; spacing = 2.5h, rng = Random.Xoshiro(4), origin = (20h, 0.0))
    P = vcat(Pd, Ps); N = vcat(Nd, Ns)

    # one small radius: the sparse half is not reached
    m1 = reconstruct(P, N, 1.3h)
    c1 = check_mesh(m1.triangles)
    @test c1.nverts < length(P)
    @test c1.orientable && c1.edge_manifold
    @test m1.stats.boundary_edges > 0

    # two radii: the whole patch is covered by a single boundary loop
    m2 = reconstruct(P, N, [1.3h, 1.3 * 2.5h])
    c2 = check_mesh(m2.triangles)
    @test c2.nverts == length(P)
    @test c2.orientable && c2.edge_manifold && c2.vertex_manifold
    @test c2.components == 1
    @test c2.chi == 1
    @test c2.boundary_loops == 1
    @test c2.boundary_clean
    @test m2.stats.triangles_per_pass[1] == length(m1.triangles)
    @test m2.stats.triangles_per_pass[2] > 0
    @test m2.stats.reactivated_per_pass[2] > 0
    @test length(m2.stats.triangles_per_pass) == 2
end

@testset "degenerate input" begin
    P, N = fibonacci_sphere(100)
    # too small a radius: nothing can be built
    @test isempty(reconstruct(P, N, 1e-4).triangles)
    # fewer than three points
    @test isempty(reconstruct(P[1:2], N[1:2], 1.0).triangles)
    @test isempty(reconstruct(P[1:0], N[1:0], 1.0).triangles)
    # duplicated points do not crash and the result is still a manifold
    Pd = vcat(P, P[1:10]); Nd = vcat(N, N[1:10])
    m = reconstruct(Pd, Nd, 1.5 * sphere_spacing(100))
    c = check_mesh(m.triangles)
    @test c.orientable && c.edge_manifold
    @test_throws ArgumentError reconstruct(P, N, Float64[])
    @test_throws ArgumentError reconstruct(P, N, -1.0)
    @test_throws ArgumentError PointCloud(P, N[1:10])
end

@testset "file I/O" begin
    P, N = fibonacci_sphere(300)
    mesh = reconstruct(P, N, 1.5 * sphere_spacing(300))
    dir = mktempdir()
    ply = write_ply(joinpath(dir, "sphere.ply"), mesh)
    cloud = read_ply(ply)
    @test length(cloud) == 300
    @test all(isapprox.(cloud.positions, P; atol = 1e-6))
    @test all(isapprox.(cloud.normals, N; atol = 1e-6))
    obj = write_obj(joinpath(dir, "sphere.obj"), mesh)
    lines = readlines(obj)
    @test count(startswith("v "), lines) == 300
    @test count(startswith("vn "), lines) == 300
    @test count(startswith("f "), lines) == length(mesh.triangles)
    xyz = joinpath(dir, "sphere.xyz")
    open(xyz, "w") do io
        println(io, "# comment")
        for (p, n) in zip(P, N)
            println(io, join(p, " "), " ", join(n, " "))
        end
    end
    cloud = read_xyz(xyz)
    @test length(cloud) == 300
    @test all(isapprox.(cloud.positions, P; atol = 1e-12))
end
