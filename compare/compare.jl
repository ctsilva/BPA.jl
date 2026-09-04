#!/usr/bin/env julia
#
# Cross-check Ball-Pivoting implementations on the same inputs. Every registered tool (see
# tools.jl: BPA.jl, Open3D and MeshLab out of the box, plus whatever you add) is run on each
# case, then each output is checked independently (every triangle must admit an empty
# rho-ball; the mesh must be orientable and manifold), compared with the reference tool's
# triangle set, and rendered with tools/render.jl (shaded with the boundary in red, depth
# parity, signed depth).
#
#   julia -t 3 --project=.. compare.jl [case|group ...] [options]      # from compare/
#
#   --list                 the built-in cases and whether their data is present
#   --tools STEMS|none     rerun only these tools (comma-separated stems); the others keep
#                          their existing output and log. none: re-analyse and re-render only
#   --reference STEM       the tool the others are compared with (default: the first in tools.jl)
#   --tools-file FILE      tool registry (default: tools.jl next to this script)
#   --out DIR              results directory (default: compare/results)
#   --input FILE --rho R [--name NAME] [--angle DEG]
#                          an ad-hoc case: FILE is anything bpa.jl -i reads (NOFF, .xyz, .ply,
#                          or a mesh whose vertex normals are derived from its faces)
#   --no-render            skip the renderings
#   --parallel             run the tools of a case at once (single-threaded tools contend for
#                          memory bandwidth; the timings come out 2 to 4 times larger)
#   --assemble             rebuild results/report.md and results/index.html only
#
# Per-case results go to results/<case>/ (outputs, logs, report fragments, render/); the
# report results/report.md and the gallery results/index.html are assembled from every case
# directory present, so cases can be rerun one at a time. A tool that is not installed, fails
# or has never been run shows as n/a.

using BPA
using BPA: Vec3, Tri, VoxelGrid, triangle_normal, orientation_consistent, ball_center,
           empty_ball, neighbors!, fibonacci_sphere, torus, plane_patch,
           classify_triangle, audit_triangles, component_sizes, AUDIT_CLASSES
using Printf, Random, StaticArrays, LinearAlgebra

const PKG = dirname(@__DIR__)                       # the BPA.jl package directory
const DATA = joinpath(PKG, "data")
const RENDER = joinpath(PKG, "tools", "render.jl")
const PYTHON = get(ENV, "BPA_COMPARE_PYTHON", joinpath(@__DIR__, ".venv", "bin", "python"))
const OUT_DIR = Ref(joinpath(@__DIR__, "results"))

# ---------------------------------------------------------------- tools

"""
A command-line reconstruction tool. `command(input, rho, output)` returns the `Cmd` that
reads the NOFF point cloud `input` (x y z nx ny nz per vertex), reconstructs it with ball
radius `rho` and writes `output`, an OFF whose vertices are exactly the input points in the
same order (indices are compared across tools); or `nothing` if the tool is not installed.
`time_pattern` captures, from the tool's log, its own reconstruction time in seconds
(excluding start-up and file loading); the wall time is used when it does not match.
"""
struct Tool
    name::String            # column label
    stem::String            # results/<case>/<stem>.off, .log, render/<stem>*.png
    command::Function
    time_pattern::Regex
end

const TOOLS = Ref(Tool[])
const REFERENCE = Ref("")               # stem of the reference tool
const ONLY = Ref(String[])              # stems to (re)run; --tools none: empty
const PARALLEL = Ref(false)
const NO_RENDER = Ref(false)

stems() = [t.stem for t in TOOLS[]]
names() = [t.name for t in TOOLS[]]
reference() = TOOLS[][findfirst(t -> t.stem == REFERENCE[], TOOLS[])]

# ---------------------------------------------------------------- cases

struct Case
    name::String
    group::String               # "synthetic", "scans" or "adhoc"
    description::String
    input::Vector{String}       # bpa.jl input arguments: -i FILE, or -l NAMES -d DIR
    rho::Float64
    angle::Float64              # render.jl rotation about the vertical axis, degrees
    scan_list::Vector{String}   # scan names, to render the input coverage of a scan list
    scan_dir::String
end

Case(name, group, description, input, rho; angle = 30.0, scans = String[], dir = "") =
    Case(name, group, description, input, rho, angle, scans, dir)

