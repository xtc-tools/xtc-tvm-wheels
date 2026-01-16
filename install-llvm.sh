#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(realpath -e "$(dirname "$0")")"

PYTHON=/opt/python/cp310-cp310/bin/python
LLVM_VERSION=21.1.2.2025091602+b708aea0

$PYTHON -m pip install \
        "llvm==$LLVM_VERSION" \
        --index-url https://gitlab.inria.fr/api/v4/projects/57611/packages/pypi/simple
