#!/usr/bin/env python3

import numpy as np

import tvm
import tvm.relax as relax
from tvm.script import ir as I, relax as R

M, N, K = 8, 4, 16
dtype = "float32"

@I.ir_module
class MatmulMod:
    @R.function
    def main(a: R.Tensor((M, K), dtype), b: R.Tensor((K, N), dtype)) -> R.Tensor((M, N), dtype):
        c = R.matmul(a, b)
        return c

target = tvm.target.Target("llvm")
executable = relax.build(MatmulMod, target=target)

dev = tvm.device(target.kind.name, 0)
vm = relax.VirtualMachine(executable, dev)

a_np = np.random.randn(M, K).astype(dtype)
b_np = np.random.randn(K, N).astype(dtype)

a_nd = tvm.nd.array(a_np, dev)
b_nd = tvm.nd.array(b_np, dev)

out_nd = vm["main"](a_nd, b_nd)
out_np = out_nd.numpy()

ref_np = np.dot(a_np, b_np)

if not np.allclose(out_np, ref_np, rtol=1e-3):
    print(out_np)
    print(ref_np)

assert np.allclose(out_np, ref_np, rtol=1e-3)

evaluator = vm.time_evaluator(
    "main", dev, min_repeat_ms=100, number=1, repeat=3
)
ret = evaluator(a_nd, b_nd)
print("Results ms:", np.array(ret.results) * 1000)
