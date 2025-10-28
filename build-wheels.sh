#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(realpath -e "$(dirname "$0")")"

cd "$dir"

DOCKER_ARGS=""
DOCKER_CCACHE_DIR=""
if [ -n "$BUILD_CCACHE_DIR-}" ]; then
    mkdir -p "$BUILD_CCACHE_DIR"
    DOCKER_CCACHE_DIR="/ccache"
    DOCKER_ARGS="$DOCKER_ARGS -v'$BUILD_CCACHE_DIR:$DOCKER_CCACHE_DIR'"
fi
CIBW_CONTAINER_ENGINE="docker;create_args:$DOCKER_ARGS"

BUILD_VERBOSITY="${BUILD_VERBOSITY:-0}"
BUILD_TVM_CLEAN_BUILD_DIR="${BUILD_TVM_CLEAN_BUILD_DIR:-1}"
CIBW_DEBUG_KEEP_CONTAINER="${CIBW_DEBUG_KEEP_CONTAINER:-0}"

TVM_PKG_VERSION="$(cat tvm_version.txt)"

# Trick for installing libLLVM along libtvm.so
# Set TVM_LIBRARY_PATH and install tvm with ninja install
# Set LLVM_LIB_LIST along with corresponding patch to copy libLLVM.so
TVM_INSTALL_PREFIX="/project/tvm/install"
TVM_LIBRARY_PATH="$TVM_INSTALL_PREFIX/lib"
TVM_EXTRA_LIB_LIST="$TVM_INSTALL_PREFIX/lib/libLLVM.so"

env \
    CIBW_PLATFORM='linux' \
    CIBW_ARCHS='x86_64' \
    CIBW_BUILD='cp310-manylinux* cp311-manylinux* cp312-manylinux* cp313-manylinux* cp314-manylinux*' \
    CIBW_PROJECT_REQUIRES_PYTHON='>=3.10' \
    CIBW_MANYLINUX_X86_64_IMAGE='manylinux_2_28' \
    CIBW_CONTAINER_ENGINE="$CIBW_CONTAINER_ENGINE" \
    CIBW_BEFORE_ALL='./install-build-tools.sh && ./install-llvm.sh && ./build-tvm.sh' \
    CIBW_TEST_COMMAND='{project}/tests/test-graph.sh' \
    BUILD_TVM_CLEAN_BUILD_DIR="$BUILD_TVM_CLEAN_BUILD_DIR" \
    CCACHE_DIR="$DOCKER_CCACHE_DIR" \
    TVM_PKG_VERSION="$TVM_PKG_VERSION" \
    TVM_INSTALL_PREFIX="$TVM_INSTALL_PREFIX" \
    TVM_LIBRARY_PATH="$TVM_LIBRARY_PATH" \
    TVM_EXTRA_LIB_LIST="$TVM_EXTRA_LIB_LIST" \
    CIBW_ENVIRONMENT_PASS_LINUX="BUILD_TVM_CLEAN_BUILD_DIR CCACHE_DIR TVM_PKG_VERSION TVM_INSTALL_PREFIX TVM_LIBRARY_PATH TVM_EXTRA_LIB_LIST" \
    CIBW_BUILD_VERBOSITY="$BUILD_VERBOSITY" \
    CIBW_DEBUG_KEEP_CONTAINER="$CIBW_DEBUG_KEEP_CONTAINER" \
    cibuildwheel \
    tvm/python
