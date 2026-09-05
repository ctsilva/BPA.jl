# The tools compare.jl runs. Included by compare.jl after `Tool` is defined; must return a
# `Vector{Tool}`. The first entry is the default reference.
#
# To add your own implementation, append a `Tool` whose `command(input, radii, output)`
# builds the command line that reads the NOFF file `input` (x y z nx ny nz per vertex),
# pivots a ball of each radius in `radii` (a vector, increasing; most cases have one), and
# writes `output` as an OFF whose vertices are the input points in the same order (the
# harness verifies this: triangle indices are compared across tools). Return `nothing` when
# the tool is not installed, or when it takes one radius and is given several (`single`
# below), and the column shows n/a. The regex
# captures the tool's own reconstruction time in seconds from its log; when it does not
# match, the wall time of the whole process is used instead.

const EXTERNAL = get(ENV, "BPA_EXTERNAL", joinpath(@__DIR__, "external"))
const FORK = get(ENV, "BPA_FORK", joinpath(homedir(), "src", "bpa", "build", "bpa"))
rho_arg(radii) = join(radii, ",")
"`command` for a tool that takes one radius: n/a when the case has several."
single(f) = (input, radii, output) -> length(radii) == 1 ? f(input, radii[1], output) : nothing
ext(name, stem, exe; multi = false) = Tool(name, stem,
    (input, radii, output) -> isfile(PYTHON) && isfile(joinpath(EXTERNAL, exe)) && (multi || length(radii) == 1) ?
        `$PYTHON $(joinpath(@__DIR__, "ext", "run_ext.py")) $stem $input $(rho_arg(radii)) $output` : nothing,
    r"time: ([\d.]+) s")

[
    # BPA.jl, run through its command-line tool from the package directory
    Tool("BPA.jl", "bpa",
         (input, radii, output) -> `$(Base.julia_cmd()) --project=$PKG $(joinpath(PKG, "bpa.jl")) -i $input -r $(rho_arg(radii)) -o $output`,
         r"triangles: \d+ in ([\d.]+) s"),

    # Open3D and MeshLab (VCG) through their Python bindings; run_py.py is the wrapper.
    # Needs a Python with open3d and pymeshlab: `uv venv --python 3.11 && uv pip install
    # open3d pymeshlab numpy` in compare/, or point BPA_COMPARE_PYTHON at an interpreter.
    Tool("Open3D", "open3d",
         (input, radii, output) -> isfile(PYTHON) ?
             `$PYTHON $(joinpath(@__DIR__, "run_py.py")) open3d $input $(rho_arg(radii)) $output` : nothing,
         r"time: ([\d.]+) s"),
    Tool("MeshLab", "meshlab",                         # one radius only
         single((input, rho, output) -> isfile(PYTHON) ?
             `$PYTHON $(joinpath(@__DIR__, "run_py.py")) meshlab $input $rho $output` : nothing),
         r"time: ([\d.]+) s"),

    # Third-party implementations found on the web, through ext/run_ext.py, which converts
    # to and from their own formats; ext/build.sh fetches and builds them into external/
    # (see ext/README.md for what each one is). Each shows n/a until it is built.
    ext("Digne", "digne", "ipol_digne/BallPivoting/build/ballpivoting"; multi = true),   # IPOL 2014, serial
    ext("Digne -p", "digne_par", "ipol_digne/BallPivoting/build/ballpivoting"; multi = true),  # the same, OpenMP
    ext("Gruber", "gruber", "bernhardmgruber_bpa/build/gruber_noff2off"),                # C++20
    ext("Gruber reseeded", "gruber_reseed", "bernhardmgruber_bpa/build/gruber_reseed_noff2off"),  # + ext/gruber_reseed.patch
    ext("bpa_rs", "bpa_rs", "martinfrances107_bpa_rs/target/release/bpa_rs_noff2off"),   # Rust port of Gruber
    ext("Schmehla", "schmehla", "schmehla_ball-pivoting-algorithm/build/BPA"),           # thesis, "modified" BPA
    ext("Giaccari", "giaccari", "LuigiGiaccari_Surface-Reconstruction-Toolbox/build/ballpivoting"),  # no normals

    # The fork of Gruber's C++ at ~/src/bpa (BPA_FORK to point elsewhere): reads the NOFF and
    # writes the OFF itself, so no wrapper is needed. n/a until it is built.
    Tool("bpa fork", "bpafork",
         (input, radii, output) -> isfile(FORK) ? `$FORK $input $(rho_arg(radii)) $output` : nothing,
         r"time: ([\d.]+) s"),

    # Your implementation: any command that follows the contract above, for example
    # Tool("mine", "mine", single((i, r, o) -> `mybpa --radius $r $i $o`), r"reconstructed in ([\d.]+) s"),
]
