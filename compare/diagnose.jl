# Details on the triangles of one tool's output that fail the empty-ball test, and on its
# non-manifold edges: the intruding point's geometry, one line per bad triangle.
#   julia --project=.. diagnose.jl <case> [STEM] [--out DIR]
include("compare.jl")
using Statistics

function main(args)
    rest, _ = setup!(args)
    isempty(rest) && error("usage: diagnose.jl <case> [STEM]")
    c = only(filter(c -> c.name == rest[1], cases()))
    stem = length(rest) > 1 ? rest[2] : REFERENCE[]
    tool = TOOLS[][findfirst(t -> t.stem == stem, TOOLS[])]
    cloud = load_cloud(c)
    P, N = cloud.positions, cloud.normals
    rho = c.rho
    grid = VoxelGrid(P, 2rho)
    # near-duplicate points in the input
    buf = Int[]
    ndup = 0
    for i in 1:length(P)
        neighbors!(buf, grid, P[i], 1e-3 * rho)
        ndup += count(j -> j > i, buf)
    end
    println("input: ", length(P), " points, ", ndup, " pairs closer than 1e-3 rho")
    _, F, _ = read_off(joinpath(OUT_DIR[], c.name, stem * ".off"))
    used = falses(length(P)); for t in F, v in t; used[v] = true; end
    directed = Dict{Tuple{Int,Int},Int}(); undirected = Dict{Tuple{Int,Int},Int}()
    for t in F, (a, b) in ((t[1], t[2]), (t[2], t[3]), (t[3], t[1]))
        directed[(a, b)] = get(directed, (a, b), 0) + 1
        undirected[minmax(a, b)] = get(undirected, minmax(a, b), 0) + 1
    end
    println("\n== ", tool.name, ": ", length(F), " triangles; directed edges used twice: ",
            count(>(1), values(directed)), ", undirected edges with >2 triangles: ",
            count(>(2), values(undirected)))
    println("  depth/rho  intruder  d(intruder,centre)/rho  d(intruder,nearest vertex)/rho  ",
            "d(intruder,plane)/rho  n.intruder_normal  intruder_used")
    rows = 0
    for t in F
        k, d = classify(P, N, grid, rho, t)
        (k == :ball_not_empty && d > TIE) || continue
        a, b, cc = t
        if !orientation_consistent(triangle_normal(P[a], P[b], P[cc]), N[a], N[b], N[cc])
            b, cc = cc, b
        end
        ctr = ball_center(P[a], P[b], P[cc], rho)
        n = normalize(triangle_normal(P[a], P[b], P[cc]))
        neighbors!(buf, grid, ctr, rho)
        worst = 0; wd = 0.0
        for id in buf
            (id == a || id == b || id == cc) && continue
            dd = (rho - norm(P[id] - ctr)) / rho
            dd > wd && (wd = dd; worst = id)
        end
        x = P[worst]
        dv = minimum(norm(x - P[v]) for v in (a, b, cc)) / rho
        dp = dot(x - P[a], n) / rho
        rows += 1
        rows <= 12 && @printf("  %8.3f  %8d  %8.3f  %8.3f  %8.3f  %8.3f  %s\n",
                              wd, worst, norm(x - ctr) / rho, dv, dp, dot(n, N[worst]), used[worst])
    end
    println("  (", rows, " triangles)")
end

main(ARGS)
