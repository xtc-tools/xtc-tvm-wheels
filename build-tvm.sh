#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(dirname "$(readlink -f "$0")")"

# dump env
env | sort

BUILD_DIR="${1-tvm/build}"
INSTALL_DIR="${2-$dir/tvm/install}"

BUILD_PLATFORM="${BUILD_PLATFORM:-$(uname -s | tr '[:upper:]' '[:lower:]')}"

BUILD_TVM_CLEAN_BUILD_DIR="${BUILD_TVM_CLEAN_BUILD_DIR:-1}"
BUILD_TVM_CLEAN_BUILD_DIR_POST="${BUILD_TVM_CLEAN_BUILD_DIR_POST:-0}"
BUILD_TVM_CCACHE="${BUILD_TVM_CCACHE:-1}"

TVM_BUILD_TYPE="Release" # "MinSizeRel"                                                                                                                                                                           

CCACHE_OPTS=""
[ "$BUILD_TVM_CCACHE" != 1 ] || \
    CCACHE_OPTS="-DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache"


PYTHON="${PYTHON-python}"
LLVM_PREFIX="$("$PYTHON" -c 'import llvm;print(llvm.__path__[0])')"

[ "$BUILD_TVM_CLEAN_BUILD_DIR" != 1 ] || rm -rf "$BUILD_DIR"

# Install minimal python dependencies
# Ref to tvm/docker/install/ubuntu2004_install_python.sh
pip3 install pip==24.2 setuptools==75.1.0

# Do not use cypthon ffi for pre-build
export TVM_FFI="ctypes"

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"

LLVM_CONFIG="$LLVM_PREFIX/bin/llvm-config"

cp "$dir"/tvm/cmake/config.cmake .
sed -i.bak "s|USE_LLVM OFF|USE_LLVM $LLVM_CONFIG|" config.cmake

# Add to CXX flags -Wno-dangling-reference to
# disable spurious warning on dangling refs with gcc 14:
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=107532
WARNING_OPTS=
[ "$BUILD_PLATFORM" != "linux" ] || WARNING_OPTS="-DCMAKE_CXX_FLAGS=-Wno-dangling-reference"

# Add to RPATH ../llvm/lib for libLLVM.so installed by xtc-llvm-tools package
cmake \
    -DCMAKE_INSTALL_PREFIX:PATH="$INSTALL_DIR" \
    -DCMAKE_INSTALL_RPATH='$ORIGIN:$ORIGIN/../llvm/lib' \
    -DCMAKE_BUILD_TYPE="$TVM_BUILD_TYPE" \
    $WARNING_OPTS \
    $CCACHE_OPTS \
    -Wno-dev \
    -Wno-deprecated \
    -G Ninja \
    "$dir"/tvm

ninja
ninja install

cd "$dir"
[ "$BUILD_TVM_CLEAN_BUILD_DIR_POST" != 1 ] || rm -rf "$BUILD_DIR"
