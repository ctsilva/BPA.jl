#!/bin/bash
# Download and prepare Stanford bunny range scan data
# Data from: http://graphics.stanford.edu/data/3Dscanrep/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data/bunny/data"

echo "Setting up Stanford bunny range scan data..."
echo ""
echo "RECOMMENDED: Download and convert with trimesh2"
echo "================================================"
echo ""
echo "1. Download bunny.tar.gz:"
echo "   wget http://graphics.stanford.edu/pub/3Dscanrep/bunny.tar.gz"
echo "   tar -xzf bunny.tar.gz"
echo ""
echo "2. Convert scans (requires trimesh2):"
echo "   cd bunny/data"
echo "   $SCRIPT_DIR/convert_bunny_scans.sh bun.conf"
echo ""
echo "   This will create .off and .xf files for BPA reconstruction"
echo ""
echo "See: scripts/README.md for detailed instructions"
