#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(realpath -e "$(dirname "$0")")"

cd "$dir"

TVM_PKG_VERSION="$(cat tvm_version.txt)"

env \
    CIBW_PLATFORM='linux' \
    CIBW_ARCHS='x86_64' \
    CIBW_BUILD='cp3*-manylinux*' \
    CIBW_PROJECT_REQUIRES_PYTHON='>=3.10' \
    CIBW_MANYLINUX_X86_64_IMAGE='manylinux_2_28' \
    CIBW_BEFORE_ALL='./install-build-tools.sh && ./install-llvm.sh && ./build-tvm.sh' \
    CIBW_TEST_COMMAND='{project}/tests/test-graph.sh' \
    TVM_PKG_VERSION="$TVM_PKG_VERSION" \
    CIBW_ENVIRONMENT_PASS_LINUX="TVM_PKG_VERSION" \
    cibuildwheel \
    tvm/python

#    CIBW_DEBUG_KEEP_CONTAINER=1 \
#    CIBW_BUILD_VERBOSITY=1 \
