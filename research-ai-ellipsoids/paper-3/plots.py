"""
plots.py -- figures for Paper 3 from paper-3/results/*.csv.

Produces:
  figs/calibration_curves.png    -- realized vs nominal coverage (ell & box),
                                     one panel per domain, with the y=x
                                     validity line and Wilson CIs.
  figs/volume_at_coverage.png    -- per-step region volume, ellipsoid vs box,
                                     one panel per domain (log scale).
  figs/failure_regime.png        -- single-ellipsoid vs mixture-oracle area on
                                     the bimodal (non-elliptical) residuals.

All inputs are the real CSVs written by cp_tubes.py. No synthetic data here.
"""
from __future__ import annotations

import csv
import os

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(HERE, "results")
FIGS = os.path.join(HERE, "figs")
os.makedirs(FIGS, exist_ok=True)


def read_csv(name):
    path = os.path.join(RESULTS, name)
    with open(path, newline="") as f:
        return list(csv.DictReader(f))


def _f(row, key):
    return float(row[key])


def plot_calibration_curves():
    rows = read_csv("calibration_curve.csv")
    domains = sorted({r["domain"] for r in rows})
    n = len(domains)
    fig, axes = plt.subplots(1, n, figsize=(4.2 * n, 4.0), squeeze=False)
    for ax, dom in zip(axes[0], domains):
        dr = sorted([r for r in rows if r["domain"] == dom],
                    key=lambda r: _f(r, "nominal"))
        nom = [_f(r, "nominal") for r in dr]
        ell = [_f(r, "ell_coverage") for r in dr]
        box = [_f(r, "box_coverage") for r in dr]
        ell_lo = [_f(r, "ell_ci_lo") for r in dr]
        ell_hi = [_f(r, "ell_ci_hi") for r in dr]
        ax.plot([0, 1], [0, 1], "k--", lw=1, label="nominal (y=x)")
        ax.fill_between(nom, ell_lo, ell_hi, color="tab:blue", alpha=0.2)
        ax.plot(nom, ell, "o-", color="tab:blue", label="ellipsoid (Mahalanobis)")
        ax.plot(nom, box, "s-", color="tab:orange", label="box (Bonferroni)")
        ax.set_title(dom, fontsize=9)
        ax.set_xlabel("nominal coverage 1-alpha")
        ax.set_ylabel("realized horizon coverage")
        ax.set_xlim(0.6, 1.02)
        ax.set_ylim(0.6, 1.02)
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=7, loc="lower right")
    fig.suptitle("Calibration curves: realized >= nominal (validity)", fontsize=11)
    fig.tight_layout(rect=[0, 0, 1, 0.96])
    out = os.path.join(FIGS, "calibration_curves.png")
    fig.savefig(out, dpi=130)
    plt.close(fig)
    return out


def plot_volume_at_coverage():
    rows = read_csv("tube_volumes.csv")
    domains = sorted({r["domain"] for r in rows})
    n = len(domains)
    fig, axes = plt.subplots(1, n, figsize=(4.2 * n, 4.0), squeeze=False)
    for ax, dom in zip(axes[0], domains):
        dr = sorted([r for r in rows if r["domain"] == dom],
                    key=lambda r: int(r["step"]))
        step = [int(r["step"]) for r in dr]
        ell = [_f(r, "ell_volume") for r in dr]
        box_iv = [_f(r, "box_interval_volume") for r in dr]
        box_fair = [_f(r, "box_fair_volume") for r in dr]
        ax.semilogy(step, box_iv, "s-", color="tab:orange",
                    label="box tube (interval / wrapping)")
        ax.semilogy(step, box_fair, "^--", color="tab:red",
                    label="box tube (fair / zonotope bbox)")
        ax.semilogy(step, ell, "o-", color="tab:blue", label="ellipsoid tube")
        ax.set_title(dom, fontsize=9)
        ax.set_xlabel("horizon step k")
        ax.set_ylabel("region volume (log)")
        ax.grid(True, alpha=0.3, which="both")
        ax.legend(fontsize=7, loc="upper left")
    fig.suptitle("Region volume vs horizon: ellipsoid vs interval box vs "
                 "wrapping-free (fair) box", fontsize=11)
    fig.tight_layout(rect=[0, 0, 1, 0.96])
    out = os.path.join(FIGS, "volume_at_coverage.png")
    fig.savefig(out, dpi=130)
    plt.close(fig)
    return out


