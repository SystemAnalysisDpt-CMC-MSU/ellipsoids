"""
conformal - split-conformal calibration primitives for ellreach prediction tubes.

Provides the per-step nonconformity primitives used by Paper 3
(Conformalized Ellipsoidal Reach Tubes):

  * MahalanobisConformal  -- correlation-aware ellipsoidal error set
        W = { w : (w - mu)^T Sigma^{-1} (w - mu) <= q_{1-alpha} },
    where Sigma is estimated on a fit split of residuals and q_{1-alpha}
    is the conformal (finite-sample-corrected) empirical quantile of the
    Mahalanobis scores on a *disjoint* calibration split.

  * BoxConformal          -- coordinate-wise (box) baseline that discards
    off-diagonal correlation: per-coordinate absolute-residual quantiles.

Both are calibrated distribution-free: with n calibration points and
level 1 - alpha, the split-conformal quantile index
    k = ceil((n + 1) * (1 - alpha))
guarantees marginal coverage >= 1 - alpha on an exchangeable held-out point
(Vovk et al. 2005; Lei et al. 2018). The Mahalanobis variant follows the
ellipsoidal-CP construction (Johnstone & Cox 2021; Messoudi et al. 2022):
the shape comes from Sigma, the *radius* is conformalized.

The ellipsoidal error set is returned as an ``ellreach.Ellipsoid`` so it can
be fed directly into the kernel's Minkowski algebra for dynamical propagation.
"""
from __future__ import annotations

import numpy as np

from ellreach import Ellipsoid

__all__ = [
    "conformal_quantile_index",
    "MahalanobisConformal",
    "BoxConformal",
    "empirical_coverage",
]


def conformal_quantile_index(n_calib: int, alpha: float) -> int:
    """1-based rank k = ceil((n+1)(1-alpha)) of the split-conformal quantile.

    Returns min(k, n) so the index is always attainable (when
    (n+1)(1-alpha) > n the conformal set is the whole space; we clamp to the
    largest observed score, the standard finite-sample behaviour).
    """
    if not 0.0 < alpha < 1.0:
        raise ValueError("alpha must be in (0, 1)")
    if n_calib < 1:
        raise ValueError("need at least one calibration residual")
    k = int(np.ceil((n_calib + 1) * (1.0 - alpha)))
    return min(k, n_calib)


def _kth_smallest(scores: np.ndarray, k: int) -> float:
    """Value of the k-th smallest (1-based) entry of ``scores``."""
    ordered = np.sort(np.asarray(scores, float).reshape(-1))
    return float(ordered[k - 1])


class MahalanobisConformal:
    """Split-conformal Mahalanobis (ellipsoidal) one-step error set.

    Parameters
    ----------
    center : bool
        If True, subtract the fit-split residual mean (so the ellipsoid is
        centred on the estimated bias). If False the ellipsoid is centred at
        the origin (assumes an unbiased surrogate).
    ridge : float
        Diagonal loading added to the empirical covariance for numerical
        stability (relative to the mean variance).
    """

    def __init__(self, center: bool = True, ridge: float = 1e-9):
        self.center = center
        self.ridge = float(ridge)
        self.mu_: np.ndarray | None = None
        self.Sigma_: np.ndarray | None = None
        self.Sigma_inv_: np.ndarray | None = None
        self.dim_: int | None = None

    def fit(self, res_fit: np.ndarray) -> "MahalanobisConformal":
        """Estimate mean/covariance on the *fit* residual split (m x d)."""
        R = np.atleast_2d(np.asarray(res_fit, float))
        m, d = R.shape
        if m < d + 1:
            raise ValueError(
                f"need >= dim+1={d + 1} fit residuals to estimate covariance, got {m}"
            )
        self.mu_ = R.mean(axis=0) if self.center else np.zeros(d)
        Rc = R - self.mu_
        Sigma = (Rc.T @ Rc) / (m - 1)
        Sigma = 0.5 * (Sigma + Sigma.T)
        # relative ridge keeps conditioning without distorting scale
        Sigma = Sigma + self.ridge * np.trace(Sigma) / d * np.eye(d)
        self.Sigma_ = Sigma
        self.Sigma_inv_ = np.linalg.inv(Sigma)
        self.dim_ = d
        return self

    def scores(self, res: np.ndarray) -> np.ndarray:
        """Mahalanobis scores s_i = sqrt((r_i - mu)^T Sigma^{-1} (r_i - mu))."""
        if self.Sigma_inv_ is None:
            raise RuntimeError("fit() must be called before scores()")
        R = np.atleast_2d(np.asarray(res, float))
        Rc = R - self.mu_
        quad = np.einsum("ij,jk,ik->i", Rc, self.Sigma_inv_, Rc)
        return np.sqrt(np.clip(quad, 0.0, None))

    def calibrate(self, res_calib: np.ndarray, alpha: float) -> float:
        """Conformal radius = k-th smallest Mahalanobis score on calib split.

        Returns the radius ``r`` s.t. the error set is
        { w : (w-mu)^T Sigma^{-1} (w-mu) <= r^2 }.
        """
        s = self.scores(res_calib)
        k = conformal_quantile_index(s.shape[0], alpha)
        self.radius_ = _kth_smallest(s, k)
        self.alpha_ = float(alpha)
        return self.radius_

    def error_ellipsoid(self, radius: float | None = None) -> Ellipsoid:
        """Return the calibrated one-step error set as an ``Ellipsoid``.

        E(mu, r^2 * Sigma) because the level set
        (w-mu)^T Sigma^{-1} (w-mu) <= r^2 equals
        { mu + (r^2 Sigma)^{1/2} u : ||u|| <= 1 }.
        """
        if self.Sigma_ is None:
            raise RuntimeError("fit() must be called before error_ellipsoid()")
        r = self.radius_ if radius is None else float(radius)
        return Ellipsoid(self.mu_.copy(), (r ** 2) * self.Sigma_)

    def contains(self, res: np.ndarray, radius: float | None = None) -> np.ndarray:
        """Boolean membership of residual rows in the calibrated set."""
        r = self.radius_ if radius is None else float(radius)
        return self.scores(res) <= r + 1e-12


