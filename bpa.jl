#!/usr/bin/env julia
# Command-line front end for BPA.jl. Run `julia bpa.jl -h` for the options.
#
# The script activates the package environment it lives in, so it works without
# `--project`. The first run compiles the package and takes a few seconds longer.

import Pkg
Pkg.activate(@__DIR__; io = devnull)
using BPA

exit(BPA.main(ARGS))
