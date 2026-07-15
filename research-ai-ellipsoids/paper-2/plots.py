"""
plots.py — Read benchmark CSVs and write figures to paper-2/figs/.

Figures produced:
  fig1_theta_gaps.png     — ext/int gap vs rotation angle
  fig2_kappa_gaps.png     — ext/int gap vs disturbance conditioning
  fig3_ratio_gaps.png     — ext/int gap vs disturbance-to-initial ratio
  fig4_dim_runtime.png    — runtime ext/int vs dimension
  fig5_dim_gaps.png       — ext/int gap vs dimension (losing-regime chart)
  fig6_inner_outer.png    — inner-outer gap (ext - int mean gap) vs theta and dim
"""

import csv
import os
import math

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

RESULTS_DIR = os.path.join(os.path.dirname(__file__), "results")
FIGS_DIR = os.path.join(os.path.dirname(__file__), "figs")


# ── CSV reader ────────────────────────────────────────────────────────────────

def read_csv(filename):
    path = os.path.join(RESULTS_DIR, filename)
    rows = []
    with open(path, newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append({k: _parse(v) for k, v in row.items()})
    return rows


def _parse(s):
    try:
        return int(s)
    except ValueError:
        pass
    try:
        return float(s)
    except ValueError:
        return s


def col(rows, key):
    return np.array([r[key] for r in rows])


# ── Style ─────────────────────────────────────────────────────────────────────

STYLE = dict(
    ext=dict(color="#1f77b4", marker="o", linewidth=1.8, label="Ext tube gap"),
    int_=dict(color="#d62728", marker="s", linewidth=1.8, label="Int tube gap"),
    runtime_ext=dict(color="#1f77b4", marker="o", linewidth=1.8, label="Runtime ext"),
    runtime_int=dict(color="#d62728", marker="s", linewidth=1.8, label="Runtime int"),
    inner_outer=dict(color="#2ca02c", marker="^", linewidth=1.8, label="Inner-outer gap"),
)

plt.rcParams.update({
    "figure.dpi": 120,
    "font.size": 10,
    "axes.titlesize": 11,
    "axes.labelsize": 10,
    "legend.fontsize": 9,
})


def _savefig(fig, name):
    os.makedirs(FIGS_DIR, exist_ok=True)
    path = os.path.join(FIGS_DIR, name)
    fig.savefig(path, bbox_inches="tight")
    plt.close(fig)
    print(f"  -> {path}")


# ── Fig 1: theta gaps ─────────────────────────────────────────────────────────

def fig_theta_gaps():
    rows = read_csv("sweep_theta.csv")
    thetas = col(rows, "theta")
    deg = np.degrees(thetas)
    fig, axes = plt.subplots(1, 2, figsize=(10, 4))

    ax = axes[0]
    ax.plot(deg, col(rows, "mean_gap_ext"), **STYLE["ext"])
    ax.plot(deg, col(rows, "mean_gap_int"), **STYLE["int_"])
    ax.set_xlabel("Rotation angle θ (degrees)")
    ax.set_ylabel("Mean support-function gap")
    ax.set_title("Mean SF gap vs rotation angle")
    ax.legend()
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.plot(deg, col(rows, "max_gap_ext"), **STYLE["ext"])
    ax.plot(deg, col(rows, "max_gap_int"), **STYLE["int_"])
    ax.set_xlabel("Rotation angle θ (degrees)")
    ax.set_ylabel("Max support-function gap")
    ax.set_title("Max SF gap vs rotation angle")
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.suptitle("Regime 1 — Rotation angle sweep (n=2, ρ=0.95)", y=1.01)
    fig.tight_layout()
    _savefig(fig, "fig1_theta_gaps.png")


# ── Fig 2: kappa gaps ─────────────────────────────────────────────────────────

def fig_kappa_gaps():
    rows = read_csv("sweep_kappa.csv")
    kappas = col(rows, "kappa")
    fig, axes = plt.subplots(1, 2, figsize=(10, 4))

    ax = axes[0]
    ax.semilogx(kappas, col(rows, "mean_gap_ext"), **STYLE["ext"])
    ax.semilogx(kappas, col(rows, "mean_gap_int"), **STYLE["int_"])
    ax.set_xlabel("Disturbance condition number κ")
    ax.set_ylabel("Mean support-function gap")
    ax.set_title("Mean SF gap vs disturbance conditioning")
    ax.legend()
    ax.grid(True, alpha=0.3, which="both")

    ax = axes[1]
    ax.semilogx(kappas, col(rows, "max_gap_ext"), **STYLE["ext"])
    ax.semilogx(kappas, col(rows, "max_gap_int"), **STYLE["int_"])
    ax.set_xlabel("Disturbance condition number κ")
    ax.set_ylabel("Max support-function gap")
    ax.set_title("Max SF gap vs disturbance conditioning")
    ax.legend()
    ax.grid(True, alpha=0.3, which="both")

    fig.suptitle("Regime 2 — Disturbance conditioning sweep (n=2): "
                 "KV tight tube stays exact under anisotropy", y=1.01)
    fig.tight_layout()
    _savefig(fig, "fig2_kappa_gaps.png")


# ── Fig 3: dist_ratio gaps ────────────────────────────────────────────────────

def fig_ratio_gaps():
    rows = read_csv("sweep_dist_ratio.csv")
    ratios = col(rows, "dist_ratio")
    fig, axes = plt.subplots(1, 2, figsize=(10, 4))

    ax = axes[0]
    ax.semilogx(ratios, col(rows, "mean_gap_ext"), **STYLE["ext"])
    ax.semilogx(ratios, col(rows, "mean_gap_int"), **STYLE["int_"])
    ax.set_xlabel("Disturbance-to-initial ratio r")
    ax.set_ylabel("Mean support-function gap")
    ax.set_title("Mean SF gap vs disturbance ratio")
    ax.legend()
    ax.grid(True, alpha=0.3, which="both")

    ax = axes[1]
    ax.semilogx(ratios, col(rows, "max_gap_ext"), **STYLE["ext"])
    ax.semilogx(ratios, col(rows, "max_gap_int"), **STYLE["int_"])
    ax.set_xlabel("Disturbance-to-initial ratio r")
    ax.set_ylabel("Max support-function gap")
    ax.set_title("Max SF gap vs disturbance ratio")
    ax.legend()
    ax.grid(True, alpha=0.3, which="both")

    fig.suptitle("Regime 3 — Disturbance-to-initial ratio sweep (n=2)", y=1.01)
    fig.tight_layout()
    _savefig(fig, "fig3_ratio_gaps.png")


# ── Fig 4: dimension runtime ──────────────────────────────────────────────────

def fig_dim_runtime():
    rows = read_csv("sweep_dim.csv")
    dims = col(rows, "dim").astype(int)
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.plot(dims, col(rows, "runtime_ext"), **STYLE["runtime_ext"])
    ax.plot(dims, col(rows, "runtime_int"), **STYLE["runtime_int"])
    ax.set_xlabel("State dimension n")
    ax.set_ylabel("Wall-clock time (s)")
    ax.set_title("Runtime vs state dimension (N=8 steps, 24 directions)")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    _savefig(fig, "fig4_dim_runtime.png")


# ── Fig 5: dimension gaps (the losing regime) ─────────────────────────────────

def fig_dim_gaps():
    rows = read_csv("sweep_dim.csv")
    dims = col(rows, "dim").astype(int)
    fig, axes = plt.subplots(1, 2, figsize=(10, 4))

    ax = axes[0]
    ax.plot(dims, col(rows, "mean_gap_ext"), **STYLE["ext"])
    ax.plot(dims, col(rows, "mean_gap_int"), **STYLE["int_"])
    ax.set_xlabel("State dimension n")
    ax.set_ylabel("Mean support-function gap")
    ax.set_title("Mean SF gap vs dimension\n(KV tight tube: machine-epsilon at all n)")
    ax.legend()
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.plot(dims, col(rows, "max_gap_ext"), **STYLE["ext"])
    ax.plot(dims, col(rows, "max_gap_int"), **STYLE["int_"])
    ax.set_xlabel("State dimension n")
    ax.set_ylabel("Max support-function gap")
    ax.set_title("Max SF gap vs dimension")
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.suptitle("Regime 4 — Dimension sweep: KV tight tube exact at all n", y=1.01)
    fig.tight_layout()
    _savefig(fig, "fig5_dim_gaps.png")


# ── Fig 6: inner-outer gap phase diagram ──────────────────────────────────────

def fig_inner_outer():
    """
    Overlay the inner-outer certified gap (ext_mean_gap + int_mean_gap)
    for the theta sweep and dim sweep in one summary figure.
    """
    rows_theta = read_csv("sweep_theta.csv")
    rows_dim = read_csv("sweep_dim.csv")

    fig, axes = plt.subplots(1, 2, figsize=(10, 4))

    # Theta panel
    ax = axes[0]
    thetas_deg = np.degrees(col(rows_theta, "theta"))
    inner_outer_theta = col(rows_theta, "mean_gap_ext") + col(rows_theta, "mean_gap_int")
    ax.plot(thetas_deg, inner_outer_theta, **STYLE["inner_outer"])
    ax.set_xlabel("Rotation angle θ (degrees)")
    ax.set_ylabel("Inner-outer gap (ext_gap + int_gap)")
    ax.set_title("Certified conservatism vs rotation angle")
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Dim panel
    ax = axes[1]
    dims = col(rows_dim, "dim").astype(int)
    inner_outer_dim = col(rows_dim, "mean_gap_ext") + col(rows_dim, "mean_gap_int")
    ax.plot(dims, inner_outer_dim, **STYLE["inner_outer"])
    ax.set_xlabel("State dimension n")
    ax.set_ylabel("Inner-outer gap (ext_gap + int_gap)")
    ax.set_title("Certified conservatism vs dimension")
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.suptitle("Inner-outer certified gap — phase diagrams", y=1.01)
    fig.tight_layout()
    _savefig(fig, "fig6_inner_outer.png")


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    os.makedirs(FIGS_DIR, exist_ok=True)
    print("=== Paper-2 Plots ===")
    fig_theta_gaps()
    fig_kappa_gaps()
    fig_ratio_gaps()
    fig_dim_runtime()
    fig_dim_gaps()
    fig_inner_outer()
    print("=== All figures written to paper-2/figs/ ===")


if __name__ == "__main__":
    main()
