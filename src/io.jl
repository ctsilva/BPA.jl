# Minimal file I/O: XYZ+normals text, ASCII PLY, OFF meshes, and OBJ output.

"""
    read_off(path) -> (positions::Vector{Vec3}, faces::Vector{Tri}, normals::Vector{Vec3})

Read an ASCII OFF file. Polygons with more than three vertices are fan-triangulated.

Two flavours are understood:

- `OFF`: `x y z` per vertex. `normals` is returned empty; use [`vertex_normals`](@ref) (or
  `PointCloud(positions, faces)`) to derive normals from the faces, or
  [`sample_surface`](@ref) to sample the surface.
- `NOFF`: `x y z nx ny nz` per vertex, the usual way to store a point cloud with normals in
  OFF format (typically with zero faces). A plain `OFF` header with no faces and six numbers
  per vertex is read the same way.
"""
function read_off(path::AbstractString)
    # One record per line (after stripping comments and blank lines): the header keyword,
    # the counts, nv vertex lines, nf face lines. Extra tokens on a line (colours, texture
    # coordinates) are ignored.
    lines = Vector{SubString{String}}[]
    for line in eachline(path)
        s = strip(first(split(line, '#'; limit = 2)))
        isempty(s) || push!(lines, split(s))
    end
    isempty(lines) && error("$path: empty file")
    ln = 1
    has_normals = false
    m = match(r"^(N?C?)OFF(.*)$", lines[1][1])
    if m !== nothing
        has_normals = startswith(m.captures[1], "N")
        rest = m.captures[2]                    # counts may follow the keyword on the same line
        if isempty(rest) && length(lines[1]) == 1
            ln = 2
        else
            lines[1] = isempty(rest) ? lines[1][2:end] : vcat([SubString(rest)], lines[1][2:end])
        end
    end
    ln <= length(lines) && length(lines[ln]) >= 2 || error("$path: missing element counts")
    nv, nf = parse(Int, lines[ln][1]), parse(Int, lines[ln][2])
    ln += 1
    length(lines) >= ln + nv + nf - 1 || error("$path: truncated file")
    if !has_normals && nf == 0 && nv > 0 && length(lines[ln]) >= 6
        has_normals = true                      # plain OFF header but x y z nx ny nz per vertex
    end
    positions = Vector{Vec3}(undef, nv)
    normals = has_normals ? Vector{Vec3}(undef, nv) : Vec3[]
    for k in 1:nv
        t = lines[ln + k - 1]
        length(t) >= (has_normals ? 6 : 3) || error("$path: vertex $k has too few numbers")
        positions[k] = Vec3(parse(Float64, t[1]), parse(Float64, t[2]), parse(Float64, t[3]))
        has_normals && (normals[k] = Vec3(parse(Float64, t[4]), parse(Float64, t[5]), parse(Float64, t[6])))
    end
    ln += nv
    faces = Tri[]
    for k in 1:nf
        t = lines[ln + k - 1]
        m = parse(Int, t[1])
        length(t) >= m + 1 || error("$path: face $k has too few indices")
        idx = [parse(Int, t[1 + i]) + 1 for i in 1:m]           # OFF indices are 0-based
        for i in 2:m-1
            push!(faces, Tri(idx[1], idx[i], idx[i + 1]))
        end
    end
    positions, faces, normals
end

"""
    vertex_colors(mesh, face_colors; unused=(255, 255, 255)) -> Vector{NTuple{3,Int}}

Per-vertex colours from per-triangle ones, for formats without face colours: each vertex
takes the colour of the first triangle that uses it; vertices in no triangle get `unused`.
"""
function vertex_colors(mesh::BPAMesh, face_colors; unused = (255, 255, 255))
    colors = fill(unused, length(mesh.cloud))
    seen = falses(length(mesh.cloud))
    for (k, t) in enumerate(mesh.triangles), v in t
        seen[v] && continue
        seen[v] = true
        colors[v] = face_colors[k]
    end
    colors
end

