# Write a torus mesh as an OFF file, e.g. data/torus-120-80-julia.off (the "-julia" suffix
# keeps it apart from the trimesh2 torus of the same size in data/, which has a different
# minor radius).
#
#   julia examples/make_torus_off.jl [nu] [nv] [output]
#
# nu samples go around the big circle (major radius 1), nv around the tube (minor
# radius 0.4). Faces are oriented outward.

nu = length(ARGS) >= 1 ? parse(Int, ARGS[1]) : 120
nv = length(ARGS) >= 2 ? parse(Int, ARGS[2]) : 80
out = length(ARGS) >= 3 ? ARGS[3] : joinpath(@__DIR__, "..", "data", "torus-$nu-$nv-julia.off")
R, r = 1.0, 0.4

vid(a, b) = mod(a, nu) * nv + mod(b, nv)          # 0-based vertex index
mkpath(dirname(out))
open(out, "w") do io
    println(io, "OFF")
    println(io, nu * nv, " ", 2 * nu * nv, " 0")
    for a in 0:nu-1, b in 0:nv-1
        u = 2π * a / nu
        v = 2π * b / nv
        println(io, (R + r * cos(v)) * cos(u), " ", (R + r * cos(v)) * sin(u), " ", r * sin(v))
    end
    for a in 0:nu-1, b in 0:nv-1
        # quad (a,b) (a+1,b) (a+1,b+1) (a,b+1); the parametrisation (u, v) with the
        # outward normal is right-handed, so this winding faces outward.
        println(io, "3 ", vid(a, b), " ", vid(a + 1, b), " ", vid(a + 1, b + 1))
        println(io, "3 ", vid(a, b), " ", vid(a + 1, b + 1), " ", vid(a, b + 1))
    end
end
println("wrote ", normpath(out))