"The files a case needs; all must exist for the case to run."
function input_files(c::Case)
    if c.input[1] == "-i"
        [c.input[2]]
    else
        [joinpath(c.scan_dir, n * ".off") for n in c.scan_list]
    end
end
available(c::Case) = all(isfile, input_files(c))

function load_cloud(c::Case)
    opts = BPA.parse_cli(vcat(c.input, ["-r", string(c.rho)]))
    BPA.load_input(opts; io = devnull)
end

"Write a synthetic cloud as NOFF into results/inputs/ and return the path."
function synthetic_file(name, cloud::PointCloud)
    path = joinpath(OUT_DIR[], "inputs", name * ".off")
    mkpath(dirname(path))
    write_off(path, BPAMesh(cloud, Tri[], BPAStats()))
    path
end

"Scan names of a list file (one per line, # comments)."
read_list(path) = isfile(path) ?
    String[n for n in strip.(first.(split.(eachline(path), '#'; limit = 2))) if !isempty(n)] : String[]

function cases()
    mkpath(OUT_DIR[])
    # synthetic, generated here
    Ps, Ns = fibonacci_sphere(2000)
    sphere = synthetic_file("sphere2000", PointCloud(Ps, Ns))
    rho_s = round(1.5 * sqrt(4π / 2000); sigdigits = 3)
    Pp, Np = plane_patch(40, 40; spacing = 0.1, jitter = 0.3)
    plane = synthetic_file("plane40", PointCloud(Pp, Np))
    Pt, Nt = torus(120, 80; jitter = 0.3, rng = Xoshiro(1))
    torus_j = synthetic_file("torus_jitter", PointCloud(Pt, Nt))
    # from data/ of the package
    torus_file = joinpath(DATA, "torus-120-80.off")
    knot = joinpath(DATA, "knot-300-100.off")
    torus_s = joinpath(OUT_DIR[], "inputs", "torus_sampled20k.off")
    rho_k = 0.0188
    if isfile(torus_file)
        tp, tf, _ = read_off(torus_file)
        synthetic_file("torus_sampled20k", sample_surface(tp, tf, 20000; rng = Xoshiro(1)))
    end
    if isfile(knot)
        rho_k = round(1.5 * estimate_spacing(read_off(knot) |> x -> PointCloud(x[1], x[2]);
                                             rng = Xoshiro(1)); sigdigits = 3)
    end
    bunny_dir = joinpath(DATA, "bunny", "data")
    bunny4 = ["bun000", "bun045", "bun090", "bun180"]
    bunny10 = read_list(joinpath(bunny_dir, "bunny_scans.txt"))
    dragon_dir = joinpath(DATA, "dragon", "scans")
    dragon62 = read_list(joinpath(DATA, "dragon", "dragon_scans_clean.txt"))
    scans(names, dir) = ["-l", join(names, ","), "-d", dir]
    Case[
        Case("sphere2000", "synthetic",
             "2000-point Fibonacci sphere, rho = 1.5 x mean spacing. Expected: closed, chi = 2, 3996 triangles, every point used.",
             ["-i", sphere], rho_s),
        Case("plane40", "synthetic",
             "40 x 40 jittered grid on a plane. Expected: a disk, chi = 1, one clean boundary loop, every point used.",
             ["-i", plane], 0.15; angle = 20.0),
        Case("torus_r0.10", "synthetic",
             "trimesh2 torus, a regular 120 x 80 lattice (spacing 0.0196), rho = 0.10: many cospherical quads, so the diagonal is a free choice. Expected: closed, chi = 0, 19200 triangles.",
             ["-i", torus_file], 0.10; angle = 40.0),
        Case("torus_r0.05", "synthetic",
             "the same regular torus at rho = 0.05, the smallest radius that still closes it.",
             ["-i", torus_file], 0.05; angle = 40.0),
        Case("torus_jitter", "synthetic",
             "parametric torus (R = 1, r = 0.4) on a 120 x 80 grid jittered by 30 % of the spacing, so no four points are cospherical and the answer is unique. rho = 0.06 (2 x the median spacing). Expected: closed, chi = 0, 19200 triangles.",
             ["-i", torus_j], 0.06; angle = 40.0),
        Case("torus_sampled20k", "synthetic",
             "20000 points sampled uniformly by area on the trimesh2 torus (uneven spacing, normals from the faces), rho = 0.05 (5 x the median nearest-neighbour distance). Expected: closed, chi = 0, 40000 triangles.",
             ["-i", torus_s], 0.05; angle = 40.0),
        Case("knot_r0.0188", "synthetic",
             "trefoil knot, 30000 points, rho = 1.5 x the estimated spacing, deliberately too small for this anisotropic lattice: many boundaries, so the tools' seeding and stopping behaviour shows.",
             ["-i", knot], rho_k),
        Case("knot_r0.03", "synthetic",
             "the same knot at rho = 0.03, the radius the package recommends: nearly closed, with small holes where the tube almost touches itself.",
             ["-i", knot], 0.03),
        Case("bun000", "scans",
             "a single Stanford bunny range scan (40256 points, normals from the scan's own triangles), rho = 1.25 mm: real data without overlapping layers. Expected: one open sheet with the scan's outline as boundary.",
             scans(["bun000"], bunny_dir), 0.00125; scans = ["bun000"], dir = bunny_dir),
        Case("bunny4_r0.0008", "scans",
             "four registered bunny body scans (150983 points), rho = 0.8 mm, close to the layer separation of the overlapping scans: the hardest case for the empty-ball property.",
             scans(bunny4, bunny_dir), 0.0008; scans = bunny4, dir = bunny_dir),
        Case("bunny4_r0.0015", "scans",
             "the same four scans at rho = 1.5 mm, where the ball rides over the overlap layers.",
             scans(bunny4, bunny_dir), 0.0015; scans = bunny4, dir = bunny_dir),
        Case("bunny10_r0.00125", "scans",
             "all ten bunny scans (362272 points), rho = 1.25 mm, the package's reference reconstruction.",
             scans(bunny10, bunny_dir), 0.00125; scans = bunny10, dir = bunny_dir),
        Case("dragon62_r0.0007", "scans",
             "the 62 Stanford dragon surface scans (1.83 million points), rho = 0.7 mm: the largest input, with up to 98 overlapping layers.",
             scans(dragon62, dragon_dir), 0.0007; scans = dragon62, dir = dragon_dir),
    ]
