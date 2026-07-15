"""
cp_tubes.py -- Conformalized Ellipsoidal Reach Tubes (Paper 3 experiments).

Combines split-conformal calibration (distribution-free per-step coverage)
with the ellreach Minkowski algebra to propagate a calibrated one-step error
ELLIPSOID through (linearized) dynamics over a horizon H, producing multi-step
prediction tubes.

Three domains (>= 3 required):
  (A) stable linear system with CORRELATED Gaussian process noise;
  (B) the same true dynamics with a learned least-squares residual surrogate
      (the model error is what we conformalize);
  (C) a correlated multivariate AR(1) time-series generator.

For each domain we:
  * split trajectories -> fit / calib / test residual pools;
  * calibrate a Mahalanobis (ellipsoid) set AND a coordinate-wise (box) set;
  * roll out prediction tubes for horizon H via the kernel's tight external
    Minkowski sum   T_{k+1} = A.T_k  (+)  W   ;
  * measure realized horizon coverage vs nominal (calibration curve) and
    region volume at matched (fixed) coverage: ellipsoid vs box.

Headline: on the CORRELATED-error systems the ellipsoidal tube is SMALLER
(volume) than the box tube at matched coverage.

Also includes a set_membership demo using minkdiff_int (the estimation dual):
the state set consistent with a measurement + ellipsoidal error model via
guaranteed-inner Minkowski erosion.

Outputs: paper-3/results/*.csv  (all numbers from real runs, seeded).
"""
from __future__ import annotations

import csv
import os

import numpy as np

from ellreach import Ellipsoid, minksum_ext, minkdiff_int
from zonotope import Zonotope, reach_tube_zonotope
from conformal import (
    MahalanobisConformal,
    BoxConformal,
    empirical_coverage,
    conformal_quantile_index,
)

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(HERE, "results")
os.makedirs(RESULTS, exist_ok=True)


# ---------------------------------------------------------------------------
# Conformalized INITIAL set E0 (addresses the "distribution-free vs
# non-conformal E0" critique).  The old E0 was a FIXED 3.5-sigma Gaussian ball
# centred on x0_mean with Q = 3.5^2 * cov(x0) -- a Gaussian tail choice, NOT a
# distribution-free conformal set.  Its escape probability P(x0 not in E0) is
# small but nonzero (~0.2-0.7%) and was silently omitted from the horizon union
# bound, which then relied on Gaussianity of x0.
#
# We instead CONFORMALIZE E0 too: given held-out x0 samples we fit a Mahalanobis
# shape on a disjoint fit split and calibrate the radius on a calibration split
# at the SAME per-step level alpha (split-conformal).  The initial set is then a
# genuine distribution-free conformal region P(x0 in E0) >= 1 - alpha, and the
# horizon guarantee becomes the union bound over H+1 events (H one-step errors
# PLUS the initial-set event):  P(traj in tube) >= 1 - (H+1)*alpha.
# ---------------------------------------------------------------------------
def conformalize_initial_set(x0_samples: np.ndarray, alpha: float,
                             seed: int = 321) -> Ellipsoid:
    """Split-conformal Mahalanobis initial set E0 from x0 samples at level
    1-alpha.  Half the samples estimate the shape (fit), the other half
    calibrate the conformal radius (disjoint calibration split)."""
    rng = np.random.default_rng(seed)
    X = np.atleast_2d(np.asarray(x0_samples, float))
    idx = rng.permutation(X.shape[0])
    h = X.shape[0] // 2
    fit, calib = X[idx[:h]], X[idx[h:]]
    cp = MahalanobisConformal(center=True).fit(fit)
    cp.calibrate(calib, alpha)
    return cp.error_ellipsoid()

# A modest but well-spread direction family for tight external sums / volumes.
def direction_family(d: int, n_extra: int = 12, seed: int = 7) -> list[np.ndarray]:
    dirs = list(np.eye(d))
    rng = np.random.default_rng(seed)
    for _ in range(n_extra):
        v = rng.standard_normal(d)
        dirs.append(v / np.linalg.norm(v))
    return dirs


# ---------------------------------------------------------------------------
# Tube propagation.  We propagate a *single* ellipsoid per step but keep the
# tube tight along a family of directions by taking, for each step, the tight
# external Minkowski sum along the direction that the volume-minimizing
# aggregate favours. In practice, for the external sum the KV formula is tight
# along the chosen l; we aggregate over the family by intersecting the
# resulting support functions. For a compact single-object tube we use the
# volume-minimizing member of the family per step (sound outer bound along
# every family direction).
# ---------------------------------------------------------------------------
def propagate_tube(A: np.ndarray, E0: Ellipsoid, W: Ellipsoid, H: int,
                   dirs: list[np.ndarray]) -> list[Ellipsoid]:
    """Return [E0, T1, ..., TH]; each T_{k+1} is the min-volume member of the
    tight-external-sum family {minksum_ext(A T_k, W, l) : l in dirs}."""
    tube = [E0]
    Ek = E0
    for _ in range(H):
        AEk = Ek.affine(A)
        best = None
        best_vol = np.inf
        for l in dirs:
            cand = minksum_ext(AEk, W, l)
            v = cand.volume()
            if np.isfinite(v) and v < best_vol:
                best_vol = v
                best = cand
        Ek = best
        tube.append(Ek)
    return tube


def propagate_box_tube(A: np.ndarray, c0: np.ndarray, half0: np.ndarray,
                       w_center: np.ndarray, w_half: np.ndarray,
                       H: int) -> tuple[list[np.ndarray], list[np.ndarray]]:
    """Interval (box) tube for x_{k+1}=A x_k + w. Interval arithmetic:
    center_{k+1} = A center_k + w_center;
    half_{k+1}   = |A| half_k + w_half  (sound coordinate-wise enclosure)."""
    Aabs = np.abs(A)
    centers = [c0.copy()]
    halves = [half0.copy()]
    c, h = c0.copy(), half0.copy()
    for _ in range(H):
        c = A @ c + w_center
        h = Aabs @ h + w_half
        centers.append(c.copy())
        halves.append(h.copy())
    return centers, halves


