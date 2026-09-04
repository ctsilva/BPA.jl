# Generates docs/LITERATE.md, a reading of the source alongside the paper: the file header
# comments and docstrings of the core source files become prose, the definitions become
# code blocks, in the order in which the paper introduces them, and each chapter opens with
# the passage of the paper it implements.
#
#     julia docs/literate.jl          # rewrite docs/LITERATE.md
#
# The test suite regenerates the document and fails if the checked-in copy differs, so the
# document cannot drift from the code. To change the prose, edit the source; to change the
# chapters or the quoted passages, edit `CHAPTERS` below.
#
# Parsing rules, applied to the top level of each file only:
#   * a run of `#` comment lines starting at column 0 is prose;
#   * a docstring (`"""..."""` or a one-line `"..."`) at column 0 is prose, attached to the
#     definition that follows it;
#   * everything else is code. A definition that opens a block (function, struct, let,
#     @enum ... begin) ends at the first `end` at column 0; any other item ends when its
#     brackets balance and the next line is not indented.
# Consecutive code items are shown as one block; the module file contributes only its prose.

const SRC = joinpath(dirname(@__DIR__), "src")
const OUT = joinpath(@__DIR__, "LITERATE.md")

# Chapters: (source file, title, paper section, passage). The passages are verbatim from
# Bernardini et al., IEEE TVCG 5(4), 1999, with the symbols restored that the PDF text loses
# (ρ, σ_i, e(i,j)); `[...]` marks an omission.
const CHAPTERS = [
    ("BPA.jl", "The package", "",
     "The principle of the BPA is very simple: Three points form a triangle if a ball of a user-specified radius ρ touches them without containing any other point. Starting with a seed triangle, the ball pivots around an edge (i.e., it revolves around the edge while keeping in contact with the edge's endpoints) until it touches another point, forming another triangle. The process continues until all reachable edges have been tried, and then starts from another seed triangle, until all points have been considered. The process can then be repeated with a ball of larger radius to handle uneven sampling densities."),

    ("types.jl", "Points, edges and the front", "4",
     "The front F is represented as a collection of linked lists of edges and is initially composed of a single loop containing the three edges defined by the first seed triangle. Each edge e(i,j) of the front is represented by its two endpoints σ_i, σ_j, the opposite vertex σ_o, the center c_ijo of the ball that touches all three points, and links to the previous and next edge along in the same loop of the front. An edge can be active, boundary, or frozen. An active edge is one that will be used for pivoting. If it is not possible to pivot from an edge, it is marked as boundary. [...] Keeping all this information with each edge makes it simpler to pivot the ball around it."),

    ("geometry.jl", "Ball centres and the pivot trajectory", "4.2, 4.3",
     "The pivoting is in principle a continuous motion of the ball, during which the ball stays in contact with the two endpoints of e(i,j), as illustrated in Fig. 2. Because of this contact, the motion is constrained as follows: The center c_ijo of the ball describes a circle which lies on the plane perpendicular to e(i,j) and through its midpoint m = ½(σ_j + σ_i). The center of this circular trajectory is m and its radius is ||c_ijo − m||. During this motion, the ball may hit another point σ_k. If no point is hit, then the edge is a boundary edge. Otherwise, the triangle (σ_i, σ_k, σ_j) is a new valid triangle, and the ball in its final position does not contain any other point, thus being a valid starting ball for the next pivoting operation."),

    ("grid.jl", "Spatial queries", "4.1",
     "Both ball_pivot and find_seed_triangle (lines 3 and 10 in Fig. 5) require efficient lookup of the subset of points contained in a small spatial neighborhood. We implemented this spatial query using a regular grid of cubic cells, or voxels. Each voxel has sides of size δ = 2ρ. Data points are stored in a list, and the list is organized using bucket-sort so that points lying in the same voxel form a contiguous sublist. Each voxel stores a pointer to the first point in its sublist."),

    ("seed.jl", "Seed selection", "4.2",
     "If we limit ourselves to considering only one data point per voxel as a candidate vertex for a seed triangle, we cannot miss components spanning a volume larger than a few voxels. Also, for a given voxel, consider the average normal n of points within it. This normal approximates the surface normal in that region. Since we want our ball to walk \"on\" the surface, it is convenient to first consider points whose projection onto n is large and positive.\n\nWe therefore simply keep a list of nonempty voxels. We search these voxels for valid seed triangles, and when one is found, we start building a triangulation using pivoting operations. When no more pivoting is possible, we continue the search for a seed triangle from where we had stopped, skipping all voxels containing a point that is now part of the triangulation. When no more seeds can be found, the algorithm stops."),

    ("pivot.jl", "Ball pivoting", "4.3",
     "In practice, we find σ_k as follows: We consider all points in a 2ρ-neighborhood of m. For each such point σ_x, we compute the center c_x of the ball touching σ_i, σ_j and σ_x, if such a ball exists. Each c_x lies on the circular trajectory γ around m and can be computed by intersecting a ρ-sphere centered at σ_x with the circle γ. Of these points c_x, we select the one that is first along the trajectory γ. We report the first point hit and the corresponding ball center. Trivial rejection tests can be added to speed up finding the first hit-point."),

    ("front.jl", "The join and glue operations", "4.4",
     "The simpler operation is the join, which is used when the ball pivots around edge e(i,j), touching a not_used vertex σ_k (i.e., σ_k is a vertex that is not yet part of the mesh). In this case, we output the triangle (σ_i, σ_k, σ_j), and locally modify the front by removing e(i,j) and adding the two edges e(i,k) and e(k,j) (see Fig. 6).\n\nWhen σ_k is already part of the mesh, one of two cases can arise: 1. σ_k is an internal mesh vertex, (i.e., no front edge uses σ_k). The corresponding triangle cannot be generated, since it would create a nonmanifold vertex. In this case, e(i,j) is simply marked as a boundary edge; 2. σ_k belongs to the front. We first check that adding the candidate new triangle would not create a nonmanifold or nonorientable manifold. This is easily accomplished by looking at the existence and orientation of edges incident on σ_k. Then we apply a join operation, and output the new mesh triangle (σ_i, σ_k, σ_j). The join could potentially create (one or two) pairs of coincident edges (with opposite orientation), which are removed by the glue operation.\n\nThe glue operation removes from the front pairs of coincident edges, with opposite orientation (coincident edges with the same orientation are never created by the algorithm). [...] Four cases are possible, as illustrated in Fig. 7."),

    ("reconstruct.jl", "The main loop and multiple passes", "4, 4.6",
     "To deal with unevenly sampled surfaces, we can easily extend the algorithm to run multiple passes with increasing ball radii. The user specifies a list of radii {ρ_0, ..., ρ_n} as input parameters. [...] We let BPA run until there are no more active edges in the queue. At this point we increment i, go through all front edges, and check whether each edge with its opposite vertex σ_o forms a valid seed triangle for a ball of radius ρ_i. If it is, then it is added to the queue of active edges. Finally, the pivoting is started again."),

    ("check.jl", "Checking the output", "",
     "Regardless of the defects in the data, the BPA is guaranteed to build an orientable manifold. Notice that the BPA will always try to build the largest possible connected manifold from a given seed triangle."),
]

