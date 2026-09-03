# The comparison harness in compare/, on the sphere with BPA.jl alone (no Python tools, no
# renderings), as a subprocess the way it is meant to be run.
@testset "compare harness" begin
    pkg = dirname(@__DIR__)
    script = joinpath(pkg, "compare", "compare.jl")
    out = mktempdir()
    cmd = `$(Base.julia_cmd()) --project=$pkg $script sphere2000 --tools bpa --no-render --out $out`
    cmd = addenv(cmd, "JULIA_LOAD_PATH" => "@:@stdlib")   # Pkg.test strips the stdlib entry
    log = IOBuffer()
    ok = success(pipeline(cmd; stdout = log, stderr = log))
    ok || println(String(take!(log)))
    @test ok
    report = read(joinpath(out, "sphere2000", "report.md"), String)
    @test occursin("| triangles | 3996 | n/a | n/a |", report)
    @test occursin("| boundary edges | 0 |", report)
    @test occursin("| Euler characteristic | 2 |", report)
    @test occursin("| orientable | yes |", report)
    @test occursin("| valid | 3996 |", report)
    @test occursin("| ball_not_empty | 0 |", report)
    @test isfile(joinpath(out, "report.md")) && isfile(joinpath(out, "index.html"))
    @test isfile(joinpath(out, "sphere2000", "bpa.off"))
end
