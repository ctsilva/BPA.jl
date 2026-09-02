using BPA: Vec3, Tri, parse_cli, main, write_xyz, progress_colors, color_bucket, read_xf, transform

@testset "OFF, vertex normals, sampling" begin
    dir = mktempdir()
    off = joinpath(dir, "tet.off")
    # regular tetrahedron with outward faces
    open(off, "w") do io
        println(io, "OFF")
        println(io, "# comment")
        println(io, "4 4 0")
        println(io, "1 1 1\n-1 -1 1\n-1 1 -1\n1 -1 -1")
        println(io, "3 0 2 1\n3 0 1 3\n3 0 3 2\n3 1 2 3")
    end
    P, F, Nfile = read_off(off)
    @test length(P) == 4 && length(F) == 4 && isempty(Nfile)
    N = vertex_normals(P, F)
    for k in 1:4
        @test dot(N[k], P[k]) > 0.99 * norm(P[k])          # outward, along the vertex
    end
    @test PointCloud(P, F).normals == N

    cloud = sample_surface(P, F, 500; rng = Random.Xoshiro(1))
    @test length(cloud) == 500
    for (p, n) in zip(cloud.positions, cloud.normals)
        @test norm(n) ≈ 1
        # the point lies on a face plane and the normal is that face's outward normal
        @test any(t -> abs(dot(p - P[t[1]], n)) < 1e-9 &&
                       dot(cross(P[t[2]] - P[t[1]], P[t[3]] - P[t[1]]), n) > 0, F)
    end

    # counts on the same line as OFF, and a quad face
    open(off, "w") do io
        println(io, "OFF 4 1 0")
        println(io, "0 0 0\n1 0 0\n1 1 0\n0 1 0")
        println(io, "4 0 1 2 3")
    end
    P, F, _ = read_off(off)
    @test length(F) == 2
    @test all(t -> cross(P[t[2]] - P[t[1]], P[t[3]] - P[t[1]])[3] > 0, F)

    # NOFF point cloud, and plain OFF with six numbers per vertex and no faces
    for header in ("NOFF", "OFF")
        open(off, "w") do io
            println(io, header, "\n3 0 0")
            println(io, "0 0 0 0 0 1\n1 0 0 0 0 1\n0 1 0 0 0 1")
        end
        P, F, N = read_off(off)
        @test length(P) == 3 && isempty(F) && N == fill(Vec3(0, 0, 1), 3)
    end

    # write_off round trip, with and without colours
    Ps, Ns = fibonacci_sphere(200)
    mesh = reconstruct(Ps, Ns, 1.5 * sphere_spacing(200))
    path = write_off(joinpath(dir, "sphere.off"), mesh)
    P, F, N = read_off(path)
    @test P ≈ Ps && N ≈ Ns && F == mesh.triangles
    colors = progress_colors(length(F), 100)
    @test all(c -> c[1] == c[2] == 0 < c[3], colors[1:100])           # first block: blue ...
    @test issorted(c[3] for c in colors[1:100]) && colors[1][3] < colors[100][3]   # ... brightening
    @test colors[101][1] == colors[101][3] == 0 < colors[101][2]     # second block: green
    @test length(unique(progress_colors(100, 10))) == 50             # 5 colours x 10 levels, then repeats
    @test_throws ArgumentError progress_colors(5, 0)
    @test color_bucket(100) == 1000 && color_bucket(50_000) == 10_000 && color_bucket(10^7) == 100_000
    write_off(path, mesh; face_colors = colors)
    lines = readlines(path)
    @test lines[1] == "COFF" && length(split(lines[3])) == 7 && length(split(lines[end])) == 4
    @test split(lines[F[1][1] + 2])[4:7] == ["0.0", "0.0", "0.298", "1.0"]  # first triangle: dark blue
    @test read_off(path)[2] == F                       # colours are ignored on reading
end

@testset "estimate_spacing" begin
    P, N = fibonacci_sphere(3000)
    s = estimate_spacing(PointCloud(P, N); rng = Random.Xoshiro(1))
    @test 0.6 * sphere_spacing(3000) < s < 1.2 * sphere_spacing(3000)
    Pp, Np = plane_patch(30, 30; spacing = 0.1, jitter = 0.0)
    @test estimate_spacing(PointCloud(Pp, Np)) ≈ 0.1
    @test_throws ArgumentError estimate_spacing(PointCloud(P[1:1], N[1:1]))
end

