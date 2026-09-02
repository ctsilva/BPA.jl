#!/bin/bash

# =============================================================================
# convert_scans.sh - Convert PLY scans to OFF format with transformations
# =============================================================================
#
# This script processes 3D scan data to prepare it for surface reconstruction:
# 1. Converts PLY files to OFF format using trimesh2's mesh_filter
# 2. Generates .xf transformation files from a configuration file
# 3. Creates a combined colored PLY file with all scans transformed and colored
#
# The .xf files contain 4x4 transformation matrices that align multiple scans
# into a common coordinate system.
#
# DATA SOURCE:
#   Stanford Bunny Dataset
#   https://graphics.stanford.edu/data/3Dscanrep
#   File: bunny.tar.gz
#
# REQUIREMENTS:
#   - trimesh2 tools: mesh_filter, mesh_shade, mesh_cat, xf (must be in PATH)
#   - Configuration file (default: bun.conf) with transformation data
#
# USAGE:
#   ./convert_scans.sh [config_file] [output_combined]
#
# ARGUMENTS:
#   config_file     - Optional: path to .conf file (default: bun.conf)
#   output_combined - Optional: combined output file (default: combined.ply)
#
# OUTPUT:
#   For each scan in the config file:
#   - <basename>.off  - Converted mesh in OFF format
#   - <basename>.xf   - Transformation matrix file
#
#   Combined output:
#   - combined.ply (or specified name) - All scans with transformations applied
#                                        and each scan colored differently
#
# CONFIGURATION FILE FORMAT:
#   The .conf file should contain lines in the format:
#   bmesh filename.ply tx ty tz qx qy qz qw
#
#   Where:
#   - tx, ty, tz: translation vector
#   - qx, qy, qz, qw: rotation quaternion
#   - Lines starting with "camera" are ignored
#
# EXAMPLE:
#   bmesh bun000.ply 0 0 0 0 0 0 1
#   bmesh bun045.ply -0.052 -0.0004 -0.011 0.0055 -0.295 -0.0039 0.956
#
# =============================================================================
# TRANSFORMATION FILES (.xf) - USAGE GUIDE
# =============================================================================
#
# Each .xf file contains a 4x4 homogeneous transformation matrix in row-major
# order that transforms vertices from the scan's local coordinate system to
# the global/world coordinate system.
#
# XF FILE FORMAT:
# ---------------
# The .xf file contains 4 lines (one per row of the matrix):
#   r11 r12 r13 tx
#   r21 r22 r23 ty
#   r31 r32 r33 tz
#     0   0   0  1
#
# Where:
#   [r11 r12 r13]
#   [r21 r22 r23]  = 3x3 rotation matrix
#   [r31 r32 r33]
#
#   [tx, ty, tz]   = translation vector
#
# APPLYING TRANSFORMATIONS TO VERTICES:
# --------------------------------------
# To transform a vertex (x, y, z) from local to world coordinates:
#
#   [x']   [r11 r12 r13 tx]   [x]
#   [y'] = [r21 r22 r23 ty] * [y]
#   [z']   [r31 r32 r33 tz]   [z]
#   [1 ]   [ 0   0   0   1]   [1]
#
# Expanded form:
#   x' = r11*x + r12*y + r13*z + tx
#   y' = r21*x + r22*y + r23*z + ty
#   z' = r31*x + r32*y + r33*z + tz
#
# IMPLEMENTATION NOTES:
# ---------------------
# 1. The transformation is applied as: T(R(v)) where R is rotation, T is translation
#    - First rotate the vertex: v_rotated = R * v
#    - Then translate: v_final = v_rotated + t
#
# 2. When reading an OFF file and applying the transformation from a .xf file:
#    - Read the 4x4 matrix from the .xf file
#    - For each vertex in the OFF file, apply the matrix multiplication above
#    - The result is the vertex position in world coordinates
#
# 3. Identity transformation (no change):
#    - bun000.xf contains the identity matrix (all scans are relative to bun000)
#
# VRIP-STYLE QUATERNION FORMAT (from .conf files):
# -------------------------------------------------
# The .conf file uses VRIP-style quaternions: (qx, qy, qz, qw) where:
#   - (qx, qy, qz) = imaginary part (i, j, k components)
#   - qw = real part (scalar/cosine component)
#
# Conversion to rotation matrix:
#   The quaternion q = (qx, qy, qz, qw) represents rotation where:
#   - Rotation angle θ: cos(θ/2) = qw
#   - Rotation axis: (qx, qy, qz) * (1/sin(θ/2))
#
# The transformation in the .conf file is composed as:
#   1. Apply rotation (from quaternion)
#   2. Apply translation (tx, ty, tz)
#
# This results in the 4x4 matrix stored in the .xf file.
#
# EXAMPLE USAGE IN RECONSTRUCTION SOFTWARE:
# ------------------------------------------
# Julia example for reading and applying transformation:
#
#   # Read transformation matrix from .xf file
#   xf_matrix = readdlm("scan.xf")  # 4x4 matrix
#
#   # Read OFF file
#   vertices, faces = read_off("scan.off")
#
#   # Transform each vertex
#   for i in 1:size(vertices, 1)
#       v_homogeneous = [vertices[i,1], vertices[i,2], vertices[i,3], 1.0]
#       v_transformed = xf_matrix * v_homogeneous
#       vertices[i,:] = v_transformed[1:3]
#   end
#
# C/C++ example:
#
#   // Apply transformation to vertex
#   void transform_vertex(float* v, float M[4][4]) {
#       float x = M[0][0]*v[0] + M[0][1]*v[1] + M[0][2]*v[2] + M[0][3];
#       float y = M[1][0]*v[0] + M[1][1]*v[1] + M[1][2]*v[2] + M[1][3];
#       float z = M[2][0]*v[0] + M[2][1]*v[1] + M[2][2]*v[2] + M[2][3];
#       v[0] = x; v[1] = y; v[2] = z;
#   }
#
# =============================================================================

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Configuration
CONF_FILE="${1:-bun.conf}"
COMBINED_OUTPUT="${2:-combined.ply}"
VERBOSE=1