end

# ---------------------------------------------------------------- running the tools

"""
Run the selected tools on the case, one after the other (or at once with `--parallel`).
Returns the output paths (or `nothing` for a tool without output) and the reconstruction
times as reported by the tools themselves, in tool order.
"""
function run_case(c::Case, cloud)
    dir = joinpath(OUT_DIR[], c.name)
    mkpath(dir)
    tools = TOOLS[]
    outs = Union{Nothing,String}[joinpath(dir, t.stem * ".off") for t in tools]
    logs = [joinpath(dir, t.stem * ".log") for t in tools]
    selected = [t.stem in ONLY[] for t in tools]
    foreach(k -> rm(outs[k]; force = true), findall(selected))
    input = joinpath(dir, "input.off")                 # the merged cloud, as NOFF, for every tool
    write_off(input, BPAMesh(cloud, Tri[], BPAStats()))
    times = Vector{Union{Nothing,Float64}}(nothing, length(tools))
    function start(k)
        cmd = Base.invokelatest(tools[k].command, input, c.rho, outs[k])   # tools.jl is included at run time
        cmd === nothing && return nothing
        p = try
            run(pipeline(Cmd(cmd; dir = dir, ignorestatus = true); stdout = logs[k], stderr = logs[k]); wait = false)
        catch err
            write(logs[k], "could not start: " * sprint(showerror, err) * "\n")
            nothing
        end
        p === nothing ? nothing : (time(), p)
    end
    function finish(k, tp)
        tp === nothing && return
        t0, p = tp
        wait(p)
        times[k] = (success(p) && isfile(outs[k])) ? time() - t0 : nothing
    end
    if PARALLEL[]
        procs = [k => start(k) for k in eachindex(tools) if selected[k]]
        foreach(((k, tp),) -> finish(k, tp), procs)
    else
        for k in eachindex(tools)
            selected[k] && finish(k, start(k))
        end
    end
    for k in eachindex(tools)
        selected[k] || (times[k] = isfile(outs[k]) ? Inf : nothing)   # kept from a previous run
        times[k] === nothing && continue
        m = isfile(logs[k]) ? match(tools[k].time_pattern, read(logs[k], String)) : nothing
        m === nothing || (times[k] = parse(Float64, m.captures[1]))
    end
    for k in eachindex(tools)
        times[k] === nothing && (outs[k] = nothing; println("  ", tools[k].name, ": no output",
                                                              isfile(logs[k]) ? " (see $(logs[k]))" : ""))
    end
    outs, times
