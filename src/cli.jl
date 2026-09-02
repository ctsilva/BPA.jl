# Command-line interface, driven by `bpa.jl` at the package root.

const CLI_USAGE = """
usage: julia bpa.jl (-i INPUT | -l NAMES | -f LISTFILE) [-d DIR] [-o OUTPUT] [-r RADIUS[,...]]
                    [-p N] [options]

Reconstruct a triangle mesh from a point cloud with the Ball-Pivoting Algorithm.

input (one of):
  -i, --input FILE      a single file:
                          .off  point cloud with normals (NOFF: x y z nx ny nz per vertex),
                                or a mesh, whose vertex normals are computed from the faces
                          .xyz  x y z nx ny nz per line
                          .ply  ASCII PLY with nx ny nz vertex properties
  -l, --list NAMES      comma-separated scan names: each is read from DIR/<name>.off and,
                        if DIR/<name>.xf exists, transformed by that 4x4 matrix (positions
                        by the full matrix, normals by its rotation part); the scans are
                        merged into one point cloud
  -f, --list-file FILE  same, with the names read from a file (one per line, # comments)
  -d, --scan-dir DIR    directory of the scans (default: the list file's directory, or .)

options:
  -o, --output FILE     output mesh: .off, .obj or .ply (default: results/<name>_bpa.off in
                        the package directory, <name> being the input or list file basename)
  -r, --radius R[,R..]  ball radius, or a comma-separated list of increasing radii for
                        multiple passes. Omitted or <= 0: 1.5 x the estimated sample spacing
  -p, --progress N      save a partial mesh every N triangles, as <output>_<count>.<ext>
  --save-colored        colour the final mesh by the order in which triangles were created
                        (blue first, red last; with -p N the colours step every N triangles).
                        Partial meshes are not saved in this mode
  --max-seeds N         stop after N seed triangles (-1, the default, for unlimited)
  --sample N            for mesh inputs, sample N points uniformly on the surface instead
                        of using the mesh vertices
  --seed SEED           random seed for sampling and spacing estimation (default 1)
  --write-points FILE   also write the point cloud that was reconstructed (.xyz)
  -v, --verbose         print a line per pass
  -h, --help            show this message
"""

"Default output directory of the command-line tool: `results/` next to `src/`."
const RESULTS_DIR = joinpath(dirname(@__DIR__), "results")

struct CLIOptions
    input::String
    scans::Vector{String}
    scan_dir::String
    output::String
    radii::Vector{Float64}
    progress::Int
    save_colored::Bool
    max_seeds::Int
    sample::Int
    seed::Int
    write_points::String
    verbose::Bool
end

"""
    parse_cli(args; io=stdout) -> CLIOptions or nothing

Parse command-line arguments; returns `nothing` after printing usage to `io` for `-h`.
Throws an `ArgumentError` with a message for invalid input.
"""
function parse_cli(args::AbstractVector{<:AbstractString}; io::IO = stdout)
    input = ""; scans = String[]; scan_dir = ""; listfile = ""; output = ""
    radii = Float64[]; progress = 0; save_colored = false
    max_seeds = -1; sample = 0; seed = 1; write_points = ""; verbose = false
    k = 1
    value(flag) = (k + 1 <= length(args) || throw(ArgumentError("$flag needs a value")); k += 1; args[k])
    while k <= length(args)
        a = args[k]
        if a in ("-h", "--help")
            print(io, CLI_USAGE)
            return nothing
        elseif a in ("-i", "--input")
            input = value(a)
        elseif a in ("-l", "--list")
            append!(scans, strip.(split(value(a), ',')))
        elseif a in ("-f", "--list-file")
            listfile = value(a)
            isfile(listfile) || throw(ArgumentError("list file not found: $listfile"))
            for line in eachline(listfile)
                name = strip(first(split(line, '#'; limit = 2)))
                isempty(name) || push!(scans, name)
            end
        elseif a in ("-d", "--scan-dir")
            scan_dir = value(a)
        elseif a in ("-o", "--output")
            output = value(a)
        elseif a in ("-r", "--radius")
            radii = [parse(Float64, s) for s in split(value(a), ',')]
            if length(radii) == 1 && radii[1] <= 0
                empty!(radii)                                    # "-r -1": estimate the radius
            end
            all(>(0), radii) || throw(ArgumentError("radii must be positive"))
        elseif a in ("-p", "--progress")
            progress = parse(Int, value(a))
            progress >= 0 || throw(ArgumentError("-p needs a non-negative count"))
        elseif a == "--save-colored"
            save_colored = true
        elseif a == "--max-seeds"
            max_seeds = parse(Int, value(a))
        elseif a == "--sample"
            sample = parse(Int, value(a))
            sample > 0 || throw(ArgumentError("--sample needs a positive count"))
        elseif a in ("-s", "--seed")
            seed = parse(Int, value(a))
        elseif a == "--write-points"
            write_points = value(a)
        elseif a in ("-v", "--verbose")
            verbose = true
        else
            throw(ArgumentError("unknown option $a"))
        end
        k += 1
    end
    isempty(input) && isempty(scans) && throw(ArgumentError("an input is required (-i, -l or -f)"))
    !isempty(input) && !isempty(scans) && throw(ArgumentError("give either -i or a scan list, not both"))
    isempty(scans) && !isempty(scan_dir) && throw(ArgumentError("-d only applies to scan lists (-l, -f)"))
    if !isempty(scans) && isempty(scan_dir)
        scan_dir = isempty(listfile) ? "." : dirname(abspath(listfile))
    end
    if isempty(output)
        stem = !isempty(input) ? splitext(basename(input))[1] :
               !isempty(listfile) ? splitext(basename(listfile))[1] : "merged"
        output = joinpath(RESULTS_DIR, stem * "_bpa.off")
    end
    ext = lowercase(splitext(output)[2])
    ext in (".off", ".obj", ".ply") || throw(ArgumentError("output must be .off, .obj or .ply"))
    CLIOptions(input, scans, scan_dir, output, radii, progress, save_colored, max_seeds,
               sample, seed, write_points, verbose)
