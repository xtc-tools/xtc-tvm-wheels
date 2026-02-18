#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(dirname "$(readlink -f "$0")")"

TVM_REVISION="$(cat "$dir"/tvm_revision.txt)"

mkdir -p tvm
cd tvm
git init
git config --local user.email "CIBOT@noreply.com"
git config --local user.name "CI BOT"
git remote add origin https://github.com/apache/tvm
git fetch --depth 1 origin "$TVM_REVISION"
git reset --hard FETCH_HEAD
git submodule init
git submodule update --recursive --depth 1

# Apply patches with git and reset to fetched revision
if [ -d "$dir"/patches ]; then
    for patch in "$dir"/patches/*.patch; do
        git am "$patch"
    done
fi
git reset FETCH_HEAD