end

# ---------------------------------------------------------------- renderings

struct RenderStats
    covered::Int                # pixels covered by at least one triangle
    odd::Int                    # pixels behind which an odd number of triangles lie
    signed_nonzero::Int         # pixels where front-facing minus back-facing is not zero
end

function parse_render_log(log)
    isfile(log) || return nothing
    s = read(log, String)
    cov = match(r"depth complexity over (\d+) covered pixels", s)
    odd = match(r"odd pixels \(holes seen through\): (\d+)", s)
    (cov === nothing || odd === nothing) && return nothing
    nz = sum(parse(Int, m.captures[1]) for m in eachmatch(r"front - back = [+-]\d+: (\d+) pixels", s); init = 0)
    RenderStats(parse(Int, cov.captures[1]), parse(Int, odd.captures[1]), nz)
end

"PPM to PNG with whatever converter is installed (sips on macOS, ImageMagick); the PPM stays otherwise."
function to_png(ppm)
    png = splitext(ppm)[1] * ".png"
    for cmd in (`sips -s format png $ppm --out $png`, `magick $ppm $png`, `convert $ppm $png`)
        Sys.which(cmd.exec[1]) === nothing && continue
        success(pipeline(cmd; stdout = devnull, stderr = devnull)) || continue
        rm(ppm)
        return true
    end
    false
end

"Path of a rendering relative to the results directory: the PNG if it exists, else the PPM."
function image(c::Case, stem, suffix)
    png = c.name * "/render/" * stem * suffix * ".png"
    isfile(joinpath(OUT_DIR[], png)) ? png : replace(png, ".png" => ".ppm")
end

"""
Render every output of the case (and, for a scan list, the input scans) with render.jl, in
parallel, keeping the renderings of tools that were not rerun. Returns the RenderStats per
tool stem (or `nothing`).
"""
function render_case(c::Case, outs)
    rdir = joinpath(OUT_DIR[], c.name, "render")
    mkpath(rdir)
    stats = Dict{String,Union{Nothing,RenderStats}}()
    NO_RENDER[] && return stats
    procs = Pair{String,Base.Process}[]
    for (t, out) in zip(TOOLS[], outs)
        out === nothing && continue
        if !(t.stem in ONLY[]) && (isfile(joinpath(rdir, t.stem * ".png")) || isfile(joinpath(rdir, t.stem * ".ppm")))
            stats[t.stem] = parse_render_log(joinpath(rdir, t.stem * ".log"))
            continue
        end
        ppm = joinpath(rdir, t.stem * ".ppm")
        log = joinpath(rdir, t.stem * ".log")
        cmd = `$(Base.julia_cmd()) $RENDER $out $ppm $(c.angle)`
        push!(procs, t.stem => run(pipeline(cmd; stdout = log, stderr = log); wait = false))
    end
    if !isempty(c.scan_list) && !(isfile(joinpath(rdir, "input.png")) || isfile(joinpath(rdir, "input.ppm")))
        list = joinpath(OUT_DIR[], c.name, "scans.txt")
        write(list, join(c.scan_list, "\n") * "\n")
        cmd = `$(Base.julia_cmd()) $RENDER -f $list -d $(c.scan_dir) $(joinpath(rdir, "input.ppm")) $(c.angle)`
        log = joinpath(rdir, "input.log")
        push!(procs, "input" => run(pipeline(cmd; stdout = log, stderr = log); wait = false))
    end
    for (stem, p) in procs
        wait(p)
        for suffix in ("", "_depth", "_signed")
            ppm = joinpath(rdir, stem * suffix * ".ppm")
            isfile(ppm) && to_png(ppm)
        end
        stats[stem] = success(p) ? parse_render_log(joinpath(rdir, stem * ".log")) : nothing
    end
    stats
end

# ---------------------------------------------------------------- checks on one output

# The empty-ball test lives in the package (`classify_triangle`, `audit_triangles` in
# src/check.jl); `classify` is kept as the name the other scripts here use.
classify(P, N, grid, rho, t) = classify_triangle(P, N, grid, rho, t)

