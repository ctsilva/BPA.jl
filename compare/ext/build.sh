#!/bin/sh
# Fetch and build the third-party Ball-Pivoting implementations that run_ext.py wraps.
# Everything lands in compare/external (gitignored). Rerunnable; each step is skipped when
# its binary exists. Needs: git, cmake, a C++20 compiler, cargo (https://rustup.rs), and
# Homebrew glm for the Gruber build (brew install glm). The Digne OpenMP build needs
# Homebrew gcc; without it the serial build is made and `digne_par` runs single-threaded.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
EXT=${BPA_EXTERNAL:-$HERE/../external}
mkdir -p "$EXT"
cd "$EXT"

clone() { [ -d "$2" ] || git clone -q --depth 1 "https://github.com/$1" "$2"; }

# --- Digne, IPOL 2014 (GPL-3) -----------------------------------------------------------
if [ ! -x ipol_digne/BallPivoting/build/ballpivoting ]; then
    mkdir -p ipol_digne && cd ipol_digne
    [ -f BallPivoting.tgz ] || curl -sfL -o BallPivoting.tgz https://www.ipol.im/pub/art/2014/81/BallPivoting.tgz
    [ -d BallPivoting ] || tar xzf BallPivoting.tgz
    cd BallPivoting
    grep -q nofill_flag main.cpp || patch -p0 main.cpp < "$HERE/digne_main.patch"
    mkdir -p build
    SRCS="main.cpp src/Facet.cpp src/Edge.cpp src/Vertex.cpp src/Point.cpp src/Mesher.cpp src/FileIO.cpp"
    GXX=$(ls /opt/homebrew/bin/g++-* 2>/dev/null | sort -V | tail -1 || true)
    if [ -n "$GXX" ]; then
        "$GXX" -O3 -fopenmp -w -o build/ballpivoting $SRCS
    else
        c++ -O3 -w -DUSE_CLANG -o build/ballpivoting $SRCS
    fi
    cd "$EXT"
fi

# --- bernhardmgruber/bpa (BSL-1.0) ------------------------------------------------------
clone bernhardmgruber/bpa bernhardmgruber_bpa
if [ ! -x bernhardmgruber_bpa/build/gruber_noff2off ]; then
    mkdir -p bernhardmgruber_bpa/build
    c++ -std=c++20 -O2 -w -DGLM_ENABLE_EXPERIMENTAL -I/opt/homebrew/include -Ibernhardmgruber_bpa/src/lib \
        -o bernhardmgruber_bpa/build/gruber_noff2off "$HERE/gruber_noff2off.cpp" bernhardmgruber_bpa/src/lib/bpa.cpp
fi

# The same library with the seed search resumed after each front is exhausted, so that it
# grows one component per seed like the paper (upstream seeds once). The patch is applied to
# a copy; the upstream binary above is unchanged.
if [ ! -x bernhardmgruber_bpa/build/gruber_reseed_noff2off ]; then
    cp bernhardmgruber_bpa/src/lib/bpa.cpp bernhardmgruber_bpa/build/bpa_reseed.cpp
    patch -p0 -s bernhardmgruber_bpa/build/bpa_reseed.cpp < "$HERE/gruber_reseed.patch"
    c++ -std=c++20 -O2 -w -DGLM_ENABLE_EXPERIMENTAL -I/opt/homebrew/include -Ibernhardmgruber_bpa/src/lib \
        -o bernhardmgruber_bpa/build/gruber_reseed_noff2off "$HERE/gruber_noff2off.cpp" bernhardmgruber_bpa/build/bpa_reseed.cpp
fi

# --- martinfrances107/bpa_rs (MIT) ------------------------------------------------------
clone martinfrances107/bpa_rs martinfrances107_bpa_rs
if [ ! -x martinfrances107_bpa_rs/target/release/bpa_rs_noff2off ]; then
    CARGO=${CARGO:-$(command -v cargo || echo "$HOME/.cargo/bin/cargo")}
    "$CARGO" build --release --quiet --manifest-path "$HERE/bpa_rs_noff2off/Cargo.toml" \
        --target-dir martinfrances107_bpa_rs/target
fi

# --- schmehla/ball-pivoting-algorithm (MIT) ---------------------------------------------
clone schmehla/ball-pivoting-algorithm schmehla_ball-pivoting-algorithm
if [ ! -x schmehla_ball-pivoting-algorithm/build/BPA ]; then
    S=schmehla_ball-pivoting-algorithm
    mkdir -p $S/build
    # Its post-processing step Normals::provideNormalsDeviation overruns a stack buffer
    # (AddressSanitizer, calculateInternalAngle) and is not part of the reconstruction.
    sed 's/^\([[:space:]]*\)Normals::provideNormalsDeviation(vertices, result.faces);/\1\/\/ skipped, see compare\/ext\/build.sh/' \
        $S/src/main.cpp > $S/build/main_patched.cpp
    c++ -std=c++20 -O2 -w -I$S/src -o $S/build/BPA $S/build/main_patched.cpp \
        $S/src/bpa/*.cpp $S/src/helpers/*.cpp $S/src/io/*.cpp $S/src/normals/*.cpp
fi

# --- LuigiGiaccari/Surface-Reconstruction-Toolbox (GPL-3) --------------------------------
clone LuigiGiaccari/Surface-Reconstruction-Toolbox LuigiGiaccari_Surface-Reconstruction-Toolbox
if [ ! -x LuigiGiaccari_Surface-Reconstruction-Toolbox/build/ballpivoting ]; then
    G=LuigiGiaccari_Surface-Reconstruction-Toolbox
    mkdir -p $G/build/include/timers
    # Its stopwatch returns (t2.tv_usec - t1.tv_usec) and ignores the seconds, so the
    # "Total Time" it prints is noise; a fixed copy of the header shadows the original.
    sed 's|return  (t2.tv_usec - t1.tv_usec) / 1000.0;.*|return ((t2.tv_sec - t1.tv_sec) * 1000000.0 + (t2.tv_usec - t1.tv_usec)) / 1000.0; // us to ms, seconds included|' \
        $G/src/timers/hr_time.h > $G/build/include/timers/hr_time.h
    grep -q tv_sec $G/build/include/timers/hr_time.h || { echo "timer patch failed"; exit 1; }
    c++ -std=c++03 -O2 -w -I$G/build/include -I$G/src -o $G/build/ballpivoting $G/src/srtools/BPAexe.cpp
fi

echo "built:"
ls -l ipol_digne/BallPivoting/build/ballpivoting bernhardmgruber_bpa/build/gruber_noff2off \
      bernhardmgruber_bpa/build/gruber_reseed_noff2off \
      martinfrances107_bpa_rs/target/release/bpa_rs_noff2off schmehla_ball-pivoting-algorithm/build/BPA \
      LuigiGiaccari_Surface-Reconstruction-Toolbox/build/ballpivoting
