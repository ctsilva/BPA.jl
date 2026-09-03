# Diagonal switching: flip edges of another tool's mesh towards the reference tool's mesh
# wherever two adjacent triangles form a quad whose other diagonal the reference uses, then
# swap whole patches with an identical boundary, and measure how much of the difference that
# removes. What survives is a triangle one tool built and the other did not.
#   julia --project=.. flip.jl [STEM] [case ...] [--out DIR] [--reference STEM]
include("compare.jl")

"""
    flip_toward(B, A) -> (B', nflips)

Repeatedly replace pairs of adjacent triangles of `B` by the pair with the other diagonal
when both replacement triangles belong to `A` (taking their winding from `A`).
"""
function flip_toward(B::Vector{Tri}, A::Vector{Tri})
    inA = Dict(vset(t) => t for t in A)
    B = copy(B)
    nflips = 0
    while true
        changed = false
        bykey = Set(vset(t) for t in B)
        emap = Dict{Tuple{Int,Int},Vector{Int}}()
        for (n, t) in enumerate(B), e in edges(t)
            push!(get!(emap, e, Int[]), n)
        end
        for ((u, v), ts) in emap
            length(ts) == 2 || continue
            t1, t2 = ts
            (haskey(inA, vset(B[t1])) && haskey(inA, vset(B[t2]))) && continue   # already agrees
            p = only(x for x in B[t1] if x != u && x != v)
            q = only(x for x in B[t2] if x != u && x != v)
            p == q && continue
            k1, k2 = vset((p, q, u)), vset((p, q, v))
            (haskey(inA, k1) && haskey(inA, k2)) || continue
            (k1 in bykey || k2 in bykey) && continue         # would duplicate a triangle
            haskey(emap, minmax(p, q)) && continue           # the new diagonal already exists
            B[t1], B[t2] = inA[k1], inA[k2]
            nflips += 1
            changed = true
            break                                            # rebuild the maps and go again
        end
        changed || return B, nflips
    end
end

"""
    patches(tris, idx) -> groups, boundaries

Group the triangles `idx` (indices into `tris`) into edge-connected patches and return, for
each patch, its triangle indices and its boundary edge set (edges used once within the patch).
"""
function patches(tris::Vector{Tri}, idx::Vector{Int})
    emap = Dict{Tuple{Int,Int},Vector{Int}}()
    for n in idx, e in edges(tris[n])
        push!(get!(emap, e, Int[]), n)
    end
    seen = Set{Int}()
    groups = Vector{Int}[]
    for n in idx
        n in seen && continue
        g = Int[]; stack = [n]; push!(seen, n)
        while !isempty(stack)
            m = pop!(stack); push!(g, m)
            for e in edges(tris[m]), o in emap[e]
                o in seen || (push!(seen, o); push!(stack, o))
            end
        end
        push!(groups, g)
    end
    bounds = [Set(e for n in g for e in edges(tris[n]) if length(emap[e]) == 1) for g in groups]
    groups, bounds
end

"""
    swap_patches(B, A) -> (B', nswapped_triangles, npatches)

Replace every edge-connected patch of triangles of `B` not in `A` by the patch of `A` not in
`B` that has exactly the same boundary (the same polygon triangulated differently).
"""
function swap_patches(B::Vector{Tri}, A::Vector{Tri})
    inA = Set(vset(t) for t in A); inB = Set(vset(t) for t in B)
    onlyB = [n for (n, t) in enumerate(B) if !(vset(t) in inA)]
    onlyA = [n for (n, t) in enumerate(A) if !(vset(t) in inB)]
    gB, bB = patches(B, onlyB)
    gA, bA = patches(A, onlyA)
    byboundary = Dict(bA[k] => k for k in eachindex(gA) if !isempty(bA[k]))
    keep = trues(length(B)); add = Tri[]; nsw = 0; np = 0
    for k in eachindex(gB)
        j = get(byboundary, bB[k], 0)
        j == 0 && continue
        keep[gB[k]] .= false
        append!(add, A[gA[j]])
        nsw += length(gB[k]); np += 1
    end
    vcat(B[keep], add), nsw, np
end

function main(args)
    rest, _ = setup!(args)
    others = [s for s in stems() if s != REFERENCE[]]
    stem = !isempty(rest) && rest[1] in others ? popfirst!(rest) : others[1]
    ref = reference().name
    cs = cases()
    sel = isempty(rest) ? cs : filter(c -> c.name in rest || c.group in rest, cs)
    println("diagonal switching of ", stem, " towards ", ref, "\n")
    println("| case | common before | only $ref / other | diagonal flips | common after flips | only $ref / other | patch swaps | common after swaps | only $ref / other | remaining other-only: edges in $ref (0/1/2/3) | remaining on points the other never uses ($ref-only / other-only) | edge-manifold |")
    println("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for c in sel
        dir = joinpath(OUT_DIR[], c.name)
        (isfile(joinpath(dir, REFERENCE[] * ".off")) && isfile(joinpath(dir, stem * ".off"))) || continue
        _, A, _ = read_off(joinpath(dir, REFERENCE[] * ".off"))
        _, B, _ = read_off(joinpath(dir, stem * ".off"))
        d0 = compare(A, B)
        B2, nflips = flip_toward(B, A)
        d1 = compare(A, B2)
        B3, nsw, np = swap_patches(B2, A)
        d2 = compare(A, B3)
        ck = check_mesh(B3)
        # of what remains, triangles whose vertices the other mesh never uses at all
        nv = max(maximum(maximum(t) for t in A), maximum(maximum(t) for t in B3))
        usedA = falses(nv); for t in A, v in t; usedA[v] = true; end
        usedB = falses(nv); for t in B3, v in t; usedB[v] = true; end
        unreachedA = count(t -> !any(v -> usedA[v], t), d2.only_b)
        unreachedB = count(t -> !any(v -> usedB[v], t), d2.only_a)
        println("| ", c.name, " | ", d0.common, " | ", length(d0.only_a), " / ", length(d0.only_b), " | ", nflips,
                " | ", d1.common, " | ", length(d1.only_a), " / ", length(d1.only_b), " | ",
                np, " patches (", nsw, " tri) | ", d2.common, " | ", length(d2.only_a), " / ", length(d2.only_b),
                " | ", join(d2.cover_b, "/"), " | ", unreachedB, " / ", unreachedA, " | ", yn(ck.edge_manifold), " |")
        open(joinpath(dir, "$(stem)_flipped.off"), "w") do f
            P, _, _ = read_off(joinpath(dir, "input.off"))
            println(f, "OFF\n", length(P), " ", length(B3), " 0")
            foreach(p -> println(f, p[1], " ", p[2], " ", p[3]), P)
            foreach(t -> println(f, "3 ", t[1] - 1, " ", t[2] - 1, " ", t[3] - 1), B3)
        end
    end
end

main(ARGS)
