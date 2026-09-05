using BPA: nearest_neighbors, smallest_eigenvector, pca_normal, estimate_spacing

@testset "nearest_neighbors" begin
    rng = Xoshiro(7)
    Q = [Vec3(rand(rng, 3)...) for _ in 1:300]
    k = 7
    nb = nearest_neighbors(Q, k)
    @test size(nb) == (k, 300)
    for i in 1:300
        brute = sort([(norm(Q[j] - Q[i]), j) for j in 1:300 if j != i])
        @test [x[2] for x in brute[1:k]] == nb[:, i]
    end
    # clustered data: the query radius has to grow to reach the other cluster
    C = vcat([Vec3(rand(rng, 3)...) for _ in 1:5], [Vec3(100, 100, 100) + Vec3(rand(rng, 3)...) for _ in 1:5])
    nb = nearest_neighbors(C, 6)
    for i in 1:10
        brute = sort([(norm(C[j] - C[i]), j) for j in 1:10 if j != i])
        @test [x[2] for x in brute[1:6]] == nb[:, i]
    end
    # k larger than the cloud: clamped; tiny clouds; coincident points
    @test size(nearest_neighbors(C, 50)) == (9, 10)
    @test nearest_neighbors([Vec3(0, 0, 0)], 3) == zeros(Int32, 0, 1)
    @test nearest_neighbors(Vec3[], 3) == zeros(Int32, 0, 0)
    @test nearest_neighbors([Vec3(0, 0, 0), Vec3(1, 0, 0)], 3) == Int32[2 1;]
    same = fill(Vec3(1, 2, 3), 4)
    nb = nearest_neighbors(same, 2)
    @test all(nb[:, i] != [0, 0] && !(i in nb[:, i]) for i in 1:4)
end

@testset "smallest_eigenvector" begin
    rng = Xoshiro(8)
    for _ in 1:200
        A = rand(rng, 3, 3); A = A' * A + 0.01 * I
        v = smallest_eigenvector(A[1, 1], A[1, 2], A[1, 3], A[2, 2], A[2, 3], A[3, 3])
        e = eigen(Symmetric(A))
        @test norm(v) ≈ 1
        @test abs(dot(v, e.vectors[:, 1])) ≈ 1 atol = 1e-8
    end
    # diagonal, rank one (points on a line: the eigenspace is a plane), and zero matrices
    v = smallest_eigenvector(3.0, 0.0, 0.0, 1.0, 0.0, 2.0)
    @test abs(v[2]) ≈ 1
    v = smallest_eigenvector(1.0, 1.0, 1.0, 1.0, 1.0, 1.0)      # d d' with d = (1,1,1)
    @test norm(v) ≈ 1 && abs(dot(v, Vec3(1, 1, 1))) < 1e-9
    @test smallest_eigenvector(0.0, 0.0, 0.0, 0.0, 0.0, 0.0) == zero(Vec3)
    @test smallest_eigenvector(2.0, 0.0, 0.0, 2.0, 0.0, 2.0) == zero(Vec3)   # isotropic: no direction
end

@testset "estimate_normals" begin
    n = 2000
    P, N = fibonacci_sphere(n)
    Ne = estimate_normals(P; k = 10, orient = false)
    @test all(norm(v) ≈ 1 for v in Ne)
    @test all(abs(dot(Ne[i], N[i])) > 0.99 for i in 1:n)      # right line, either sign
    Ne = estimate_normals(P; k = 10)
    @test all(dot(Ne[i], N[i]) > 0.99 for i in 1:n)           # right sign after orientation
    mesh = reconstruct(P, Ne, 1.5 * sphere_spacing(n))
    c = check_mesh(mesh.triangles)
    @test c.chi == 2 && c.boundary_edges == 0 && c.components == 1
    @test outward(mesh.triangles, P, zero(Vec3))
    # plane with jitter: normals ±z, then +z
    Pp, Np = plane_patch(30, 30)
    @test all(abs(estimate_normals(Pp; k = 8, orient = false)[i][3]) > 0.999 for i in eachindex(Pp))
    @test all(estimate_normals(Pp; k = 8)[i][3] > 0.999 for i in eachindex(Pp))
    # too few neighbours: zero normals, no error
    @test estimate_normals([Vec3(0, 0, 0)]) == [zero(Vec3)]
    @test estimate_normals([Vec3(0, 0, 0), Vec3(1, 0, 0)]) == [zero(Vec3), zero(Vec3)]
    @test_throws ArgumentError estimate_normals(P; k = 0)
    @test pca_normal(P, 1, Int32[]) == zero(Vec3)
end

@testset "orient_normals!" begin
    P, N = torus(120, 48)
    rng = Xoshiro(3)
    Nf = [rand(rng) < 0.5 ? -v : v for v in N]
    nflipped = count(Nf .!= N)
    components, flipped = orient_normals!(Nf, P)
    @test components == 1
    @test Nf == N
    @test flipped == nflipped
    # the same through a cloud, and the reconstruction is what the true normals give
    cloud = PointCloud(P, [rand(rng) < 0.5 ? -v : v for v in N])
    orient_normals!(cloud; k = 10)
    @test cloud.normals ≈ N
    @test reconstruct(cloud, 0.09).triangles == reconstruct(P, N, 0.09).triangles
    # two separate spheres: two components, both outward
    P1, N1 = fibonacci_sphere(500)
    P2 = [p + Vec3(10, 0, 0) for p in P1]
    Pb = vcat(P1, P2)
    Nb = vcat([-v for v in N1], N1)                     # the first sphere inside out
    components, flipped = orient_normals!(Nb, Pb)
    @test components == 2
    @test Nb == vcat(N1, N1)
    # a precomputed neighbour matrix, zero normals left alone, argument checks
    nb = nearest_neighbors(Pb, 10)
    Nz = vcat(fill(zero(Vec3), 500), N1)
    orient_normals!(Nz, Pb; neighbors = nb)
    @test Nz == vcat(fill(zero(Vec3), 500), N1)
    @test_throws ArgumentError orient_normals!(N1, Pb)
    @test_throws ArgumentError orient_normals!(Nb, Pb; neighbors = nb[:, 1:10])
    @test orient_normals!(Vec3[], Vec3[]) == (0, 0)
end

@testset "readers without normals" begin
    dir = mktempdir()
    xyz = joinpath(dir, "p.xyz")
    write(xyz, "0 0 0\n1 0 0 0 0 1\n# comment\n0 1 0\n")
    c = read_xyz(xyz)
    @test c.positions == [Vec3(0, 0, 0), Vec3(1, 0, 0), Vec3(0, 1, 0)]
    @test c.normals == [zero(Vec3), Vec3(0, 0, 1), zero(Vec3)]
    write(xyz, "0 0 0 1\n")
    @test_throws ErrorException read_xyz(xyz)
    ply = joinpath(dir, "p.ply")
    write(ply, "ply\nformat ascii 1.0\nelement vertex 2\nproperty float x\nproperty float y\nproperty float z\nend_header\n0 0 0\n1 2 3\n")
    c = read_ply(ply)
    @test c.positions == [Vec3(0, 0, 0), Vec3(1, 2, 3)] && all(iszero, c.normals)
end
