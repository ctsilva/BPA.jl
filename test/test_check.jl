using BPA: check_main, sweep_main, write_stats, load_cloud, parse_cli, main, write_xyz,
           AUDIT_CLASSES, classify_triangle, VoxelGrid

@testset "audit_triangles" begin
    n = 2000
    P, N = fibonacci_sphere(n)
    rho = 1.5 * sphere_spacing(n)
    cloud = PointCloud(P, N)
    mesh = reconstruct(cloud, rho)
    au = audit_triangles(cloud, rho, mesh.triangles)
    @test au[:valid] == length(mesh.triangles)
    @test all(==(:valid), au.per_triangle) && au.max_depth == 0
    @test all(k -> au[k] == 0, AUDIT_CLASSES[2:end])
    # reversed winding: the outward ball is still empty
    rev = [Tri(t[1], t[3], t[2]) for t in mesh.triangles]
    au = audit_triangles(cloud, rho, rev)
    @test au[:valid_reversed_winding] == length(rev) && au[:valid] == 0
    # zero normals: both sides are tried, the winding side first
    au = audit_triangles(PointCloud(P, fill(zero(Vec3), n)), rho, mesh.triangles)
    @test au[:valid] == length(mesh.triangles)
    # a triangle spanning the sphere is too big for the ball, or has points inside it; a degenerate one
    i, j = 1, argmin(dot(P[1], p) for p in P)                # antipode of σ_1
    k = argmin(abs(dot(P[1], p)) for p in P)                # a point on the equator
    au = audit_triangles(cloud, rho, [Tri(i, k, j), Tri(i, i, j), mesh.triangles[1]])
    @test au[:circumradius_too_large] == 1 && au[:degenerate] == 1 && au[:valid] == 1
    bigrho = 1.1                                             # a ball that fits the spanning triangle
    au = audit_triangles(cloud, bigrho, [Tri(i, k, j)])
    @test au[:ball_not_empty] == 1 && au.max_depth > 0.3
    # the tie tolerance: an intrusion below it is a tie, above it an error
    grid = VoxelGrid(P, 2bigrho)
    cls, depth = classify_triangle(P, N, grid, bigrho, Tri(i, k, j))
    @test cls == :ball_not_empty && depth ≈ au.max_depth
    @test audit_triangles(cloud, bigrho, [Tri(i, k, j)]; tie = 1.0)[:ball_not_empty_tie] == 1
    @test audit_triangles(cloud, rho, Tri[])[:valid] == 0
end

@testset "sizes" begin
    n = 2000
    P, N = fibonacci_sphere(n)
    full = reconstruct(P, N, 1.5 * sphere_spacing(n)).triangles
    @test boundary_loop_sizes(full) == Int[]
    @test component_sizes(full) == [length(full)]
    @test component_sizes(Tri[]) == Int[] && boundary_loop_sizes(Tri[]) == Int[]
    v = 777
    fan = filter(t -> !(v in t), full)
    valence = length(full) - length(fan)
    @test boundary_loop_sizes(fan) == [valence]
    @test boundary_loop_sizes(full[2:end]) == [3]
    two = filter(t -> !(v in t) && !(1500 in t), full)
    @test length(boundary_loop_sizes(two)) == 2 && sum(boundary_loop_sizes(two)) == check_mesh(two).boundary_edges
    # two spheres far apart: two components, largest first
    P2 = vcat(P, [p + Vec3(10, 0, 0) for p in P[1:1000]])
    N2 = vcat(N, N[1:1000])
    m2 = reconstruct(P2, N2, 1.5 * sphere_spacing(n))
    cs = component_sizes(m2.triangles)
    @test length(cs) == 2 && cs[1] >= cs[2] && sum(cs) == length(m2.triangles)
end

@testset "report_mesh" begin
    n = 2000
    P, N = fibonacci_sphere(n)
    rho = 1.5 * sphere_spacing(n)
    cloud = PointCloud(P, N)
    mesh = reconstruct(cloud, rho)
    log = sprint(io -> report_mesh(io, mesh.triangles; cloud = cloud, rho = rho))
    @test occursin("triangles: 3996, vertices used: 2000 of 2000", log)
    @test occursin("orientable: yes, edge-manifold: yes, vertex-manifold: yes, Euler characteristic: 2", log)
    @test occursin("components: 1 (largest 3996 triangles)", log)
    @test occursin("boundary edges: 0", log)
    @test occursin("empty-ball audit at rho = $rho: valid 3996\n", log)
    fan = filter(t -> !(777 in t), mesh.triangles)
    log = sprint(io -> report_mesh(io, fan; npoints = n))
    @test occursin("vertices used: 1999 of 2000", log)
    @test occursin(r"boundary edges: \d+ in 1 loops \(1 of at most 10 edges, 0 of 11-50, 0 of 51-200, 0 larger; largest \d+ edges\)", log)
    @test !occursin("empty-ball", log)
    log = sprint(io -> report_mesh(io, mesh.triangles))
    @test occursin("vertices used: 2000\n", log)
end