const TIE = 1e-5     # intrusions below this fraction of rho are cospherical ties, not errors
const CLASSES = AUDIT_CLASSES

struct Analysis
    ntri::Int
    check::MeshCheck
    classes::Dict{Symbol,Int}
    max_depth::Float64          # deepest intrusion among :ball_not_empty triangles
    duplicates::Int             # triangles listed more than once (as vertex sets)
    verts_used::Int
    largest::Int                # triangles in the largest edge-connected component
end

"Number of triangles in the largest edge-connected component."
largest_component(tris) = (s = component_sizes(tris); isempty(s) ? 0 : s[1])

function analyze(cloud, grid, rho, tris)
    au = audit_triangles(cloud, rho, tris; grid = grid, tie = TIE)
    seen = Set{NTuple{3,Int}}()
    dup = 0
    for t in tris
        key = Tuple(sort(collect(t)))
        key in seen ? (dup += 1) : push!(seen, key)
    end
    used = falses(length(cloud))
    for t in tris, v in t
        used[v] = true
    end
    Analysis(length(tris), check_mesh(tris), au.classes, au.max_depth, dup, count(used), largest_component(tris))
end

# ---------------------------------------------------------------- comparing two outputs

vset(t) = Tuple(sort(collect(t)))
cyclic(t) = (i = argmin(t); (t[i], t[mod1(i + 1, 3)], t[mod1(i + 2, 3)]))
edges(t) = (minmax(t[1], t[2]), minmax(t[2], t[3]), minmax(t[3], t[1]))

struct Diff
    common::Int
    common_same_winding::Int
    only_a::Vector{Tri}
    only_b::Vector{Tri}
    # for triangles only in one mesh: how many of their 3 edges the other mesh also has
    cover_a::Vector{Int}        # histogram index 1..4 <-> 0..3 edges of only_a present in B
    cover_b::Vector{Int}
end

function compare(A, B)
    ka = Dict(vset(t) => cyclic(t) for t in A)
    kb = Dict(vset(t) => cyclic(t) for t in B)
    common = 0
    same = 0
    for (k, ca) in ka
        cb = get(kb, k, nothing)
        cb === nothing && continue
        common += 1
        same += (ca == cb)
    end
    only_a = [t for t in A if !haskey(kb, vset(t))]
    only_b = [t for t in B if !haskey(ka, vset(t))]
    ea = Set(e for t in A for e in edges(t))
    eb = Set(e for t in B for e in edges(t))
    cover(ts, es) = (h = zeros(Int, 4); for t in ts; h[1 + count(in(es), edges(t))] += 1; end; h)
    Diff(common, same, only_a, only_b, cover(only_a, eb), cover(only_b, ea))
end

# ---------------------------------------------------------------- reporting

yn(b) = b ? "yes" : "no"
na(x, f = string) = x === nothing ? "n/a" : f(x)
pct(a, b) = b == 0 ? "n/a" : @sprintf("%.2f%%", 100a / b)

"Rows of the per-tool table: (label, [value per tool])."
function summary_rows(an::Vector, times, rstats)
    col(f) = [a === nothing ? "n/a" : f(a) for a in an]
    rows = Pair{String,Vector{String}}[]
    push!(rows, "triangles" => col(a -> string(a.ntri)))
    push!(rows, "reconstruction time (s)" => [na(t, t -> string(round(t; digits = 3))) for t in times])
    push!(rows, "vertices used" => col(a -> string(a.verts_used)))
    push!(rows, "boundary edges" => col(a -> string(a.check.boundary_edges)))
    push!(rows, "boundary loops" => col(a -> string(a.check.boundary_loops)))
    push!(rows, "components" => col(a -> string(a.check.components)))
    push!(rows, "largest component (triangles)" => col(a -> string(a.largest)))
    push!(rows, "Euler characteristic" => col(a -> string(a.check.chi)))
    push!(rows, "orientable" => col(a -> yn(a.check.orientable)))
    push!(rows, "edge-manifold" => col(a -> yn(a.check.edge_manifold)))
    push!(rows, "vertex-manifold" => col(a -> yn(a.check.vertex_manifold)))
    push!(rows, "duplicate triangles" => col(a -> string(a.duplicates)))
    for k in CLASSES
        push!(rows, string(k) => col(a -> string(get(a.classes, k, 0))))
    end
    push!(rows, "deepest intrusion / rho" => col(a -> @sprintf("%.2e", a.max_depth)))
    push!(rows, "render: odd-parity pixels (holes seen through)" =>
          [na(get(rstats, s, nothing), r -> pct(r.odd, r.covered)) for s in stems()])
    push!(rows, "render: pixels with front ≠ back" =>
          [na(get(rstats, s, nothing), r -> pct(r.signed_nonzero, r.covered)) for s in stems()])
    rows