const INTRO = """
This document is generated from the source of BPA.jl by `docs/literate.jl`: the prose is
the file header comments and docstrings, the code is the definitions, in the order in which
the paper introduces them. Each chapter opens with the passage of Bernardini, Mittleman,
Rushmeier, Silva and Taubin, "The Ball-Pivoting Algorithm for Surface Reconstruction"
(IEEE TVCG 5(4), 1999) that it implements. The narrative that ties the pieces together,
the derivations and the invariants, is in [`algorithm.md`](algorithm.md); this is the code
itself, read in the paper's order.

Do not edit this file by hand: edit the source and run `julia docs/literate.jl`. The test
suite checks that the two agree.
"""

struct Item
    kind::Symbol      # :prose or :code
    text::String
end

opens_block(l) = occursin(r"^(function|struct|mutable struct|macro)\b", l) ||
                 occursin(r"\b(let|begin)\b", l)
bracket_delta(l) = count(c -> c in "([{", l) - count(c -> c in ")]}", l)

"Split a source file into top-level prose and code items."
function parse_file(path)
    lines = readlines(path)
    items = Item[]
    i = 1
    n = length(lines)
    while i <= n
        l = lines[i]
        if isempty(strip(l))
            i += 1
        elseif startswith(l, "#")
            j = i
            buf = String[]
            while j <= n && startswith(lines[j], "#")
                push!(buf, replace(lines[j][2:end], r"^ " => ""))
                j += 1
            end
            push!(items, Item(:prose, join(buf, "\n")))
            i = j
        elseif startswith(l, "\"\"\"")
            buf = String[]
            rest = l[4:end]
            if length(rest) >= 3 && endswith(rest, "\"\"\"")
                push!(buf, rest[1:end-3])
                j = i
            else
                isempty(rest) || push!(buf, rest)
                j = i + 1
                while j <= n && !endswith(lines[j], "\"\"\"")
                    push!(buf, lines[j])
                    j += 1
                end
                j <= n && lines[j] != "\"\"\"" && push!(buf, lines[j][1:end-3])
            end
            push!(items, Item(:prose, join(buf, "\n")))
            i = j + 1
        elseif startswith(l, "\"")
            push!(items, Item(:prose, l[2:end-1]))
            i += 1
        else
            j = i
            if opens_block(l)
                while j <= n && lines[j] != "end"
                    j += 1
                end
            else
                depth = bracket_delta(l)
                while j < n && (depth > 0 || startswith(lines[j + 1], " "))
                    j += 1
                    depth += bracket_delta(lines[j])
                end
            end
            push!(items, Item(:code, join(lines[i:j], "\n")))
            i = j + 1
        end
    end
    items
