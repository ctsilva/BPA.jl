# Synthetic point clouds with analytic normals.

using StaticArrays, Random

"""
    fibonacci_sphere(n; r=1.0) -> (positions, normals)

`n` nearly uniformly distributed points on a sphere of radius `r`. Mean spacing ≈ `sqrt(4πr²/n)`.
"""
function fibonacci_sphere(n::Int; r::Real = 1.0)
    P = Vector{SVector{3,Float64}}(undef, n)
    N = Vector{SVector{3,Float64}}(undef, n)
    ga = π * (3 - sqrt(5))
    for k in 0:n-1
        y = 1 - 2 * (k + 0.5) / n
        s = sqrt(1 - y^2)
        θ = ga * k
        d = SVector(s * cos(θ), y, s * sin(θ))
        P[k+1] = r * d
        N[k+1] = d
    end
    P, N
end

sphere_spacing(n, r = 1.0) = sqrt(4π * r^2 / n)

"""
    torus(nu, nv; R=1.0, r=0.4, jitter=0.3, rng) -> (positions, normals)

Parametric torus sampled on a `nu × nv` grid in `(u, v)` with random jitter (a fraction of
the parametric spacing) to avoid exactly co-spherical samples.
"""
function torus(nu::Int, nv::Int; R::Real = 1.0, r::Real = 0.4, jitter::Real = 0.3,
               rng = Random.Xoshiro(1))
    P = SVector{3,Float64}[]
    N = SVector{3,Float64}[]
    du = 2π / nu
    dv = 2π / nv
    for a in 0:nu-1, b in 0:nv-1
        u = (a + jitter * (rand(rng) - 0.5)) * du
        v = (b + jitter * (rand(rng) - 0.5)) * dv
        push!(P, SVector((R + r * cos(v)) * cos(u), (R + r * cos(v)) * sin(u), r * sin(v)))
        push!(N, SVector(cos(v) * cos(u), cos(v) * sin(u), sin(v)))
    end
    P, N
end

"""
    plane_patch(nx, ny; spacing=1/nx, jitter=0.3, rng, origin=(0,0)) -> (positions, normals)

Jittered grid of points on the plane `z = 0`, normals `+z`.
"""
function plane_patch(nx::Int, ny::Int; spacing::Real = 1 / nx, jitter::Real = 0.3,
                     rng = Random.Xoshiro(2), origin = (0.0, 0.0))
    P = SVector{3,Float64}[]
    N = SVector{3,Float64}[]
    for a in 0:nx-1, b in 0:ny-1
        x = origin[1] + (a + jitter * (rand(rng) - 0.5)) * spacing
        y = origin[2] + (b + jitter * (rand(rng) - 0.5)) * spacing
        push!(P, SVector(x, y, 0.0))
        push!(N, SVector(0.0, 0.0, 1.0))
    end
    P, N
end