# Color palette for different scans (hex RGB values)
# These will be assigned cyclically to each scan
COLORS=(
    "ff0000"  # Red
    "00ff00"  # Green
    "0000ff"  # Blue
    "ffff00"  # Yellow
    "ff00ff"  # Magenta
    "00ffff"  # Cyan
    "ff8800"  # Orange
    "8800ff"  # Purple
    "00ff88"  # Spring Green
    "ff0088"  # Rose
    "88ff00"  # Chartreuse
    "0088ff"  # Sky Blue
)

# ANSI color codes for output
COLOR_RESET='\033[0m'
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'

# -----------------------------------------------------------------------------
# Function: log_info
# Print informational message
# -----------------------------------------------------------------------------
log_info() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
    fi
}

# -----------------------------------------------------------------------------
# Function: log_success
# Print success message
# -----------------------------------------------------------------------------
log_success() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*"
    fi
}

# -----------------------------------------------------------------------------
# Function: log_warning
# Print warning message
# -----------------------------------------------------------------------------
log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*" >&2
}

# -----------------------------------------------------------------------------
# Function: log_error
# Print error message and exit
# -----------------------------------------------------------------------------
log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
    exit 1
}

# -----------------------------------------------------------------------------
# Function: check_dependencies
# Verify required tools are available
# -----------------------------------------------------------------------------
check_dependencies() {
    local missing_deps=0

    for tool in mesh_filter mesh_shade mesh_cat xf; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool not found. Please install trimesh2 and add it to PATH."
            missing_deps=1
        fi
    done

    if [ "$missing_deps" -eq 1 ]; then
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Function: convert_ply_to_off
# Convert a PLY file to OFF format
# Arguments:
#   $1 - Input PLY filename
#   $2 - Output OFF filename
# -----------------------------------------------------------------------------
convert_ply_to_off() {
    local ply_file="$1"
    local off_file="$2"

    if [ ! -f "$ply_file" ]; then
        log_warning "PLY file not found: $ply_file (skipping)"
        return 1
    fi

    log_info "Converting $ply_file -> $off_file"

    if mesh_filter "$ply_file" "$off_file" 2>&1 | grep -q "error"; then
        log_warning "mesh_filter reported errors for $ply_file"
        return 1
    fi

    if [ ! -f "$off_file" ]; then
        log_warning "Failed to create $off_file"
        return 1
    fi

    log_success "Created $off_file"
    return 0
}

# -----------------------------------------------------------------------------
# Function: create_xf_file
# Create a .xf transformation file from translation and quaternion
# Arguments:
#   $1 - Output .xf filename
#   $2 - tx (translation x)
#   $3 - ty (translation y)
#   $4 - tz (translation z)
#   $5 - qx (quaternion x)
#   $6 - qy (quaternion y)
#   $7 - qz (quaternion z)
#   $8 - qw (quaternion w)
# -----------------------------------------------------------------------------
create_xf_file() {
    local xf_file="$1"
    local tx="$2"
    local ty="$3"
    local tz="$4"
    local qx="$5"
    local qy="$6"
    local qz="$7"
    local qw="$8"

    log_info "Creating transformation file: $xf_file"
    log_info "  Translation: ($tx, $ty, $tz)"
    log_info "  Quaternion:  ($qx, $qy, $qz, $qw)"

    # Note: bun.conf uses VRIP-style quaternions (qx, qy, qz, qw)
    # Use -v flag which expects: qi qj qk iqr format
    # Correct order: -trans first, then -v with quaternion values
    if ! xf -trans "$tx" "$ty" "$tz" -v "$qx" "$qy" "$qz" "$qw" -o "$xf_file" 2>&1; then
        log_warning "Failed to create $xf_file"
        return 1
    fi

    if [ ! -f "$xf_file" ]; then
        log_warning "Failed to create $xf_file"
        return 1
    fi

    log_success "Created $xf_file"
    return 0
}

# -----------------------------------------------------------------------------
# Function: parse_and_process_conf
# Parse the configuration file and process each scan
# Arguments:
#   $1 - Configuration file path
# -----------------------------------------------------------------------------
parse_and_process_conf() {
    local conf_file="$1"
    local processed=0
    local skipped=0
    local color_index=0
    local -a colored_ply_files=()  # Array to store colored+transformed PLY files

    if [ ! -f "$conf_file" ]; then
        log_error "Configuration file not found: $conf_file"
    fi

    log_info "Reading configuration from: $conf_file"
    echo ""

    while IFS= read -r line; do
        # Skip empty lines and comments
        if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        # Skip camera lines
        if [[ "$line" =~ ^camera ]]; then
            log_info "Skipping camera configuration"
            continue
        fi

        # Parse bmesh lines: bmesh filename.ply tx ty tz qx qy qz qw
        if [[ "$line" =~ ^bmesh ]]; then
            # Use read to split the line into fields
            read -r _ ply_file tx ty tz qx qy qz qw <<< "$line"

            # Extract basename without extension
            local basename="${ply_file%.ply}"
            local off_file="${basename}.off"
            local xf_file="${basename}.xf"

            echo ""
            log_info "Processing: $ply_file"
            log_info "============================================"

            # Convert PLY to OFF
            local success=0
            if convert_ply_to_off "$ply_file" "$off_file"; then
                # Create transformation file
                if create_xf_file "$xf_file" "$tx" "$ty" "$tz" "$qx" "$qy" "$qz" "$qw"; then
                    success=1
                fi
            fi

            # Create colored and transformed PLY for combined output
            if [ "$success" -eq 1 ]; then
                local color="${COLORS[$color_index]}"
                local colored_ply="${basename}_colored.ply"
                local xformed_ply="${basename}_xformed.ply"

                log_info "Creating colored mesh (color: #$color)"
                if mesh_shade "$off_file" color "$color" "$colored_ply" > /dev/null 2>&1; then
                    log_success "Created colored mesh: $colored_ply"

                    log_info "Applying transformation to colored mesh"
                    if mesh_filter "$colored_ply" -xform "$xf_file" "$xformed_ply" > /dev/null 2>&1; then
                        log_success "Created transformed mesh: $xformed_ply"
                        colored_ply_files+=("$xformed_ply")
                        ((processed += 1))

                        # Cycle through colors
                        color_index=$(( (color_index + 1) % ${#COLORS[@]} ))
                    else
                        log_warning "Failed to transform colored mesh"
                        ((skipped += 1))
                    fi
                else
                    log_warning "Failed to create colored mesh"
                    ((skipped += 1))
                fi
            else
                ((skipped += 1))
            fi
        fi
    done < "$conf_file"

    echo ""
    echo "============================================"
    log_success "Individual scan processing complete!"
    log_info "Processed: $processed scans"
    if [ "$skipped" -gt 0 ]; then
        log_warning "Skipped: $skipped scans"
    fi

    # Combine all colored PLY files
    if [ "${#colored_ply_files[@]}" -gt 0 ]; then
        echo ""
        log_info "Combining all scans into: $COMBINED_OUTPUT"
        log_info "============================================"

        if mesh_cat "${colored_ply_files[@]}" -o "$COMBINED_OUTPUT" > /dev/null 2>&1; then
            log_success "Created combined mesh: $COMBINED_OUTPUT"
            log_info "Combined ${#colored_ply_files[@]} scans with different colors"
        else
            log_error "Failed to create combined mesh"
        fi
    else
        log_warning "No colored PLY files to combine"
    fi

    # Generate list files for BPA reconstruction
    echo ""
    log_info "Generating scan list files..."

    # Find all OFF files and extract basenames
    all_scans=($(find . -maxdepth 1 -name "bun*.off" -o -name "chin.off" -o -name "ear*.off" -o -name "top*.off" | sed 's|^\./||; s|\.off$||' | sort))

    if [ ${#all_scans[@]} -gt 0 ]; then
        # Create full list file
        cat > bunny_scans.txt << 'EOF'
# Stanford Bunny Scan List
# All 10 range scans for complete bunny reconstruction
# Usage: julia bpa.jl -r 0.00125 -f data/bunny/bunny_scans.txt -d data/bunny/data --max-seeds 5
#
# Lines starting with # are comments
# Empty lines are ignored

EOF
        printf "%s\n" "${all_scans[@]}" >> bunny_scans.txt
        log_success "Created: bunny_scans.txt (${#all_scans[@]} scans)"

        # Create main body scans list (subset)
        cat > bunny_main.txt << 'EOF'
# Stanford Bunny - Main Body Scans Only
# Subset of 4 main scans for quick testing
# Usage: julia bpa.jl -r 0.00125 -f data/bunny/bunny_main.txt -d data/bunny/data --max-seeds 5

bun000
bun045
bun090
bun180
EOF
        log_success "Created: bunny_main.txt (4 scans)"
    fi
}

# -----------------------------------------------------------------------------
# Main execution
# -----------------------------------------------------------------------------
main() {
    log_info "3D Scan Conversion Script"
    log_info "============================================"

    # Check dependencies
    check_dependencies

    # Process configuration file
    parse_and_process_conf "$CONF_FILE"
}

# Run main function
main
