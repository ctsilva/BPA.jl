# Classify the triangles that survive flip.jl: what one tool built and the other did not,
# and why (empty-ball class, one-triangle holes, the normal test).
#   julia --project=.. remaining.jl [STEM] [case ...] [--out DIR] [--reference STEM]
include("compare.jl")

function main(args)
    rest, _ = setup!(args)
    others = [s for s in stems() if s != REFERENCE[]]
    stem = !isempty(rest) && rest[1] in others ? popfirst!(rest) : others[1]
    ref = reference().name
    cs = cases()
    sel = isempty(rest) ? cs : filter(c -> c.name in rest || c.group in rest, cs)
    for c in sel
        dir = joinpath(OUT_DIR[], c.name)
        f = joinpath(dir, "$(stem)_flipped.off")
        (isfile(f) && isfile(joinpath(dir, REFERENCE[] * ".off"))) || continue
        cloud = load_cloud(c); P, N = cloud.positions, cloud.normals
        grid = VoxelGrid(P, 2c.rho)
        _, A, _ = read_off(joinpath(dir, REFERENCE[] * ".off"))
        _, B, _ = read_off(f)
        d = compare(A, B)
        cls(ts) = (h = Dict{Symbol,Int}(); for t in ts; k = classify(P, N, grid, c.rho, t)[1]; h[k] = get(h, k, 0) + 1; end; h)
        # triangles with all three edges in the other mesh = one-triangle holes there
        ea = Set(e for t in A for e in edges(t)); eb = Set(e for t in B for e in edges(t))
        holes_in_b = count(t -> all(in(eb), edges(t)), d.only_a)
        holes_in_a = count(t -> all(in(ea), edges(t)), d.only_b)
        # reference-only triangles whose face normal does not agree with all three vertex
        # normals (the test Open3D applies; BPA.jl tests only the point the ball lands on)
        strict(t) = orientation_consistent(triangle_normal(P[t[1]], P[t[2]], P[t[3]]), N[t[1]], N[t[2]], N[t[3]])
        nostrict_a = count(!strict, d.only_a)
        nonormal_a = count(t -> any(v -> N[v] == zero(Vec3), t), d.only_a)
        println(c.name, ":\n  only in ", stem, " (after flips) ", length(d.only_b), " -> ", cls(d.only_b),
                "; one-triangle holes in ", ref, ": ", holes_in_a,
                "\n  only in ", ref, " ", length(d.only_a), " -> ", cls(d.only_a),
                "; one-triangle holes in ", stem, ": ", holes_in_b,
                "; failing the all-three-normals test: ", nostrict_a, " (with a zero normal: ", nonormal_a, ")")
    end
end

main(ARGS)
