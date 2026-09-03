# The tools compare.jl runs. Included by compare.jl after `Tool` is defined; must return a
# `Vector{Tool}`. The first entry is the default reference.
#
# To add your own implementation, append a `Tool` whose `command(input, rho, output)` builds
# the command line that reads the NOFF file `input` (x y z nx ny nz per vertex), pivots a
# ball of radius `rho`, and writes `output` as an OFF whose vertices are the input points in
# the same order (the harness verifies this: triangle indices are compared across tools).
# Return `nothing` when the tool is not installed, and the column shows n/a. The regex
# captures the tool's own reconstruction time in seconds from its log; when it does not
# match, the wall time of the whole process is used instead.

[
    # BPA.jl, run through its command-line tool from the package directory
    Tool("BPA.jl", "bpa",
         (input, rho, output) -> `$(Base.julia_cmd()) --project=$PKG $(joinpath(PKG, "bpa.jl")) -i $input -r $rho -o $output`,
         r"triangles: \d+ in ([\d.]+) s"),

    # Open3D and MeshLab (VCG) through their Python bindings; run_py.py is the wrapper.
    # Needs a Python with open3d and pymeshlab: `uv venv --python 3.11 && uv pip install
    # open3d pymeshlab numpy` in compare/, or point BPA_COMPARE_PYTHON at an interpreter.
    Tool("Open3D", "open3d",
         (input, rho, output) -> isfile(PYTHON) ?
             `$PYTHON $(joinpath(@__DIR__, "run_py.py")) open3d $input $rho $output` : nothing,
         r"time: ([\d.]+) s"),
    Tool("MeshLab", "meshlab",
         (input, rho, output) -> isfile(PYTHON) ?
             `$PYTHON $(joinpath(@__DIR__, "run_py.py")) meshlab $input $rho $output` : nothing,
         r"time: ([\d.]+) s"),

    # Your implementation: any command that follows the contract above, for example
    # Tool("mine", "mine", (i, r, o) -> `mybpa --radius $r $i $o`, r"reconstructed in ([\d.]+) s"),
]
