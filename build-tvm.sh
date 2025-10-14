#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(realpath -e "$(dirname "$0")")"

# dump env                                                                                                                                                                                                        env

BUILD_DIR="tvm/build"
INSTALL_DIR="${TVM_INSTALL_PREFIX-$dir/install}"

BUILD_TVM_CLEAN_BUILD_DIR="${BUILD_TVM_CLEAN_BUILD_DIR:-1}"
BUILD_TVM_CLEAN_BUILD_DIR_POST="${BUILD_TVM_CLEAN_BUILD_DIR_POST:-0}"
BUILD_TVM_CCACHE="${BUILD_TVM_CCACHE:-1}"

TVM_BUILD_TYPE="Release" # "MinSizeRel"                                                                                                                                                                           

CCACHE_OPTS=""
[ "$BUILD_TVM_CCACHE" != 1 ] || \
    CCACHE_OPTS="-DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache"


PYTHON=/opt/python/cp310-cp310/bin/python
LLVM_PREFIX="$("$PYTHON" -c 'import llvm;print(llvm.__path__[0])')"

[ "$BUILD_TVM_CLEAN_BUILD_DIR" != 1 ] || rm -rf "$BUILD_DIR"

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"

# Install llvm components in install dir
cp -a "$LLVM_PREFIX"/lib "$LLVM_PREFIX"/include "$LLVM_PREFIX"/bin "$INSTALL_DIR"
LLVM_CONFIG="$INSTALL_DIR/bin/llvm-config"

cp "$dir"/tvm/cmake/config.cmake .
sed -i \
    "s|USE_LLVM OFF|USE_LLVM $LLVM_CONFIG|" \
    config.cmake

cmake \
    -DCMAKE_INSTALL_PREFIX:PATH="$INSTALL_DIR" \
    -DCMAKE_INSTALL_RPATH='$ORIGIN' \
    -DCMAKE_BUILD_TYPE="$TVM_BUILD_TYPE" \
    $CCACHE_OPTS \
    -Wno-dev \
    -Wno-deprecated \
    -G Ninja \
    "$dir"/tvm


ninja
ninja install

cd "$dir"
[ "$BUILD_TVM_CLEAN_BUILD_DIR_POST" != 1 ] || rm -rf "$BUILD_DIR"
