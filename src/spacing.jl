# Sample spacing estimate, used to pick a default ball radius.

"""
    estimate_spacing(cloud; nsamples=2000, rng) -> Float64
    estimate_spacing(positions; nsamples=2000, rng) -> Float64

Median distance from a point to its nearest neighbour, estimated on a random subset of at
most `nsamples` points. A ball radius of about 1.5–2 times this value is a reasonable
default for evenly sampled data; random samples of a surface (as from `sample_surface`)
have larger gaps and want 3 times, or two passes at 1.5 and 3 times.
"""
estimate_spacing(cloud::PointCloud; kwargs...) = estimate_spacing(cloud.positions; kwargs...)

function estimate_spacing(P::Vector{Vec3}; nsamples::Integer = 2000, rng = Random.default_rng())
    n = length(P)
    n >= 2 || throw(ArgumentError("need at least two points"))
    idx = n <= nsamples ? collect(1:n) : sort!(randperm(rng, n)[1:nsamples])
    dist = fill(Inf, length(idx))
    lo = reduce((a, b) -> min.(a, b), P)
    hi = reduce((a, b) -> max.(a, b), P)
    extent = maximum(hi - lo)
    extent > 0 || return 0.0
    # Start from the spacing of n points spread over a surface the size of the bounding box
    # and keep doubling the query radius until every sampled point has found a neighbour.
    delta = max(sqrt(extent^2 / n), 1e-9 * extent)
    buf = Int[]
    remaining = collect(eachindex(idx))
    while !isempty(remaining) && delta <= 4 * extent
        g = VoxelGrid(P, delta)
        still = Int[]
        for k in remaining
            i = idx[k]
            neighbors!(buf, g, P[i], delta)
            best = Inf
            for j in buf
                j == i && continue
                best = min(best, norm(P[j] - P[i]))
            end
            if best < Inf
                dist[k] = best
            else
                push!(still, k)
            end
        end
        remaining = still
        delta *= 2
    end
    finite = sort!(filter(isfinite, dist))
    isempty(finite) && return 0.0
    m = length(finite)
    isodd(m) ? finite[(m + 1) ÷ 2] : (finite[m ÷ 2] + finite[m ÷ 2 + 1]) / 2
end
