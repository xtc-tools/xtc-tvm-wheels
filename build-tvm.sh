#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(realpath -e "$(dirname "$0")")"

PYTHON=/opt/python/cp310-cp310/bin/python
LLVM_PREFIX="$("$PYTHON" -c 'import llvm;print(llvm.__path__[0])')"
LLVM_CONFIG="$LLVM_PREFIX/bin/llvm-config"

cd tvm
mkdir build
cp cmake/config.cmake build
sed -i \
    -e "s|USE_LLVM OFF|USE_LLVM $LLVM_CONFIG|" \
    -e "s|USE_MICRO OFF|USE_MICRO ON|" \
    -e "s|USE_MICRO_STANDALONE_RUNTIME OFF|USE_MICRO_STANDALONE_RUNTIME ON|" \
    build/config.cmake

cmake -B build -G Ninja .

ninja -C build
