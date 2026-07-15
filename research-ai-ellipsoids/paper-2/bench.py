"""
bench.py — Ellipsoidal reach-tube tightness benchmark (Phase 1, Paper 2).

Reference truth: exact support-function formula for discrete-time LTI
  x_{k+1} = A x_k + w,  x_0 in E0,  w in W

  rho_R_k(m) = rho(A^k E0, m) + sum_{j=0}^{k-1} rho(A^j W, m)

where rho(E, m) = q^T m + sqrt(m^T Q m) for E = Ellipsoid(q, Q).
This is *exact* (no Monte-Carlo error) for the true reachable set under
additive disturbances when E0 and W are ellipsoids.

A Monte-Carlo cloud is generated separately as a cross-check column in CSVs.

Tube construction: we use the CORRECT joint k-fold Kurzhanski-Varaiya tight
sum `reach_tube_lti_discrete_tight`. At step k the reachable set is the k-fold
Minkowski sum  A^k E0 ⊕ A^{k-1} W ⊕ ... ⊕ A^0 W, and for each direction l the
kernel builds ONE ellipsoid tight along l via `minksum_ext_multi` /
`minksum_int_multi`. Because the KV per-direction ellipsoid is tight along its
own direction, its support along that direction equals the EXACT reach-set
support — so the gap is machine-epsilon in every direction, for every convex
(isotropic, anisotropic) ellipsoidal disturbance. The earlier large gaps at
high anisotropy were an ARTIFACT of naive pairwise recursion
(`reach_tube_lti_discrete`), not a property of KV theory; the naive vs tight
comparison is quantified separately in `bench_tight_vs_naive.py`.

Metrics per config:
  - mean/max support-function gap (ext tube above truth, int tube below truth)
  - volume ratio (tube vol / reference vol estimate)
  - wall-clock runtime (tube computation)

Sweeps:
  1. theta   — rotation angle of A = rho_spec * rot(theta)
  2. kappa   — conditioning (aspect ratio) of disturbance ellipsoid W
  3. dist_ratio — disturbance-to-initial ratio
  4. dim     — state dimension n = 2..12
"""

import csv
import os
import time
import math

import numpy as np
from numpy.linalg import matrix_power

from ellreach import Ellipsoid, reach_tube_lti_discrete_tight

# ── helpers ──────────────────────────────────────────────────────────────────

RESULTS_DIR = os.path.join(os.path.dirname(__file__), "results")


def _rho_ellipsoid(q, Q, m):
    """Support function of Ellipsoid(q, Q) along direction m."""
    val = float(q @ m) + math.sqrt(max(0.0, float(m @ Q @ m)))
    return val


def exact_reach_support(A, q0, Q0, qw, Qw, k, m):
    """
    Exact support of the true reach set at step k along direction m.

    rho_R_k(m) = rho(A^k E0, m) + sum_{j=0}^{k-1} rho(A^j W, m)
    """
    Ak = matrix_power(A, k)
    # rho(A^k E0, m) = q0^T (A^k)^T m + sqrt(m^T (A^k Q0 A^{kT}) m)
    qk = Ak @ q0
    Qk = Ak @ Q0 @ Ak.T
    total = _rho_ellipsoid(qk, Qk, m)
    for j in range(k):
        Aj = matrix_power(A, j)
        qwj = Aj @ qw
        Qwj = Aj @ Qw @ Aj.T
        total += _rho_ellipsoid(qwj, Qwj, m)
    return total


