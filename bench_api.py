from collections import defaultdict, OrderedDict

from matplotlib import pyplot as plt
import numpy as np

from benchmark import Options


__all__ = [
    "get_log",
    "extract",
    "to_mat",
    "Serie",
    "noop_nosections",
    "SubSerie",
    "merge",
]


def get_log(serie):
    with open(Options.resdir+"last_"+serie+"/output.txt", "r") as f:
        return f.read().splitlines()


def extract(log):
    result = OrderedDict()
    current = None
    for line in log:
        if line.startswith(Options.section):
            section = line[len(Options.section):]
            section = " ".join(n for n in section.split(" ") if not n.startswith("%"))
            current = defaultdict(list)
            result[section] = current
        else:
            split = line.split(Options.measure, 1)
            if len(split) > 1:
                label, value = split
                value = int(value)
                current[label].append(value)

    return result


def to_mat(dic, label, sections=None):
    keys = list(dic.keys())
    mat = []
    if sections is None:
        sections = [k for k in keys if dic[k].get(label, None) is not None]
    for section in sections:
        if isinstance(section, int):
            section = keys[section]
        mat.append(dic[section][label])
    return np.array(mat, dtype="float64"), sections


class Serie:
    def __init__(self, serie):
        self.serie = extract(get_log(serie))

    def get(self, label, sections=None, *, scale=1e-9):
        if isinstance(label, tuple):
            return tuple(self.get(l, sections, scale=scale) for l in label)

        mat, sections = to_mat(self.serie, label, sections)
        return SubSerie(mat*scale, sections)

    def __getitem__(self, label):
        if isinstance(label, tuple):
            return tuple(self.get(l) for l in label)
        return self.get(label)


def noop_nosections(*, result=None):
    def decorator(f):
        def wrapper(self, *args, **kwargs):
            if not self.sections:
                return result if result is not None else self
            return f(self, *args, **kwargs)
        return wrapper
    return decorator


class SubSerie:
    def __init__(self, mat, sections):
        self.mat = mat
        self.sections = sections

    def sub(self, *args, **kwargs):
        plt.subplot(*args, **kwargs)
        return self

    @noop_nosections()
    def plot(self, sections=None, *, legend=1, yscale="log"):
        for m in self.mat:
            plt.plot(m)
        if yscale is not None:
            plt.yscale(yscale)
        if legend is not None:
            plt.legend(sections if sections is not None else self.sections, loc=legend)
        return self

    @noop_nosections()
    def prog(self, sections=None, *, legend=9, yscale=None):
        cumtime = np.cumsum(self.mat, axis=1)
        y = np.cumsum(np.ones((cumtime.shape[1])))
        for x in cumtime:
            plt.plot(y, x)
        if yscale is not None:
            plt.yscale(yscale)
        if legend is not None:
            plt.legend(sections if sections is not None else self.sections, loc=legend)
        return self

    @noop_nosections(result=np.array([]))
    def agg(self, f):
        return f(self.mat, axis=1)

    def show(self):
        plt.show()
        return self

    @noop_nosections(result=True)
    def is_empty(self):
        return False


def merge(subseries, serie_fmts):
    assert len(subseries) == len(serie_fmts)
    mat = np.vstack(s.mat for s in subseries if not s.is_empty())
    sections = [fmt.format(section) for subserie, fmt in zip(subseries, serie_fmts)
                                    if not subserie.is_empty()
                                    for section in subserie.sections]
    return SubSerie(mat, sections)
