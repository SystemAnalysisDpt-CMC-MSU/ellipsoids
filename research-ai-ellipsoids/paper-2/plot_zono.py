"""Grouped bar chart of ellipsoid vs zonotope mean support-gap per scenario."""
import csv
import os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
rows = list(csv.DictReader(open(os.path.join(HERE, "results", "ell_vs_zono.csv"))))
names = [r["scenario"] for r in rows]
ell = [max(float(r["ell_mean_gap"]), 0.0) for r in rows]
zono = [max(float(r["zono_mean_gap"]), 0.0) for r in rows]

x = np.arange(len(names))
w = 0.38
fig, ax = plt.subplots(figsize=(9, 4.5))
ax.bar(x - w / 2, ell, w, label="ellipsoidal tube (KV)", color="#1f77b4")
ax.bar(x + w / 2, zono, w, label="zonotope tube (Girard)", color="#ff7f0e")
ax.set_ylabel("mean relative support gap vs exact reach set")
ax.set_title("Ellipsoid vs zonotope reach tube — each exact on its native geometry")
ax.set_xticks(x)
ax.set_xticklabels(names, rotation=20, ha="right")
for i, (e, z) in enumerate(zip(ell, zono)):
    win = "E" if e < z else "Z"
    ax.text(i, max(e, z) + 0.01, win, ha="center", fontweight="bold")
ax.legend()
fig.tight_layout()
out = os.path.join(HERE, "figs", "fig7_ell_vs_zono.png")
fig.savefig(out, dpi=120)
print(f"-> {out}")