@testset "check.jl and sweep.jl" begin
    dir = mktempdir()
    n = 1500
    P, N = fibonacci_sphere(n)
    rho = 1.5 * sphere_spacing(n)
    cloud = PointCloud(P, N)
    mesh = reconstruct(cloud, rho)
    off = write_off(joinpath(dir, "sphere.off"), mesh)                 # plain OFF: no normals
    noff = write_off(joinpath(dir, "sphere_n.off"), mesh; normals = true)
    xyz = write_xyz(joinpath(dir, "sphere.xyz"), cloud)
    @test load_cloud(xyz).normals ≈ N
    @test load_cloud(noff).normals ≈ N
    pts = write_off(joinpath(dir, "pts.off"), BPAMesh(cloud, Tri[], BPAStats()); normals = false)
    @test all(iszero, load_cloud(pts).normals)
    @test_throws ArgumentError load_cloud(joinpath(dir, "x.stl"))

    log = sprint(io -> @test(check_main([off]; io = io) == 0))
    @test occursin("mesh: $off (1500 vertices, 2996 triangles)", log)
    @test occursin("Euler characteristic: 2", log) && !occursin("empty-ball", log)
    log = sprint(io -> @test(check_main([off, "-r", string(rho)]; io = io) == 0))
    @test occursin("valid 2996", log)                                  # both sides tried, winding side first
    log = sprint(io -> @test(check_main([off, "-r", string(rho), "-i", xyz]; io = io) == 0))
    @test occursin("cloud: $xyz\n", log) && occursin("valid 2996", log)
    log = sprint(io -> @test(check_main([noff, "--radius", string(rho)]; io = io) == 0))
    @test occursin("valid 2996", log)
    @test occursin("usage:", sprint(io -> check_main(["-h"]; io = io)))
    @test check_main(String[]; io = devnull) == 1
    @test check_main([off, "--bogus"]; io = devnull) == 1
    @test check_main([off, "-r", "0"]; io = devnull) == 1
    @test check_main([joinpath(dir, "missing.off")]; io = devnull) == 1
    @test check_main([xyz]; io = devnull) == 1                           # xyz is not an OFF
    @test check_main([noff, "-i", write_xyz(joinpath(dir, "short.xyz"), PointCloud(P[1:10], N[1:10]))]; io = devnull) == 1
    shifted = write_xyz(joinpath(dir, "shifted.xyz"), PointCloud([p + Vec3(1, 0, 0) for p in P], N))
    @test check_main([noff, "-i", shifted]; io = devnull) == 1

    log = sprint(io -> @test(sweep_main(["-i", noff, "-r", "$(rho),$(2rho)"]; io = io) == 0))
    @test occursin("radius", log) && count(==('\n'), log) >= 4
    rows = filter(l -> occursin(r"^\s+\d", l), split(log, '\n'))
    @test length(rows) == 2
    @test all(r -> occursin(r"\s2996\s", r), rows)                      # both radii close the sphere
    log = sprint(io -> @test(sweep_main(["-i", noff]; io = io) == 0))
    @test occursin("estimated sample spacing", log)
    @test length(filter(l -> occursin(r"^\s+\d", l), split(log, '\n'))) == 4
    @test occursin("usage:", sprint(io -> sweep_main(["-h"]; io = io)))
    @test sweep_main(String[]; io = devnull) == 1
    @test sweep_main(["-i", pts]; io = devnull) == 1                     # no normals
    @test sweep_main(["-i", pts, "--estimate-normals", "-r", string(rho)]; io = devnull) == 0
end

@testset "--check and --stats" begin
    dir = mktempdir()
    n = 1500
    P, N = fibonacci_sphere(n)
    rho = 1.5 * sphere_spacing(n)
    noff = write_off(joinpath(dir, "sphere_n.off"), BPAMesh(PointCloud(P, N), Tri[], BPAStats()))
    out = joinpath(dir, "out.off")
    stats = joinpath(dir, "run.json")
    log = sprint(io -> @test(main(["-i", noff, "-r", string(rho), "-o", out, "--check", "--stats", stats]; io = io) == 0))
    @test occursin("check:\ntriangles: 2996, vertices used: 1500 of 1500", log)
    @test occursin("empty-ball audit at rho = $rho: valid 2996", log)
    @test occursin("wrote $stats", log)
    js = read(stats, String)
    @test startswith(js, "{\n") && endswith(js, "}\n")
    @test occursin("\"input\": \"$noff\"", js)
    @test occursin("\"radii\": [$rho]", js)
    @test occursin("\"triangles\": 2996", js)
    @test occursin("\"points_used\": 1500", js)
    @test occursin("\"seeds\": 1", js) && occursin("\"boundary_edges\": 0", js)
    @test occursin("\"triangles_per_pass\": [2996]", js)
    @test occursin("\"scans\": null", js)
    @test occursin("\"fill_loops\": 0", js) && occursin("\"estimate_normals\": false", js)
    @test count(==('{'), js) == count(==('}'), js) == 3
    # a quoted path survives escaping
    opts = parse_cli(["-i", "a\"b.off", "-o", out])
    p = write_stats(joinpath(dir, "q.json"), opts, PointCloud(P, N), [rho], reconstruct(P, N, rho), 0.5)
    @test occursin("\"input\": \"a\\\"b.off\"", read(p, String))
end