end

"Merge consecutive code items: one-liners stack, blocks are separated by a blank line."
function merge_code(items)
    out = Item[]
    for it in items
        if it.kind == :code && !isempty(out) && out[end].kind == :code
            sep = occursin('\n', out[end].text) || occursin('\n', it.text) ? "\n\n" : "\n"
            out[end] = Item(:code, out[end].text * sep * it.text)
        else
            push!(out, it)
        end
    end
    out
end

"""
Docstring text as document prose: headings inside a docstring go below the chapter
headings, and Documenter cross-references become plain code spans.
"""
function prose(s)
    s = replace(s, r"\[(`[^`]+`)\]\(@ref\)" => s"\1")
    join((startswith(l, "#") ? "###" * l : l for l in split(s, "\n")), "\n")
end

anchor(k, title) = string(k, "-", lowercase(replace(title, r"[^A-Za-z0-9 ]" => "", " " => "-")))

function emit(io, k, (file, title, section, passage))
    println(io, "## $k. $title\n")
    isempty(section) || println(io, "*Paper section $section, file `src/$file`.*\n")
    if !isempty(passage)
        for q in split(passage, "\n")
            println(io, "> ", q)
        end
        println(io)
    end
    for it in merge_code(parse_file(joinpath(SRC, file)))
        if it.kind == :prose
            println(io, prose(it.text), "\n")
        elseif file != "BPA.jl"          # the module file's code is includes and exports
            println(io, "```julia\n", it.text, "\n```\n")
        end
    end
end

"The whole document as a string."
function generate()
    io = IOBuffer()
    println(io, "# BPA.jl, read alongside the paper\n")
    println(io, INTRO)
    println(io, "Contents\n")
    for (k, ch) in enumerate(CHAPTERS)
        println(io, "$k. [", ch[2], "](#", anchor(k, ch[2]), ")")
    end
    println(io)
    for (k, ch) in enumerate(CHAPTERS)
        emit(io, k, ch)
    end
    String(take!(io))
end

if abspath(PROGRAM_FILE) == @__FILE__
    write(OUT, generate())
    println("wrote ", OUT)
end