end

"""
    read_xf(path) -> Matrix{Float64}

Read a 4×4 transformation matrix stored as 16 whitespace-separated numbers (row-major, the
trimesh2 / Stanford `.xf` format).
"""
function read_xf(path::AbstractString)
    v = parse.(Float64, split(read(path, String)))
    length(v) == 16 || error("$path: expected 16 numbers, got $(length(v))")
    permutedims(reshape(v, 4, 4))
end

"""
    transform(cloud, M) -> PointCloud

Apply a 4×4 homogeneous matrix to a point cloud: positions by the full matrix, normals by
its upper-left 3×3 block (re-normalised, so scaling is tolerated).
"""
function transform(cloud::PointCloud, M::AbstractMatrix)
    R = SMatrix{3,3,Float64}(M[1:3, 1:3])
    t = Vec3(M[1:3, 4])
    PointCloud([R * p + t for p in cloud.positions], [R * n for n in cloud.normals])
end

"""
    load_scans(opts; io) -> PointCloud

Read every scan of `opts.scans` from `opts.scan_dir`, apply its `.xf` matrix when present,
and merge them into one cloud.
"""
function load_scans(opts::CLIOptions; io::IO = stdout)
    opts.sample > 0 && throw(ArgumentError("--sample is not available for scan lists"))
    P = Vec3[]
    N = Vec3[]
    for name in opts.scans
        off = joinpath(opts.scan_dir, name * ".off")
        isfile(off) || throw(ArgumentError("scan not found: $off"))
        positions, faces, normals = read_off(off)
        cloud = if !isempty(normals)
            PointCloud(positions, normals)
        elseif !isempty(faces)
            PointCloud(positions, faces)
        else
            throw(ArgumentError("$off has neither normals nor faces"))
        end
        xf = joinpath(opts.scan_dir, name * ".xf")
        if isfile(xf)
            cloud = transform(cloud, read_xf(xf))
        end
        println(io, "  ", rpad(name, 12), lpad(length(cloud), 8), " points",
                isfile(xf) ? "  (transformed by $name.xf)" : "")
        append!(P, cloud.positions)
        append!(N, cloud.normals)
    end
    PointCloud(P, N)
end

"""
    load_input(opts; io) -> PointCloud

Read the input file according to its extension (sampling meshes if `--sample` was given),
or merge the scans of a list.
"""
function load_input(opts::CLIOptions; io::IO = stdout)
    isempty(opts.scans) || return load_scans(opts; io = io)
    ext = lowercase(splitext(opts.input)[2])
    rng = Random.Xoshiro(opts.seed)
    if ext == ".off"
        positions, faces, normals = read_off(opts.input)
        if opts.sample > 0
            isempty(faces) && throw(ArgumentError("$(opts.input) has no faces to sample"))
            return sample_surface(positions, faces, opts.sample; rng = rng)
        end
        isempty(normals) || return PointCloud(positions, normals)
        isempty(faces) && throw(ArgumentError("$(opts.input) has neither normals nor faces"))
        return PointCloud(positions, faces)
    elseif ext == ".xyz" || ext == ".ply"
        opts.sample > 0 && throw(ArgumentError("--sample requires a mesh input (.off)"))
        return ext == ".xyz" ? read_xyz(opts.input) : read_ply(opts.input)
    else
        throw(ArgumentError("unsupported input format '$ext' (use .off, .xyz or .ply)"))
    end
end

"Write a point cloud as `x y z nx ny nz` lines (the format `read_xyz` reads)."
function write_xyz(path::AbstractString, cloud::PointCloud)
    open(path, "w") do io
        for (p, n) in zip(cloud.positions, cloud.normals)
            println(io, p[1], " ", p[2], " ", p[3], " ", n[1], " ", n[2], " ", n[3])
        end
    end
    path
end

