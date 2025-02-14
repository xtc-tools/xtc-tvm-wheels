#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(realpath -e "$(dirname "$0")")"

PYTHON=/opt/python/cp310-cp310/bin/python
LLVM_VERSION=19.1.7.2025011201+cd708029

$PYTHON -m pip install \
        "llvm==$LLVM_VERSION" \
        --index-url https://gitlab.inria.fr/api/v4/projects/57611/packages/pypi/simple
