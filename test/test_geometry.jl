using BPA: Vec3, Vec2, ball_center, circumcircle, pivot_frame, pivot_angle, point_on_trajectory,
           triangle_normal, pivot_contact, pivot_center, angle_less, angle_tie, lower_half

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

@testset "pivot_contact agrees with pivot_angle" begin
    # Angle of a 2-D contact in [0, 2π), the quantity angle_less and angle_tie avoid computing.
    angle_of(c) = mod2pi(atan(c[2], c[1]))
    rng = Random.Xoshiro(13)
    rho = 1.0
    nhit = 0
    nagree = 0
    for _ in 1:2000
        pi, pj, po = (Vec3(2 * rand(rng, 3) .- 1) for _ in 1:3)
        c0 = ball_center(pi, pj, po, rho)
        c0 === nothing && continue
        fr = pivot_frame(pi, pj, c0)
        # random candidates within 2ρ of the midpoint, plus the opposite vertex (touching at
        # θ = 0) and a point touching the ball on its leading side (immediate hit)
        xs = [fr.m + 2rho * Vec3(2 * rand(rng, 3) .- 1) for _ in 1:30]
        push!(xs, po, c0 + rho * fr.v)
        θs = Float64[]
        for x in xs
            ref = pivot_angle(fr, x, rho)
            c = pivot_contact(fr, x, rho)
            @test (ref === nothing) == (c === nothing)
            ref === nothing && continue
            nhit += 1
            θ, center = ref
            @test isapprox(angle_of(c), θ; atol = 1e-9) || isapprox(abs(angle_of(c) - θ), 2π; atol = 1e-9)
            @test norm(pivot_center(fr, c) - center) < 1e-9
            @test norm(pivot_center(fr, c) - x) ≈ rho atol = 1e-9
            @test abs(hypot(c[1], c[2]) - fr.r) < 1e-12
            push!(θs, θ)
        end
        # the trig-free order of the contacts is the order of the angles
        cs = [pivot_contact(fr, x, rho) for x in xs]
        cs = [c for c in cs if c !== nothing]
        for a in eachindex(cs), b in eachindex(cs)
            abs(θs[a] - θs[b]) < 1e-7 && continue
            @test angle_less(cs[a], cs[b]) == (θs[a] < θs[b])
            nagree += 1
        end
    end
    @test nhit > 10000
    @test nagree > 10000
end

@testset "angle_less and angle_tie" begin
    at(θ) = Vec2(cos(θ), sin(θ))
    tol = 1e-7
    st = sin(tol)
    @test !lower_half(at(0)) && !lower_half(at(1)) && !lower_half(at(π - 1e-9))
    @test lower_half(Vec2(-1, 0)) && lower_half(at(4)) && lower_half(at(2π - 1e-9))
    # order across the halves and near the wrap at 0 / 2π
    @test angle_less(at(0.1), at(3)) && angle_less(at(3), at(4)) && angle_less(at(0.0), at(2π - 1e-3))
    @test !angle_less(at(4), at(3)) && !angle_less(at(2π - 1e-3), at(0.0)) && !angle_less(at(1), at(1))
    # ties: within tolerance, including across π, but never across 0 / 2π
    @test angle_tie(at(1), at(1 + 0.5e-7), 1.0, st) && angle_tie(at(1 + 0.5e-7), at(1), 1.0, st)
    @test !angle_tie(at(1), at(1 + 2e-7), 1.0, st)
    @test angle_tie(at(π - 0.4e-7), at(π + 0.4e-7), 1.0, st)
    @test !angle_tie(at(0.4e-7), at(2π - 0.4e-7), 1.0, st) && !angle_tie(at(2π - 0.4e-7), at(0.4e-7), 1.0, st)
    @test !angle_tie(at(1), at(1 + π), 1.0, st)
    # the tolerance scales with the squared radius of the pivot circle
    @test angle_tie(3 * at(1), 3 * at(1 + 0.5e-7), 9.0, st) && !angle_tie(3 * at(1), 3 * at(1 + 2e-7), 9.0, st)
end
