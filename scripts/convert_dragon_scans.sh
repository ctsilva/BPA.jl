#!/bin/bash

# =============================================================================
# convert_dragon_scans.sh - Convert Dragon PLY scans to OFF format
# =============================================================================
#
# This script processes Stanford Dragon scan data:
# 1. Converts PLY files to OFF format using trimesh2's mesh_filter
# 2. Generates .xf transformation files from configuration files
#
# DATA SOURCE:
#   Stanford Dragon Dataset
#   https://graphics.stanford.edu/data/3Dscanrep
#   Downloaded via scripts/download_dragon.sh
#
# REQUIREMENTS:
#   - trimesh2 tools: mesh_filter, xf (must be in PATH)
#   - Dragon scans in data/dragon/scans/ (downloaded via download_dragon.sh)
#
# USAGE:
#   cd data/dragon/scans
#   ../../../scripts/convert_dragon_scans.sh [conf_file]
#
# ARGUMENTS:
#   conf_file - Optional: specific .conf file to process
#               If not specified, processes all .conf files in current directory
#
# OUTPUT:
#   For each scan referenced in the config files:
#   - <basename>.off  - Converted mesh in OFF format
#   - <basename>.xf   - Transformation matrix file
#
# =============================================================================

set -euo pipefail

# ANSI color codes
COLOR_RESET='\033[0m'
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'

log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*"
}

log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*" >&2
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
    exit 1
}

check_dependencies() {
    for tool in mesh_filter xf mesh_shade mesh_cat; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool not found. Please install trimesh2 and add it to PATH."
        fi
    done
}

# Color palette for different scans (hex RGB values)
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
)

# Global array to collect all colored PLY files
declare -a ALL_COLORED_PLY_FILES

convert_ply_to_off() {
    local ply_file="$1"
    local off_file="$2"

    if [ ! -f "$ply_file" ]; then
        log_warning "PLY file not found: $ply_file (skipping)"
        return 1
    fi

    if mesh_filter "$ply_file" "$off_file" > /dev/null 2>&1; then
        log_success "Converted: $ply_file -> $off_file"
        return 0
    else
        log_warning "Failed to convert: $ply_file"
        return 1
    fi
}

create_xf_file() {
    local xf_file="$1"
    local tx="$2" ty="$3" tz="$4"
    local qx="$5" qy="$6" qz="$7" qw="$8"

    if xf -trans "$tx" "$ty" "$tz" -v "$qx" "$qy" "$qz" "$qw" -o "$xf_file" > /dev/null 2>&1; then
        log_success "Created: $xf_file"
        return 0
    else
        log_warning "Failed to create: $xf_file"
        return 1
    fi
}

process_conf_file() {
    local conf_file="$1"
    local color_index="$2"
    local processed=0
    local skipped=0

    log_info "Processing configuration: $conf_file"
    log_info "Using color: #${COLORS[$color_index]}"
    echo ""

    while IFS= read -r line; do
        # Skip empty lines, comments, and camera lines
        [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]] || [[ "$line" =~ ^camera ]] && continue

        # Parse bmesh lines: bmesh filename.ply tx ty tz qx qy qz qw
        if [[ "$line" =~ ^bmesh ]]; then
            read -r _ ply_file tx ty tz qx qy qz qw <<< "$line"

            local basename="${ply_file%.ply}"
            local off_file="${basename}.off"
            local xf_file="${basename}.xf"

            log_info "Processing: $ply_file"

            # Convert PLY to OFF and create XF file
            local success=0
            if convert_ply_to_off "$ply_file" "$off_file"; then
                if create_xf_file "$xf_file" "$tx" "$ty" "$tz" "$qx" "$qy" "$qz" "$qw"; then
                    success=1
                fi
            fi

            # Create colored and transformed PLY for combined output
            if [ "$success" -eq 1 ]; then
                local color="${COLORS[$color_index]}"
                local colored_ply="${basename}_colored.ply"
                local xformed_ply="${basename}_xformed.ply"

                if mesh_shade "$off_file" color "$color" "$colored_ply" > /dev/null 2>&1; then
                    if mesh_filter "$colored_ply" -xform "$xf_file" "$xformed_ply" > /dev/null 2>&1; then
                        ALL_COLORED_PLY_FILES+=("$xformed_ply")
                        ((processed += 1))
                    else
                        ((skipped += 1))
                    fi
                else
                    ((skipped += 1))
                fi
            else
                ((skipped += 1))
            fi
            echo ""
        fi
    done < "$conf_file"

    echo "============================================"
    log_success "Processed $processed scans from $conf_file"
    [ "$skipped" -gt 0 ] && log_warning "Skipped: $skipped scans"
    echo ""
}