"""
    write_off(path, mesh::BPAMesh; face_colors=nothing, normals=isempty(mesh.triangles))

Write the points and triangles as an ASCII OFF file. A mesh is written as a plain `OFF`,
positions only, which is what viewers such as trimesh2's `mesh_view` read. A point cloud
(no triangles) is written as `NOFF`, each position followed by its normal, so the normals
survive a round trip through [`read_off`](@ref); `normals` overrides that choice. With
`face_colors`, a vector of `(r, g, b)` integers in 0–255, one per triangle, the file is a
`COFF`: each vertex line is `x y z r g b 1.0` with the colours in 0–1 (see
[`vertex_colors`](@ref)), and no normals.
"""
function write_off(path::AbstractString, mesh::BPAMesh; face_colors = nothing,
                   normals::Bool = isempty(mesh.triangles))
    c = mesh.cloud
    vc = face_colors === nothing ? nothing : vertex_colors(mesh, face_colors)
    open(path, "w") do io
        println(io, vc !== nothing ? "COFF" : normals ? "NOFF" : "OFF")
        println(io, length(c), " ", length(mesh.triangles), " 0")
        if vc !== nothing
            for (p, col) in zip(c.positions, vc)
                r, g, b = round.(col ./ 255, digits = 3)
                println(io, p[1], " ", p[2], " ", p[3], " ", r, " ", g, " ", b, " 1.0")
            end
        elseif normals
            for (p, n) in zip(c.positions, c.normals)
                println(io, p[1], " ", p[2], " ", p[3], " ", n[1], " ", n[2], " ", n[3])
            end
        else
            for p in c.positions
                println(io, p[1], " ", p[2], " ", p[3])
            end
        end
        for t in mesh.triangles
            println(io, "3 ", t[1] - 1, " ", t[2] - 1, " ", t[3] - 1)
        end
    end
    path
end

"""
    vertex_normals(positions, faces) -> Vector{Vec3}

Area-weighted vertex normals of a triangle mesh (right-hand rule on the face winding, so a
consistently outward-oriented mesh gives outward normals). Vertices with no face get a zero
normal.
"""
function vertex_normals(positions::Vector{Vec3}, faces::Vector{Tri})
    normals = zeros(Vec3, length(positions))
    for t in faces
        n = triangle_normal(positions[t[1]], positions[t[2]], positions[t[3]])
        normals[t[1]] += n
        normals[t[2]] += n
        normals[t[3]] += n
    end
    map(_unit, normals)
end

"""
    PointCloud(positions, faces::Vector{Tri}) -> PointCloud

The vertices of a triangle mesh with their area-weighted vertex normals.
"""
PointCloud(positions::Vector{Vec3}, faces::Vector{Tri}) =
    PointCloud(positions, vertex_normals(positions, faces))

"""
    sample_surface(positions, faces, n; rng) -> PointCloud

`n` points sampled uniformly (by area) on the surface of a triangle mesh, each with the
normal of the face it lies on.
"""
function sample_surface(positions::Vector{Vec3}, faces::Vector{Tri}, n::Integer;
                        rng = Random.default_rng())
    isempty(faces) && throw(ArgumentError("mesh has no faces"))
    areas = [norm(triangle_normal(positions[t[1]], positions[t[2]], positions[t[3]])) / 2 for t in faces]
    cum = cumsum(areas)
    total = cum[end]
    total > 0 || throw(ArgumentError("mesh has zero area"))
    P = Vector{Vec3}(undef, n)
    N = Vector{Vec3}(undef, n)
    for k in 1:n
        f = searchsortedfirst(cum, rand(rng) * total)
        f = min(f, length(faces))
        t = faces[f]
        a, b, c = positions[t[1]], positions[t[2]], positions[t[3]]
        u, v = rand(rng), rand(rng)
        if u + v > 1                            # fold into the triangle
            u, v = 1 - u, 1 - v
        end
        P[k] = a + u * (b - a) + v * (c - a)
        N[k] = _unit(triangle_normal(a, b, c))
    end
    PointCloud(P, N)
end

"""
    read_xyz(path) -> PointCloud

Read a text file with one sample per line: `x y z nx ny nz` (whitespace separated; lines
starting with `#` are ignored). Lines with only `x y z` are accepted and get a zero normal,
to be filled in by [`estimate_normals`](@ref).
"""
function read_xyz(path::AbstractString)
    positions = Vec3[]
    normals = Vec3[]
    for (ln, line) in enumerate(eachline(path))
        s = strip(line)
        (isempty(s) || startswith(s, '#')) && continue
        v = split(s)
        length(v) == 3 || length(v) >= 6 || error("$path:$ln: expected 3 or 6 numbers, got $(length(v))")
        x = parse.(Float64, v[1:min(6, end)])
        push!(positions, Vec3(x[1], x[2], x[3]))
        push!(normals, length(x) >= 6 ? Vec3(x[4], x[5], x[6]) : zero(Vec3))
    end
    PointCloud(positions, normals)
end

