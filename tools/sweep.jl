#!/usr/bin/env julia
# One reconstruction per radius, as a table. Run `julia tools/sweep.jl -h`.
# Activates the package environment itself, so it works without `--project`.

import Pkg
Pkg.activate(dirname(@__DIR__); io = devnull)
using BPA

exit(BPA.sweep_main(ARGS))
