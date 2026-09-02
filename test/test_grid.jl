using BPA: Vec3, VoxelGrid, neighbors!, empty_ball, nslots, slot_range

@testset "voxel grid" begin
    rng = Random.Xoshiro(20)
    P = [Vec3(rand(rng, 3)) for _ in 1:500]
    for delta in (0.5, 0.25, 0.1, 0.001)
        g = VoxelGrid(P, delta)
        # every point appears exactly once in the bucket-sorted list
        @test sort(g.sorted) == 1:500
        @test all(s -> !isempty(slot_range(g, s)) || g.dense, 1:nslots(g))
        @test !(delta == 0.001) == g.dense
        buf = Int[]
        for r in (delta, 0.6 * delta)
            for _ in 1:50
                q = Vec3(rand(rng, 3) .* 1.2 .- 0.1)       # also outside the bounding box
                neighbors!(buf, g, q, r)
                brute = [i for i in 1:500 if norm(P[i] - q) <= r]
                @test sort(buf) == brute
            end
        end
        @test_throws ArgumentError neighbors!(buf, g, P[1], 1.5 * delta)
        # empty_ball agrees with brute force
        for _ in 1:100
            c = Vec3(rand(rng, 3))
            rho = delta * rand(rng)
            e1, e2, e3 = rand(rng, 1:500, 3)
            brute = !any(i -> !(i in (e1, e2, e3)) && norm(P[i] - c) < rho * (1 - 1e-9), 1:500)
            @test empty_ball(g, c, rho, e1, e2, e3) == brute
        end
    end
    # empty grid
    g = VoxelGrid(Vec3[], 1.0)
    @test nslots(g) == 1
    @test isempty(neighbors!(Int[], g, Vec3(0, 0, 0), 1.0))
    @test_throws ArgumentError VoxelGrid(P, 0.0)
end
