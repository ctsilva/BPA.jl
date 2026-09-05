#!/usr/bin/env julia
# Topology report and empty-ball audit of a mesh file. Run `julia tools/check.jl -h`.
# Activates the package environment itself, so it works without `--project`.

import Pkg
Pkg.activate(dirname(@__DIR__); io = devnull)
using BPA

exit(BPA.check_main(ARGS))
