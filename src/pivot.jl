# Ball pivoting (Section 4.3).

"""
    ball_pivot(state, id) -> (k, center) or nothing

Pivot the ball around front edge `id = e(i,j)`, starting from its stored centre. All points
within `2ρ` of the edge midpoint are candidates (any point the ball can touch lies within
`r_γ + ρ ≤ 2ρ` of the midpoint); for each the first touching angle along the trajectory is
computed, and the point hit first is returned with the corresponding ball centre. `nothing`
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
    neighbors!(buf, st.grid, fr.m, 2 * rho)
    best = 0
    bestθ = Inf
    bestc = zero(Vec3)
    nties = 1
    for x in buf
        (x == e.i || x == e.j) && continue
        res = pivot_angle(fr, P[x], rho)
        res === nothing && continue
        θ, c = res
        if θ < bestθ - TIE_TOLERANCE
            bestθ = θ
            best = x
            bestc = c
            nties = 1
        elseif θ <= bestθ + TIE_TOLERANCE
            nties += 1
            bestθ = min(bestθ, θ)
        end
    end
    best == 0 && return nothing
    best == e.o && nties == 1 && return nothing    # the ball came back to σ_o first
    nties == 1 && return best, bestc

    # Resolve simultaneous hits deterministically. σ_o is never chosen: a point hit at the
    # same angle gives a valid triangle, with σ_o on the ball's surface rather than inside.
    bestscore = -1
    for x in buf
        (x == e.i || x == e.j || x == e.o) && continue
        res = pivot_angle(fr, P[x], rho)
        res === nothing && continue
        θ, c = res
        θ <= bestθ + TIE_TOLERANCE || continue
        score = tie_score(st, e, x)
        if score > bestscore || (score == bestscore && x < best)
            bestscore = score
            best = x
            bestc = c
        end
    end
    return best, bestc
end

"Angular tolerance (radians) within which two pivot hits count as simultaneous."
const TIE_TOLERANCE = 1e-7

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
    orientation_consistent(ntri, N[i], N[k], N[j]) || return 0
    (not_used(f, k) || on_front(f, k)) || return 0
    can_add_triangle(f, i, k, j) || return 0
    1 + haskey(f.lookup, (k, i)) + haskey(f.lookup, (j, k))
end