@testset "max_seeds and progress callback" begin
    P1, N1 = fibonacci_sphere(300)
    P2, N2 = fibonacci_sphere(300)
    P = vcat(P1, [p + Vec3(5, 0, 0) for p in P2]); N = vcat(N1, N2)
    rho = 1.5 * sphere_spacing(300)
    @test reconstruct(P, N, rho).stats.seeds == 2
    m = reconstruct(P, N, rho; max_seeds = 1)
    @test m.stats.seeds == 1
    @test length(m.triangles) == 2 * 300 - 4
    @test isempty(reconstruct(P, N, rho; max_seeds = 0).triangles)
    counts = Int[]
    reconstruct(P, N, rho; on_progress = (t, s) -> push!(counts, length(t)), progress_every = 100)
    @test counts == 100:100:(2 * (2 * 300 - 4))
    @test_throws ArgumentError reconstruct(P, N, rho; progress_every = 0)
end

@testset "command line" begin
    @test_throws ArgumentError parse_cli(["-r", "0.1"])                  # no input
    @test_throws ArgumentError parse_cli(["-i", "a.off", "-r"])           # missing value
    @test_throws ArgumentError parse_cli(["-i", "a.off", "-r", "0.1,-1"])
    @test_throws ArgumentError parse_cli(["-i", "a.off", "-o", "a.stl"])
    @test_throws ArgumentError parse_cli(["-i", "a.off", "--bogus"])
    o = parse_cli(["-r", "0.1,0.2", "-i", "data/t.off", "-p", "1000", "-v", "--seed", "7",
                   "--save-colored", "--max-seeds", "3", "--sample", "500"])
    @test o.radii == [0.1, 0.2] && o.input == "data/t.off" && o.progress == 1000
    @test o.verbose && o.seed == 7 && o.output == joinpath(BPA.RESULTS_DIR, "t_bpa.off")
    @test o.save_colored && o.max_seeds == 3 && o.sample == 500
    @test isempty(parse_cli(["-i", "a.off", "-r", "-1"]).radii)          # -1: estimate
    @test sprint(io -> main(["-h"]; io = io)) |> s -> occursin("usage:", s)

    dir = mktempdir()
    torus_off = joinpath(dir, "torus.off")
    run(pipeline(`$(Base.julia_cmd()) $(joinpath(@__DIR__, "..", "examples", "make_torus_off.jl")) 60 24 $torus_off`,
                 stdout = devnull))
    nv = 60 * 24

    # mesh vertices with computed normals, OFF output, progress snapshots
    out = joinpath(dir, "torus_bpa.off")
    log = sprint(io -> @test(main(["-i", torus_off, "-r", "0.2", "-p", "1000", "-o", out]; io = io) == 0))
    @test occursin("wrote $out", log)
    P, F, N = read_off(out)
    @test length(F) == 2nv && length(N) == nv                   # closed torus: F = 2V
    snapshots = filter(f -> occursin(r"torus_bpa_\d{8}\.off", f), readdir(dir))
    @test length(snapshots) == 2nv ÷ 1000
    @test length(read_off(joinpath(dir, snapshots[1]))[2]) == 1000
    @test readlines(joinpath(dir, snapshots[1]))[1] == "COFF"   # snapshots are coloured
    @test readlines(out)[1] == "NOFF"                            # the output is not

    # --save-colored: plain output plus a coloured copy, in all three formats; -p N still
    # writes the snapshots
    for ext in (".off", ".ply", ".obj")
        out = joinpath(dir, "tor" * ext)
        @test main(["-i", torus_off, "-r", "0.2", "-o", out, "--save-colored", "-p", "500"]; io = devnull) == 0
        @test count(f -> occursin(Regex("^tor_\\d{8}\\" * ext * raw"$"), f), readdir(dir)) == 2nv ÷ 500
        plain = readlines(out)
        lines = readlines(joinpath(dir, "tor_colored" * ext))
        if ext == ".obj"
            @test count(l -> startswith(l, "v ") && length(split(l)) == 7, lines) == nv
            @test count(l -> startswith(l, "v ") && length(split(l)) == 4, plain) == nv
        elseif ext == ".ply"
            @test any(==("property uchar red"), lines) && !any(==("property uchar red"), plain)
            @test length(split(lines[end])) == 7
        else
            @test lines[1] == "COFF" && length(split(lines[nv + 2])) == 7 && plain[1] == "NOFF"
        end
    end

    # NOFF point cloud input, radius estimated, PLY output, --write-points, --max-seeds
    noff = joinpath(dir, "cloud.off")
    write_off(noff, BPAMesh(PointCloud(P, N), Tri[], BPAStats()))
    ply = joinpath(dir, "cloud.ply")
    xyz = joinpath(dir, "cloud.xyz")
    log = sprint(io -> @test(main(["-i", noff, "-o", ply, "--write-points", xyz, "--max-seeds", "1"]; io = io) == 0))
    @test occursin("estimated sample spacing", log)
    @test occursin("seeds: 1,", log)
    @test length(read_ply(ply)) == nv
    @test length(read_xyz(xyz)) == nv

    # sampled surface, multiple radii, OBJ output
    obj = joinpath(dir, "sampled.obj")
    log = sprint(io -> @test(main(["-i", torus_off, "--sample", "4000", "-r", "0.05,0.1,0.2", "-o", obj]; io = io) == 0))
    @test occursin("(4000 points)", log)
    @test occursin("triangles per pass", log)
    @test count(startswith("f "), readlines(obj)) > 0

    # error paths return 1 with a message
    @test main(["-i", joinpath(dir, "missing.off")]; io = devnull) == 1
    @test main(["-i", xyz, "--sample", "10"]; io = devnull) == 1
    @test main(["--bogus"]; io = devnull) == 1
    @test main(["-i", joinpath(dir, "cloud.stl")]; io = devnull) == 1