# ---------------------------------------------------------------------------
# FAIR (wrapping-free) box baseline.  The interval box tube above accumulates
# INTERVAL-ARITHMETIC WRAPPING: |A| h_k + h_W rotates a box and re-encloses it
# axis-aligned every step, inflating the region even when the true reachable
# set is small.  For a HONEST shape comparison we must strip wrapping out.
#
# For the linear system x_{k+1}=A x_k + w with a box initial set and a box
# error set, the EXACT reachable set is a zonotope (affine images and Minkowski
# sums of zonotopes are exact -- zero wrapping; see zonotope.py).  We propagate
# that zonotope and take its EXACT axis-aligned bounding box each step.  This is
# the wrapping-free box baseline: the tightest axis-aligned box that still
# soundly encloses the (box-init, box-error) affine reachable set.  Comparing
#   interval-box  vs  zonotope-bbox   isolates the WRAPPING effect, and
#   ellipsoid     vs  zonotope-bbox   isolates the genuine ELLIPSOIDAL-SHAPE /
#                                     correlation-propagation effect.
# ---------------------------------------------------------------------------
def zonotope_bbox_halves(Z: Zonotope) -> np.ndarray:
    """Exact axis-aligned bounding-box half-widths of a zonotope:
    h_j = sum_i |G_{ji}| (support of the zonotope along +/- e_j)."""
    return np.sum(np.abs(Z.G), axis=1)


def propagate_fair_box_tube(A: np.ndarray, c0: np.ndarray, half0: np.ndarray,
                            w_center: np.ndarray, w_half: np.ndarray, H: int,
                            w_scale: float = 1.0
                            ) -> tuple[list[np.ndarray], list[np.ndarray]]:
    """Wrapping-FREE box tube: propagate the (box-init, box-error) affine
    reachable set as an EXACT zonotope and return its exact axis-aligned
    bounding box (centers, half-widths) per step.  ``w_scale`` rescales the
    error-box half-widths (used for equalized-coverage sweeps)."""
    Z0 = Zonotope.box(c0, half0)
    WZ = Zonotope.box(w_center, w_scale * w_half)
    ztube = reach_tube_zonotope(A, Z0, WZ, H)
    centers = [Z.c.copy() for Z in ztube]
    halves = [zonotope_bbox_halves(Z) for Z in ztube]
    return centers, halves


def ellipsoid_bbox_volume(E: Ellipsoid) -> float:
    """Volume of the axis-aligned bounding box of E(q, Q):
    half_j = sqrt(Q_jj)  (rho(E, e_j) - rho(E, -e_j) = 2 sqrt(Q_jj))."""
    half = np.sqrt(np.clip(np.diag(E.Q), 0.0, None))
    return float(np.prod(2.0 * half))


def ellipsoid_contains_traj(tube: list[Ellipsoid], traj: np.ndarray) -> bool:
    """traj shape (H+1, d). True iff every state lies in its step's ellipsoid."""
    for k, Ek in enumerate(tube):
        if not Ek.contains(traj[k]):
            return False
    return True


def box_contains_traj(centers, halves, traj: np.ndarray) -> bool:
    for k in range(len(centers)):
        if not np.all(np.abs(traj[k] - centers[k]) <= halves[k] + 1e-9):
            return False
    return True


# ---------------------------------------------------------------------------
# Data generators (return: A, x0_mean, residual pools, and a test-trajectory
# sampler). Residuals are the one-step model errors w_k that the tube must
# contain: for the true-model domains w_k is the process noise; for the
# learned-surrogate domain w_k is the surrogate prediction error.
# ---------------------------------------------------------------------------
def make_correlated_cov(d: int, rng: np.random.Generator, scale: float = 1.0):
    M = rng.standard_normal((d, d))
    S = M @ M.T + 0.2 * np.eye(d)
    # normalize to a target average variance = scale^2
    S = S * (scale ** 2) / (np.trace(S) / d)
    return 0.5 * (S + S.T)


def stable_matrix(d: int, rng: np.random.Generator, rho: float = 0.85):
    """Random matrix with spectral radius ~ rho (stable)."""
    M = rng.standard_normal((d, d))
    ev = np.max(np.abs(np.linalg.eigvals(M)))
    return M * (rho / ev)


def domain_linear_correlated(seed=0, d=2, H=8, n_traj=4000):
    """(A) Stable linear system, correlated Gaussian process noise (true model)."""
    rng = np.random.default_rng(seed)
    A = stable_matrix(d, rng, rho=0.8)
    Sigma_w = make_correlated_cov(d, rng, scale=0.5)
    Lw = np.linalg.cholesky(Sigma_w)
    x0_mean = np.zeros(d)
    x0_cov = 0.05 * np.eye(d)  # small, known initial set
    Lx0 = np.linalg.cholesky(x0_cov)

    def sample_noise(n):
        return (Lw @ rng.standard_normal((d, n))).T

    def sample_x0(n):
        return (Lx0 @ rng.standard_normal((d, n))).T + x0_mean

    def sample_trajectories(n):
        trajs = np.zeros((n, H + 1, d))
        x = (Lx0 @ rng.standard_normal((d, n))).T + x0_mean
        trajs[:, 0, :] = x
        for k in range(H):
            w = (Lw @ rng.standard_normal((d, n))).T
            x = x @ A.T + w
            trajs[:, k + 1, :] = x
        return trajs

    residuals = sample_noise(3 * n_traj)  # w residual pool
    x0_pool = sample_x0(3 * n_traj)       # initial-state pool (conformalize E0)
    return dict(name="A_linear_correlated", A=A, d=d, H=H,
                residuals=residuals, x0_samples=x0_pool,
                sample_trajectories=sample_trajectories, correlated=True)


