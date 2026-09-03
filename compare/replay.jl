# Replay the pivots that produced the worst empty-ball violations in a BPA.jl-style output
# (triangles written as (i, k, j) for a pivot of the edge (i, j) that hit k): re-roll the
# ball from the triangle that owns the pivoted edge and list what it touches first. This is
# how the opposite-vertex bug of the first cross-check was traced.
#   julia --project=.. replay.jl <case> [n] [STEM] [--out DIR]
include("compare.jl")
using BPA: pivot_frame, pivot_angle

function main(args)
    rest, _ = setup!(args)
    isempty(rest) && error("usage: replay.jl <case> [n] [STEM]")
    c = only(filter(c -> c.name == rest[1], cases()))
    nshow = length(rest) > 1 ? parse(Int, rest[2]) : 3
    stem = length(rest) > 2 ? rest[3] : REFERENCE[]
    cloud = load_cloud(c)
    P, N = cloud.positions, cloud.normals
    rho = c.rho
    grid = VoxelGrid(P, 2rho)
    _, F, _ = read_off(joinpath(OUT_DIR[], c.name, stem * ".off"))
    owner = Dict{Tuple{Int,Int},Int}()          # directed half-edge -> triangle index
    for (n, t) in enumerate(F), (a, b) in ((t[1], t[2]), (t[2], t[3]), (t[3], t[1]))
        owner[(a, b)] = n
    end
    bad = Tuple{Float64,Int}[]
    for (n, t) in enumerate(F)
        k, d = classify(P, N, grid, rho, t)
        k == :ball_not_empty && d > TIE && push!(bad, (d, n))
    end
    sort!(bad; rev = true)
    buf = Int[]
    # how many violations are explained by the ball rolling past the opposite vertex?
    nopp = 0
    for (d, n) in bad
        i, k, j = F[n]
        m = get(owner, (i, j), 0)
        m == 0 && continue
        o = only(v for v in F[m] if v != i && v != j)
        ctr = ball_center(P[i], P[k], P[j], rho)
        neighbors!(buf, grid, ctr, rho)
        ins = [x for x in buf if !(x in (i, j, k)) && (rho - norm(P[x] - ctr)) / rho > TIE]
        ins == [o] && (nopp += 1)
    end
    println(stem, ": ", length(bad), " triangles fail the empty-ball test; in ", nopp,
            " the only intruder is the opposite vertex of the triangle pivoted from")
    for (d, n) in bad[1:min(nshow, end)]
        i, k, j = F[n]                                   # output order (i, k, j): pivot of e(i,j) hit k
        @printf("\n### triangle %d = (%d, %d, %d), depth %.3f rho\n", n, i, k, j, d)
        for (lab, a, b, cc) in (("outward", i, k, j), ("inward", i, j, k))
            ctr = ball_center(P[a], P[b], P[cc], rho)
            ctr === nothing && (println("  ", lab, " ball: none"); continue)
            neighbors!(buf, grid, ctr, rho)
            ins = [(x, (rho - norm(P[x] - ctr)) / rho) for x in buf if !(x in (i, j, k))]
            println("  ", lab, " ball contains ", length(ins), " points: ",
                    join((@sprintf("%d (depth %.3f)", x, dd) for (x, dd) in ins), ", "))
        end
        m = get(owner, (i, j), 0)
        if m == 0
            println("  no triangle owns half-edge ($i,$j): (i,k,j) was a seed or edge order differs")
            continue
        end
        t = F[m]
        o = only(v for v in t if v != i && v != j)
        println("  pivoted from triangle $m = ($(t[1]), $(t[2]), $(t[3])), opposite vertex $o")
        for (lab, a, b, cc) in (("outward", i, j, o), ("inward", i, o, j))
            ctr = ball_center(P[a], P[b], P[cc], rho)
            if ctr === nothing
                println("  start ", lab, " ball: none")
                continue
            end
            neighbors!(buf, grid, ctr, rho)
            ins = [x for x in buf if !(x in (i, j, o)) && norm(P[x] - ctr) < rho * (1 - 1e-9)]
            println("  start ", lab, " ball contains ", length(ins), " points ", ins)
            fr = pivot_frame(P[i], P[j], ctr)
            neighbors!(buf, grid, fr.m, 2rho)
            hits = Tuple{Float64,Int}[]
            for x in buf
                x in (i, j, o) && continue
                r = pivot_angle(fr, P[x], rho)
                r === nothing || push!(hits, (r[1], x))
            end
            sort!(hits)
            println("    first hits (angle, id): ",
                    join((@sprintf("(%.4f, %d)", θ, x) for (θ, x) in hits[1:min(6, end)]), " "))
            θk = findfirst(h -> h[2] == k, hits)
            println("    k = $k is hit number ", θk === nothing ? "never" : θk)
        end
    end
end

main(ARGS)
