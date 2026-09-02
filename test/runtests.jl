using Test
using BPA
using LinearAlgebra
using StaticArrays
using Random

include("synthetic.jl")
include("meshcheck.jl")

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
end