def mc_reach_support(A, q0, Q0, qw, Qw, k, m, n_samples=2000, rng=None):
    """Monte-Carlo support estimate of the true reach set at step k."""
    if rng is None:
        rng = np.random.default_rng(42)
    n = A.shape[0]
    # Sample x0 from E0 uniformly (rejection from bounding box)
    Q0_eig, Q0_vec = np.linalg.eigh(Q0)
    Q0_sqrt = Q0_vec @ np.diag(np.sqrt(np.maximum(Q0_eig, 0)))
    raw = rng.standard_normal((n_samples * 4, n))
    norms = np.linalg.norm(raw, axis=1, keepdims=True)
    u = raw / np.where(norms > 0, norms, 1)
    r = rng.random(n_samples * 4) ** (1.0 / n)
    pts0 = (u * r[:, None]) @ Q0_sqrt.T + q0
    inside0 = np.array([_inside_ellipsoid(q0, Q0, x) for x in pts0[:n_samples * 2]])
    pts0 = pts0[:n_samples * 2][inside0][:n_samples]
    if len(pts0) < n_samples // 2:
        pts0 = pts0

    # Sample w from W at each step
    Qw_eig, Qw_vec = np.linalg.eigh(Qw)
    Qw_sqrt = Qw_vec @ np.diag(np.sqrt(np.maximum(Qw_eig, 0)))

    x = pts0.T  # n x ns
    ns = x.shape[1]
    for _ in range(k):
        raw_w = rng.standard_normal((ns, n))
        norms_w = np.linalg.norm(raw_w, axis=1, keepdims=True)
        u_w = raw_w / np.where(norms_w > 0, norms_w, 1)
        r_w = rng.random(ns) ** (1.0 / n)
        w = (u_w * r_w[:, None]) @ Qw_sqrt.T + qw
        x = A @ x + w.T
    # support along m
    proj = m @ x
    return float(np.max(proj))


def _inside_ellipsoid(q, Q, x):
    diff = x - q
    try:
        Qi = np.linalg.inv(Q)
    except np.linalg.LinAlgError:
        return False
    return float(diff @ Qi @ diff) <= 1.0 + 1e-9


def make_direction_grid(n, n_dirs=32):
    """Return n_dirs unit directions in R^n (Fibonacci / random on sphere)."""
    rng = np.random.default_rng(123)
    if n == 2:
        angles = np.linspace(0, 2 * math.pi, n_dirs, endpoint=False)
        dirs = np.column_stack([np.cos(angles), np.sin(angles)])
    else:
        raw = rng.standard_normal((n_dirs, n))
        norms = np.linalg.norm(raw, axis=1, keepdims=True)
        dirs = raw / np.where(norms > 0, norms, 1)
    return dirs  # (n_dirs, n)