class BoxConformal:
    """Coordinate-wise (box) split-conformal baseline.

    Per coordinate j, the half-width h_j is the conformal quantile of the
    absolute centred residuals |r_ij - mu_j|; the region is the axis-aligned
    box prod_j [mu_j - h_j, mu_j + h_j]. This is the standard multi-output
    split-CP baseline and, being axis-aligned, discards error correlation.
    """

    def __init__(self, center: bool = True):
        self.center = center
        self.mu_: np.ndarray | None = None
        self.half_: np.ndarray | None = None
        self.dim_: int | None = None

    def fit(self, res_fit: np.ndarray) -> "BoxConformal":
        R = np.atleast_2d(np.asarray(res_fit, float))
        self.mu_ = R.mean(axis=0) if self.center else np.zeros(R.shape[1])
        self.dim_ = R.shape[1]
        return self

    def calibrate(self, res_calib: np.ndarray, alpha: float) -> np.ndarray:
        """Per-coordinate half-widths via the conformal quantile index.

        Uses a Bonferroni-corrected per-coordinate level so the *joint* box
        attains >= 1-alpha coverage: each coordinate is calibrated at
        1 - alpha/d. This is the honest apples-to-apples baseline for a
        joint-coverage comparison against the (joint) Mahalanobis set.
        """
        if self.mu_ is None:
            raise RuntimeError("fit() must be called before calibrate()")
        R = np.atleast_2d(np.asarray(res_calib, float))
        n, d = R.shape
        abs_res = np.abs(R - self.mu_)
        alpha_j = alpha / d  # Bonferroni for joint coverage
        k = conformal_quantile_index(n, alpha_j)
        self.half_ = np.array([_kth_smallest(abs_res[:, j], k) for j in range(d)])
        self.alpha_ = float(alpha)
        return self.half_

    def calibrate_marginal(self, res_calib: np.ndarray, alpha: float) -> np.ndarray:
        """Per-coordinate half-widths at the *marginal* level 1-alpha (no
        Bonferroni). Used for per-coordinate (marginal) coverage checks."""
        if self.mu_ is None:
            raise RuntimeError("fit() must be called before calibrate_marginal()")
        R = np.atleast_2d(np.asarray(res_calib, float))
        n, d = R.shape
        abs_res = np.abs(R - self.mu_)
        k = conformal_quantile_index(n, alpha)
        self.half_ = np.array([_kth_smallest(abs_res[:, j], k) for j in range(d)])
        self.alpha_ = float(alpha)
        return self.half_

    def error_box(self) -> tuple[np.ndarray, np.ndarray]:
        """Return (center mu, half-widths h)."""
        if self.half_ is None:
            raise RuntimeError("calibrate() must be called before error_box()")
        return self.mu_.copy(), self.half_.copy()

    def error_ellipsoid_enclosing(self) -> Ellipsoid:
        """Smallest-in-scale axis-aligned ellipsoid ENCLOSING the box (for a
        volume-comparable object). The box [mu +- h] is inscribed in the
        ellipsoid with Q = diag((sqrt(d) * h)^2)."""
        if self.half_ is None:
            raise RuntimeError("calibrate() must be called before this")
        d = self.dim_
        Q = np.diag((np.sqrt(d) * self.half_) ** 2)
        return Ellipsoid(self.mu_.copy(), Q)

    def box_volume(self) -> float:
        """Volume of the calibrated box = prod_j (2 h_j)."""
        if self.half_ is None:
            raise RuntimeError("calibrate() must be called before box_volume()")
        return float(np.prod(2.0 * self.half_))

    def contains(self, res: np.ndarray) -> np.ndarray:
        if self.half_ is None:
            raise RuntimeError("calibrate() must be called before contains()")
        R = np.atleast_2d(np.asarray(res, float))
        inside = np.all(np.abs(R - self.mu_) <= self.half_ + 1e-12, axis=1)
        return inside


