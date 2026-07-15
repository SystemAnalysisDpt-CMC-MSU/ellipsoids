"""
bench_tight_vs_naive.py — the cautionary methods contribution of Paper 2.

Quantifies the true cause of the naive reach-tube blow-up. The blow-up is a
DIRECTION-SELECTION error, NOT a recursion-structure error. A pairwise recursion
is perfectly fine — as long as it uses the correct TIME-VARYING good direction at
each step. Holding the query direction FIXED across steps is what wraps.

  x_{k+1} = A x_k + w,  x_0 in E0,  w in W,  W anisotropic (condition number kappa)

Three ellipsoidal tubes are compared on the SAME system, initial set, disturbance,
and exact reference support:

  - naive_fixed : reach_tube_lti_discrete — pairwise E_{k+1} = minksum(A E_k, W, l)
        that re-approximates every step with the SAME FIXED query direction l = m.
        The running ellipsoid is wrapped in the wrong direction, so the error
        accumulates over the horizon and blows up as anisotropy grows.

  - pairwise_good : pairwise recursion E_j = minksum(A E_{j-1}, W, l_j) that uses
        the correct TIME-VARYING good direction. To be tight along query direction m
        at target step K, propagate the direction BACKWARD through the dynamics:
            l_K = m,   l_j = A^T l_{j+1}   (so l_j = (A^T)^{K-j} m).
        At each forward step j the summands A E_{j-1} and W are combined tight along
        l_j, and E_{j-1} was itself built tight along A^T l_j = l_{j-1}. This is a
        PAIRWISE recursion, yet it is machine-epsilon exact along m at step K, at
        every kappa. It proves the blow-up is not caused by the pairwise structure.

  - joint : reach_tube_lti_discrete_tight — one joint k-fold KV tight sum per query
        direction (minksum over the whole array A^k E0, A^{k-1} W, ..., A^0 W). Also
        machine-epsilon exact per direction.

Exact reference along direction m at step k (per-QUERY-direction; each entry needs
its own direction-specific ellipsoid tight along m):
  rho_R_k(m) = rho(A^k E0, m) + sum_{j=0}^{k-1} rho(A^j W, m).

Headline (corrected causal story): the naive FIXED-direction recursion blows up as
the disturbance anisotropy grows (max support-function gap ~900 at kappa=200, a ~63x
over-approximation factor in the worst direction at the final step). BOTH the
pairwise-good-direction recursion AND the joint k-fold tight sum stay exact (gap =
machine epsilon) at every kappa. The blow-up is therefore a DIRECTION-SELECTION
error — fix the query direction across steps and you wrap; propagate the correct
time-varying good direction and even a plain pairwise recursion is exact. It was
NEVER a deficiency of KV ellipsoidal theory or of the pairwise recursion structure.
"""
import csv
import os
import math

import numpy as np
from numpy.linalg import matrix_power

from ellreach import (
    Ellipsoid,
    minksum_ext,
    reach_tube_lti_discrete,
    reach_tube_lti_discrete_tight,
)

RESULTS_DIR = os.path.join(os.path.dirname(__file__), "results")


def exact_reach_support(A, E0, W, k, m):
    """Exact support of the true reach set at step k along direction m."""
    total = E0.rho(matrix_power(A, k).T @ m)
    for j in range(k):
        total += W.rho(matrix_power(A, j).T @ m)
    return total


def pairwise_good_support(A, E0, W, m, K):
    """Support along m at step K of a PAIRWISE recursion that uses the correct
    TIME-VARYING good direction.

    To make the step-K ellipsoid tight along the query direction m, propagate the
    direction BACKWARD through the dynamics so that at each forward step the
    running ellipsoid is combined tight along the direction that maps to m at
    step K:
        l_K = m,   l_j = A^T l_{j+1}   (so l_j = (A^T)^{K-j} m).
    Then run the plain pairwise external Minkowski sum
        E_j = minksum_ext(A E_{j-1}, W, l_j),   j = 1..K,
    and read rho(E_K, m). This is a PAIRWISE recursion — the only change from the
    naive tube is the per-step DIRECTION — yet it is machine-epsilon exact."""
    A = np.asarray(A, float)
    m = np.asarray(m, float).reshape(-1)
    ls = [None] * (K + 1)
    ls[K] = m
    for j in range(K - 1, -1, -1):
        ls[j] = A.T @ ls[j + 1]
    E = E0
    for j in range(1, K + 1):
        E = minksum_ext(E.affine(A), W, ls[j])
    return E.rho(m)


