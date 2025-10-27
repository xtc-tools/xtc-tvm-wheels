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

LLVM_VERSION=19.1.7.2025011201+cd708029

$PYTHON -m pip install \
        "llvm==$LLVM_VERSION" \
        --index-url https://gitlab.inria.fr/api/v4/projects/57611/packages/pypi/simple
