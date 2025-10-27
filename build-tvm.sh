#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(dirname "$(readlink -f "$0")")"

if [ "$BUILD_PLATFORM" = "linux" ]; then
    PYTHON=/opt/python/cp310-cp310/bin/python
elif [ "$BUILD_PLATFORM" = "darwin" ]; then
    PYTHON=/Library/Frameworks/Python.framework/Versions/3.10/bin/python3.10
else 
    echo "Error: Unknown BUILD_PLATFORM '$BUILD_PLATFORM'. Must be 'linux' or 'darwin'."
    exit 1
fi

LLVM_PREFIX="$("$PYTHON" -c 'import llvm;print(llvm.__path__[0])')"

TVM_INSTALL_PREFIX="${TVM_INSTALL_PREFIX-/usr/local}"

cd tvm
rm -rf build "$TVM_INSTALL_PREFIX"
mkdir -p build "$TVM_INSTALL_PREFIX"

# Install llvm components in install dir
cp -a "$LLVM_PREFIX"/lib "$LLVM_PREFIX"/include "$LLVM_PREFIX"/bin "$TVM_INSTALL_PREFIX"
LLVM_CONFIG="$TVM_INSTALL_PREFIX/bin/llvm-config"

cp cmake/config.cmake build
sed -i \
    "s|USE_LLVM OFF|USE_LLVM $LLVM_CONFIG|" \
    build/config.cmake

cmake \
    -DCMAKE_INSTALL_PREFIX:PATH="$TVM_INSTALL_PREFIX" \
    -DCMAKE_INSTALL_RPATH='$ORIGIN' \
    -B build -G Ninja .

ninja -C build
ninja -C build install