end

diff_header(ref) = ["common", "same winding", "only in $ref", "only in the other",
                    "edges of only-in-$ref triangles present in the other (0/1/2/3)",
                    "edges of only-in-other triangles present in $ref (0/1/2/3)"]

diff_row(d::Diff) = [string(d.common), string(d.common_same_winding), string(length(d.only_a)),
                     string(length(d.only_b)), join(d.cover_a, "/"), join(d.cover_b, "/")]

function md_table(io, header, rows)
    println(io, "| ", join(header, " | "), " |")
    println(io, "|", "---|"^length(header))
    for r in rows
        println(io, "| ", join(r, " | "), " |")
    end
    println(io)
end

html_escape(s) = replace(string(s), "&" => "&amp;", "<" => "&lt;", ">" => "&gt;")
function html_table(io, header, rows)
    println(io, "<table><thead><tr>", join(("<th>" * html_escape(h) * "</th>" for h in header)), "</tr></thead><tbody>")
    for r in rows
        println(io, "<tr>", join(("<td>" * html_escape(x) * "</td>" for x in r)), "</tr>")
    end
    println(io, "</tbody></table>")
end

const IMAGE_KINDS = [("", "shaded, boundary edges in red"),
                     ("_depth", "triangles behind each pixel: warm = odd (a hole is seen through), cool = even"),
                     ("_signed", "front-facing minus back-facing: grey 0, blue +, red −")]

"Write results/<case>/report.md and report.html, the fragments the assembled report is built from."
function write_case_report(c::Case, cloud, an, diffs, times, rstats)
    dir = joinpath(OUT_DIR[], c.name)
    ref = reference().name
    others = [t.name for t in TOOLS[] if t.stem != REFERENCE[]]
    rows = summary_rows(an, times, rstats)
    drows = [vcat([tool], diff_row(d)) for (tool, d) in zip(others, diffs) if d !== nothing]
    intro = "input: `" * join(c.input, " ") * "`, rho = $(c.rho), $(length(cloud)) points"
    open(joinpath(dir, "report.md"), "w") do io
        println(io, "\n## ", c.name, "\n\n", c.description, "\n\n", intro, "\n")
        md_table(io, vcat([""], names()), [vcat([k], v) for (k, v) in rows])
        println(io, "triangle sets against ", ref, ":\n")
        md_table(io, vcat([""], diff_header(ref)), drows)
        if !NO_RENDER[]
            println(io, "renderings (`", c.name, "/render/`, view $(c.angle)°):\n")
            imgs = [["![](" * image(c, s, suffix) * ")" for s in stems()] for (suffix, _) in IMAGE_KINDS]
            md_table(io, vcat([""], names()), [vcat([label], row) for ((_, label), row) in zip(IMAGE_KINDS, imgs)])
            isempty(c.scan_list) || println(io, "input scans: ![](", image(c, "input", ""), ")\n")
        end
    end
    open(joinpath(dir, "report.html"), "w") do io
        println(io, "<section id=\"", c.name, "\"><h2>", c.name, "</h2>")
        println(io, "<p>", html_escape(c.description), "</p><p><code>", html_escape(intro), "</code></p>")
        println(io, "<div class=\"tables\">")
        html_table(io, vcat([""], names()), [vcat([k], v) for (k, v) in rows])
        println(io, "<div><p>triangle sets against ", html_escape(ref), "</p>")
        html_table(io, vcat([""], diff_header(ref)), drows)
        println(io, "</div></div>")
        NO_RENDER[] && (println(io, "</section>"); return)
        for (suffix, label) in IMAGE_KINDS
            println(io, "<p class=\"kind\">", html_escape(label), " (view $(c.angle)°)</p><div class=\"grid\">")
            for t in TOOLS[]
                src = image(c, t.stem, suffix)
                println(io, "<figure><a href=\"", src, "\"><img src=\"", src, "\" loading=\"lazy\"></a><figcaption>", html_escape(t.name), "</figcaption></figure>")
            end
            println(io, "</div>")
        end
        if !isempty(c.scan_list)
            println(io, "<p class=\"kind\">input scans, with their boundaries</p><div class=\"grid\">")
            for suffix in ("", "_depth")
                src = image(c, "input", suffix)
                println(io, "<figure><a href=\"", src, "\"><img src=\"", src, "\" loading=\"lazy\"></a><figcaption>input", suffix, "</figcaption></figure>")
            end
            println(io, "</div>")
        end
        println(io, "</section>")
    end
