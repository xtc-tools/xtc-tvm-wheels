#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(readlink -e "$(dirname "$0")")"

PYTHON_MAJOR="$(python -c 'import sys;print(sys.version_info.major)')"
PYTHON_MINOR="$(python -c 'import sys;print(sys.version_info.minor)')"

[ "$PYTHON_MAJOR" = 3 ] || { echo "SKIPPED TESTS for python $PYTHON_MAJOR.x != 3.x: version not supported"; exit 0; }
[ "$PYTHON_MINOR" -ge 10 ] || { echo "SKIPPED TESTS for python $PYTHON_MAJOR.$PYTHON_MINOR < 3.10: version not supported"; exit 0; }

PREFIX="$(python -c 'import tvm;print(tvm.__path__[0])')"

cd "$dir"
res=0
./test-te-graph.py || res=1
./test-relay-graph.py || res=1
./test-relax-graph.py || res=1

[ "$res" != 0 ] || echo "PASSED: All tests passed"
[ "$res" = 0 ] || echo "FAILED: SOME TESTS FAILED"
exit $res

