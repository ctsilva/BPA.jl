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

This is the reference formulation; `ball_pivot` uses [`pivot_contact`](@ref), which gives the
same first contact without trigonometry.
"""
function pivot_angle(fr::PivotFrame, x::Vec3, rho::Real; θeps::Real = TOUCH_TOLERANCE)
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

"Angle (radians) below which a candidate counts as touching the ball in its initial position."
const TOUCH_TOLERANCE = 1e-6

"`sin(TOUCH_TOLERANCE)`: the touching test on a 2-D contact compares `|y| / r` with this."
const TOUCH_SIN = sin(TOUCH_TOLERANCE)

"""
A position of the ball centre on the pivot circle, as coordinates `(x, y)` in the frame
`(u, v)` of a `PivotFrame`: the centre is `m + x u + y v`, with `x² + y² = r²`, and the
pivot angle is the argument of `(x, y)` taken in `[0, 2π)`. Contacts are compared by angle
without evaluating it (`angle_less`, `angle_tie`).
"""
const Vec2 = SVector{2,Float64}

"3-D ball centre of the contact `c` on the trajectory of `frame`."
@inline pivot_center(fr::PivotFrame, c::Vec2) = fr.m + c[1] * fr.u + c[2] * fr.v

"`true` if the angle of `c` lies in `[π, 2π)`, `false` if in `[0, π)`."
@inline lower_half(c::Vec2) = c[2] < 0 || (c[2] == 0 && c[1] < 0)

"""
    angle_less(p, q) -> Bool

`true` if the pivot angle of contact `p` is smaller than that of `q`, both taken in
`[0, 2π)`. An angle in `[0, π)` precedes any angle in `[π, 2π)`; within one half the two
angles differ by less than π, so the sign of the 2-D cross product `p × q` decides: it is
positive exactly when `q` is counter-clockwise from `p`.
"""
@inline function angle_less(p::Vec2, q::Vec2)
    hp = lower_half(p)
    hq = lower_half(q)
    hp == hq ? p[1] * q[2] - p[2] * q[1] > 0 : hq
end

"""
    angle_tie(p, q, r2, sintol) -> Bool

`true` if the pivot angles of `p` and `q`, taken as numbers in `[0, 2π)`, differ by at most
the angle whose sine is `sintol`; `r2` is the squared radius of the pivot circle. The
angular difference `Δ` satisfies `r² sin Δ = p × q` and `r² cos Δ = p · q`, so `|Δ| ≤ tol`
is `p · q > 0` and `|p × q| ≤ r² sin tol`. Two contacts on either side of angle 0 are not a
tie, although they are geometrically close: the rolling ball reaches one at once and the
other only after a full turn. They are told apart by lying in different halves with a
positive first coordinate, whereas a near-π pair in different halves has a negative one.
"""
@inline function angle_tie(p::Vec2, q::Vec2, r2::Float64, sintol::Float64)
    p[1] * q[1] + p[2] * q[2] > 0 &&
        abs(p[1] * q[2] - p[2] * q[1]) <= r2 * sintol &&
        (lower_half(p) == lower_half(q) || p[1] < 0)
end

"`true` if contact `c` on a circle of radius `r` is within `TOUCH_TOLERANCE` of angle 0."
@inline touching(c::Vec2, r::Float64) = c[1] > 0 && abs(c[2]) < r * TOUCH_SIN

"""
    pivot_contact(frame, x, rho) -> Vec2 or nothing

The ball centre at the first contact of the pivoting ball with `x`, as a 2-D contact on the
trajectory of `frame` (see [`Vec2`](@ref)); `nothing` if the ball never reaches `x`. This
is [`pivot_angle`](@ref) without trigonometry: the pivot needs only the order of the
candidates' first contacts, and that order can be read off the 2-D positions of the centre.

In the coordinates of the pivot plane the centre `(x, y)` runs on the circle of radius `r`
and the contact condition `d_u cos θ + d_v sin θ = K` is the line `d_u x + d_v y = r K`.
Its intersections with the circle are `F ± h (-d_v, d_u) / R` with `F` the foot of the
perpendicular from the origin, `F = (r K / R²) (d_u, d_v)`, and half-chord
`h = r sqrt(1 - (K/R)²)`. The `+` root is `θ = φ + α` of `pivot_angle` and the `-` root
`θ = φ - α`; the touching rule of `pivot_angle` is applied to the same roots, and otherwise
the root with the smaller angle is the first contact.
"""
function pivot_contact(fr::PivotFrame, x::Vec3, rho::Real)
    d = x - fr.m
    du = dot(d, fr.u)
    dv = dot(d, fr.v)
    R = sqrt(du * du + dv * dv)                  # no overflow to guard against: |d| ≤ 2ρ
    R > 1e-12 * rho || return nothing
    r = fr.r
    K = (r * r + dot(d, d) - rho * rho) / (2 * r)
    ratio = K / R
    abs(ratio) <= 1 + 1e-9 || return nothing
    ratio = clamp(ratio, -1.0, 1.0)
    s = r * ratio / R                            # F = s (d_u, d_v)
    h = r * sqrt(1 - ratio * ratio) / R          # roots F ± h (-d_v, d_u)
    ca = Vec2(s * du - h * dv, s * dv + h * du)  # θ = φ + α
    cb = Vec2(s * du + h * dv, s * dv - h * du)  # θ = φ - α
    ta = touching(ca, r)
    tb = touching(cb, r)
    if ta || tb
        # x is on the initial ball. Moving into it? The centre's velocity at θ = 0 is along
        # v, so the ball moves into x exactly when d_v > 0.
        dv > 0 && return Vec2(r, 0.0)
        (ta && tb) && return nothing
        return ta ? cb : ca
    end
    angle_less(cb, ca) ? cb : ca
end
