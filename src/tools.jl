# Entry points of the scripts in tools/ (`check.jl`, `sweep.jl`) and the JSON run record of
# `bpa.jl --stats`. They share the input handling of the command-line tool in cli.jl.

const CHECK_USAGE = """
usage: julia tools/check.jl MESH [-i CLOUD] [-r RADIUS]

Report the topology of a triangle mesh (any OFF file with faces, from any tool): orientable,
manifold, Euler characteristic, components, boundary loops by size. With a ball radius,
every triangle is also audited for the empty-ball property of the BPA, against the normals
of CLOUD (an .off, .xyz or .ply point cloud with the same vertices as MESH, in the same
order) or, without -i, the normals of MESH itself when it is a NOFF file. A mesh with no
normals at all is audited on both sides of each triangle.

  -i, --input CLOUD     point cloud with normals matching the mesh vertices
  -r, --radius RADIUS   ball radius of the reconstruction, for the empty-ball audit
  -h, --help            show this message
"""

"""
    load_cloud(path) -> PointCloud

Read a point cloud by extension: `.off` (NOFF normals, else vertex normals from the faces,
else zero normals), `.xyz` or `.ply`.
"""
function load_cloud(path::AbstractString)
    ext = lowercase(splitext(path)[2])
    if ext == ".off"
        positions, faces, normals = read_off(path)
        isempty(normals) || return PointCloud(positions, normals)
        isempty(faces) || return PointCloud(positions, faces)
        return PointCloud(positions, fill(zero(Vec3), length(positions)))
    elseif ext == ".xyz"
        return read_xyz(path)
    elseif ext == ".ply"
        return read_ply(path)
    end
    throw(ArgumentError("unsupported input format '$ext' (use .off, .xyz or .ply)"))
end

"""
    check_main(args = ARGS; io = stdout) -> exit code

Entry point of `tools/check.jl`: [`report_mesh`](@ref) on a mesh file.
"""
function check_main(args::AbstractVector{<:AbstractString} = ARGS; io::IO = stdout)
    mesh = ""; cloudfile = ""; rho = 0.0
    k = 1
    value(flag) = (k + 1 <= length(args) || throw(ArgumentError("$flag needs a value")); k += 1; args[k])
    try
        while k <= length(args)
            a = args[k]
            if a in ("-h", "--help")
                print(io, CHECK_USAGE)
                return 0
            elseif a in ("-i", "--input")
                cloudfile = value(a)
            elseif a in ("-r", "--radius")
                rho = parse(Float64, value(a))
                rho > 0 || throw(ArgumentError("the radius must be positive"))
            elseif startswith(a, "-")
                throw(ArgumentError("unknown option $a"))
            else
                isempty(mesh) || throw(ArgumentError("only one mesh file, please"))
                mesh = a
            end
            k += 1
        end
        isempty(mesh) && throw(ArgumentError("a mesh file is required"))
    catch err
        err isa ArgumentError || rethrow()
        println(io, "error: ", err.msg, "\n")
        print(io, CHECK_USAGE)
        return 1
    end
    try
        positions, faces, normals = read_off(mesh)
        isempty(faces) && throw(ArgumentError("$mesh has no faces"))
        println(io, "mesh: ", mesh, " (", length(positions), " vertices, ", length(faces), " triangles)")
        cloud = if !isempty(cloudfile)
            c = load_cloud(cloudfile)
            length(c) == length(positions) ||
                throw(ArgumentError("$cloudfile has $(length(c)) points, the mesh $(length(positions)) vertices"))
            scale = maximum(norm(p) for p in positions; init = 1.0)
            all(norm(c.positions[i] - positions[i]) <= 1e-6 * scale for i in eachindex(positions)) ||
                throw(ArgumentError("the points of $cloudfile are not the vertices of $mesh"))
            println(io, "cloud: ", cloudfile, all(iszero, c.normals) ? " (no normals: both sides of each triangle are tried)" : "")
            c
        else
            PointCloud(positions, isempty(normals) ? fill(zero(Vec3), length(positions)) : normals)
        end
        report_mesh(io, faces; cloud = rho > 0 ? cloud : nothing, rho = rho > 0 ? rho : nothing,
                    npoints = length(positions))
    catch err
        (err isa ArgumentError || err isa SystemError || err isa ErrorException) || rethrow()
        println(io, "error: ", sprint(showerror, err))
        return 1
    end
    return 0
end

const SWEEP_USAGE = """
usage: julia tools/sweep.jl (-i INPUT | -l NAMES | -f LISTFILE) [-d DIR] [-r R1,R2,...] [options]

Reconstruct the same input once per radius and print one line per radius: time, triangles,
points used, seeds, components, boundary edges and the pivots rejected by the normal test.
Without -r the radii are 1.5, 2, 3 and 4 times the estimated sample spacing. No mesh is
written. The input options and --estimate-normals, --orient-normals, --knn, --max-seeds,
--seed-neighbors, --min-component, --sample and --seed are those of bpa.jl (see
`julia bpa.jl -h`); each radius is a separate single-pass run, not a multi-pass one.
"""

