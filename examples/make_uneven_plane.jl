# Write an unevenly sampled plane as a NOFF point cloud, the input for bpa.jl:
#
#   julia --project=. examples/make_uneven_plane.jl [output]
#
# A jittered grid of 50 x 100 points at 1 mm spacing on the left half, beside 12 x 25 points
# at 4 mm on the right half: 5,300 points in all, with normals +z. It is the plane_uneven
# case of the comparison harness (compare/), with the same seeds, and it exercises the
# multi-radius passes of section 4.6 of the paper: a 1.5 mm ball triangulates the dense
# half and stops at the coarse one, which the 6 mm pass of `-r 0.0015,0.006` then covers.
# The output defaults to data/plane_uneven.off.

using BPA, Random

out = length(ARGS) >= 1 ? ARGS[1] : joinpath(@__DIR__, "..", "data", "plane_uneven.off")
h = 0.001
Pd, Nd = BPA.plane_patch(50, 100; spacing = h, jitter = 0.3, rng = Xoshiro(5))
Pc, Nc = BPA.plane_patch(12, 25; spacing = 4h, jitter = 0.3, rng = Xoshiro(6), origin = (50h, 0.0))
cloud = PointCloud(vcat(Pd, Pc), vcat(Nd, Nc))
mkpath(dirname(out))
write_off(out, BPAMesh(cloud, BPA.Tri[], BPAStats()))
println("wrote ", normpath(out), ": ", length(Pd), " points at 1 mm and ", length(Pc), " at 4 mm")
