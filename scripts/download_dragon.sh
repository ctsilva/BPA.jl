#!/bin/bash
# Download and prepare Stanford Dragon range scan data
# Data from: http://graphics.stanford.edu/data/3Dscanrep/
#
# Dragon dataset:
# - ~70 scans total
# - 2,748,318 points total
# - Reconstructed mesh: 566,098 vertices, 1,132,830 triangles
# - Contains numerous small holes (challenging for BPA)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data/dragon"
TEMP_DIR="$DATA_DIR/temp"

echo "========================================================================="
echo "Stanford Dragon Dataset Download"
echo "========================================================================="
echo ""
echo "This script downloads the Stanford Dragon range scan data."
echo "Dataset details:"
echo "  - Source: Stanford Computer Graphics Laboratory"
echo "  - Scanner: Cyberware 3030 MS + spacetime analysis"
echo "  - ~70 range scans"
echo "  - 2,748,318 points total (~5.5M triangles)"
echo "  - Reconstruction: 566,098 vertices, 1,132,830 triangles"
echo ""

# Create directories
mkdir -p "$DATA_DIR"
mkdir -p "$TEMP_DIR"

# Download options
echo "Available downloads:"
echo "  1. Vripped reconstruction (dragon_recon.tar.gz - 11 MB)"
echo "  2. All range scans (5 files, ~34 MB total)"
echo "  3. Both reconstruction and range scans"
echo ""
read -p "Select option [1-3]: " choice

download_reconstruction() {
    echo ""
    echo "Downloading dragon reconstruction..."
    cd "$TEMP_DIR"

    if [ ! -f dragon_recon.tar.gz ]; then
        curl -L -o dragon_recon.tar.gz \
            "http://graphics.stanford.edu/pub/3Dscanrep/dragon/dragon_recon.tar.gz"
    else
        echo "  dragon_recon.tar.gz already exists, skipping download"
    fi

    echo "Extracting dragon reconstruction..."
    tar -xzf dragon_recon.tar.gz

    # Move PLY files to main dragon directory
    if [ -d dragon_recon ]; then
        mv dragon_recon/*.ply "$DATA_DIR/"
        echo "  Moved reconstruction files to $DATA_DIR/"
    fi
}

download_range_scans() {
    echo ""
    echo "Downloading dragon range scans..."
    cd "$TEMP_DIR"

    # Array of scan archives
    scans=(
        "dragon_stand.tar.gz"
        "dragon_side.tar.gz"
        "dragon_up.tar.gz"
        "dragon_fillers.tar.gz"
        "dragon_backdrop.tar.gz"
    )

    for scan in "${scans[@]}"; do
        if [ ! -f "$scan" ]; then
            echo "  Downloading $scan..."
            curl -L -o "$scan" \
                "http://graphics.stanford.edu/pub/3Dscanrep/dragon/$scan"
        else
            echo "  $scan already exists, skipping"
        fi

        echo "  Extracting $scan..."
        tar -xzf "$scan"
    done

    # Organize scan files
    mkdir -p "$DATA_DIR/scans"
    find . -name "*.conf" -o -name "*.ply" | while read file; do
        mv "$file" "$DATA_DIR/scans/" 2>/dev/null || true
    done

    echo "  Moved scan files to $DATA_DIR/scans/"
}

# Execute based on user choice
case $choice in
    1)
        download_reconstruction
        ;;
    2)
        download_range_scans
        ;;
    3)
        download_reconstruction
        download_range_scans
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Cleanup
echo ""
echo "Cleaning up temporary files..."
cd "$SCRIPT_DIR"
rm -rf "$TEMP_DIR"

echo ""
echo "========================================================================="
echo "Download complete!"
echo "========================================================================="
echo ""
echo "Files saved to: $DATA_DIR/"
echo ""

# Check what we have
if [ -f "$DATA_DIR/dragon_vrip.ply" ]; then
    echo "Reconstruction mesh available:"
    echo "  dragon_vrip.ply (566,098 vertices, 1,132,830 triangles)"
    echo ""
fi

if [ -d "$DATA_DIR/scans" ]; then
    num_scans=$(find "$DATA_DIR/scans" -name "*.ply" | wc -l)
    echo "Range scans available:"
    echo "  $num_scans PLY scan files in $DATA_DIR/scans/"
    echo ""
fi

echo "Next steps:"
echo ""

if [ -f "$DATA_DIR/dragon_vrip.ply" ]; then
    echo "1. Convert reconstruction to OFF format (requires trimesh2):"
    echo "   cd $DATA_DIR"
    echo "   mesh_filter dragon_vrip.ply dragon_vrip.off"
    echo ""
    echo "2. Run BPA on the reconstruction's vertices, or on points sampled from its surface:"
    echo "   julia bpa.jl -r 0.002 -i data/dragon/dragon_vrip.off"
    echo "   julia bpa.jl -r 0.002 -i data/dragon/dragon_vrip.off --sample 200000"
    echo ""
fi

if [ -d "$DATA_DIR/scans" ]; then
    echo "To convert range scans to OFF format (requires trimesh2):"
    echo "   cd $DATA_DIR/scans"
    echo "   $SCRIPT_DIR/convert_dragon_scans.sh"
    echo ""
fi

echo "For more information, see:"
echo "  - http://graphics.stanford.edu/data/3Dscanrep/"
echo "  - scripts/README.md"
echo ""