"Multiples of the estimated spacing that `sweep_main` tries when no radii are given."
const SWEEP_FACTORS = (1.5, 2.0, 3.0, 4.0)

"""
    sweep_main(args = ARGS; io = stdout) -> exit code

Entry point of `tools/sweep.jl`: one reconstruction per radius, as a table.
"""
function sweep_main(args::AbstractVector{<:AbstractString} = ARGS; io::IO = stdout)
    any(a -> a in ("-h", "--help"), args) && (print(io, SWEEP_USAGE); return 0)
    opts = try
        parse_cli(args; io = io)
    catch err
        err isa ArgumentError || rethrow()
        println(io, "error: ", err.msg, "\n")
        print(io, SWEEP_USAGE)
        return 1
    end
    opts === nothing && return 0
    cloud = prepare_cloud(opts; io = io)
    cloud === nothing && return 1
    radii = opts.radii
    if isempty(radii)
        spacing = estimate_spacing(cloud; rng = Random.Xoshiro(opts.seed))
        radii = [f * spacing for f in SWEEP_FACTORS]
        println(io, "estimated sample spacing: ", spacing, "; radii at ", join(SWEEP_FACTORS, ", "), " times it")
    end
    widths = (12, 8, 10, 10, 6, 6, 9, 9)
    row(cells) = println(io, join((lpad(string(c), w) for (c, w) in zip(cells, widths)), " "))
    row(("radius", "time s", "triangles", "used", "seeds", "comps", "boundary", "rej.norm"))
    for rho in radii
        t = @elapsed mesh = reconstruct(cloud, rho; max_seeds = opts.max_seeds, seed_neighbors = opts.seed_neighbors,
                                        min_component = opts.min_component)
        s = mesh.stats
        used = falses(length(cloud))
        for tri in mesh.triangles, v in tri
            used[v] = true
        end
        cs = component_sizes(mesh.triangles)
        row((round(rho; sigdigits = 6), round(t; digits = 2), length(mesh.triangles), count(used),
             s.seeds, length(cs), s.boundary_edges, s.rejected_normal))
    end
    return 0
end

# ------------------------------------------------------------------ the JSON run record

json_string(s::AbstractString) = "\"" * replace(String(s), "\\" => "\\\\", "\"" => "\\\"", "\n" => "\\n") * "\""
json_value(x::AbstractString) = json_string(x)
json_value(x::Bool) = x ? "true" : "false"
json_value(x::Integer) = string(x)
json_value(x::AbstractFloat) = isfinite(x) ? string(x) : "null"
json_value(x::AbstractVector) = "[" * join((json_value(v) for v in x), ", ") * "]"
json_value(x::Nothing) = "null"

"""
    write_stats(path, opts, cloud, radii, mesh, elapsed)

Write the run record of the command-line tool as JSON: the input and output, the radii,
the options that shape the result, the number of points and triangles, the time, and
every field of the [`BPAStats`](@ref). Written by `bpa.jl --stats FILE`, one file per run,
so that experiments can be compared later without the terminal output.
"""
function write_stats(path::AbstractString, opts, cloud::PointCloud, radii, mesh::BPAMesh, elapsed::Real)
    s = mesh.stats
    used = falses(length(cloud))
    for t in mesh.triangles, v in t
        used[v] = true
    end
    pairs = Pair{String,Any}[
        "input" => isempty(opts.scans) ? opts.input : nothing,
        "scans" => isempty(opts.scans) ? nothing : opts.scans,
        "scan_dir" => isempty(opts.scans) ? nothing : opts.scan_dir,
        "output" => opts.output,
        "radii" => collect(Float64, radii),
        "options" => Pair{String,Any}[
            "max_seeds" => opts.max_seeds, "seed_neighbors" => opts.seed_neighbors,
            "min_component" => opts.min_component, "estimate_normals" => opts.estimate_normals,
            "orient_normals" => opts.orient_normals, "knn" => opts.knn, "fill_loops" => opts.fill_loops,
            "sample" => opts.sample, "seed" => opts.seed],
        "points" => length(cloud),
        "points_used" => count(used),
        "triangles" => length(mesh.triangles),
        "time_s" => Float64(elapsed),
        "stats" => Pair{String,Any}[string(f) => getfield(s, f) for f in fieldnames(BPAStats)],
    ]
    open(path, "w") do io
        write_json(io, pairs, 0)
        println(io)
    end
    path
end

function write_json(io::IO, pairs::Vector{Pair{String,Any}}, indent::Int)
    pad = " "^(indent + 2)
    println(io, "{")
    for (i, (k, v)) in enumerate(pairs)
        print(io, pad, json_string(k), ": ")
        v isa Vector{Pair{String,Any}} ? write_json(io, v, indent + 2) : print(io, json_value(v))
        println(io, i < length(pairs) ? "," : "")
    end
    print(io, " "^indent, "}")
end
