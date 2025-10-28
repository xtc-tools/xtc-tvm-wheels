#!/usr/bin/env python
import tvm
import tvm.relay as relay
import numpy as np

M, N, K = 8, 4, 16
dtype = "float32"

a = relay.var("A", shape=(M, K), dtype=dtype)
b = relay.var("B", shape=(K, N), dtype=dtype)
c = relay.nn.matmul(a, b)
func = relay.Function([a, b], c)

target = tvm.target.Target("llvm")
with tvm.transform.PassContext(opt_level=3):
    lib = relay.build(func, target=target)

dev = tvm.device(target.kind.name, 0)
module = tvm.contrib.graph_executor.GraphModule(lib["default"](dev))

a_np = np.random.randn(M, K).astype(dtype)
b_np = np.random.randn(K, N).astype(dtype)

module.set_input("A", a_np)
module.set_input("B", b_np)
module.run()
out_np = module.get_output(0).numpy()

ref_np = np.dot(a_np, b_np)

if not np.allclose(out_np, ref_np, rtol=1e-3):
    print(out_np)
    print(ref_np)

assert np.allclose(out_np, ref_np, rtol=1e-3)

evaluator = module.module.time_evaluator(
    "run", dev, min_repeat_ms=100, number=1, repeat=3
)
ret = evaluator()
print("Results ms:", np.array(ret.results) * 1000)