def empirical_coverage(hits: np.ndarray) -> tuple[float, float, float]:
    """Realized coverage with a Wilson 95% CI.

    Parameters
    ----------
    hits : boolean array (True = point inside region)

    Returns
    -------
    (coverage, ci_lo, ci_hi)
    """
    hits = np.asarray(hits, bool).reshape(-1)
    n = hits.shape[0]
    if n == 0:
        return (float("nan"), float("nan"), float("nan"))
    p = float(hits.mean())
    z = 1.959963984540054  # 95%
    denom = 1.0 + z * z / n
    centre = (p + z * z / (2 * n)) / denom
    half = (z / denom) * np.sqrt(p * (1 - p) / n + z * z / (4 * n * n))
    return (p, max(0.0, centre - half), min(1.0, centre + half))


# ---------------------------------------------------------------------------
# Self-test: marginal one-step coverage ~= 1 - alpha on held-out residuals.
# Runnable standalone AND pytest-collectable.
# ---------------------------------------------------------------------------
def test_mahalanobis_marginal_coverage():
    """Held-out one-step coverage of the Mahalanobis set is >= 1-alpha (up to
    finite-sample slack) across correlated Gaussian residuals."""
    rng = np.random.default_rng(0)
    d = 3
    # strongly correlated residual covariance
    Araw = rng.standard_normal((d, d))
    Sigma_true = Araw @ Araw.T + 0.3 * np.eye(d)
    L = np.linalg.cholesky(Sigma_true)
    alpha = 0.1
    covs = []
    for _ in range(40):
        fit = (L @ rng.standard_normal((d, 2000))).T
        calib = (L @ rng.standard_normal((d, 2000))).T
        test = (L @ rng.standard_normal((d, 5000))).T
        cp = MahalanobisConformal(center=True).fit(fit)
        cp.calibrate(calib, alpha)
        covs.append(cp.contains(test).mean())
    mean_cov = float(np.mean(covs))
    # exact-exchangeability lower bound (allow small MC slack)
    assert mean_cov >= (1.0 - alpha) - 0.01, f"coverage {mean_cov:.4f} < {1 - alpha}"
    # not grossly over-covering (Mahalanobis is tight for Gaussian residuals)
    assert mean_cov <= (1.0 - alpha) + 0.03, f"coverage {mean_cov:.4f} too high"


def test_box_joint_coverage():
    """Bonferroni box attains >= 1-alpha joint coverage on held-out residuals."""
    rng = np.random.default_rng(1)
    d = 3
    Araw = rng.standard_normal((d, d))
    Sigma_true = Araw @ Araw.T + 0.3 * np.eye(d)
    L = np.linalg.cholesky(Sigma_true)
    alpha = 0.1
    covs = []
    for _ in range(40):
        fit = (L @ rng.standard_normal((d, 2000))).T
        calib = (L @ rng.standard_normal((d, 2000))).T
        test = (L @ rng.standard_normal((d, 5000))).T
        box = BoxConformal(center=True).fit(fit)
        box.calibrate(calib, alpha)
        covs.append(box.contains(test).mean())
    mean_cov = float(np.mean(covs))
    assert mean_cov >= (1.0 - alpha) - 0.01, f"box coverage {mean_cov:.4f} < {1 - alpha}"


def test_quantile_index_bounds():
    assert conformal_quantile_index(100, 0.1) == 91   # ceil(101*0.9)=91
    assert conformal_quantile_index(9, 0.1) == 9       # ceil(10*0.9)=9
    assert conformal_quantile_index(5, 0.01) == 5      # clamped to n


if __name__ == "__main__":
    test_quantile_index_bounds()
    test_mahalanobis_marginal_coverage()
    test_box_joint_coverage()
    print("ALL CONFORMAL SELF-TESTS PASSED")