def run_tube_and_metrics(A, E0, W, N, n_dirs=32, mc_samples=2000):
    """
    Compute ext and int reach tubes for N steps and measure tightness.

    The tubes are the CORRECT joint k-fold KV tight sums
    (`reach_tube_lti_discrete_tight`): for each direction index d the returned
    ellipsoid sequence is tight along dirs[d], so evaluating its support along
    dirs[d] reproduces the exact reach-set support in that direction (gap =
    machine epsilon). The gap arrays therefore quantify only floating-point
    round-off, not any KV wrapping loss.

    Returns dict with keys:
      mean_gap_ext, max_gap_ext   — avg/max (ext_rho - exact_rho) >= 0
      mean_gap_int, max_gap_int   — avg/max (exact_rho - int_rho) >= 0
      vol_ratio_ext, vol_ratio_int — tube_vol / ref_vol (at final step)
      runtime_ext, runtime_int    — wall-clock seconds
      mc_max_gap_ext              — MC cross-check for ext at step N
    """
    n = A.shape[0]
    dirs = make_direction_grid(n, n_dirs)  # (n_dirs, n)

    q0, Q0 = E0.q, E0.Q
    qw, Qw = W.q, W.Q

    # Compute exact reference support at each step along each direction
    exact_rho = np.zeros((N + 1, n_dirs))
    for k in range(N + 1):
        for d_idx, m in enumerate(dirs):
            exact_rho[k, d_idx] = exact_reach_support(A, q0, Q0, qw, Qw, k, m)

    # External tube (joint k-fold KV tight sum; tube d is tight along dirs[d])
    t0 = time.perf_counter()
    tube_ext = reach_tube_lti_discrete_tight(A, E0, W, dirs, N, approx="ext")
    runtime_ext = time.perf_counter() - t0

    # Internal tube
    t0 = time.perf_counter()
    tube_int = reach_tube_lti_discrete_tight(A, E0, W, dirs, N, approx="int")
    runtime_int = time.perf_counter() - t0

    # Compute gaps across all steps and directions
    gaps_ext = []
    gaps_int = []
    for d_idx, m in enumerate(dirs):
        for k in range(1, N + 1):
            e_ext = tube_ext[d_idx][k]
            e_int = tube_int[d_idx][k]
            ref = exact_rho[k, d_idx]
            rho_ext = e_ext.rho(m)
            rho_int = e_int.rho(m)
            gaps_ext.append(rho_ext - ref)   # should be >= 0
            gaps_int.append(ref - rho_int)   # should be >= 0

    gaps_ext = np.array(gaps_ext)
    gaps_int = np.array(gaps_int)

    # Volume ratio at final step (use first direction's tube ellipsoid vs reference)
    # Reference volume: we estimate via the average of ext and int ellipsoid volumes
    vol_ext = tube_ext[0][N].volume() if n <= 8 else float("nan")
    vol_int = tube_int[0][N].volume() if n <= 8 else float("nan")

    # MC cross-check: max rho from MC vs exact at step N, first direction
    m0 = dirs[0]
    mc_rho = mc_reach_support(A, q0, Q0, qw, Qw, N, m0, n_samples=mc_samples)
    ext_rho_final = tube_ext[0][N].rho(m0)
    mc_gap_ext = ext_rho_final - mc_rho  # should be >= 0

    return dict(
        mean_gap_ext=float(np.mean(gaps_ext)),
        max_gap_ext=float(np.max(gaps_ext)),
        mean_gap_int=float(np.mean(gaps_int)),
        max_gap_int=float(np.max(gaps_int)),
        vol_ext_final=float(vol_ext),
        vol_int_final=float(vol_int),
        runtime_ext=float(runtime_ext),
        runtime_int=float(runtime_int),
        mc_gap_ext=float(mc_gap_ext),
    )


# ── Sweep 1: rotation angle ──────────────────────────────────────────────────

def sweep_theta(N=10, n_dirs=32):
    """Sweep rotation angle theta in A = rho_spec * rot(theta)."""
    print("  Sweep 1: rotation angle (n=2) ...")
    rho_spec = 0.95
    thetas = np.linspace(0, math.pi, 17)  # 0..pi in 17 steps
    rows = []
    for theta in thetas:
        c, s = math.cos(theta), math.sin(theta)
        A = rho_spec * np.array([[c, -s], [s, c]])
        E0 = Ellipsoid(np.zeros(2), np.eye(2))
        W = Ellipsoid(np.zeros(2), 0.05 * np.eye(2))
        metrics = run_tube_and_metrics(A, E0, W, N, n_dirs=n_dirs)
        row = dict(theta=float(theta), rho_spec=rho_spec, N=N, **metrics)
        rows.append(row)
        print(f"    theta={theta:.3f}  mean_gap_ext={metrics['mean_gap_ext']:.5f}  "
              f"mean_gap_int={metrics['mean_gap_int']:.5f}")
    _write_csv("sweep_theta.csv", rows)
    return rows


# ── Sweep 2: disturbance conditioning ────────────────────────────────────────

def sweep_kappa(N=10, n_dirs=32):
    """Sweep condition number kappa of disturbance shape W (n=2)."""
    print("  Sweep 2: disturbance conditioning (n=2) ...")
    theta = math.pi / 4
    c, s = math.cos(theta), math.sin(theta)
    A = 0.95 * np.array([[c, -s], [s, c]])
    E0 = Ellipsoid(np.zeros(2), np.eye(2))
    kappas = [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0]
    rows = []
    for kappa in kappas:
        # W = diag(sigma_1, sigma_2) with sigma_1/sigma_2 = kappa, sigma_1*sigma_2 = const
        base_area = 0.05
        sigma1 = math.sqrt(base_area * kappa)
        sigma2 = math.sqrt(base_area / kappa)
        Qw = np.diag([sigma1**2, sigma2**2])
        W = Ellipsoid(np.zeros(2), Qw)
        metrics = run_tube_and_metrics(A, E0, W, N, n_dirs=n_dirs)
        row = dict(kappa=float(kappa), N=N, **metrics)
        rows.append(row)
        print(f"    kappa={kappa:.1f}  mean_gap_ext={metrics['mean_gap_ext']:.5f}  "
              f"mean_gap_int={metrics['mean_gap_int']:.5f}")
    _write_csv("sweep_kappa.csv", rows)
    return rows