end

@testset "scan lists with .xf transforms" begin
    @test_throws ArgumentError parse_cli(["-i", "a.off", "-l", "b"])       # both -i and -l
    @test_throws ArgumentError parse_cli(["-i", "a.off", "-d", "dir"])     # -d without a list
    @test_throws ArgumentError parse_cli(["-f", "/nonexistent/list.txt"])
    o = parse_cli(["-l", "a, b,c", "-d", "scans"])
    @test o.scans == ["a", "b", "c"] && o.scan_dir == "scans"
    @test o.output == joinpath(BPA.RESULTS_DIR, "merged_bpa.off")

    # Split a sphere into two "scans": the upper half in place, the lower half stored in a
    # rotated frame together with the .xf matrix that brings it back.
    dir = mktempdir()
    P, N = fibonacci_sphere(2000)
    upper = findall(p -> p[2] >= 0, P); lower = findall(p -> p[2] < 0, P)
    θ = 0.7
    R = [cos(θ) -sin(θ) 0; sin(θ) cos(θ) 0; 0 0 1]
    t = [0.3, -0.2, 0.1]
    M = [R t; 0 0 0 1]
    Minv = inv(M)
    cloudA = PointCloud(P[upper], N[upper])
    cloudB = transform(PointCloud(P[lower], N[lower]), Minv)     # stored in the scan's own frame
    write_off(joinpath(dir, "upper.off"), BPAMesh(cloudA, Tri[], BPAStats()))
    write_off(joinpath(dir, "lower.off"), BPAMesh(cloudB, Tri[], BPAStats()))
    open(joinpath(dir, "lower.xf"), "w") do io
        for r in 1:4; println(io, join(M[r, :], " ")); end
    end
    @test read_xf(joinpath(dir, "lower.xf")) ≈ M
    back = transform(cloudB, M)
    @test all(isapprox.(back.positions, P[lower]; atol = 1e-9))
    @test all(isapprox.(back.normals, N[lower]; atol = 1e-9))

    open(joinpath(dir, "scans.txt"), "w") do io
        println(io, "# two halves of a sphere\nupper\n\nlower   # rotated, has an .xf")
    end
    out = joinpath(dir, "sphere.off")
    rho = 1.5 * sphere_spacing(2000)
    log = sprint(io -> @test(main(["-f", joinpath(dir, "scans.txt"), "-r", string(rho), "-o", out]; io = io) == 0))
    @test occursin("transformed by lower.xf", log)
    @test occursin("merged 2 scans: 2000 points", log)
    _, F, _ = read_off(out)
    c = check_mesh(F)
    @test c.nverts == 2000 && c.boundary_edges == 0 && c.chi == 2      # halves re-aligned into a closed sphere
    # -l with -d, default output name
    log = sprint(io -> @test(main(["-l", "upper,lower", "-d", dir, "-r", string(rho), "-o", out]; io = io) == 0))
    @test occursin("merged 2 scans", log)
    @test main(["-l", "upper,missing", "-d", dir, "-o", out]; io = devnull) == 1
    @test main(["-l", "upper", "-d", dir, "--sample", "10", "-o", out]; io = devnull) == 1
end
