#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(dirname "$(readlink -f "$0")")"


PYTHON_MAJOR="$(python -c 'import sys;print(sys.version_info.major)')"
PYTHON_MINOR="$(python -c 'import sys;print(sys.version_info.minor)')"

[ "$PYTHON_MAJOR" = 3 ] || { echo "SKIPPED TESTS for python $PYTHON_MAJOR.x != 3.x: version not supported"; exit 0; }
[ "$PYTHON_MINOR" -ge 10 ] || { echo "SKIPPED TESTS for python $PYTHON_MAJOR.$PYTHON_MINOR < 3.10: version not supported"; exit 0; }

PREFIX="$(python -c 'import tvm;print(tvm.__path__[0])')"
tvmc --version

cd "$dir"

python -m pip install tflite==2.18.0

tvmc compile hello_world_float.tflite
tvmc run module.tar --print-time

echo "ALL TESTS PASSED"
