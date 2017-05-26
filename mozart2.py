#!/usr/bin/env python3
import subprocess
import sys

from os import environ

mozart = "/home/max/mozart2/bin/"

env = environ.copy()
env["PATH"] = env["PATH"]+":"+mozart

def run(cmd, **kwargs):
    print(cmd)
    subprocess.run(cmd, **kwargs)

for filename in sys.argv[1:-1]:
    if filename.endswith(".oz"):
        run(["ozc", "-c", filename], env=env)

ozfile = sys.argv[-1]
ozffile = ozfile+"f"

run(["ozc", "-c", ozfile], env=env)
try:
    run(["ozengine", ozffile], env=env)
finally:
    run(["rm", ozffile])
