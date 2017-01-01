#!/usr/bin/env python3
import subprocess
import sys

from os import environ

mozart = "/Applications/Mozart2.app/Contents/Resources/bin/"

env = environ.copy()
env["PATH"] = env["PATH"]+":"+mozart

def run(cmd, **kwargs):
    print(cmd)
    subprocess.run(cmd, **kwargs)

ozfile = sys.argv[-1]
ozffile = ozfile+"f"

run(["ozc", "-c", ozfile], env=env)
try:
    run(["ozengine", ozffile], env=env)
finally:
    run(["rm", ozffile])