"""
    read_ply(path) -> PointCloud

Read the vertices of an ASCII PLY file. Vertex properties `x y z` are required; `nx ny nz`
are read when present and the normals are zero otherwise (see [`estimate_normals`](@ref));
other properties and elements are skipped.
"""
function read_ply(path::AbstractString)
    lines = eachline(path)
    it = iterate(lines)
    it !== nothing && strip(it[1]) == "ply" || error("$path: not a PLY file")
    # header
    elements = Tuple{String,Int}[]
    props = Dict{String,Vector{String}}()
    current = ""
    while true
        it = iterate(lines, it[2])
        it === nothing && error("$path: unexpected end of header")
        line = strip(it[1])
        tok = split(line)
        isempty(tok) && continue
        if tok[1] == "format"
            tok[2] == "ascii" || error("$path: only ASCII PLY is supported")
        elseif tok[1] == "element"
            current = String(tok[2])
            push!(elements, (current, parse(Int, tok[3])))
            props[current] = String[]
        elseif tok[1] == "property"
            if tok[2] == "list"
                push!(props[current], String(tok[5]))
            else
                push!(props[current], String(tok[3]))
            end
        elseif tok[1] == "end_header"
            break
        end
    end
    haskey(props, "vertex") || error("$path: no vertex element")
    vp = props["vertex"]
    idx = Dict(name => k for (k, name) in enumerate(vp))
    for name in ("x", "y", "z")
        haskey(idx, name) || error("$path: vertex property '$name' is required")
    end
    has_normals = all(name -> haskey(idx, name), ("nx", "ny", "nz"))
    positions = Vec3[]
    normals = Vec3[]
    for (name, count) in elements
        for _ in 1:count
            it = iterate(lines, it[2])
            it === nothing && error("$path: unexpected end of file")
            name == "vertex" || continue
            v = split(strip(it[1]))
            x = n -> parse(Float64, v[idx[n]])
            push!(positions, Vec3(x("x"), x("y"), x("z")))
            push!(normals, has_normals ? Vec3(x("nx"), x("ny"), x("nz")) : zero(Vec3))
        end
    end
    PointCloud(positions, normals)
end

"""
    write_ply(path, mesh::BPAMesh; face_colors=nothing)

Write the point cloud (with normals) and the triangles as an ASCII PLY file. `face_colors`
may be a vector of `(r, g, b)` integers in 0–255, one per triangle, stored as the face
properties `red green blue`.
"""
function write_ply(path::AbstractString, mesh::BPAMesh; face_colors = nothing)
    c = mesh.cloud
    open(path, "w") do io
        println(io, "ply\nformat ascii 1.0\ncomment generated by BPA.jl")
        println(io, "element vertex ", length(c))
        println(io, "property float x\nproperty float y\nproperty float z")
        println(io, "property float nx\nproperty float ny\nproperty float nz")
        println(io, "element face ", length(mesh.triangles))
        println(io, "property list uchar int vertex_indices")
        face_colors === nothing || println(io, "property uchar red\nproperty uchar green\nproperty uchar blue")
        println(io, "end_header")
        for (p, n) in zip(c.positions, c.normals)
            println(io, p[1], " ", p[2], " ", p[3], " ", n[1], " ", n[2], " ", n[3])
        end
        for (k, t) in enumerate(mesh.triangles)
            print(io, "3 ", t[1] - 1, " ", t[2] - 1, " ", t[3] - 1)
            if face_colors !== nothing
                r, g, b = face_colors[k]
                print(io, " ", r, " ", g, " ", b)
            end
            println(io)
        end
    end
    path
end

"""
    write_obj(path, mesh::BPAMesh; vertex_colors=nothing)

Write the point cloud and triangles as a Wavefront OBJ file (with vertex normals).
OBJ has no per-face colours; `vertex_colors` (a vector of `(r, g, b)` in 0–255, one per
point) is written in the widely supported `v x y z r g b` extension, with values in 0–1.
"""
function write_obj(path::AbstractString, mesh::BPAMesh; vertex_colors = nothing)
    c = mesh.cloud
    open(path, "w") do io
        println(io, "# generated by BPA.jl")
        for (k, p) in enumerate(c.positions)
            print(io, "v ", p[1], " ", p[2], " ", p[3])
            if vertex_colors !== nothing
                r, g, b = vertex_colors[k]
                print(io, " ", r / 255, " ", g / 255, " ", b / 255)
            end
            println(io)
        end
        for n in c.normals
            println(io, "vn ", n[1], " ", n[2], " ", n[3])
        end
        for t in mesh.triangles
            println(io, "f ", t[1], "//", t[1], " ", t[2], "//", t[2], " ", t[3], "//", t[3])
        end
    end
    path
end
