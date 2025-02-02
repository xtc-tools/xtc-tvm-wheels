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
    "s|USE_LLVM OFF|USE_LLVM $LLVM_CONFIG|" \
    build/config.cmake

cmake -B build -G Ninja .

ninja -C build
