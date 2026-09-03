# Ball pivoting (Section 4.3).

"""
    ball_pivot(state, id) -> (k, center) or nothing

Pivot the ball around front edge `id = e(i,j)`, starting from its stored centre. All points
within `r_γ + ρ` of the edge midpoint are candidates, `r_γ ≤ ρ` being the radius of the
circle the centre moves on (a point farther away is never touched); for each the ball centre at first contact along the trajectory is
computed (`pivot_contact`), and the point hit first, i.e. the contact of smallest pivot
angle (`angle_less`), is returned with that centre. `nothing`
if the ball touches no point during a full revolution.

The endpoints are excluded: the ball touches them throughout. The opposite vertex `σ_o` is
touched at angle 0 by construction, which `pivot_angle` ignores, but it remains a candidate
at the angle where the ball, having rolled over to the other side of the surface, comes back
to it. If that happens before any other point is reached there is no new triangle to build
and the pivot fails; otherwise `σ_o` would end up inside the ball of the new triangle.
Because the initial ball is empty (it was the result of the previous pivot or the seed
test), the ball found here is empty too: it stops the moment its surface reaches the first
point.

Several points can be hit at the same angle (within `TIE_TOLERANCE`): four cospherical
points, as on any regular lattice, are the common case. All of them are "first", and the
choice among them must not depend on which edge the ball came from, or two pivots into the
same quad can pick different diagonals and collide. Ties are therefore resolved by
[`tie_score`](@ref): candidates that give a valid triangle win, among those the one gluing
to the most existing front edges, and finally the lowest index.
"""
function ball_pivot(st::BPAState, id::Int)
    e = st.front.edges[id]
    P = st.cloud.positions
    pi, pj = P[e.i], P[e.j]
    fr = pivot_frame(pi, pj, e.center)
    fr === nothing && return nothing
    rho = st.rho
    buf = st.buf
    # Any point the ball can touch lies within r + ρ of the midpoint. pivot_contact admits
    # contacts up to a relative 1e-9 beyond the exact reach, which the margin covers.
    neighbors!(buf, st.grid, fr.m, min(2 * rho, (fr.r + rho) * (1 + 1e-8)))
    r2 = fr.r * fr.r
    best = 0
    bestc = Vec2(0.0, 0.0)      # contact of the smallest angle among the current leaders
    nties = 1
    for x in buf
        (x == e.i || x == e.j) && continue
        c = pivot_contact(fr, P[x], rho)
        c === nothing && continue
        if best == 0
            best = x
            bestc = c
        elseif angle_tie(c, bestc, r2, TIE_SIN)
            nties += 1
            angle_less(c, bestc) && (bestc = c)
        elseif angle_less(c, bestc)
            best = x
            bestc = c
            nties = 1
        end
    end
    best == 0 && return nothing
    best == e.o && nties == 1 && return nothing    # the ball came back to σ_o first
    nties == 1 && return best, pivot_center(fr, bestc)

    # Resolve simultaneous hits deterministically. σ_o is never chosen: a point hit at the
    # same angle gives a valid triangle, with σ_o on the ball's surface rather than inside.
    bestscore = -1
    for x in buf
        (x == e.i || x == e.j || x == e.o) && continue
        c = pivot_contact(fr, P[x], rho)
        c === nothing && continue
        (angle_tie(c, bestc, r2, TIE_SIN) || angle_less(c, bestc)) || continue
        score = tie_score(st, e, x)
        if score > bestscore || (score == bestscore && x < best)
            bestscore = score
            best = x
            bestc = c
        end
    end
    return best, pivot_center(fr, bestc)
end

"Angular tolerance (radians) within which two pivot hits count as simultaneous."
const TIE_TOLERANCE = 1e-7

"`sin(TIE_TOLERANCE)`, the form in which `angle_tie` takes the tolerance."
const TIE_SIN = sin(TIE_TOLERANCE)

"""
    tie_score(state, edge, k) -> Int

Preference among points hit simultaneously by the ball pivoting around `edge = e(i,j)`:
0 if the triangle `(i, k, j)` would be rejected (normal test, interior vertex, or
non-manifold), otherwise 1 plus the number of its new edges that would glue to an existing
front edge. A consistent choice across the edges of a cospherical polygon follows: the
first pivot into it fixes a diagonal, and later pivots can only pick the candidate that
respects it.
"""
function tie_score(st::BPAState, e::FrontEdge, k::Int)
    f = st.front
    P = st.cloud.positions
    N = st.cloud.normals
    i, j = e.i, e.j
    ntri = triangle_normal(P[i], P[k], P[j])
    pivot_orientation_consistent(ntri, N[k]) || return 0
    (not_used(f, k) || on_front(f, k)) || return 0
    can_add_triangle(f, i, k, j) || return 0
    1 + has_edge(f, k, i) + has_edge(f, j, k)
end
