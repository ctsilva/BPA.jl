# Reconstruct a sampled sphere and write the result as OBJ and PLY.
#
#   julia --project=.. sphere.jl [npoints]

using BPA, StaticArrays

n = length(ARGS) >= 1 ? parse(Int, ARGS[1]) : 5000

function fibonacci_sphere(n)
    P = Vector{SVector{3,Float64}}(undef, n)
    ga = π * (3 - sqrt(5))
    for k in 0:n-1
        y = 1 - 2 * (k + 0.5) / n
        s = sqrt(1 - y^2)
        P[k+1] = SVector(s * cos(ga * k), y, s * sin(ga * k))
    end
    P
end

P = fibonacci_sphere(n)
cloud = PointCloud(P, P)                    # unit sphere: the normal is the position
spacing = sqrt(4π / n)                      # mean sample spacing
rho = 1.5 * spacing

println("reconstructing $n points with rho = $rho")
mesh = @time reconstruct(cloud, rho; verbose = true)
println(mesh)
println(mesh.stats)

out = joinpath(@__DIR__, "sphere")
write_obj(out * ".obj", mesh)
write_ply(out * ".ply", mesh)
println("wrote $out.obj and $out.ply")