def plot_wrapping_shape_decomposition():
    rows = read_csv("wrapping_shape_decomposition.csv")
    domains = [r["domain"] for r in rows]
    x = range(len(domains))
    iv = [_f(r, "final_interval_box_volume") for r in rows]
    fair = [_f(r, "final_fair_box_volume") for r in rows]
    ell = [_f(r, "final_ell_volume") for r in rows]
    fig, ax = plt.subplots(figsize=(1.9 * len(domains) + 3.0, 4.4))
    w = 0.26
    b1 = ax.bar([i - w for i in x], iv, w, color="tab:orange",
                label="interval box (wrapping)")
    b2 = ax.bar(list(x), fair, w, color="tab:red",
                label="fair box (wrapping-free)")
    b3 = ax.bar([i + w for i in x], ell, w, color="tab:blue",
                label="ellipsoid")
    ax.set_yscale("log")
    ax.set_xticks(list(x))
    ax.set_xticklabels(domains, fontsize=8, rotation=10)
    ax.set_ylabel("final-step region volume (log)")
    for r, i in zip(rows, x):
        wrap = _f(r, "wrapping_factor_interval_over_fair")
        shape = _f(r, "shape_factor_fairbox_over_ell")
        ax.text(i, max(iv) * 1.15,
                f"wrap {wrap:.1f}x\nshape {shape:.2f}x",
                ha="center", va="bottom", fontsize=8)
    ax.set_ylim(top=max(iv) * 3.0)
    ax.set_title("Decomposing the box advantage:\n"
                 "wrapping-elimination vs genuine ellipsoidal shape",
                 fontsize=10)
    ax.legend(fontsize=8, loc="lower right")
    ax.grid(True, axis="y", alpha=0.3, which="both")
    fig.tight_layout()
    out = os.path.join(FIGS, "wrapping_shape_decomposition.png")
    fig.savefig(out, dpi=130)
    plt.close(fig)
    return out


def plot_failure_regime():
    rows = read_csv("failure_regime.csv")
    r = rows[0]
    ell_area = _f(r, "single_ellipsoid_area")
    mix_area = _f(r, "mixture_oracle_area")
    ell_cov = _f(r, "single_ellipsoid_coverage")
    mix_cov = _f(r, "mixture_oracle_coverage")
    fig, ax = plt.subplots(figsize=(5.2, 4.2))
    labels = ["single\nellipsoid", "mixture\noracle"]
    areas = [ell_area, mix_area]
    covs = [ell_cov, mix_cov]
    bars = ax.bar(labels, areas, color=["tab:blue", "tab:green"], alpha=0.8)
    for b, a, c in zip(bars, areas, covs):
        ax.text(b.get_x() + b.get_width() / 2, a,
                f"area={a:.2f}\ncov={c:.2f}", ha="center", va="bottom", fontsize=9)
    ax.set_ylabel("one-step region area")
    ax.set_title("Failure regime (bimodal residuals):\n"
                 "single ellipsoid is crowded vs a mixture", fontsize=10)
    ax.set_ylim(0, max(areas) * 1.25)
    ax.grid(True, axis="y", alpha=0.3)
    fig.tight_layout()
    out = os.path.join(FIGS, "failure_regime.png")
    fig.savefig(out, dpi=130)
    plt.close(fig)
    return out


def main():
    outs = [
        plot_calibration_curves(),
        plot_volume_at_coverage(),
        plot_wrapping_shape_decomposition(),
        plot_failure_regime(),
    ]
    for o in outs:
        print("wrote", os.path.relpath(o, HERE))


if __name__ == "__main__":
    main()