def domain_learned_surrogate(seed=1, d=2, H=8, n_traj=4000):
    """(B) True nonlinear-ish dynamics; least-squares LINEAR surrogate learned
    from data. The conformalized error is the surrogate one-step residual,
    which is correlated (the omitted nonlinearity couples coordinates)."""
    rng = np.random.default_rng(seed)
    A_true = stable_matrix(d, rng, rho=0.75)
    # mild coupled quadratic nonlinearity + small correlated process noise
    Bnl = 0.12 * rng.standard_normal((d, d))
    Sigma_w = make_correlated_cov(d, rng, scale=0.15)
    Lw = np.linalg.cholesky(Sigma_w)
    x0_mean = np.zeros(d)
    x0_cov = 0.05 * np.eye(d)
    Lx0 = np.linalg.cholesky(x0_cov)

    def true_step(x, n):
        nl = (x @ Bnl.T) * x  # elementwise coupled quadratic term
        w = (Lw @ rng.standard_normal((d, n))).T
        return x @ A_true.T + nl + w

    # ---- generate training data & fit least-squares linear surrogate A_hat ----
    n_train = 20000
    xt = (Lx0 @ rng.standard_normal((d, n_train))).T + x0_mean
    # spread training states over the operating region
    for _ in range(rng.integers(1, 4)):
        xt = true_step(xt, n_train)
    xt_next = true_step(xt, n_train)
    # least squares: xt_next ~ xt @ A_hat.T  -> A_hat = (X^+ Y)
    A_hat = np.linalg.lstsq(xt, xt_next, rcond=None)[0].T

    def surrogate_residual(x, n):
        """One-step surrogate error r = true_next - A_hat x."""
        xn = true_step(x, n)
        return xn - x @ A_hat.T

    # Residual pool sampled over the FULL horizon operating distribution.
    # Exchangeability caveat: the tube is tested over H steps, so calibration
    # residuals must reflect the states visited at every step k=0..H-1, not a
    # single step out.  We therefore roll the true dynamics forward and collect
    # one-step surrogate residuals from EACH step 0..H-1, pooled together.  This
    # makes the calibration pool exchangeable with the per-step test residuals
    # along the whole horizon (addresses the horizon-exchangeability caveat).
    def sample_horizon_residual_pool(n_per_step):
        x = (Lx0 @ rng.standard_normal((d, n_per_step))).T + x0_mean
        pools = []
        for _ in range(H):
            pools.append(surrogate_residual(x, x.shape[0]))  # residual at this step
            x = true_step(x, n_per_step)                     # advance the true state
        return np.vstack(pools)

    # 3*n_traj residuals total, spread evenly across the H horizon steps.
    residuals = sample_horizon_residual_pool(max(1, (3 * n_traj) // H))

    def sample_x0(n):
        return (Lx0 @ rng.standard_normal((d, n))).T + x0_mean

    def sample_trajectories(n):
        """Roll the SURROGATE forward (that's what the tube is built on) but the
        realized state follows the TRUE dynamics; store true states."""
        trajs = np.zeros((n, H + 1, d))
        x = (Lx0 @ rng.standard_normal((d, n))).T + x0_mean
        trajs[:, 0, :] = x
        xtrue = x.copy()
        for k in range(H):
            xtrue = true_step(xtrue, n)
            trajs[:, k + 1, :] = xtrue
        return trajs

    x0_pool = sample_x0(3 * n_traj)
    return dict(name="B_learned_surrogate", A=A_hat, d=d, H=H,
                residuals=residuals, x0_samples=x0_pool,
                sample_trajectories=sample_trajectories, correlated=True)


def domain_var_timeseries(seed=2, d=3, H=10, n_traj=4000):
    """(C) Correlated multivariate AR(1)/VAR time-series generator with
    strongly correlated innovation covariance."""
    rng = np.random.default_rng(seed)
    A = stable_matrix(d, rng, rho=0.7)
    # highly correlated innovations
    base = rng.standard_normal((d, d))
    Sigma_e = base @ base.T
    # inject strong off-diagonal correlation
    corr = 0.7
    Dstd = np.sqrt(np.diag(Sigma_e))
    C = corr * np.ones((d, d)) + (1 - corr) * np.eye(d)
    Sigma_e = (np.outer(Dstd, Dstd) * C)
    Sigma_e = Sigma_e * (0.3 ** 2) / (np.trace(Sigma_e) / d)
    Sigma_e = 0.5 * (Sigma_e + Sigma_e.T)
    Le = np.linalg.cholesky(Sigma_e)
    x0_mean = np.zeros(d)
    x0_cov = 0.04 * np.eye(d)
    Lx0 = np.linalg.cholesky(x0_cov)

    def sample_innov(n):
        return (Le @ rng.standard_normal((d, n))).T

    def sample_x0(n):
        return (Lx0 @ rng.standard_normal((d, n))).T + x0_mean

    def sample_trajectories(n):
        trajs = np.zeros((n, H + 1, d))
        x = (Lx0 @ rng.standard_normal((d, n))).T + x0_mean
        trajs[:, 0, :] = x
        for k in range(H):
            e = (Le @ rng.standard_normal((d, n))).T
            x = x @ A.T + e
            trajs[:, k + 1, :] = x
        return trajs

    residuals = sample_innov(3 * n_traj)
    x0_pool = sample_x0(3 * n_traj)
    return dict(name="C_var_timeseries", A=A, d=d, H=H,
                residuals=residuals, x0_samples=x0_pool,
                sample_trajectories=sample_trajectories, correlated=True)


def domain_multimodal_failure(seed=3, d=2, H=6, n_traj=4000):
    """(D, honest failure regime) BIMODAL / non-elliptical residuals: a
    two-component mixture with well-separated means. A single ellipsoid must
    inflate to cover both modes -> box (or a mixture method) is more efficient.
    Reported to characterize where static ellipsoidal CP is 'crowded'."""
    rng = np.random.default_rng(seed)
    A = stable_matrix(d, rng, rho=0.6)
    sep = 2.0
    mode_means = np.array([[sep, 0.0], [-sep, 0.0]])
    small = make_correlated_cov(d, rng, scale=0.2)
    Ls = np.linalg.cholesky(small)
    x0_mean = np.zeros(d)
    x0_cov = 0.03 * np.eye(d)
    Lx0 = np.linalg.cholesky(x0_cov)

    def sample_noise(n):
        comp = rng.integers(0, 2, size=n)
        base = (Ls @ rng.standard_normal((d, n))).T
        return base + mode_means[comp]

    def sample_x0(n):
        return (Lx0 @ rng.standard_normal((d, n))).T + x0_mean

    def sample_trajectories(n):
        trajs = np.zeros((n, H + 1, d))
        x = (Lx0 @ rng.standard_normal((d, n))).T + x0_mean
        trajs[:, 0, :] = x
        for k in range(H):
            w = sample_noise(n)
            x = x @ A.T + w
            trajs[:, k + 1, :] = x
        return trajs

    residuals = sample_noise(3 * n_traj)
    x0_pool = sample_x0(3 * n_traj)
    return dict(name="D_multimodal_failure", A=A, d=d, H=H,
                residuals=residuals, x0_samples=x0_pool,
                sample_trajectories=sample_trajectories, correlated=False)


# ---------------------------------------------------------------------------
# Experiment driver
# ---------------------------------------------------------------------------
def split_three(residuals: np.ndarray, seed: int):
    rng = np.random.default_rng(seed)
    idx = rng.permutation(residuals.shape[0])
    n = residuals.shape[0] // 3
    return residuals[idx[:n]], residuals[idx[n:2 * n]], residuals[idx[2 * n:]]


def run_domain(dom: dict, alpha: float, seed: int = 123, trajs=None):
    """Calibrate ellipsoid + interval-box + FAIR (wrapping-free) box at level
    1-alpha; propagate all three tubes; measure realized horizon coverage and
    per-step volumes.  Returns (volume-records, summary).

    Three tubes are propagated so wrapping can be separated from shape:
      * ell         -- propagated single ellipsoid (correlation-aware);
      * box (iv)    -- INTERVAL-arithmetic box (accumulates wrapping);
      * box (fair)  -- exact zonotope reachable-set axis-aligned bbox
                       (wrapping-free honest box baseline).
    """
    A, H, d = dom["A"], dom["H"], dom["d"]
    E0 = conformalize_initial_set(dom["x0_samples"], alpha)
    res_fit, res_calib, _ = split_three(dom["residuals"], seed)
    dirs = direction_family(d)

    # --- calibrate one-step ellipsoidal error set ---
    maha = MahalanobisConformal(center=True).fit(res_fit)
    maha.calibrate(res_calib, alpha)
    W_ell = maha.error_ellipsoid()

    # --- calibrate one-step box error set (Bonferroni joint) ---
    box = BoxConformal(center=True).fit(res_fit)
    box.calibrate(res_calib, alpha)
    w_center, w_half = box.error_box()

    # --- propagate tubes over horizon ---
    ell_tube = propagate_tube(A, E0, W_ell, H, dirs)
    half0 = np.sqrt(np.diag(E0.Q))
    # interval (wrapping) box tube
    box_centers, box_halves = propagate_box_tube(
        A, E0.q, half0, w_center, w_half, H)
    # fair (wrapping-free) box tube: exact zonotope reachable-set bbox
    fair_centers, fair_halves = propagate_fair_box_tube(
        A, E0.q, half0, w_center, w_half, H)

    # --- realized horizon coverage on fresh test trajectories ---
    n_test = 8000
    if trajs is None:
        trajs = dom["sample_trajectories"](n_test)
    n_test = trajs.shape[0]
    ell_hits = np.array([ellipsoid_contains_traj(ell_tube, trajs[i])
                         for i in range(n_test)])
    box_hits = np.array([box_contains_traj(box_centers, box_halves, trajs[i])
                         for i in range(n_test)])
    fair_hits = np.array([box_contains_traj(fair_centers, fair_halves, trajs[i])
                          for i in range(n_test)])
    ell_cov, ell_lo, ell_hi = empirical_coverage(ell_hits)
    box_cov, box_lo, box_hi = empirical_coverage(box_hits)
    fair_cov, fair_lo, fair_hi = empirical_coverage(fair_hits)

    # --- initial-set coverage: is x0 inside the CONFORMALIZED E0? ---
    # E0 is now a split-conformal Mahalanobis region at level 1-alpha, so this
    # should be >= 1-alpha (distribution-free), and the escape probability
    # P(x0 not in E0) is the extra union-bound term folded into (H+1)*alpha.
    e0_hits = np.array([E0.contains(trajs[i, 0, :]) for i in range(n_test)])
    e0_cov, e0_lo, e0_hi = empirical_coverage(e0_hits)

    # --- per-step volumes ---
    ell_vols = np.array([E.volume() for E in ell_tube])
    ell_bbox_vols = np.array([ellipsoid_bbox_volume(E) for E in ell_tube])
    box_vols = np.array([float(np.prod(2.0 * h)) for h in box_halves])
    fair_vols = np.array([float(np.prod(2.0 * h)) for h in fair_halves])

    records = []
    for k in range(H + 1):
        records.append(dict(
            domain=dom["name"], alpha=alpha, nominal=1 - alpha, step=k,
            ell_volume=ell_vols[k],
            ell_bbox_volume=ell_bbox_vols[k],
            box_interval_volume=box_vols[k],
            box_fair_volume=fair_vols[k],
            vol_ratio_ell_over_box=(ell_vols[k] / box_vols[k]
                                    if box_vols[k] > 0 else float("nan")),
        ))

    summary = dict(
        domain=dom["name"], correlated=dom["correlated"], d=d, H=H,
        alpha=alpha, nominal=1 - alpha,
        ell_coverage=ell_cov, ell_ci_lo=ell_lo, ell_ci_hi=ell_hi,
        box_coverage=box_cov, box_ci_lo=box_lo, box_ci_hi=box_hi,
        fair_box_coverage=fair_cov, fair_box_ci_lo=fair_lo,
        fair_box_ci_hi=fair_hi,
        e0_coverage=e0_cov, e0_ci_lo=e0_lo, e0_ci_hi=e0_hi,
        e0_escape_prob=1.0 - e0_cov,
        ell_final_volume=ell_vols[-1], box_final_volume=box_vols[-1],
        vol_ratio_final=(ell_vols[-1] / box_vols[-1]
                         if box_vols[-1] > 0 else float("nan")),
        n_test=n_test,
    )
    return records, summary


# ---------------------------------------------------------------------------
# Wrapping vs shape decomposition (addresses the "unfair baseline" critique).
# At the final horizon step we report FOUR region volumes and decompose the
# headline advantage into (i) the WRAPPING-elimination factor and (ii) the
# genuine ELLIPSOIDAL-SHAPE / correlation factor:
#   interval_box  ---(/wrapping)-->  fair_box (zonotope bbox)  --(/shape)-->  ell
# so   interval_box / ell  =  wrapping_factor * shape_factor.
# We also report the one-step W ellipsoid-vs-box ratio (no propagation).
# ---------------------------------------------------------------------------
def wrapping_shape_decomposition(dom: dict, alpha: float, seed: int = 123):
    A, H, d = dom["A"], dom["H"], dom["d"]
    E0 = conformalize_initial_set(dom["x0_samples"], alpha)
    res_fit, res_calib, _ = split_three(dom["residuals"], seed)
    dirs = direction_family(d)

    maha = MahalanobisConformal(center=True).fit(res_fit)
    maha.calibrate(res_calib, alpha)
    W_ell = maha.error_ellipsoid()
    box = BoxConformal(center=True).fit(res_fit)
    box.calibrate(res_calib, alpha)
    w_center, w_half = box.error_box()

    # one-step error-set volumes (no propagation)
    W_ell_vol = W_ell.volume()
    W_box_vol = float(np.prod(2.0 * w_half))

    half0 = np.sqrt(np.diag(E0.Q))
    ell_tube = propagate_tube(A, E0, W_ell, H, dirs)
    box_centers, box_halves = propagate_box_tube(
        A, E0.q, half0, w_center, w_half, H)
    fair_centers, fair_halves = propagate_fair_box_tube(
        A, E0.q, half0, w_center, w_half, H)

    ell_vol = ell_tube[-1].volume()
    ell_bbox_vol = ellipsoid_bbox_volume(ell_tube[-1])
    interval_box_vol = float(np.prod(2.0 * box_halves[-1]))
    fair_box_vol = float(np.prod(2.0 * fair_halves[-1]))

    wrapping_factor = (interval_box_vol / fair_box_vol
                       if fair_box_vol > 0 else float("nan"))
    # genuine ellipsoidal-shape advantage of ell over the wrapping-free box of
    # the SAME affine reachable set:
    shape_factor_vs_fairbox = (fair_box_vol / ell_vol
                               if ell_vol > 0 else float("nan"))
    # correlation/shape advantage isolated from the reachable set itself:
    # given the ellipsoidal reachable set, using the ellipsoid vs its own
    # axis-aligned bounding box.
    shape_factor_ell_vs_own_bbox = (ell_bbox_vol / ell_vol
                                    if ell_vol > 0 else float("nan"))
    old_headline_ell_over_interval = (ell_vol / interval_box_vol
                                      if interval_box_vol > 0 else float("nan"))
    return dict(
        domain=dom["name"], d=d, H=H, alpha=alpha, nominal=1 - alpha,
        onestep_W_ell_volume=W_ell_vol, onestep_W_box_volume=W_box_vol,
        onestep_ratio_ell_over_box=(W_ell_vol / W_box_vol
                                    if W_box_vol > 0 else float("nan")),
        final_interval_box_volume=interval_box_vol,
        final_fair_box_volume=fair_box_vol,
        final_ell_volume=ell_vol,
        final_ell_bbox_volume=ell_bbox_vol,
        wrapping_factor_interval_over_fair=wrapping_factor,
        shape_factor_fairbox_over_ell=shape_factor_vs_fairbox,
        shape_factor_ellbbox_over_ell=shape_factor_ell_vs_own_bbox,
        old_headline_ell_over_intervalbox=old_headline_ell_over_interval,
    )


# ---------------------------------------------------------------------------
# TWO-OPERATING-POINT comparison (addresses the "one-sided equalized-coverage
# framing" critique).  Neither single direction is "the correct" comparison;
# we report BOTH and let the reader see the tradeoff honestly:
#
#   (i)  OWN-NOMINAL calibration -- each method calibrated at its OWN nominal
#        1-alpha level (ellipsoid at s=1, fair box at t=1).  Here the ellipsoid
#        is SMALLER than the fair box (the box over-covers by more at the same
#        nominal level, so this favours the ellipsoid).
#
#   (ii) EQUALIZED-coverage -- shrink the over-covering fair box down until its
#        REALIZED horizon coverage matches the ellipsoid's (~0.99 tail).  Here
#        the box is SMALLER on the low-D / weakly-correlated domains A,B, and
#        the ellipsoid stays smaller only on the strongly-correlated 3-D C.
#
# Both are genuine wrapping-free numbers (fair zonotope-bbox box); they differ
# only in the operating point.  We report both ratios per domain.
# ---------------------------------------------------------------------------
def equalized_coverage_comparison(dom: dict, alpha: float, seed: int = 123,
                                  trajs=None):
    A, H, d = dom["A"], dom["H"], dom["d"]
    E0 = conformalize_initial_set(dom["x0_samples"], alpha)
    res_fit, res_calib, _ = split_three(dom["residuals"], seed)
    dirs = direction_family(d)

    maha = MahalanobisConformal(center=True).fit(res_fit)
    maha.calibrate(res_calib, alpha)
    r0 = maha.radius_
    box = BoxConformal(center=True).fit(res_fit)
    box.calibrate(res_calib, alpha)
    w_center, w_half = box.error_box()
    half0 = np.sqrt(np.diag(E0.Q))

    if trajs is None:
        trajs = dom["sample_trajectories"](8000)
    n_test = trajs.shape[0]

    def ell_cov_vol(s):
        Ws = maha.error_ellipsoid(radius=s * r0)
        tube = propagate_tube(A, E0, Ws, H, dirs)
        hits = np.array([ellipsoid_contains_traj(tube, trajs[i])
                         for i in range(n_test)])
        cov, lo, hi = empirical_coverage(hits)
        return cov, tube[-1].volume()

    def fairbox_cov_vol(t):
        c, hlv = propagate_fair_box_tube(A, E0.q, half0, w_center, w_half, H,
                                         w_scale=t)
        hits = np.array([box_contains_traj(c, hlv, trajs[i])
                         for i in range(n_test)])
        cov, lo, hi = empirical_coverage(hits)
        return cov, float(np.prod(2.0 * hlv[-1]))

    # target realized coverage = ellipsoid tube at nominal (s = 1)
    target_cov, ell_vol = ell_cov_vol(1.0)

    # equalize the fair box DOWN to target_cov by bisection on the scale t.
    # t=1 is the nominal fair box (over-covers); shrink until coverage <= target.
    lo, hi = 0.2, 1.0
    if fairbox_cov_vol(lo)[0] > target_cov:
        # even the smallest scale over-covers: report at lo
        t = lo
    else:
        for _ in range(40):
            mid = 0.5 * (lo + hi)
            cov, _ = fairbox_cov_vol(mid)
            if cov > target_cov:
                hi = mid
            else:
                lo = mid
        t = 0.5 * (lo + hi)
    fair_cov, fair_vol = fairbox_cov_vol(t)

    return dict(
        domain=dom["name"], d=d, H=H, alpha=alpha, nominal=1 - alpha,
        equalized_coverage_target=target_cov,
        ell_coverage=target_cov, ell_volume=ell_vol,
        fair_box_scale=t, fair_box_coverage=fair_cov, fair_box_volume=fair_vol,
        vol_ratio_ell_over_fairbox=(ell_vol / fair_vol
                                    if fair_vol > 0 else float("nan")),
        n_test=n_test,
    )


# ---------------------------------------------------------------------------
# Per-timestep quantile tube (the closest prior-art baseline: distribution-free
# trajectory-prediction tubes a la Lindemann et al., and data-driven
# reachability).  Instead of propagating a one-step set through the dynamics,
# this baseline calibrates a SEPARATE Mahalanobis conformal ellipsoid at every
# horizon step k directly from calibration TRAJECTORIES (per-step deviations),
# with a Bonferroni-over-horizon level alpha/H so the joint tube covers
# >= 1-alpha.  It needs calibration data at every step and gives no
# closed-form / composable propagation.  We report its realized coverage and
# final-step volume against the propagated ellipsoidal tube to quantify what
# set arithmetic buys (compact single-shot propagation from ONE one-step
# calibration, not smaller volume).
# ---------------------------------------------------------------------------
def per_step_quantile_tube_comparison(dom: dict, alpha: float, seed: int = 123,
                                      trajs=None):
    A, H, d = dom["A"], dom["H"], dom["d"]
    E0 = conformalize_initial_set(dom["x0_samples"], alpha)
    dirs = direction_family(d)
    res_fit, res_calib, _ = split_three(dom["residuals"], seed)

    # propagated ellipsoidal tube (our method) at nominal
    maha = MahalanobisConformal(center=True).fit(res_fit)
    maha.calibrate(res_calib, alpha)
    ell_tube = propagate_tube(A, E0, maha.error_ellipsoid(), H, dirs)

    # per-step quantile tube: fit + calibrate an ellipsoid per step from
    # calibration trajectories (disjoint from the test set).
    n_cal = 6000
    cal_trajs = dom["sample_trajectories"](n_cal)
    per_step = []
    for k in range(1, H + 1):
        Rk = cal_trajs[:, k, :]
        cp = MahalanobisConformal(center=True).fit(Rk)
        cp.calibrate(Rk, alpha / H)  # Bonferroni over horizon for joint tube
        per_step.append(cp)

    if trajs is None:
        trajs = dom["sample_trajectories"](8000)
    n_test = trajs.shape[0]

    ell_hits = np.array([ellipsoid_contains_traj(ell_tube, trajs[i])
                         for i in range(n_test)])
    ps_hit = np.ones(n_test, bool)
    for i, cp in enumerate(per_step, start=1):
        ps_hit &= cp.contains(trajs[:, i, :])
    ell_cov, _, _ = empirical_coverage(ell_hits)
    ps_cov, ps_lo, ps_hi = empirical_coverage(ps_hit)

    ell_final_vol = ell_tube[-1].volume()
    ps_final_vol = per_step[-1].error_ellipsoid().volume()
    return dict(
        domain=dom["name"], d=d, H=H, alpha=alpha, nominal=1 - alpha,
        propagated_ell_coverage=ell_cov,
        propagated_ell_final_volume=ell_final_vol,
        perstep_quantile_coverage=ps_cov,
        perstep_quantile_ci_lo=ps_lo, perstep_quantile_ci_hi=ps_hi,
        perstep_quantile_final_volume=ps_final_vol,
        vol_ratio_propagated_over_perstep=(ell_final_vol / ps_final_vol
                                           if ps_final_vol > 0
                                           else float("nan")),
        n_test=n_test,
    )


def calibration_curve(dom: dict, alphas: np.ndarray, seed: int = 123):
    """Realized ell/box coverage across a grid of nominal levels."""
    rows = []
    for a in alphas:
        _, s = run_domain(dom, float(a), seed=seed)
        rows.append(dict(
            domain=dom["name"], nominal=1 - a,
            ell_coverage=s["ell_coverage"], box_coverage=s["box_coverage"],
            ell_ci_lo=s["ell_ci_lo"], ell_ci_hi=s["ell_ci_hi"],
            box_ci_lo=s["box_ci_lo"], box_ci_hi=s["box_ci_hi"],
        ))
    return rows


# ---------------------------------------------------------------------------
# set_membership demo (estimation dual) using minkdiff_int
# ---------------------------------------------------------------------------
def set_membership_demo(seed: int = 5):
    """Guaranteed-INNER consistent state set via ellipsoidal Minkowski erosion.

    Model: we observe y = x + v with an ellipsoidal measurement-error model
    V = E(0, Qv). Given a prior state set X = E(qx, Qx), the set of states
    consistent with the observation and the error model is (a sound inner
    approximation of) the erosion  X ⊖ V, computed with minkdiff_int -- the
    estimation dual of the prediction-tube Minkowski SUM. The eroded set is
    the guaranteed-feasible region an estimator may certify.
    """
    rng = np.random.default_rng(seed)
    d = 2
    # prior state set (large, correlated)
    Mx = rng.standard_normal((d, d))
    Qx = Mx @ Mx.T + 0.5 * np.eye(d)
    X = Ellipsoid(np.array([0.3, -0.2]), Qx)
    # measurement error set (smaller, must be enclosed by X for a nonempty diff)
    Qv = 0.15 * Qx  # co-shaped, smaller -> erosion is nonempty in many dirs
    V = Ellipsoid(np.zeros(d), Qv)

    dirs = direction_family(d, n_extra=20, seed=9)
    inner = None
    inner_vol = -np.inf
    n_valid = 0
    for l in dirs:
        Ed = minkdiff_int(X, V, l)
        if Ed is not None:
            n_valid += 1
            v = Ed.volume()
            if v > inner_vol:  # pick the LARGEST guaranteed-inner (best certified)
                inner_vol = v
                inner = Ed

    # Soundness of the erosion (definition of Minkowski/geometric difference):
    #   for every s in (X ⊖ V) and every v in V, we must have s + v in X.
    # The kernel diff subtracts centers (inner.q = X.q - V.q); reconstruct the
    # erosion centered so that (X ⊖ V) ⊕ V ⊆ X holds about X's center.
    ok = True
    n_check = 0
    if inner is not None:
        # recenter the erosion about (X.q - V.q) as returned; test s + v in X.
        for _ in range(3000):
            u = rng.standard_normal(d)
            u = u / np.linalg.norm(u) * rng.uniform(0.0, 1.0) ** (1.0 / d)
            s = inner.q + sqrtm_apply(inner.Q, u)      # s in X ⊖ V
            uv = rng.standard_normal(d)
            uv = uv / np.linalg.norm(uv) * rng.uniform(0.0, 1.0) ** (1.0 / d)
            vv = V.q + sqrtm_apply(V.Q, uv)            # v in V
            n_check += 1
            if not X.contains(s + vv):                 # require s + v in X
                ok = False
                break

    return dict(
        prior_volume=X.volume(),
        meas_error_volume=V.volume(),
        inner_consistent_volume=(inner.volume() if inner else float("nan")),
        n_valid_directions=n_valid, n_directions=len(dirs),
        erosion_sound=ok,
    )


def sqrtm_apply(Q, u):
    from ellreach import sqrtm_pos
    return sqrtm_pos(Q) @ u


# ---------------------------------------------------------------------------
# Honest failure-regime analysis: one-step efficiency of a SINGLE Mahalanobis
# ellipsoid vs a two-component MIXTURE oracle on the bimodal (non-elliptical)
# residuals. A single ellipsoid must span both modes at matched coverage and
# therefore contains a large dead zone between them; the mixture is far
# smaller. This is the regime where static ellipsoidal CP is "crowded".
# ---------------------------------------------------------------------------
def failure_regime_analysis(alpha: float = 0.1, seed: int = 123):
    dom = domain_multimodal_failure()
    res_fit, res_calib, res_test = split_three(dom["residuals"], seed)
    d = dom["d"]

    # ---- single Mahalanobis ellipsoid one-step region ----
    maha = MahalanobisConformal(center=True).fit(res_fit)
    maha.calibrate(res_calib, alpha)
    W_ell = maha.error_ellipsoid()
    ell_area = W_ell.volume()  # 2-D "volume" = area
    ell_cov = maha.contains(res_test).mean()

    # ---- mixture oracle: fit 2 comps (k-means-lite via median split on x) ----
    # assign each residual to nearest mode using the fit split, then per-comp
    # Mahalanobis-calibrate on the calib split at a Bonferroni-per-component
    # level so the union attains >= 1-alpha coverage.
    split_axis = 0
    thr = np.median(res_fit[:, split_axis])
    comp_masks_fit = [res_fit[:, split_axis] >= thr, res_fit[:, split_axis] < thr]
    comp_masks_cal = [res_calib[:, split_axis] >= thr, res_calib[:, split_axis] < thr]

    mix_regions = []
    for mf, mc in zip(comp_masks_fit, comp_masks_cal):
        cp = MahalanobisConformal(center=True).fit(res_fit[mf])
        # per-component level so union coverage ~ 1-alpha (two comps -> alpha/1
        # each roughly; use alpha directly per comp, union coverage is higher).
        cp.calibrate(res_calib[mc], alpha)
        mix_regions.append(cp)
    # mixture area = sum of component ellipsoid areas (modes are separated, so
    # overlap is negligible -> this is a tight estimate of the union area).
    mix_area = 0.0
    for cp in mix_regions:
        mix_area += cp.error_ellipsoid().volume()
    # mixture coverage on test = in ANY component region
    mix_hit = np.zeros(res_test.shape[0], dtype=bool)
    for cp in mix_regions:
        mix_hit |= cp.contains(res_test)
    mix_cov = mix_hit.mean()

    return dict(
        domain="D_multimodal_failure_onestep", alpha=alpha, nominal=1 - alpha,
        single_ellipsoid_area=ell_area, single_ellipsoid_coverage=float(ell_cov),
        mixture_oracle_area=mix_area, mixture_oracle_coverage=float(mix_cov),
        area_ratio_ellipsoid_over_mixture=(ell_area / mix_area
                                           if mix_area > 0 else float("nan")),
    )


# ---------------------------------------------------------------------------
# CSV writers
# ---------------------------------------------------------------------------
def write_csv(path, rows, fieldnames=None):
    if not rows:
        return
    fieldnames = fieldnames or list(rows[0].keys())
    with open(path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        for r in rows:
            w.writerow(r)


def union_bound_row(summ: dict) -> dict:
    """Realized ellipsoidal coverage vs the horizon union bound 1 - (H+1)*alpha.

    The propagated tube is a probabilistic conformal region built from H+1
    split-conformal sets: the CONFORMALIZED initial set E0 (which contains x0
    with prob >= 1-alpha) plus H one-step error sets W (each containing its
    one-step error with prob >= 1-alpha).  Conditioned on ALL H+1 events, the
    whole trajectory lies in the tube, so the union bound over H+1 events gives
    P(traj in tube) >= 1 - (H+1)*alpha.  We report this bound alongside realized
    coverage and the measured initial-set escape probability P(x0 not in E0).
    Note the bound can be vacuous (< 0) for large (H+1)*alpha; realized coverage
    is far tighter."""
    H = summ["H"]
    alpha = summ["alpha"]
    bound = 1.0 - (H + 1) * alpha
    return dict(
        domain=summ["domain"], d=summ["d"], H=H, alpha=alpha,
        nominal_per_step=1 - alpha,
        union_bound_1_minus_Hplus1_alpha=bound,
        e0_coverage=summ["e0_coverage"],
        e0_escape_prob=summ["e0_escape_prob"],
        realized_ell_coverage=summ["ell_coverage"],
        realized_ell_ci_lo=summ["ell_ci_lo"],
        realized_ell_ci_hi=summ["ell_ci_hi"],
        realized_exceeds_union_bound=bool(summ["ell_ci_lo"] >= bound),
        realized_exceeds_per_step_nominal=bool(summ["ell_ci_lo"] >= 1 - alpha),
    )


def main():
    alpha = 0.1  # nominal 90% headline level
    domains = [
        domain_linear_correlated(),
        domain_learned_surrogate(),
        domain_var_timeseries(),
        domain_multimodal_failure(),
    ]
    correlated_domains = [d for d in domains if d["correlated"]]

    # one shared fresh test set per domain, reused across every analysis so the
    # coverage numbers are mutually consistent.
    test_sets = {d["name"]: d["sample_trajectories"](8000) for d in domains}

    volume_rows = []
    summary_rows = []
    union_rows = []
    for dom in domains:
        recs, summ = run_domain(dom, alpha, trajs=test_sets[dom["name"]])
        volume_rows.extend(recs)
        summary_rows.append(summ)
        union_rows.append(union_bound_row(summ))
        print(f"[{dom['name']:24s}] nominal={1 - alpha:.2f}  "
              f"ell_cov={summ['ell_coverage']:.4f} "
              f"[{summ['ell_ci_lo']:.4f},{summ['ell_ci_hi']:.4f}]  "
              f"box_cov(iv)={summ['box_coverage']:.4f}  "
              f"fairbox_cov={summ['fair_box_coverage']:.4f}  "
              f"vol_ratio(ell/ivbox)_final={summ['vol_ratio_final']:.4f}")

    write_csv(os.path.join(RESULTS, "tube_volumes.csv"), volume_rows)
    write_csv(os.path.join(RESULTS, "coverage_summary.csv"), summary_rows)
    write_csv(os.path.join(RESULTS, "coverage_vs_union_bound.csv"), union_rows)

    # ---- FAIR baseline: wrapping vs shape decomposition (correlated domains) ----
    decomp_rows = []
    for dom in correlated_domains:
        dr = wrapping_shape_decomposition(dom, alpha)
        decomp_rows.append(dr)
        print(f"[decomp {dom['name']:16s}] one-step W ell/box={dr['onestep_ratio_ell_over_box']:.3f}  "
              f"final: ivbox={dr['final_interval_box_volume']:.2f} "
              f"fairbox={dr['final_fair_box_volume']:.2f} ell={dr['final_ell_volume']:.2f}  "
              f"wrapping={dr['wrapping_factor_interval_over_fair']:.2f}x  "
              f"shape(fairbox/ell)={dr['shape_factor_fairbox_over_ell']:.2f}x  "
              f"shape(ellbbox/ell)={dr['shape_factor_ellbbox_over_ell']:.2f}x")
    write_csv(os.path.join(RESULTS, "wrapping_shape_decomposition.csv"), decomp_rows)

    # ---- volume at EQUALIZED realized coverage (ell vs fair box) ----
    eq_rows = []
    for dom in correlated_domains:
        eq = equalized_coverage_comparison(dom, alpha,
                                           trajs=test_sets[dom["name"]])
        eq_rows.append(eq)
        print(f"[eqcov {dom['name']:16s}] target_cov={eq['equalized_coverage_target']:.4f}  "
              f"ell_vol={eq['ell_volume']:.3f}  "
              f"fairbox_vol@t={eq['fair_box_scale']:.3f}={eq['fair_box_volume']:.3f} "
              f"(cov={eq['fair_box_coverage']:.4f})  "
              f"ratio ell/fairbox={eq['vol_ratio_ell_over_fairbox']:.3f}")
    write_csv(os.path.join(RESULTS, "equalized_coverage.csv"), eq_rows)

    # ---- per-timestep quantile tube (closest prior art) comparison ----
    ps_rows = []
    for dom in correlated_domains:
        ps = per_step_quantile_tube_comparison(dom, alpha,
                                               trajs=test_sets[dom["name"]])
        ps_rows.append(ps)
        print(f"[perstep {dom['name']:14s}] propagated ell cov={ps['propagated_ell_coverage']:.4f} "
              f"vol={ps['propagated_ell_final_volume']:.3f}  |  "
              f"per-step quantile cov={ps['perstep_quantile_coverage']:.4f} "
              f"vol={ps['perstep_quantile_final_volume']:.3f}  "
              f"ratio prop/perstep={ps['vol_ratio_propagated_over_perstep']:.3f}")
    write_csv(os.path.join(RESULTS, "perstep_quantile_tube.csv"), ps_rows)

    # calibration curves across nominal grid (use the 3 primary domains + failure)
    alphas = np.array([0.30, 0.20, 0.15, 0.10, 0.05, 0.02])
    calib_rows = []
    for dom in domains:
        calib_rows.extend(calibration_curve(dom, alphas))
    write_csv(os.path.join(RESULTS, "calibration_curve.csv"), calib_rows)

    # honest failure regime: single ellipsoid vs mixture oracle on bimodal data
    fr = failure_regime_analysis(alpha)
    write_csv(os.path.join(RESULTS, "failure_regime.csv"), [fr])
    print(f"[failure_regime ] single-ellipsoid area={fr['single_ellipsoid_area']:.4f} "
          f"(cov={fr['single_ellipsoid_coverage']:.3f})  "
          f"mixture area={fr['mixture_oracle_area']:.4f} "
          f"(cov={fr['mixture_oracle_coverage']:.3f})  "
          f"area_ratio(ell/mix)={fr['area_ratio_ellipsoid_over_mixture']:.3f}")

    # set-membership demo
    sm = set_membership_demo()
    write_csv(os.path.join(RESULTS, "set_membership_demo.csv"), [sm])
    print(f"[set_membership ] prior_vol={sm['prior_volume']:.4f} "
          f"inner_consistent_vol={sm['inner_consistent_volume']:.4f} "
          f"sound={sm['erosion_sound']} "
          f"({sm['n_valid_directions']}/{sm['n_directions']} dirs valid)")

    print("\nWrote:", ", ".join(sorted(os.listdir(RESULTS))))


if __name__ == "__main__":
    main()
