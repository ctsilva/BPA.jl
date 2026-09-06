# Sample points with normals on a "waved" torus and write them as a NOFF point cloud, the
# input for bpa.jl:
#
#   julia examples/make_wavy_torus.jl [N] [output] [--grid]
#
# The surface is a torus of major radius R whose tube radius swells and shrinks six times
# around the ring:
#
#   P(a, b) = R (cos a, sin a, 0) + ρ(a) (cos a cos b, sin a cos b, sin b),   ρ(a) = r + e cos 6a
#
# with R = 1, r = 0.4 and e = 0.1, and a, b in [0, 2π). About N points (default 15 000) are
# placed by dart throwing: candidates are drawn uniformly by surface area and kept when no
# earlier point lies within d = 0.8 sqrt(area / N), so the sampling is irregular the way a
# scan is but evenly spaced, and one ball radius of about 1.5 d closes the surface; --grid
# samples an nu x nv grid instead (nu = round(sqrt(4N)), nv = N / nu).
# The normal of each point is the unit cross product of the parametric derivatives, which
# points outward. The output defaults to data/wavy_torus.off.

using LinearAlgebra, Random

N = 15_000; out = joinpath(@__DIR__, "..", "data", "wavy_torus.off"); grid = false
positional = String[]
for a in ARGS
    a == "--grid" ? (global grid = true) : push!(positional, a)
end
length(positional) >= 1 && (N = parse(Int, positional[1]))
length(positional) >= 2 && (out = positional[2])

const R, r, e = 1.0, 0.4, 0.1
ρ(a) = r + e * cos(6a)
dρ(a) = -6e * sin(6a)

# The point, its outward unit normal and the area element |∂P/∂a × ∂P/∂b| at (a, b).
function surface(a, b)
    ca, sa, cb, sb = cos(a), sin(a), cos(b), sin(b)
    p = R * [ca, sa, 0.0] + ρ(a) * [ca * cb, sa * cb, sb]
    pa = R * [-sa, ca, 0.0] + dρ(a) * [ca * cb, sa * cb, sb] + ρ(a) * [-sa * cb, ca * cb, 0.0]
    pb = ρ(a) * [-ca * sb, -sa * sb, cb]
    n = cross(pa, pb); area = norm(n)
    p, n / area, area
end

function sample_grid(N)
    pts = Vector{Float64}[]; nrm = Vector{Float64}[]
    nu = round(Int, sqrt(4N)); nv = max(1, round(Int, N / nu))
    for i in 0:nu-1, j in 0:nv-1
        p, n, _ = surface(2π * i / nu, 2π * j / nv)
        push!(pts, p); push!(nrm, n)
    end
    pts, nrm
end

function sample_darts(N)
    pts = Vector{Float64}[]; nrm = Vector{Float64}[]
    rng = MersenneTwister(1)
    amax = maximum(surface(a, b)[3] for a in range(0, 2π, 400), b in range(0, 2π, 100))
    total = 4π^2 * R * r                      # the area of the surface, to first order in e
    d = 0.8 * sqrt(total / N)
    cells = Dict{NTuple{3,Int},Vector{Int}}() # points by cell of side d
    cell(p) = (floor(Int, p[1] / d), floor(Int, p[2] / d), floor(Int, p[3] / d))
    tries = 0
    while tries < 40N                         # dart throwing on the area element
        tries += 1
        a, b = 2π * rand(rng), 2π * rand(rng)
        p, n, area = surface(a, b)
        rand(rng) * amax <= area || continue
        c = cell(p); free = true
        for i in c[1]-1:c[1]+1, j in c[2]-1:c[2]+1, k in c[3]-1:c[3]+1
            for q in get(cells, (i, j, k), Int[])
                norm(pts[q] - p) < d && (free = false; break)
            end
            free || break
        end
        free || continue
        push!(pts, p); push!(nrm, n)
        push!(get!(cells, c, Int[]), length(pts))
    end
    println("minimum spacing ", d, " after ", tries, " candidates")
    pts, nrm
end

pts, nrm = grid ? sample_grid(N) : sample_darts(N)

mkpath(dirname(out))
open(out, "w") do io
    println(io, "NOFF")
    println(io, length(pts), " 0 0")
    for (p, n) in zip(pts, nrm)
        println(io, join(round.(p, digits=6), " "), " ", join(round.(n, digits=6), " "))
    end
end
println("wrote ", normpath(out), ": ", length(pts), " points", grid ? " on a grid" : "")