main() {
    log_info "Stanford Dragon Scan Conversion"
    log_info "============================================"
    echo ""

    check_dependencies

    local color_index=0

    # Process specified conf file or all conf files
    if [ $# -eq 1 ]; then
        if [ ! -f "$1" ]; then
            log_error "Configuration file not found: $1"
        fi
        process_conf_file "$1" "$color_index"
    else
        # Process all .conf files
        shopt -s nullglob
        local conf_files=(*.conf)
        shopt -u nullglob
        if [ ${#conf_files[@]} -eq 0 ]; then
            log_error "No .conf files found in current directory"
        fi

        log_info "Found ${#conf_files[@]} configuration files"
        echo ""

        for conf in "${conf_files[@]}"; do
            process_conf_file "$conf" "$color_index"
            color_index=$(( (color_index + 1) % ${#COLORS[@]} ))
        done
    fi

    # Combine all colored PLY files
    if [ "${#ALL_COLORED_PLY_FILES[@]}" -gt 0 ]; then
        echo ""
        log_info "Combining all scans into: dragon_combined.ply"
        log_info "============================================"
        log_info "Total scans to combine: ${#ALL_COLORED_PLY_FILES[@]}"

        if mesh_cat "${ALL_COLORED_PLY_FILES[@]}" -o dragon_combined.ply > /dev/null 2>&1; then
            log_success "Created combined mesh: dragon_combined.ply"
            log_info "Combined ${#ALL_COLORED_PLY_FILES[@]} scans with different colors"
        else
            log_warning "Failed to create combined mesh"
        fi
        echo ""
    else
        log_warning "No colored PLY files to combine"
    fi

    # Generate list files for BPA reconstruction
    echo ""
    log_info "Generating scan list files..."

    # Find all OFF files and extract basenames
    all_scans=($(find . -maxdepth 1 -name "*.off" -type f | sed 's|^\./||; s|\.off$||' | sort))

    if [ ${#all_scans[@]} -gt 0 ]; then
        # Create full list file
        cat > ../dragon_scans.txt << 'EOF'
# Stanford Dragon Scan List
# All scans for complete dragon reconstruction
# Usage: julia bpa.jl -r 0.005 -f data/dragon/dragon_scans.txt -d data/dragon/scans --max-seeds 5
#
# Lines starting with # are comments
# Empty lines are ignored

EOF
        printf "%s\n" "${all_scans[@]}" >> ../dragon_scans.txt
        log_success "Created: ../dragon_scans.txt (${#all_scans[@]} scans)"

        # Create subset file (10 representative scans)
        cat > ../dragon_subset.txt << 'EOF'
# Stanford Dragon - Representative Subset
# 10 scans from different viewpoints for quick testing
# Usage: julia bpa.jl -r 0.005 -f data/dragon/dragon_subset.txt -d data/dragon/scans --max-seeds 5

dragonStandRight_0
dragonStandRight_96
dragonStandRight_192
dragonSideRight_0
dragonSideRight_192
dragonUpRight_0
dragonUpRight_192
dragonMouth1_0
dragonKnee_0
dragonToes_0
EOF
        log_success "Created: ../dragon_subset.txt (10 scans)"

        # Create the clean list: every scan except the space carvers (backdrop and
        # clear-space planes listed in carvers.conf), which are not surface data
        if [ -f carvers.conf ]; then
            carvers=$(grep '^bmesh' carvers.conf | awk '{print $2}' | sed 's/\.ply$//' | grep -E 'Bk|ClearSpace')
            cat > ../dragon_scans_clean.txt << 'EOF'
# Stanford Dragon - surface scans only
# All scans except the backdrop (dragonBk*) and clear-space carvers of carvers.conf
# Usage: julia bpa.jl -r 0.0003,0.0005,0.001 -f data/dragon/dragon_scans_clean.txt

EOF
            for scan in "${all_scans[@]}"; do
                echo "$carvers" | grep -qx "$scan" || echo "$scan" >> ../dragon_scans_clean.txt
            done
            log_success "Created: ../dragon_scans_clean.txt ($(grep -cv '^#\|^$' ../dragon_scans_clean.txt) scans)"
        fi
    fi

    echo "============================================"
    log_success "Conversion complete!"
    echo ""
    log_info "Output files:"
    echo "  - Individual scans: dragon*.off, dragon*.xf"
    if [ "${#ALL_COLORED_PLY_FILES[@]}" -gt 0 ]; then
        echo "  - Combined visualization: dragon_combined.ply"
    fi
    echo "  - Scan lists: ../dragon_scans.txt, ../dragon_subset.txt, ../dragon_scans_clean.txt"
    echo ""
    log_info "Next steps:"
    echo "  1. View dragon_combined.ply to verify alignment"
    echo "  2. Run BPA reconstruction:"
    echo ""
    echo "     # Full dataset (${#all_scans[@]} scans)"
    echo "     julia bpa.jl -r 0.005 -f data/dragon/dragon_scans.txt -d data/dragon/scans --max-seeds 5"
    echo ""
    echo "     # Subset (10 scans, faster)"
    echo "     julia bpa.jl -r 0.005 -f data/dragon/dragon_subset.txt -d data/dragon/scans --max-seeds 5"
    echo ""
}

main "$@"