end

const REPORT_INTRO = """
Each output is checked on its own: every triangle should admit an empty rho-ball on its \
outward side (`valid`; the side its vertex normals point to, or either side when they do \
not all agree), and the mesh should be orientable and manifold. `ball_not_empty_tie` counts \
triangles whose ball contains a point within 1e-5 rho of its surface (cospherical ties, not \
errors). Then each triangle set is compared with the reference tool's as unordered vertex \
triples. The render rows come from `tools/render.jl`: the share of covered pixels behind \
which an odd number of triangles lie (a hole seen through, for a closed surface), and the \
share where front-facing and back-facing triangles do not cancel (holes and flipped patches).
"""

const HTML_HEAD = """
<!doctype html><meta charset="utf-8"><title>BPA cross-check</title>
<style>
body{font-family:-apple-system,Helvetica,Arial,sans-serif;margin:1.5em 2em;color:#222;max-width:1900px}
table{border-collapse:collapse;font-size:12.5px;margin:0.5em 0}
th,td{border:1px solid #ccc;padding:2px 7px;text-align:right;white-space:nowrap}
th:first-child,td:first-child{text-align:left}
.tables{display:flex;gap:2em;flex-wrap:wrap;align-items:flex-start}
.grid{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-bottom:1em}
.grid img{width:100%;border:1px solid #ddd}
figcaption{font-size:12px;text-align:center;color:#555}
.kind{margin:1em 0 0.2em;font-weight:600}
nav a{margin-right:1em}
section{border-top:1px solid #ddd;margin-top:2em}
code{font-size:12px}
</style>
"""

"Assemble results/report.md and results/index.html from the case directories present."
function assemble(cs::Vector{Case})
    present = filter(c -> isfile(joinpath(OUT_DIR[], c.name, "report.md")), cs)
    open(joinpath(OUT_DIR[], "report.md"), "w") do io
        println(io, "# BPA cross-check\n\n", REPORT_INTRO)
        for c in present
            print(io, read(joinpath(OUT_DIR[], c.name, "report.md"), String))
        end
    end
    open(joinpath(OUT_DIR[], "index.html"), "w") do io
        println(io, HTML_HEAD, "<h1>BPA cross-check</h1><p>", html_escape(REPORT_INTRO), "</p><nav>")
        for c in present
            println(io, "<a href=\"#", c.name, "\">", c.name, "</a>")
        end
        println(io, "</nav>")
        for c in present
            print(io, read(joinpath(OUT_DIR[], c.name, "report.html"), String))
        end
    end
end

function run_and_check(c::Case)
    println("== ", c.name)
    cloud = load_cloud(c)
    outs, times = run_case(c, cloud)
    println("  reconstruction times: ", join((na(t, t -> @sprintf("%.2f", t)) for t in times), " / "))
    rstats = render_case(c, outs)
    grid = VoxelGrid(cloud.positions, 2 * c.rho)
    scale = 1 + maximum(norm.(cloud.positions))
    n = length(TOOLS[])
    faces = Vector{Union{Nothing,Vector{Tri}}}(nothing, n)
    an = Vector{Union{Nothing,Analysis}}(nothing, n)
    Threads.@threads for k in 1:n                      # start julia with -t <number of tools>
        out = outs[k]
        out === nothing && continue
        P, F, _ = read_off(out)
        length(P) == length(cloud) || error("$(c.name): $(TOOLS[][k].name) has $(length(P)) vertices, input $(length(cloud))")
        maximum(norm.(P .- cloud.positions)) < 1e-5 * scale ||
            error("$(c.name): $(TOOLS[][k].name) output vertices differ from the input")
        faces[k] = F
        an[k] = analyze(cloud, grid, c.rho, F)
    end
    r = findfirst(t -> t.stem == REFERENCE[], TOOLS[])
    others = [k for k in 1:n if k != r]
    diffs = Vector{Union{Nothing,Diff}}(nothing, length(others))
    Threads.@threads for j in eachindex(others)
        k = others[j]
        (faces[r] === nothing || faces[k] === nothing) && continue
        diffs[j] = compare(faces[r], faces[k])
    end
    for (k, d) in zip(others, diffs)
        d === nothing && continue
        stem = TOOLS[][k].stem
        open(joinpath(OUT_DIR[], c.name, "only_in_$(REFERENCE[])_vs_$stem.txt"), "w") do io
            foreach(t -> println(io, join(t, " ")), d.only_a)
        end
        open(joinpath(OUT_DIR[], c.name, "only_in_$stem.txt"), "w") do io
            foreach(t -> println(io, join(t, " ")), d.only_b)
        end
    end
    write_case_report(c, cloud, an, diffs, times, rstats)
