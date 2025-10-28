#!/usr/bin/env python3

import numpy as np

import tvm
import tvm.te as te
import tvm.topi as topi

M, N, K = 8, 4, 16
dtype = "float32"

A = te.placeholder((M, K), name="A", dtype=dtype)
B = te.placeholder((K, N), name="B", dtype=dtype)
C = topi.nn.matmul(A, B)

s = te.create_schedule(C.op)

target = tvm.target.Target("llvm")
fmatmul = tvm.build(s, [A, B, C], target=target)

dev = tvm.device(target.kind.name, 0)

a_np = np.random.randn(M, K).astype(dtype)
b_np = np.random.randn(K, N).astype(dtype)
c_np = np.empty((M, N), dtype=dtype)

a_nd = tvm.nd.array(a_np, dev)
b_nd = tvm.nd.array(b_np, dev)
c_nd = tvm.nd.array(c_np, dev)

fmatmul(a_nd, b_nd, c_nd)
out_np = c_nd.numpy()

ref_np = np.dot(a_np, b_np)

if not np.allclose(out_np, ref_np, rtol=1e-3):
    print(out_np)
    print(ref_np)

assert np.allclose(out_np, ref_np, rtol=1e-3)

evaluator = fmatmul.time_evaluator(
    fmatmul.entry_name, dev, min_repeat_ms=100, number=1, repeat=3
)
ret = evaluator(a_nd, b_nd, c_nd)
print("Results ms:", np.array(ret.results) * 1000)
