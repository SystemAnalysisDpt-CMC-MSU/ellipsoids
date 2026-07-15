"""
plots.py - figures for Paper 1 neural-feedback-loop reachability.

Produces paper-1/figs/*.png:
  * <bench>_tube.png       - reach-tube (ellipse) vs box overlays over the horizon,
                             with Monte-Carlo sampled true trajectory points.
  * support_gap.png        - box-minus-ellipsoid support gap along safety normals
                             vs horizon (all benchmarks).
  * volume_vs_horizon.png  - ellipsoid vs box enclosure volume vs horizon (log).

Reads nothing from CSV for geometry (recomputes tubes) but uses the same
benchmark configs and kernel, so figures and CSVs are consistent.
"""
from __future__ import annotations

import os
import sys

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(_HERE, "..", "python"))
sys.path.insert(0, _HERE)

from ellreach import Ellipsoid  # noqa: E402
from nfl import (  # noqa: E402
    ellipsoid_tube, box_tube, zono_tube, box_support, box_volume,
    bench_double_integrator, bench_stable_linear, bench_rotation, bench_stable_4d,
    _sqrtm,
)

FIGS = os.path.join(_HERE, "figs")
os.makedirs(FIGS, exist_ok=True)


def _ellipse_pts(E, n=120):
    th = np.linspace(0, 2 * np.pi, n)
    S = _sqrtm(E.Q)
    circ = np.stack([np.cos(th), np.sin(th)], axis=0)
    pts = E.q[:, None] + S @ circ
    return pts[0], pts[1]


def _box_pts(lo, hi):
    x = [lo[0], hi[0], hi[0], lo[0], lo[0]]
    y = [lo[1], lo[1], hi[1], hi[1], lo[1]]
    return x, y


def _zono_pts(Z):
    """Boundary polygon of a 2-D zonotope via support directions."""
    th = np.linspace(0.0, 2 * np.pi, 361)
    pts = np.array([Z.c + Z.G @ np.sign(np.array([np.cos(t), np.sin(t)]) @ Z.G)
                    for t in th])
    return pts[:, 0], pts[:, 1]


def _sample_traj(cfg, n_traj=40, seed=1):
    rng = np.random.default_rng(seed)
    A, B, net, E0, W = cfg["A"], cfg["B"], cfg["net"], cfg["E0"], cfg["W"]
    N = cfg["N"]
    n = E0.dim
    S0 = _sqrtm(E0.Q)
    SW = _sqrtm(W.Q) if np.any(W.Q) else None
    trajs = []
    for _ in range(n_traj):
        u = rng.standard_normal(n); u /= max(np.linalg.norm(u), 1e-12)
        x = E0.q + S0 @ (u * rng.uniform(0, 1) ** (1.0 / n))
        pts = [x.copy()]
        for _k in range(N):
            w = np.zeros(n)
            if SW is not None:
                uw = rng.standard_normal(n); uw /= max(np.linalg.norm(uw), 1e-12)
                w = SW @ (uw * rng.uniform(0, 1) ** (1.0 / n))
            x = A @ x + B @ net.forward(x) + w
            pts.append(x.copy())
        trajs.append(np.array(pts))
    return trajs


def plot_tube(cfg):
    """2D reach-tube overlay (ellipse vs box) with sampled trajectories."""
    if cfg["E0"].dim != 2:
        return
    A, B, net, E0, W = cfg["A"], cfg["B"], cfg["net"], cfg["E0"], cfg["W"]
    N = cfg["N"]
    # ellipsoid tube tight along a neutral direction for visualization
    ax_dirs = [np.array([1.0, 0.0]), np.array([0.0, 1.0]),
               np.array([1.0, 1.0]), np.array([1.0, -1.0])]
    tubes = [ellipsoid_tube(A, B, net, E0, W, d, N) for d in ax_dirs]
    half = np.sqrt(np.clip(np.diag(E0.Q), 0.0, None))
    if np.any(W.Q):
        wh = np.sqrt(np.clip(np.diag(W.Q), 0.0, None)); w_lo, w_hi = -wh, wh
    else:
        w_lo = w_hi = np.zeros(2)
    bseq = box_tube(A, B, net, E0.q - half, E0.q + half, w_lo, w_hi, N)
    zseq = zono_tube(A, B, net, E0, W, N)
    trajs = _sample_traj(cfg)

    fig, ax = plt.subplots(figsize=(7, 6))
    for k in range(N + 1):
        # intersection-of-directions ellipse: draw the tightest per-direction ell
        # for a clean picture, draw the axis-x tube ellipse (representative)
        ex, ey = _ellipse_pts(tubes[0][k])
        ax.plot(ex, ey, color="C0", lw=0.8, alpha=0.5)
        zx, zy = _zono_pts(zseq[k])
        ax.plot(zx, zy, color="C2", lw=0.8, alpha=0.5, ls="-.")
        bx, by = _box_pts(*bseq[k])
        ax.plot(bx, by, color="C3", lw=0.8, alpha=0.4, ls="--")
    for tr in trajs:
        ax.plot(tr[:, 0], tr[:, 1], color="k", lw=0.4, alpha=0.35)
        ax.scatter(tr[:, 0], tr[:, 1], s=2, color="k", alpha=0.35)
    ax.plot([], [], color="C0", lw=1.5, label="ellipsoidal tube")
    ax.plot([], [], color="C2", lw=1.5, ls="-.", label="zonotope tube")
    ax.plot([], [], color="C3", lw=1.5, ls="--", label="box (IBP) tube")
    ax.plot([], [], color="k", lw=0.8, label="sampled true trajectories")
    ax.set_title(f"{cfg['name']}: reach tube vs box (N={N})")
    ax.set_xlabel("x1"); ax.set_ylabel("x2")
    ax.legend(loc="best", fontsize=8)
    ax.axis("equal"); ax.grid(alpha=0.25)
    path = os.path.join(FIGS, f"{cfg['name']}_tube.png")
    fig.tight_layout(); fig.savefig(path, dpi=130); plt.close(fig)
    print("wrote", path)


