# Geometric primitives: ball centres for triangles (seed test, Section 4.2) and the
# ball-pivoting trajectory computation (Section 4.3, Fig. 2).

"""
    triangle_normal(a, b, c)

Unnormalised normal `(b - a) × (c - a)` of the triangle `(a, b, c)`.
"""
@inline triangle_normal(a::Vec3, b::Vec3, c::Vec3) = cross(b - a, c - a)

"""
    orientation_consistent(n, na, nb, nc)

`true` if the triangle normal `n` points to the same side as all three vertex normals.
"""
@inline orientation_consistent(n::Vec3, na::Vec3, nb::Vec3, nc::Vec3) =
    dot(n, na) > 0 && dot(n, nb) > 0 && dot(n, nc) > 0

"""
    pivot_orientation_consistent(n, nk)

`true` if the triangle normal `n` of a pivot triangle does not point against the normal `nk`
of the point the ball landed on. The other two vertices are the front edge, whose
orientation already fixes the winding of the new triangle, so only the new point can
reveal that the ball has rolled onto the back of a nearby sheet. A zero dot product passes:
it arises from a point without a normal (a scan vertex that belongs to no face) or from a
normal at right angles to a steep triangle between two overlapping scans, and neither says
the triangle faces the wrong way.
"""
@inline pivot_orientation_consistent(n::Vec3, nk::Vec3) = dot(n, nk) >= 0

"""
    circumcircle(a, b, c) -> (center, unit_normal) or nothing

Circumcentre of the triangle and its unit normal (right-hand rule). `nothing` if degenerate.
"""
function circumcircle(a::Vec3, b::Vec3, c::Vec3)
    ab = b - a
    ac = c - a
    n = cross(ab, ac)
    nn = dot(n, n)
    nn > 1e-20 * dot(ab, ab) * dot(ac, ac) || return nothing
    cc = a + (cross(n, ab) * dot(ac, ac) + cross(ac, n) * dot(ab, ab)) / (2 * nn)
    return cc, n / sqrt(nn)
end

"""
    ball_center(a, b, c, rho) -> Vec3 or nothing

Centre of the ball of radius `rho` touching the three points, on the side of the triangle
normal `(b - a) × (c - a)`. `nothing` if the circumradius exceeds `rho` or the triangle is
degenerate. Callers orient `(a, b, c)` so that the normal points outward.
"""
function ball_center(a::Vec3, b::Vec3, c::Vec3, rho::Real)
    res = circumcircle(a, b, c)
    res === nothing && return nothing
    cc, n = res
    h2 = rho * rho - sum(abs2, cc - a)
    h2 < 0 && return nothing
    return cc + sqrt(h2) * n
end

"""
Local frame for pivoting around edge `e(i,j)` (Fig. 2): the ball centre moves on the circle
`γ(θ) = m + r (cos θ u + sin θ v)` lying in the plane perpendicular to the edge through its
midpoint `m`. `u` points from `m` to the current centre, `a` is the unit edge direction
`σ_j - σ_i`, and `v = a × u` is the direction in which the ball leaves the current triangle.
"""
struct PivotFrame
    m::Vec3
    a::Vec3
    u::Vec3
    v::Vec3
    r::Float64
end

"""
    pivot_frame(pi, pj, center) -> PivotFrame or nothing

`nothing` if the current centre lies on the edge (the trajectory is undefined).
"""
function pivot_frame(pi::Vec3, pj::Vec3, center::Vec3)
    m = (pi + pj) / 2
    a = pj - pi
    la = norm(a)
    la > 0 || return nothing
    a = a / la
    w = center - m
    w = w - dot(w, a) * a                  # remove any numerical drift along the edge
    r = norm(w)
    r > 1e-12 * la || return nothing
    u = w / r
    v = cross(a, u)
    PivotFrame(m, a, u, v, r)
end

@inline point_on_trajectory(fr::PivotFrame, θ::Real) = fr.m + fr.r * (cos(θ) * fr.u + sin(θ) * fr.v)

"""
    pivot_angle(frame, x, rho; θeps) -> (θ, center) or nothing

Smallest rotation angle `θ ∈ [0, 2π)` at which the ball travelling along the trajectory of
`frame` touches the point `x`, together with the ball centre at that moment. `nothing` if the
ball never reaches `x`.

With `d = x - m` decomposed in the frame as `(d_a, d_u, d_v)`, `|γ(θ) - x|² = ρ²` reduces to
`d_u cos θ + d_v sin θ = K` with `K = (r² + |d|² - ρ²) / (2r)`, i.e. `cos(θ - φ) = K / R`
where `(d_u, d_v) = R (cos φ, sin φ)`.

A solution within `θeps` of 0 (or, equivalently, of 2π: a tiny negative angle wraps to just
below 2π) means `x` is touching the ball in its initial position. If the ball is moving into
`x` the hit is immediate (`θ = 0`); otherwise that solution is ignored and the other one,
where the ball comes back to `x` from the far side, is used.
"""
function pivot_angle(fr::PivotFrame, x::Vec3, rho::Real; θeps::Real = 1e-6)
    d = x - fr.m
    du = dot(d, fr.u)
    dv = dot(d, fr.v)
    R = hypot(du, dv)
    R > 1e-12 * rho || return nothing
    K = (fr.r * fr.r + dot(d, d) - rho * rho) / (2 * fr.r)
    ratio = K / R
    abs(ratio) <= 1 + 1e-9 || return nothing
    ratio = clamp(ratio, -1.0, 1.0)
    φ = atan(dv, du)
    α = acos(ratio)
    θa = mod2pi(φ + α)
    θb = mod2pi(φ - α)
    touching(θ) = θ < θeps || θ > 2π - θeps
    ta = touching(θa)
    tb = touching(θb)
    if ta || tb
        # x is on the initial ball. Moving into it? The centre's velocity at θ = 0 is along v.
        c0 = fr.m + fr.r * fr.u
        dot(c0 - x, fr.v) < 0 && return 0.0, c0
        (ta && tb) && return nothing
        θ = ta ? θb : θa
        return θ, point_on_trajectory(fr, θ)
    end
    θ = min(θa, θb)
    return θ, point_on_trajectory(fr, θ)
end
