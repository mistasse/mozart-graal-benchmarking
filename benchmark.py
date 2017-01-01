#!/usr/bin/env python3

import io
import subprocess
import sys
import os
import shutil
import re
import gc

from tqdm import tqdm
from datetime import datetime
from contextlib import contextmanager
from collections import namedtuple, defaultdict


class Options:
    section = "### "
    measure = " --- "
    resdir = "results/"
    executing = "executing.oz"
    ozcmd = "../oz"


def run(cmd, **kwargs):
    p = subprocess.run(cmd, stdout=subprocess.PIPE, **kwargs)
    return p.stdout.splitlines()


@contextmanager
def without_gc():
    gcenabled = gc.isenabled()
    try:
        gc.disable()
        yield
    finally:
        if gcenabled:
            gc.enable()


def parse_args(params):
    cmd, tpl_vars, kwargs = [], {}, {}
    for p in params:
        if p.startswith("~"):
            k, v = p[1:].split("=", 1)
            kwargs[k] = v
        elif p.startswith("$"):
            k, v = p.split("=", 1)
            tpl_vars[k] = v
        else:
            cmd.append(p)
    return BaseCommand(cmd, tpl_vars, kwargs)


tpl_var_re = re.compile(r"`(\$[a-zA-Z0-9_]+)`")


def sub_tpl_vars(lines, tpl_vars):
    counts = defaultdict(int)
    def repl(matchobj):
        original, varname = matchobj.group(0), matchobj.group(1)
        counts[varname] += 1
        if counts[varname] == 1:
            return original
        return tpl_vars.get(varname, original)

    return [tpl_var_re.sub(repl, line) for line in lines]


def expand_macros(cmd, macros):
    ret = []
    for c in cmd:
        expanded = macros.get(c, None)
        if expanded is not None:
            ret += expanded
        else:
            ret.append(c)
    return ret


class BaseCommand(namedtuple("BaseCommand", "cmd, tpl_vars, kwargs")):
    pass


class FinalCommand(namedtuple("FinalCommand", "file, cmd, tpl_vars, kwargs")):
    pass


class TestSuite:

    skip_line_re = re.compile("^( *|%.*)$")
    def __init__(self, name, commands):
        self.name = name
        self._input = ["_"+name]+commands
        self.macros, self.commands = {}, []
        for cmd in commands:
            if cmd.startswith("#"):
                split = cmd[1:].split(" ")
                self.macros[split[0]] = expand_macros(split[1:], self.macros)
            elif self.skip_line_re.match(cmd) is None:
                self.commands.append(cmd)
        self.bcmds = [parse_args(expand_macros(line.split(" "), self.macros)) for line in self.commands]
        self.dirname = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")+"_"+name
        self.dir = Options.resdir + self.dirname
        self.fcmds = [self.bcmd_to_fcmd(bcmd) for bcmd in self.bcmds]
        self.files = set(bcmd.cmd[0] for bcmd in self.bcmds)
        self.report = []

    def in_dir(self, filepath):
        return self.dir+"/"+filepath.split("/")[-1]

    def executing(self, ozfile):
        return Options.executing

    oz = os.path.dirname(os.path.abspath(__file__))+"/"+Options.ozcmd
    def bcmd_to_fcmd(self, bcmd):
        cmd, tpl_vars, kwargs = bcmd
        ozfile = cmd[0]
        cmd = [kwargs.pop("oz", self.oz), *cmd[1:], self.executing(ozfile)]
        return FinalCommand(ozfile, cmd, tpl_vars, kwargs)

    def init_files(self):
        os.makedirs(self.dir)
        for f in self.files:
            shutil.copy2(f, self.in_dir(f))
        with open(self.in_dir("commands.txt"), "w") as cmdfile:
            cmdfile.write("\n".join(self._input))

    def execute_fcmd(self, fcmd):
        ozfile, cmd, tpl_vars, kwargs = fcmd
        with open(ozfile, "r") as iozfile:
            lines = iozfile.read().splitlines()
        lines = sub_tpl_vars(lines, tpl_vars)
        with open(self.executing(ozfile), "w") as oozfile:
            oozfile.write("\n".join(lines))

        return run(cmd, **kwargs)

    def run(self):
        self.init_files()
        with open(self.in_dir("output.txt"), "w") as reportfile:
            for fcmd, cmd in zip(tqdm(self.fcmds), self.commands):

                result = Result(fcmd.kwargs.pop("name", cmd), self.execute_fcmd(fcmd))
                reportfile.write("{options.section}{title}\n{output}\n".format(
                    options=Options,
                    title=result.title,
                    output=b"\n".join(result.output).decode("utf-8")
                ))
                reportfile.flush()

        subprocess.run(["ln", "-fsn", self.dirname, Options.resdir+"last_"+self.name])


class Result(namedtuple("Result", "title, output")):
    pass

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "test":
        ts = TestSuite("test", ["""bench_map.oz $N=3 --graal"""])
        print(ts.sub_tpl_vars(["`$N`=4 {Browse `$N`}\n`$N`=3"], ts.fcmds[0].tpl_vars))
    else:
        lines = sys.stdin.read().splitlines()
        TestSuite(lines[0], lines[1:]).run()
