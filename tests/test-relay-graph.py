#!/usr/bin/env python

try:
    import tvm.relay
except:
    print("SKIPPED: relay is not supported anymore in tvm >= 0.21")
    raise SystemExit()

print("WARNING: relay should not be available for tvm >= 1.21")
