using BPA: Vec3, ball_center, circumcircle, pivot_frame, pivot_angle, point_on_trajectory,
           triangle_normal

@testset "ball_center" begin
    rng = Random.Xoshiro(10)
    rho = 1.0
    nfound = 0
    for _ in 1:200
        a, b, c = (Vec3(rand(rng, 3)) for _ in 1:3)
        res = circumcircle(a, b, c)
        res === nothing && continue
        cc, n = res
        R = norm(cc - a)
        @test norm(cc - b) ≈ R
        @test norm(cc - c) ≈ R
        @test dot(n, triangle_normal(a, b, c)) > 0
        center = ball_center(a, b, c, rho)
        if R > rho
            @test center === nothing
        else
            nfound += 1
            @test norm(center - a) ≈ rho
            @test norm(center - b) ≈ rho
            @test norm(center - c) ≈ rho
            @test dot(center - a, n) >= 0
            @test ball_center(a, b, c, 0.5 * R) === nothing
        end
    end
    @test nfound > 50
    # degenerate (collinear) triangle
    @test ball_center(Vec3(0, 0, 0), Vec3(1, 0, 0), Vec3(2, 0, 0), 5.0) === nothing
end

@testset "pivot frame direction" begin
    # Ball on triangle (i, j, o), CCW with normal +z. Rolling around e(i,j) must move the
    # centre away from o.
    pi, pj, po = Vec3(0, 0, 0), Vec3(1, 0, 0), Vec3(0, 1, 0)
    c = ball_center(pi, pj, po, 1.0)
    @test c[3] > 0
    fr = pivot_frame(pi, pj, c)
    @test dot(c - po, fr.v) > 0
    @test abs(dot(fr.u, fr.a)) < 1e-12
    @test abs(dot(fr.v, fr.a)) < 1e-12
    @test point_on_trajectory(fr, 0.0) ≈ c

    rng = Random.Xoshiro(11)
    for _ in 1:100
        pi, pj, po = (Vec3(rand(rng, 3)) for _ in 1:3)
        c = ball_center(pi, pj, po, 1.0)
        c === nothing && continue
        fr = pivot_frame(pi, pj, c)
        @test dot(c - po, fr.v) > 0
    end
    # centre on the edge: no trajectory
    @test pivot_frame(Vec3(0, 0, 0), Vec3(2, 0, 0), Vec3(1, 0, 0)) === nothing
end

@testset "pivot_angle vs brute force" begin
    rng = Random.Xoshiro(12)
    rho = 1.0
    θs = range(0, 2π, length = 20001)
    nhit = 0
    nmiss = 0
    for _ in 1:300
        pi, pj, po = (Vec3(2 * rand(rng, 3) .- 1) for _ in 1:3)
        c0 = ball_center(pi, pj, po, rho)
        c0 === nothing && continue
        fr = pivot_frame(pi, pj, c0)
        x = Vec3(2 * rand(rng, 3) .- 1) * 1.5
        norm(x - c0) > rho * (1 + 1e-3) || continue     # x must start outside the ball
        d = [norm(point_on_trajectory(fr, θ) - x) for θ in θs]
        mind = minimum(d)
        abs(mind - rho) < 1e-3 && continue              # grazing: skip ambiguous cases
        first = findfirst(<=(rho), d)
        res = pivot_angle(fr, x, rho)
        if first === nothing
            nmiss += 1
            @test res === nothing
        else
            nhit += 1
            @test res !== nothing
            θ, c = res
            @test abs(θ - θs[first]) < 2 * step(θs)
            @test norm(c - x) ≈ rho atol = 1e-9
            @test norm(c - pi) ≈ rho atol = 1e-9
            @test norm(c - pj) ≈ rho atol = 1e-9
        end
    end
    @test nhit > 20
    @test nmiss > 20

    # The opposite vertex itself touches the ball at θ = 0 and the ball moves away from it:
    # it is hit again only after nearly a full turn.
    pi, pj, po = Vec3(0, 0, 0), Vec3(1, 0, 0), Vec3(0, 1, 0)
    c0 = ball_center(pi, pj, po, rho)
    fr = pivot_frame(pi, pj, c0)
    θ, c = pivot_angle(fr, po, rho)
    @test θ > π
    @test norm(c - po) ≈ rho
    # A point touching the ball on the far side is hit immediately.
    x = c0 + rho * fr.v
    θ, c = pivot_angle(fr, x, rho)
    @test θ == 0
end