end

# ---------------------------------------------------------------- command line

"Parse the options, load the tool registry; returns the remaining (case) arguments and an ad-hoc case or nothing."
function setup!(args)
    args = String.(args)
    tools_file = joinpath(@__DIR__, "tools.jl")
    only = nothing
    adhoc = Dict{String,String}()
    rest = String[]
    k = 1
    value() = (k += 1; k <= length(args) || error("$(args[k-1]) needs a value"); args[k])
    while k <= length(args)
        a = args[k]
        if a == "--parallel"; PARALLEL[] = true
        elseif a == "--no-render"; NO_RENDER[] = true
        elseif a == "--tools"; only = value()
        elseif a == "--reference"; REFERENCE[] = value()
        elseif a == "--tools-file"; tools_file = value()
        elseif a == "--out"; OUT_DIR[] = abspath(value())
        elseif a in ("--input", "--rho", "--name", "--angle"); adhoc[a] = value()
        else push!(rest, a)
        end
        k += 1
    end
    TOOLS[] = include(tools_file)::Vector{Tool}
    isempty(TOOLS[]) && error("$tools_file registers no tools")
    allunique(stems()) || error("tool stems must be unique")
    isempty(REFERENCE[]) && (REFERENCE[] = TOOLS[][1].stem)
    REFERENCE[] in stems() || error("--reference must be one of " * join(stems(), ","))
    ONLY[] = only === nothing ? stems() : only == "none" ? String[] : String.(split(only, ','))
    all(in(stems()), ONLY[]) || error("--tools takes none or a subset of " * join(stems(), ","))
    case = nothing
    if haskey(adhoc, "--input")
        haskey(adhoc, "--rho") || error("--input needs --rho")
        file = abspath(adhoc["--input"])
        isfile(file) || error("no such input: $file")
        name = get(adhoc, "--name", splitext(basename(file))[1])
        case = Case(name, "adhoc", "ad-hoc case", ["-i", file], parse(Float64, adhoc["--rho"]);
                    angle = parse(Float64, get(adhoc, "--angle", "30")))
    end
    rest, case
end

function main(args = ARGS)
    rest, adhoc = setup!(args)
    cs = cases()
    if "--list" in rest
        for c in cs
            println(rpad(c.name, 20), rpad(c.group, 11), "rho = ", rpad(c.rho, 8), available(c) ? "" : "(data missing)")
        end
        println("tools: ", join(("$(t.name) [$(t.stem)]" for t in TOOLS[]), ", "), "; reference: ", reference().name)
        return
    end
    if "--assemble" in rest
        assemble(cs)
        return
    end
    sel = adhoc !== nothing ? [adhoc] :
          isempty(rest) ? cs : filter(c -> c.name in rest || c.group in rest, cs)
    isempty(sel) && error("no such case; available: " * join(getfield.(cs, :name), ", "))
    adhoc === nothing || push!(cs, adhoc)
    for c in sel
        if !available(c)
            println("== ", c.name, ": skipped, input data missing (", join(filter(!isfile, input_files(c)), ", "), ")")
            continue
        end
        t = @elapsed run_and_check(c)
        println("  done in ", round(t; digits = 1), " s")
        assemble(cs)
    end
    println("wrote ", joinpath(OUT_DIR[], "report.md"), " and ", joinpath(OUT_DIR[], "index.html"))
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
