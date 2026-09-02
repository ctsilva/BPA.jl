#!/bin/bash
# Generate test meshes for BPA algorithm testing
# Requires: trimesh2 (mesh_make command)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"

echo "Generating test meshes in $DATA_DIR..."
mkdir -p "$DATA_DIR"

# Torus - simple test case
echo "Generating torus-120-80.off..."
mesh_make torus 120 80 "$DATA_DIR/torus-120-80.off"

# Trefoil knot - challenging case with near self-intersection
echo "Generating knot-300-100.off..."
mesh_make knot 300 100 "$DATA_DIR/knot-300-100.off"

echo "Done! Test meshes generated in $DATA_DIR"
echo ""
echo "To test:"
echo "  julia bpa.jl -r 0.1 -i data/torus-120-80.off"
echo "  julia bpa.jl -r 0.05 -i data/knot-300-100.off"
