# docs/LITERATE.md is generated from the source by docs/literate.jl; it must match.

@testset "literate" begin
    docs = joinpath(dirname(@__DIR__), "docs")
    m = Module(:LiterateGen)
    Base.include(m, joinpath(docs, "literate.jl"))
    generated = Base.invokelatest(m.generate)
    checked_in = read(joinpath(docs, "LITERATE.md"), String)
    @test generated == checked_in     # if this fails: julia docs/literate.jl
    # every core source file contributes a chapter, and every chapter has code
    @test count("\n## ", generated) == length(m.CHAPTERS)
    @test count("```julia", generated) > 50
end
