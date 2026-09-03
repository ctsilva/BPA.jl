# Minimal flat-shaded painter's-algorithm renderer: OFF -> PPM, plus depth-complexity images.
#
#   julia tools/render.jl mesh.off [out.ppm] [ANGLE] [--no-edges] [--size WxH]
#   julia tools/render.jl -f scans.txt [-d DIR] [out.ppm] [ANGLE] [--size WxH]
#
# A COFF mesh (per-vertex colours, as bpa.jl writes with --save-colored or -p) is shaded in
# its own colours, each triangle taking the colour of its first vertex; --no-edges leaves the
# boundary edges undrawn, for pictures rather than diagnosis; --size sets the image size
# (default 1400x1000), for instance to crop a detail at full resolution afterwards.
# The second form renders the range scans named in the list file (one per line, # comments)
# as one mesh: each <name>.off is read from DIR (default: the list file's directory) with its
# faces and moved by <name>.xf when that exists, so the depth-complexity images show how
# many scans cover each part of the surface. ANGLE is the rotation about the vertical axis in
# degrees (default 30); out.ppm defaults to the mesh's (or list's) name with a .ppm extension,
# next to it. Writes out.ppm (shaded, boundary
# edges in red), out_depth.ppm (number of triangles behind
# each pixel: warm colours for odd counts, cool for even; a closed surface is even everywhere,
# so odd pixels are holes, and local jumps are duplicate layers) and out_signed.ppm
# (front-facing minus back-facing triangles per pixel: 0 for a closed, consistently oriented
# surface; +-1 at holes, +-2 at flipped patches). Pixel centres are sampled exactly, with a
# top-left rule for centres on a shared edge, so every pixel is counted once per triangle.
using LinearAlgebra, Printf

# Returns the vertices, the faces and, for a COFF file, the per-vertex colours (r, g, b in
# 0..1; nothing otherwise).
function read_off_faces(path)
    lines = filter(l -> !isempty(strip(l)) && !startswith(strip(l), '#'), readlines(path))
    nv, nf, _ = parse.(Int, split(lines[2]))
    rows = [split(lines[2+i]) for i in 1:nv]
    V = [parse.(Float64, r[1:3]) for r in rows]
    F = [parse.(Int, split(lines[2+nv+i])[2:4]) .+ 1 for i in 1:nf]
    C = nothing
    if startswith(strip(lines[1]), "COFF") && all(r -> length(r) >= 6, rows)
        C = [parse.(Float64, r[4:6]) for r in rows]
        maximum(maximum.(C)) > 1 && (C = [c ./ 255 for c in C])      # 0..255 colours
    end
    V, F, C
end

