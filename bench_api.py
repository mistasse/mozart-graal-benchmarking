from collections import defaultdict, OrderedDict

from matplotlib import pyplot as plt
import numpy as np

from benchmark import Options


__all__ = [
    "get_log",
    "extract",
    "Serie",
    "noop_nosections",
    "SubSerie",
    "merge",

    "asis",
    "nano_mat"
]


def get_log(serie, n=0):
    n = str(n) if n > 0 else ""
    with open(Options.resdir+"last_"+serie+"/output{}.txt".format(n), "r") as f:
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


def to_list(dic, label, sections=None):
    keys = list(dic.keys())
    lst = []
    if sections is None:
        sections = [k for k in keys if dic[k].get(label, None) is not None]
    else:
        sections = [keys[section] if isinstance(section, int) else section for section in sections]

    for section in sections:
        lst.append(dic[section][label])
    return lst, sections


def nano_mat(lst):
    return np.array(lst, dtype="float64") * 1e-9


def asis(lst):
    return lst


class Serie:
    def __init__(self, serie, n=0):
        self.serie = extract(get_log(serie, n))

    def get(self, label, sections=None, *, conv=nano_mat):
        if isinstance(label, tuple):
            return tuple(self.get(l, sections, conv=conv) for l in label)
        lst, sections = to_list(self.serie, label, sections)
        return SubSerie(conv(lst), sections)

    def __getitem__(self, label):
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
    def hist(self, sections=None, *, yscale="log", legend=1, bins=None, stacked=False):
        min_, max_ = min(self.mat[0]), max(self.mat[0])
        for m in self.mat:
            mi, ma = min(m), max(m)
            if mi < min_:
                min_ = mi
            if ma > max_:
                max_ = ma
        # default: from min-0.5 to max+0.5 with max_ - min_ + 1 bins
        bins = np.linspace(min_, max_+1, max_ - min_ + 2 if bins is None else bins+1)-0.5
        plt.hist(self.mat, bins, stacked=stacked)
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
