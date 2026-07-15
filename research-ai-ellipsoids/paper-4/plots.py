"""Figures for the certified-inner NFL paper: inner/true/outer bracket over the
horizon, and a 2-D view of inner ellipsoids vs the sampled true reach + target."""
import csv
import os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
R = os.path.join(HERE, "results")
os.makedirs(os.path.join(HERE, "figs"), exist_ok=True)


def rows(name):
    return list(csv.DictReader(open(os.path.join(R, name))))


# --- bracket figure ---
br = rows("bracket.csv")
step = [int(r["step"]) for r in br]
inner = [float(r["inner_mc_area"]) for r in br]
robust = [max(float(r["robust_mc_area"]), 1e-6) for r in br]
true = [float(r["true_hull_mc_area"]) for r in br]
outer = [float(r["outer_area"]) for r in br]
fig, ax = plt.subplots(figsize=(7.5, 4.5))
ax.plot(step, outer, "s-", label="outer over-approx (CROWN+KV ext)", color="#d62728")
ax.plot(step, true, "o-", label="true reach (sampled hull)", color="#2ca02c")
ax.plot(step, inner, "^-", label="certified inner (this work)", color="#1f77b4")
ax.plot(step, robust, "v--", label="robust inner (guaranteed vs worst-case w)", color="#9467bd")
ax.set_yscale("log")
ax.set_xlabel("step k"); ax.set_ylabel("reach-set area (log)")
ax.set_title("Certified inner ⊆ true ⊆ outer: a two-sided bracket for a ReLU NFL")
ax.legend()
fig.tight_layout(); fig.savefig(os.path.join(HERE, "figs", "fig1_bracket.png"), dpi=120)

# --- inner-tube ratio figure ---
ratio = [float(r["inner_over_true"]) for r in br]
oratio = [float(r["outer_over_true"]) for r in br]
fig, ax = plt.subplots(figsize=(7.5, 4.0))
ax.plot(step, ratio, "^-", label="inner / true (≤1, sound lower bound)", color="#1f77b4")
ax.plot(step, oratio, "s-", label="outer / true (≥1, sound upper bound)", color="#d62728")
ax.axhline(1.0, color="k", lw=0.8, ls=":")
ax.set_xlabel("step k"); ax.set_ylabel("area ratio vs true")
ax.set_title("Two-sided containment ratios (inner tightest early, conservative later)")
ax.legend()
fig.tight_layout(); fig.savefig(os.path.join(HERE, "figs", "fig2_ratios.png"), dpi=120)
print("wrote figs/fig1_bracket.png, figs/fig2_ratios.png")