"""
    write_mesh(path, mesh; face_colors=nothing)

Write `mesh` in the format given by the extension of `path` (.off, .obj or .ply). For OBJ,
which has no face colours, each vertex takes the colour of the first triangle using it.
"""
function write_mesh(path::AbstractString, mesh::BPAMesh; face_colors = nothing)
    ext = lowercase(splitext(path)[2])
    if ext == ".obj"
        vertex_colors = nothing
        if face_colors !== nothing
            vertex_colors = fill((200, 200, 200), length(mesh.cloud))
            seen = falses(length(mesh.cloud))
            for (k, t) in enumerate(mesh.triangles), v in t
                seen[v] && continue
                seen[v] = true
                vertex_colors[v] = face_colors[k]
            end
        end
        write_obj(path, mesh; vertex_colors = vertex_colors)
    elseif ext == ".ply"
        write_ply(path, mesh; face_colors = face_colors)
    else
        write_off(path, mesh; face_colors = face_colors)
    end
end

"""
    progress_colors(ntriangles; bucket=0) -> Vector{NTuple{3,Int}}

Colour for each triangle by creation order, blue for the first through green to red for the
last. With `bucket > 0` all triangles in the same block of `bucket` consecutive triangles
share a colour.
"""
function progress_colors(ntriangles::Integer; bucket::Integer = 0)
    colors = Vector{NTuple{3,Int}}(undef, ntriangles)
    nb = bucket > 0 ? cld(ntriangles, bucket) : ntriangles
    for k in 1:ntriangles
        step = bucket > 0 ? (k - 1) ÷ bucket : k - 1
        t = nb <= 1 ? 0.0 : step / (nb - 1)
        # hue from 240° (blue) down to 0° (red), full saturation and value
        h = 240 * (1 - t) / 60
        i = floor(Int, h) % 6
        f = h - floor(h)
        rgb = i == 0 ? (1.0, f, 0.0) : i == 1 ? (1 - f, 1.0, 0.0) : i == 2 ? (0.0, 1.0, f) :
              i == 3 ? (0.0, 1 - f, 1.0) : i == 4 ? (f, 0.0, 1.0) : (1.0, 0.0, 1 - f)
        colors[k] = (round(Int, 255 * rgb[1]), round(Int, 255 * rgb[2]), round(Int, 255 * rgb[3]))
    end
    colors
end

"""
    main(args = ARGS; io = stdout) -> exit code

Entry point of the command-line tool. Prints a summary of the reconstruction and returns 0
on success, 1 on a usage or input error.
"""
function main(args::AbstractVector{<:AbstractString} = ARGS; io::IO = stdout)
    opts = try
        parse_cli(args; io = io)
    catch err
        err isa ArgumentError || rethrow()
        println(io, "error: ", err.msg, "\n")
        print(io, CLI_USAGE)
        return 1
    end
    opts === nothing && return 0

    isempty(opts.scans) || println(io, "scans from ", opts.scan_dir, ":")
    cloud = try
        load_input(opts; io = io)
    catch err
        (err isa ArgumentError || err isa SystemError || err isa ErrorException) || rethrow()
        println(io, "error: ", sprint(showerror, err))
        return 1
    end
    if isempty(opts.scans)
        println(io, "input: ", opts.input, " (", length(cloud), " points)")
    else
        println(io, "merged ", length(opts.scans), " scans: ", length(cloud), " points")
    end
    isempty(opts.write_points) || write_xyz(opts.write_points, cloud)

    radii = opts.radii
    if isempty(radii)
        spacing = estimate_spacing(cloud; rng = Random.Xoshiro(opts.seed))
        radii = [1.5 * spacing]
        println(io, "estimated sample spacing: ", spacing, " -> radius ", radii[1])
    end

    base, ext = splitext(opts.output)
    mkpath(dirname(abspath(opts.output)))
    on_progress = nothing
    if opts.progress > 0 && !opts.save_colored
        on_progress = (triangles, stats) -> begin
            path = base * "_" * lpad(length(triangles), 8, '0') * ext
            write_mesh(path, BPAMesh(cloud, triangles, stats))
            println(io, "saved ", path)
        end
    end

    t = @elapsed mesh = reconstruct(cloud, radii; verbose = opts.verbose, max_seeds = opts.max_seeds,
                                    on_progress = on_progress,
                                    progress_every = max(opts.progress, 1))
    s = mesh.stats
    println(io, "triangles: ", length(mesh.triangles), " in ", round(t; digits = 2), " s")
    nused = count(!=(0), let used = falses(length(cloud))
        for t in mesh.triangles, v in t
            used[v] = true
        end
        used
    end)
    println(io, "points used: ", nused, " of ", length(cloud),
            nused < 0.95 * length(cloud) ? "  (many points unreached: try a larger radius, or several radii)" : "")
    println(io, "seeds: ", s.seeds, ", pivots: ", s.pivots, ", boundary edges: ", s.boundary_edges)
    println(io, "rejected: no hit ", s.rejected_no_hit, ", normal ", s.rejected_normal,
            ", interior vertex ", s.rejected_used, ", manifold ", s.rejected_manifold)
    length(radii) > 1 && println(io, "triangles per pass: ", s.triangles_per_pass,
                                 ", reactivated edges: ", s.reactivated_per_pass)

    colors = opts.save_colored ? progress_colors(length(mesh.triangles); bucket = opts.progress) : nothing
    write_mesh(opts.output, mesh; face_colors = colors)
    println(io, "wrote ", opts.output)
    return 0
end
