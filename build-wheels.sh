#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(dirname "$(readlink -f "$0")")"

cd "$dir"

TVM_PKG_NAME="xtc-tvm-python-bindings"
TVM_PKG_VERSION="$(cat tvm_version.txt)"

BUILD_PLATFORM="${BUILD_PLATFORM:-$(uname -s | tr '[:upper:]' '[:lower:]')}"

# Trick for installing libLLVM along libtvm.so
# Set TVM_EXTRA_LIB_LIST along with corresponding patch to copy libLLVM.so
# Path is relative to .../tvm/python, hence install path is ../install/
TVM_EXTRA_LIB_LIST="../install/lib/libLLVM.so"

# Must specify TVM_LIBRARY_PATH in environment such that tvm finds the installed
# lib during the build wheel phase.
# Note that we unset it for the test command below, otherwise the wrong lib is used
TVM_LIBRARY_PATH=/project/tvm/install/lib
[ "$BUILD_PLATFORM" = linux ] || TVM_LIBRARY_PATH="$dir"/tvm/install/lib

CIBW_PLATFORM="linux"
CIBW_ARCHS="x86_64"
CIBW_BUILD="cp310-manylinux* cp311-manylinux* cp312-manylinux* cp313-manylinux* cp314-manylinux*"
CIBW_MANYLINUX_IMAGE="manylinux_2_28"
CONTAINER_ENGINE_ARG=""

BUILD_VERBOSITY="${BUILD_VERBOSITY:-0}"
BUILD_TVM_CLEAN_BUILD_DIR="${BUILD_TVM_CLEAN_BUILD_DIR:-1}"
CIBW_DEBUG_KEEP_CONTAINER="${CIBW_DEBUG_KEEP_CONTAINER:-0}"
BUILD_PIP_CACHE_DIR="${BUILD_PIP_CACHE_DIR-}"
BUILD_CCACHE_DIR="${BUILD_CCACHE_DIR-}"

CIBW_BEFORE_BUILD="rm -rf dist build *egg-info"
CIBW_TEST_COMMAND="unset TVM_LIBRARY_PATH && {project}/tests/test-graph.sh"
BUILD_PYTHON=python
[ "$BUILD_PLATFORM" != "linux" ] || BUILD_PYTHON=/opt/python/cp310-cp310/bin/python
CIBW_BEFORE_ALL="env PYTHON=$BUILD_PYTHON sh -c './install-build-tools.sh && ./install-llvm.sh && ./build-tvm.sh'"
CIBW_BEFORE_TEST="./install-llvm.sh"
MACOSX_DEPLOYMENT_ARGS=""

if [ "$BUILD_PLATFORM" = "linux" ]; then
    DOCKER_ARGS=""
    DOCKER_CCACHE_DIR=""
    if [ -n "$BUILD_PIP_CACHE_DIR" ]; then
        DOCKER_PIP_CACHE_DIR="/pip_cache"
        DOCKER_ARGS="$DOCKER_ARGS -v'$BUILD_PIP_CACHE_DIR:$DOCKER_PIP_CACHE_DIR'"
        BUILD_PIP_CACHE_DIR="$DOCKER_PIP_CACHE_DIR"
    fi
    if [ -n "$BUILD_CCACHE_DIR" ]; then
        DOCKER_CCACHE_DIR="/ccache"
        DOCKER_ARGS="$DOCKER_ARGS -v'$BUILD_CCACHE_DIR:$DOCKER_CCACHE_DIR'"
        BUILD_CCACHE_DIR="$DOCKER_CCACHE_DIR"
    fi
    CONTAINER_ENGINE_ARG="CIBW_CONTAINER_ENGINE=docker;create_args:$DOCKER_ARGS"
elif [ "$BUILD_PLATFORM" = "darwin" ]; then
    CIBW_PLATFORM="macos"
    CIBW_ARCHS="arm64"
    CIBW_BUILD="cp310-macosx_arm64 cp311-macosx_arm64 cp312-macosx_arm64 cp313-macosx_arm64 cp314-macosx_arm64"
    CIBW_MANYLINUX_IMAGE=""
    TVM_EXTRA_LIB_LIST=""
    MACOSX_DEPLOYMENT_ARGS="MACOSX_DEPLOYMENT_TARGET=14.0" # supports macos14+
else
    echo "Error: Unknown BUILD_PLATFORM '$BUILD_PLATFORM'. Must be 'linux' or 'darwin'."
    exit 1
fi

ENV_VARS=(
    CIBW_PLATFORM="$CIBW_PLATFORM"
    CIBW_ARCHS="$CIBW_ARCHS"
    CIBW_BUILD="$CIBW_BUILD"
    CIBW_PROJECT_REQUIRES_PYTHON=">=3.10"
    CIBW_MANYLINUX_X86_64_IMAGE="$CIBW_MANYLINUX_IMAGE"
    CIBW_BEFORE_ALL="$CIBW_BEFORE_ALL"
    CIBW_BEFORE_TEST="$CIBW_BEFORE_TEST"
    CIBW_TEST_COMMAND="$CIBW_TEST_COMMAND"
    TVM_PKG_NAME="$TVM_PKG_NAME"
    TVM_PKG_VERSION="$TVM_PKG_VERSION"
    TVM_EXTRA_LIB_LIST="$TVM_EXTRA_LIB_LIST"
    TVM_LIBRARY_PATH="$TVM_LIBRARY_PATH"
    BUILD_TVM_CLEAN_BUILD_DIR="$BUILD_TVM_CLEAN_BUILD_DIR"
    BUILD_PLATFORM="$BUILD_PLATFORM"
    PIP_CACHE_DIR="$BUILD_PIP_CACHE_DIR"
    CCACHE_DIR="$BUILD_CCACHE_DIR"
    CIBW_REPAIR_WHEEL_COMMAND_MACOS="pip install wheel && python mac-os-wheels-fixer.py --original {wheel} --output {dest_dir}"
    CIBW_ENVIRONMENT_PASS="TVM_PKG_NAME TVM_PKG_VERSION TVM_EXTRA_LIB_LIST TVM_LIBRARY_PATH BUILD_TVM_CLEAN_BUILD_DIR BUILD_PLATFORM PIP_CACHE_DIR CCACHE_DIR"
    CIBW_BUILD_VERBOSITY="$BUILD_VERBOSITY"
    CIBW_DEBUG_KEEP_CONTAINER="$CIBW_DEBUG_KEEP_CONTAINER"
)

[ -z "$CONTAINER_ENGINE_ARG" ] || ENV_VARS+=("$CONTAINER_ENGINE_ARG")
[ -z "$MACOSX_DEPLOYMENT_ARGS" ] || ENV_VARS+=("$MACOSX_DEPLOYMENT_ARGS")

env "${ENV_VARS[@]}" \
      cibuildwheel \
      tvm/python
