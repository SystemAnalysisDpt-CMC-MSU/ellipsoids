"""
plot_tight_vs_naive.py — figure for the naive-recursion DIRECTION-SELECTION artifact.

Reads results/tight_vs_naive.csv and writes figs/fig8_tight_vs_naive.png:
  Left  — max support-function gap vs kappa. Three curves:
            naive fixed-direction pairwise (blows up),
            pairwise + good time-varying direction (~machine eps),
            KV joint k-fold tight sum (~machine eps).
          The two exact curves lie on top of each other at machine epsilon,
          demonstrating the blow-up is a direction-selection error, not a
          recursion-structure error.
  Right — worst-direction over-approximation factor of each tube vs kappa.
"""
import csv
import os

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(HERE, "results")
FIGS = os.path.join(HERE, "figs")


def read_csv(name):
    with open(os.path.join(RESULTS, name), newline="") as f:
        return [{k: float(v) for k, v in row.items()} for row in csv.DictReader(f)]


def main():
    os.makedirs(FIGS, exist_ok=True)
    rows = read_csv("tight_vs_naive.csv")
    kappa = np.array([r["kappa"] for r in rows])
    naive_max = np.array([r["naive_fixed_max_gap"] for r in rows])
    good_max = np.array([r["pairwise_good_max_gap"] for r in rows])
    joint_max = np.array([r["joint_max_gap"] for r in rows])
    naive_ratio = np.array([r["naive_fixed_max_overapprox_ratio"] for r in rows])

    fig, axes = plt.subplots(1, 2, figsize=(11, 4))

    ax = axes[0]
    ax.loglog(kappa, np.maximum(naive_max, 1e-18), "o-", color="#d62728",
              linewidth=1.8, label="naive pairwise, FIXED direction")
    ax.loglog(kappa, np.maximum(good_max, 1e-18), "^-", color="#2ca02c",
              linewidth=1.8, label="pairwise + good (time-varying) direction")
    ax.loglog(kappa, np.maximum(joint_max, 1e-18), "s--", color="#1f77b4",
              linewidth=1.8, label="KV joint k-fold tight sum")
    ax.set_xlabel("Disturbance condition number κ")
    ax.set_ylabel("Max support-function gap vs exact")
    ax.set_title("Direction-selection error: fixed direction blows up,\n"
                 "good direction & joint sum both stay exact")
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3, which="both")

    ax = axes[1]
    ax.semilogx(kappa, naive_ratio, "o-", color="#d62728", linewidth=1.8,
                label="naive fixed-direction over-approx factor")
    ax.axhline(1.0, color="#2ca02c", linestyle="-", linewidth=1.5,
               label="pairwise good direction (exact, factor = 1.0)")
    ax.axhline(1.0, color="#1f77b4", linestyle="--", linewidth=1.2,
               label="KV joint tight sum (exact, factor = 1.0)")
    ax.set_xlabel("Disturbance condition number κ")
    ax.set_ylabel("ρ / exact ρ  (worst direction, final step)")
    ax.set_title("Naive fixed-direction over-approximation factor vs κ")
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3, which="both")

    fig.suptitle("The naive blow-up is a DIRECTION-SELECTION error, "
                 "not a recursion-structure error", y=1.03)
    fig.tight_layout()
    out = os.path.join(FIGS, "fig8_tight_vs_naive.png")
    fig.savefig(out, bbox_inches="tight", dpi=120)
    plt.close(fig)
    print(f"-> {out}")


if __name__ == "__main__":
    main()
