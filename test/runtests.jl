using Test
using BPA
using LinearAlgebra
using StaticArrays
using Random

using BPA: outward, fibonacci_sphere, sphere_spacing, torus, plane_patch

@testset "BPA" begin
    @testset "geometry" begin
        include("test_geometry.jl")
    end
    @testset "grid" begin
        include("test_grid.jl")
    end
    @testset "front" begin
        include("test_front.jl")
    end
    @testset "reconstruct" begin
        include("test_reconstruct.jl")
    end
    @testset "cli" begin
        include("test_cli.jl")
    end
    include("test_compare.jl")
end