def make_direction_grid(n_dirs=32):
    angles = np.linspace(0, 2 * math.pi, n_dirs, endpoint=False)
    return np.column_stack([np.cos(angles), np.sin(angles)])


def run(N=10, n_dirs=32):
    os.makedirs(RESULTS_DIR, exist_ok=True)
    print("=== Paper-2: naive fixed-direction blow-up is a DIRECTION-SELECTION "
          "error ===")
    theta = math.pi / 4
    c, s = math.cos(theta), math.sin(theta)
    A = 0.95 * np.array([[c, -s], [s, c]])
    E0 = Ellipsoid(np.zeros(2), np.eye(2))
    dirs = make_direction_grid(n_dirs)
    kappas = [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0]
    base_area = 0.05
    rows = []
    for kappa in kappas:
        sigma1 = math.sqrt(base_area * kappa)
        sigma2 = math.sqrt(base_area / kappa)
        W = Ellipsoid(np.zeros(2), np.diag([sigma1 ** 2, sigma2 ** 2]))

        # naive FIXED-direction pairwise recursion (query direction held constant)
        naive = reach_tube_lti_discrete(A, E0, W, dirs, N, approx="ext")
        # joint k-fold KV tight sum, per query direction
        joint = reach_tube_lti_discrete_tight(A, E0, W, dirs, N, approx="ext")

        naive_gaps, good_gaps, joint_gaps = [], [], []
        naive_over, good_over, joint_over = [], [], []  # rho/exact at final step
        for d_idx, m in enumerate(dirs):
            ref_N = exact_reach_support(A, E0, W, N, m)
            good_N = pairwise_good_support(A, E0, W, m, N)
            if ref_N > 0:
                naive_over.append(naive[d_idx][N].rho(m) / ref_N)
                good_over.append(good_N / ref_N)
                joint_over.append(joint[d_idx][N].rho(m) / ref_N)
            for k in range(1, N + 1):
                ref = exact_reach_support(A, E0, W, k, m)
                naive_gaps.append(naive[d_idx][k].rho(m) - ref)
                # good-direction pairwise: build one tube per target step k,
                # tight along m at step k (direction propagated from step k)
                good_gaps.append(pairwise_good_support(A, E0, W, m, k) - ref)
                joint_gaps.append(joint[d_idx][k].rho(m) - ref)

        naive_gaps = np.array(naive_gaps)
        good_gaps = np.array(good_gaps)
        joint_gaps = np.array(joint_gaps)
        row = dict(
            kappa=float(kappa),
            N=N,
            naive_fixed_mean_gap=float(np.mean(naive_gaps)),
            naive_fixed_max_gap=float(np.max(naive_gaps)),
            pairwise_good_mean_gap=float(np.mean(good_gaps)),
            pairwise_good_max_gap=float(np.max(good_gaps)),
            joint_mean_gap=float(np.mean(joint_gaps)),
            joint_max_gap=float(np.max(joint_gaps)),
            naive_fixed_max_overapprox_ratio=float(np.max(naive_over)),
            pairwise_good_max_overapprox_ratio=float(np.max(good_over)),
            joint_max_overapprox_ratio=float(np.max(joint_over)),
        )
        rows.append(row)
        print(f"  kappa={kappa:6.1f}  "
              f"naive_fixed_max={row['naive_fixed_max_gap']:9.4f}  "
              f"pairwise_good_max={row['pairwise_good_max_gap']:.2e}  "
              f"joint_max={row['joint_max_gap']:.2e}  "
              f"naive_overapprox={row['naive_fixed_max_overapprox_ratio']:6.1f}x")

    # sanity: BOTH the good-direction pairwise tube and the joint tube are exact
    # along the query direction at every kappa; only the fixed-direction tube wraps.
    for r in rows:
        assert r["pairwise_good_max_gap"] <= 1e-6, (
            f"pairwise good-direction tube not exact at kappa={r['kappa']} "
            f"(max gap {r['pairwise_good_max_gap']})")
        assert r["joint_max_gap"] <= 1e-6, (
            f"joint tight tube not exact at kappa={r['kappa']} "
            f"(max gap {r['joint_max_gap']})")

    path = os.path.join(RESULTS_DIR, "tight_vs_naive.csv")
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    print(f"  -> Wrote {path}")
    print("pairwise-good AND joint tubes exact (machine-epsilon) at every kappa; "
          "only naive FIXED-direction recursion blows up.")
    return rows


if __name__ == "__main__":
    run()
