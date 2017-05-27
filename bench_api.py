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
    "nano_mat",

    "mean",
    "geomean",
    "first",
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
    length = max((len(l) for l in lst), default=0)
    for l in lst:
        if len(l) != length:
            l += [float("nan")] * (length-len(l))
    return np.array(lst, dtype="float64") * 1e-9


def asis(lst):
    return lst


def mean(lst):
    s = lst[0]
    for l in lst[1:]:
        s += l
    return s / len(lst)


def geomean(lst):
    s = lst[0]
    for l in lst[1:]:
        s *= l
    return np.power(s, 1/len(lst))


def first(lst):
	return lst[0]


class Serie:
    def __init__(self, serie, n=0):
        self.n = n
        if isinstance(n, int):
            self.serie = [extract(get_log(serie, n))]
        else:
            self.serie = [extract(get_log(serie, i)) for i in n]

    def get(self, label, sections=None, *, conv=nano_mat, agg=first):
        if isinstance(label, tuple):
            return tuple(self.get(l, sections, conv=conv, agg=agg) for l in label)
        lst, sections = to_list(self.serie[0], label, sections)
        lst = [lst]
        for serie in self.serie[1:]:
            lst.append(to_list(serie, label, sections)[0])
        return SubSerie(agg([conv(l) for l in lst]), sections)

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

    def sub(self, *args, init_axis=None, **kwargs):
        ax = plt.subplot(*args, **kwargs)
        if init_axis is not None:
            init_axis.append(ax)
        return self

    def grid(self):
        plt.grid()
        return self

    @noop_nosections()
    def plot(self, sections=None, *, init_axis=None, legend=1, xlabel=None, ylabel=None, xscale=None, yscale="log"):
        for m in self.mat:
            ax = plt.plot(m)
            if init_axis is not None:
                init_axis.append(ax)
        if xlabel is not None:
            plt.xlabel(xlabel)
        if ylabel is not None:
            plt.ylabel(ylabel)
        if xscale is not None:
            plt.xscale(xscale)
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
