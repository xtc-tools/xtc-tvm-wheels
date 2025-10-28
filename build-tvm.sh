#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(dirname "$(readlink -f "$0")")"

LLVM_PREFIX="$(python -c 'import llvm;print(llvm.__path__[0])')"

TVM_INSTALL_PREFIX="${TVM_INSTALL_PREFIX-/usr/local}"

cd tvm
rm -rf build "$TVM_INSTALL_PREFIX"
mkdir -p build "$TVM_INSTALL_PREFIX"

# Install llvm components in install dir
cp -a "$LLVM_PREFIX"/lib "$LLVM_PREFIX"/include "$LLVM_PREFIX"/bin "$TVM_INSTALL_PREFIX"
LLVM_CONFIG="$TVM_INSTALL_PREFIX/bin/llvm-config"

cp cmake/config.cmake build
if [ "$BUILD_PLATFORM" = "darwin" ]; then
    # --ignore-libllvm --link-static for MacOS 
    sed -i '' "s|USE_LLVM OFF|USE_LLVM \"$LLVM_CONFIG --ignore-libllvm --link-static\"|" build/config.cmake
else
    sed -i '' "s|USE_LLVM OFF|USE_LLVM $LLVM_CONFIG|" build/config.cmake
fi

cmake \
    -DCMAKE_INSTALL_PREFIX:PATH="$TVM_INSTALL_PREFIX" \
    -DCMAKE_INSTALL_RPATH='$ORIGIN' \
    -B build -G Ninja .

ninja -C build
ninja -C build install