# ── Sweep 3: disturbance-to-initial ratio ────────────────────────────────────

def sweep_dist_ratio(N=10, n_dirs=32):
    """Sweep disturbance-to-initial ratio (n=2)."""
    print("  Sweep 3: disturbance-to-initial ratio (n=2) ...")
    theta = math.pi / 4
    c, s = math.cos(theta), math.sin(theta)
    A = 0.95 * np.array([[c, -s], [s, c]])
    ratios = [0.001, 0.005, 0.01, 0.05, 0.1, 0.2, 0.5, 1.0, 2.0]
    rows = []
    for ratio in ratios:
        E0 = Ellipsoid(np.zeros(2), np.eye(2))
        W = Ellipsoid(np.zeros(2), ratio**2 * np.eye(2))
        metrics = run_tube_and_metrics(A, E0, W, N, n_dirs=n_dirs)
        row = dict(dist_ratio=float(ratio), N=N, **metrics)
        rows.append(row)
        print(f"    ratio={ratio:.4f}  mean_gap_ext={metrics['mean_gap_ext']:.5f}  "
              f"mean_gap_int={metrics['mean_gap_int']:.5f}")
    _write_csv("sweep_dist_ratio.csv", rows)
    return rows


# ── Sweep 4: state dimension ──────────────────────────────────────────────────

def sweep_dim(N=8, n_dirs=24):
    """Sweep state dimension n from 2 to 12."""
    print("  Sweep 4: state dimension n=2..12 ...")
    dims = list(range(2, 13))
    rows = []
    rng = np.random.default_rng(7)
    for n in dims:
        # Build a stable rotation-like matrix in n-D
        # Use a random orthogonal matrix scaled by 0.95
        Z = rng.standard_normal((n, n))
        U, _, Vt = np.linalg.svd(Z)
        A = 0.95 * U @ Vt  # orthogonal * 0.95

        E0 = Ellipsoid(np.zeros(n), np.eye(n))
        W = Ellipsoid(np.zeros(n), 0.05 * np.eye(n))
        metrics = run_tube_and_metrics(A, E0, W, N, n_dirs=n_dirs)
        row = dict(dim=n, N=N, **metrics)
        rows.append(row)
        print(f"    dim={n}  mean_gap_ext={metrics['mean_gap_ext']:.5f}  "
              f"runtime_ext={metrics['runtime_ext']:.3f}s  "
              f"runtime_int={metrics['runtime_int']:.3f}s")
    _write_csv("sweep_dim.csv", rows)
    return rows


# ── CSV writer ────────────────────────────────────────────────────────────────

def _write_csv(filename, rows):
    path = os.path.join(RESULTS_DIR, filename)
    if not rows:
        return
    fieldnames = list(rows[0].keys())
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    print(f"  -> Wrote {path}")


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    os.makedirs(RESULTS_DIR, exist_ok=True)
    print("=== Paper-2 Benchmark: Ellipsoidal Reach-Tube Tightness ===")
    print()
    print("[1/4] Rotation-angle sweep")
    sweep_theta(N=10, n_dirs=32)
    print()
    print("[2/4] Disturbance-conditioning sweep")
    sweep_kappa(N=10, n_dirs=32)
    print()
    print("[3/4] Disturbance-to-initial-ratio sweep")
    sweep_dist_ratio(N=10, n_dirs=32)
    print()
    print("[4/4] State-dimension sweep")
    sweep_dim(N=8, n_dirs=24)
    print()
    print("=== Benchmark complete. Results in paper-2/results/ ===")


if __name__ == "__main__":
    main()
