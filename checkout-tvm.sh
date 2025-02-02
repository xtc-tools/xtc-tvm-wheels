#!/usr/bin/env bash
set -euo pipefail
set -x
dir="$(realpath -e "$(dirname "$0")")"

TVM_REVISION="$(cat "$dir"/tvm_revision.txt)"

mkdir -p tvm
cd tvm
git init
git remote add origin https://github.com/apache/tvm
git fetch --depth 1 origin "$TVM_REVISION"
git reset --hard FETCH_HEAD
git submodule init
git submodule update --recursive --depth 1
git am "$dir"/patches/*