def plot_support_gap_and_volume(cfgs):
    fig1, ax1 = plt.subplots(figsize=(7, 5))
    fig2, ax2 = plt.subplots(figsize=(7, 5))
    for ci, cfg in enumerate(cfgs):
        A, B, net, E0, W = cfg["A"], cfg["B"], cfg["net"], cfg["E0"], cfg["W"]
        N = cfg["N"]; n = E0.dim
        c = cfg["safety_dirs"][0]
        etube = ellipsoid_tube(A, B, net, E0, W, c, N)
        half = np.sqrt(np.clip(np.diag(E0.Q), 0.0, None))
        if np.any(W.Q):
            wh = np.sqrt(np.clip(np.diag(W.Q), 0.0, None)); w_lo, w_hi = -wh, wh
        else:
            w_lo = w_hi = np.zeros(n)
        bseq = box_tube(A, B, net, E0.q - half, E0.q + half, w_lo, w_hi, N)
        # for volume use the axis-x tight tube (representative outer ellipse)
        vtube = ellipsoid_tube(A, B, net, E0, W, np.eye(n)[0], N)
        zseq = zono_tube(A, B, net, E0, W, N)
        # gap along safety normal: box vs ellipsoid, and zonotope vs ellipsoid
        gaps = [box_support(bseq[k][0], bseq[k][1], c) - etube[k].rho(c)
                for k in range(N + 1)]
        zgaps = [zseq[k].rho(c) - etube[k].rho(c) for k in range(N + 1)]
        evol = [vtube[k].volume() for k in range(N + 1)]
        bvol = [box_volume(*bseq[k]) for k in range(N + 1)]
        ks = np.arange(N + 1)
        ax1.plot(ks, gaps, marker="o", ms=3, label=f"{cfg['name']} box-ell",
                 color=f"C{ci}")
        ax1.plot(ks, zgaps, marker="^", ms=3, ls=":", color=f"C{ci}",
                 label=f"{cfg['name']} zono-ell")
        ax2.plot(ks, evol, marker="o", ms=3, color=f"C{ci}",
                 label=f"{cfg['name']} ell")
        ax2.plot(ks, bvol, marker="s", ms=3, ls="--", color=f"C{ci}",
                 label=f"{cfg['name']} box")

    ax1.axhline(0, color="k", lw=0.6)
    ax1.set_title("Support gap (box - ellipsoid) along safety normal vs horizon")
    ax1.set_xlabel("step k"); ax1.set_ylabel("support gap  (>0 : ellipsoid tighter)")
    ax1.legend(fontsize=8); ax1.grid(alpha=0.25)
    p1 = os.path.join(FIGS, "support_gap.png")
    fig1.tight_layout(); fig1.savefig(p1, dpi=130); plt.close(fig1)
    print("wrote", p1)

    ax2.set_yscale("log")
    ax2.set_title("Enclosure volume vs horizon (log scale)")
    ax2.set_xlabel("step k"); ax2.set_ylabel("volume")
    ax2.legend(fontsize=7, ncol=2); ax2.grid(alpha=0.25, which="both")
    p2 = os.path.join(FIGS, "volume_vs_horizon.png")
    fig2.tight_layout(); fig2.savefig(p2, dpi=130); plt.close(fig2)
    print("wrote", p2)


def main():
    cfgs = [bench_double_integrator(), bench_stable_linear(),
            bench_rotation(), bench_stable_4d()]
    for cfg in cfgs:
        plot_tube(cfg)
    plot_support_gap_and_volume(cfgs)
    print("all figures written to", FIGS)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