# Read the scans named in a list file and merge them into one mesh in the common frame.
function read_scan_list(list, dir)
    names = filter(l -> !isempty(l) && !startswith(l, '#'), strip.(readlines(list)))
    V = Vector{Float64}[]; F = Vector{Int}[]
    for name in names
        off = joinpath(dir, name * ".off")
        isfile(off) || error("scan not found: $off")
        Vs, Fs, _ = read_off_faces(off)
        xf = joinpath(dir, name * ".xf")
        if isfile(xf)
            M = reduce(vcat, [parse.(Float64, split(l))' for l in readlines(xf) if !isempty(strip(l))])
            Vs = [(M * [v; 1.0])[1:3] for v in Vs]
        end
        println("  ", rpad(name, 12), lpad(length(Vs), 8), " points", lpad(length(Fs), 8), " faces",
                isfile(xf) ? "  (transformed by $name.xf)" : "")
        offset = length(V)
        append!(V, Vs); append!(F, [f .+ offset for f in Fs])
    end
    println("merged ", length(names), " scans: ", length(V), " points, ", length(F), " faces")
    V, F
end

function write_ppm(path, img)
    W, H = size(img, 2), size(img, 3)
    open(path, "w") do io
        write(io, "P6\n$W $H\n255\n")
        write(io, img)              # layout (channel, x, y) is already PPM byte order
    end
end

# Call f(x, y) for every pixel whose centre lies inside the screen triangle (x1,y1)-(x2,y2)-(x3,y3).
# A centre exactly on an edge belongs to the triangle for which that edge is a "top-left"
# edge, so two triangles sharing the edge never both claim the pixel.
function rasterize(f, x1, y1, x2, y2, x3, y3, W, H)
    det = (x2-x1)*(y3-y1) - (x3-x1)*(y2-y1)
    det == 0 && return
    if det < 0                     # make the winding positive in screen space
        x2, y2, x3, y3 = x3, y3, x2, y2
    end
    xmin = max(1, floor(Int, min(x1,x2,x3))); xmax = min(W, ceil(Int, max(x1,x2,x3)))
    ymin = max(1, floor(Int, min(y1,y2,y3))); ymax = min(H, ceil(Int, max(y1,y2,y3)))
    topleft(dx, dy) = dy > 0 || (dy == 0 && dx > 0)
    tl1 = topleft(x2-x1, y2-y1); tl2 = topleft(x3-x2, y3-y2); tl3 = topleft(x1-x3, y1-y3)
    inside(w, tl) = w > 0 || (w == 0 && tl)
    for y in ymin:ymax, x in xmin:xmax
        px, py = x + 0.5, y + 0.5
        w1 = (x2-x1)*(py-y1) - (y2-y1)*(px-x1)
        w2 = (x3-x2)*(py-y2) - (y3-y2)*(px-x2)
        w3 = (x1-x3)*(py-y3) - (y1-y3)*(px-x3)
        inside(w1, tl1) && inside(w2, tl2) && inside(w3, tl3) && f(x, y)
    end
end

# Colours for the depth-complexity image. For a reconstruction, odd counts are on a warm ramp
# (yellow to dark red) and even counts on a cool one (light blue to navy), so holes stand out.
# For merged scans, whose sheets are open and overlap freely, parity means nothing and a
# single sequential ramp (pale yellow, orange, dark purple) shows the number of layers. The
# ramp saturates at `cmax` layers: a fixed DEPTH_MAX for reconstructions, so colours mean the
# same across meshes, and the 99th percentile of the counts present for scans, which can
# stack dozens deep.
const DEPTH_MAX = 16
lerp(a, b, t) = ntuple(i -> round(UInt8, a[i] + t * (b[i] - a[i])), 3)
function depth_color(c, parity, cmax)
    c == 0 && return (0xf5, 0xf5, 0xf5)
    t = (min(c, cmax) - 1) / (cmax - 1)
    if parity
        isodd(c) ? lerp((255, 225, 90), (130, 0, 0), t) : lerp((175, 205, 245), (10, 20, 90), t)
    else
        t < 0.5 ? lerp((255, 245, 190), (235, 110, 30), 2t) : lerp((235, 110, 30), (70, 0, 90), 2t - 1)
    end
end
# Colours for front - back: 0 grey, positive blues, negative reds, saturating at +-SIGNED_MAX.
const SIGNED_MAX = 6
function signed_color(s)
    s == 0 && return (0xc8, 0xc8, 0xc8)
    t = (min(abs(s), SIGNED_MAX) - 1) / (SIGNED_MAX - 1)
    s > 0 ? lerp((160, 190, 255), (5, 25, 120), t) : lerp((255, 180, 160), (120, 5, 5), t)
end

function main(args)
    list = ""; dir = ""; positional = String[]; edges = true; W, H = 1400, 1000
    i = 1
    while i <= length(args)
        if args[i] == "-f" && i < length(args); list = args[i+1]; i += 2
        elseif args[i] == "-d" && i < length(args); dir = args[i+1]; i += 2
        elseif args[i] == "--no-edges"; edges = false; i += 1
        elseif args[i] == "--size" && i < length(args); W, H = parse.(Int, split(args[i+1], 'x')); i += 2
        else push!(positional, args[i]); i += 1
        end
    end
    if isempty(list) && isempty(positional)
        println(stderr, "usage: julia render.jl mesh.off [out.ppm] [ANGLE] [--no-edges] [--size WxH]\n       julia render.jl -f scans.txt [-d DIR] [out.ppm] [ANGLE] [--size WxH]")
        exit(1)
    end
    if isempty(list)
        input = popfirst!(positional)
        V, F, C = read_off_faces(input)
    else
        input = list
        V, F = read_scan_list(list, isempty(dir) ? dirname(abspath(list)) : dir)
        C = nothing
    end
    out = length(positional) >= 1 ? positional[1] : splitext(input)[1] * ".ppm"
    angle = length(positional) >= 2 ? parse(Float64, positional[2]) : 30.0
    # View: rotate about Y (bunny's up axis is +Y in Stanford data) so we see the side/front
    θ = deg2rad(angle); φ = deg2rad(15)
    Ry = [cos(θ) 0 sin(θ); 0 1 0; -sin(θ) 0 cos(θ)]
    Rx = [1 0 0; 0 cos(φ) -sin(φ); 0 sin(φ) cos(φ)]
    R = Rx * Ry
    P = [R * v for v in V]
    xs = [p[1] for p in P]; ys = [p[2] for p in P]
    cx, cy = (maximum(xs)+minimum(xs))/2, (maximum(ys)+minimum(ys))/2
    s = 0.9 * min(W/(maximum(xs)-minimum(xs)), H/(maximum(ys)-minimum(ys)))
    sx(p) = (p[1]-cx)*s + W/2; sy(p) = H/2 - (p[2]-cy)*s
    light = normalize([0.3, 0.5, 1.0])
    img = fill(UInt8(245), 3, W, H)
    cover = zeros(Int, W, H)        # triangles behind each pixel
    signed = zeros(Int, W, H)       # front-facing minus back-facing
    depth = [ (P[f[1]][3]+P[f[2]][3]+P[f[3]][3])/3 for f in F ]
    order = sortperm(depth)  # far to near (z toward viewer is +)
    for i in order
        f = F[i]; a, b, c = P[f[1]], P[f[2]], P[f[3]]
        n = cross(b - a, c - a); nn = norm(n); nn == 0 && continue; n /= nn
        facing = n[3] >= 0 ? 1 : -1
        if n[3] < 0; n = -n; end  # two-sided lighting
        shade = 0.25 + 0.75 * max(0.0, dot(n, light))
        base = C === nothing ? (0.85, 0.70, 0.55) : (C[f[1]][1], C[f[1]][2], C[f[1]][3])
        col = (UInt8(round(255*base[1]*shade)), UInt8(round(255*base[2]*shade)), UInt8(round(255*base[3]*shade)))
        rasterize(sx(a),sy(a),sx(b),sy(b),sx(c),sy(c), W, H) do x, y
            img[1,x,y] = col[1]; img[2,x,y] = col[2]; img[3,x,y] = col[3]
            cover[x,y] += 1
            signed[x,y] += facing
        end
    end
    # Draw boundary edges in red on top
    ec = Dict{Tuple{Int,Int},Int}()
    for f in F, (p,q) in ((f[1],f[2]),(f[2],f[3]),(f[3],f[1])); k = p<q ? (p,q) : (q,p); ec[k] = get(ec,k,0)+1; end
    for ((p,q),c) in ec
        (edges && c == 1) || continue
        a, b = P[p], P[q]
        x1,y1,x2,y2 = sx(a),sy(a),sx(b),sy(b)
        nsteps = max(2, ceil(Int, 2*hypot(x2-x1,y2-y1)))
        for t in range(0,1,length=nsteps)
            x = round(Int, x1 + t*(x2-x1)); y = round(Int, y1 + t*(y2-y1))
            for dx in -1:1, dy in -1:1
                xx, yy = x+dx, y+dy
                (1 <= xx <= W && 1 <= yy <= H) || continue
                img[1,xx,yy] = 220; img[2,xx,yy] = 20; img[3,xx,yy] = 20
            end
        end
    end
    write_ppm(out, img)

    # Depth-complexity images and a histogram of what they contain.
    base_name = splitext(out)[1]
    parity = isempty(list)
    covered_counts = sort(cover[cover .> 0])
    cmax = parity ? DEPTH_MAX : max(2, covered_counts[ceil(Int, 0.99 * length(covered_counts))])
    dimg = similar(img); simg = similar(img)
    for y in 1:H, x in 1:W
        r, g, b = depth_color(cover[x,y], parity, cmax);  dimg[1,x,y] = r; dimg[2,x,y] = g; dimg[3,x,y] = b
        r, g, b = signed_color(signed[x,y]); simg[1,x,y] = r; simg[2,x,y] = g; simg[3,x,y] = b
    end
    write_ppm(base_name * "_depth.ppm", dimg)
    write_ppm(base_name * "_signed.ppm", simg)
    covered = count(>(0), cover)
    println("depth complexity over $covered covered pixels (colour ramp saturates at $cmax layers):")
    for c in 1:maximum(cover)
        n = count(==(c), cover); n == 0 && continue
        @printf("  %d triangles: %7d pixels (%5.1f%%)%s\n", c, n, 100n/covered, isodd(c) ? "  odd" : "")
    end
    nodd = count(isodd, cover)
    @printf("  odd pixels (holes seen through): %d (%.2f%%)\n", nodd, 100nodd/covered)
    for sgn in sort(unique(signed[cover .> 0]))
        sgn == 0 && continue
        @printf("  front - back = %+d: %d pixels\n", sgn, count(==(sgn), signed))
    end
end

main(ARGS)
