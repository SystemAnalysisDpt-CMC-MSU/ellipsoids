"""
Soundness oracle for neural gauge scheduling: the gauge step is a sound outer
bound of (A E) ⊕ W for ANY beta>0 (structural soundness, independent of the
policy weights). Also checks the policy always emits beta>0 and myopic tightness.
"""
import numpy as np
from ellreach import Ellipsoid, sqrtm_pos
from ell_gauge import gauge_step, myopic_beta, GaugePolicy, features

rng = np.random.default_rng(3)


def _rand_sys():
    th = rng.uniform(0.2, 1.2); rho = rng.uniform(0.8, 0.95)
    A = rho * np.array([[np.cos(th), -np.sin(th)], [np.sin(th), np.cos(th)]])
    M = rng.standard_normal((2, 2)); W = Ellipsoid(np.zeros(2), M@M.T + 0.02*np.eye(2))
    E = Ellipsoid(rng.standard_normal(2), np.diag(rng.uniform(0.05, 0.4, 2)))
    return A, E, W


def test_gauge_step_sound_for_any_beta():
    """Q_beta must dominate the true support of (A E)⊕W in every direction, for
    arbitrary beta>0 (the structural soundness invariant the learning relies on)."""
    for _ in range(60):
        A, E, W = _rand_sys()
        AE = Ellipsoid(A @ E.q, A @ E.Q @ A.T)         # exact affine image
        for beta in (1e-3, 0.1, 0.5, 1.0, 3.0, 50.0, rng.uniform(0.01, 20)):
            G = gauge_step(E, A, W, beta)
            for _ in range(50):
                d = rng.standard_normal(2)
                assert G.rho(d) + 1e-9 >= AE.rho(d) + W.rho(d), "gauge step not sound"


def test_gauge_step_contains_sampled_sum():
    A, E, W = _rand_sys()
    LAE = sqrtm_pos(A @ E.Q @ A.T); LW = sqrtm_pos(W.Q)
    for beta in (0.05, 1.0, 10.0):
        G = gauge_step(E, A, W, beta)
        for _ in range(2000):
            ua = rng.standard_normal(2); ua = ua/max(np.linalg.norm(ua),1e-9)*rng.uniform(0,1)
            uw = rng.standard_normal(2); uw = uw/max(np.linalg.norm(uw),1e-9)*rng.uniform(0,1)
            x = (A @ E.q + LAE @ ua) + (W.q + LW @ uw)
            assert G.contains(x, tol=1e-9)


def test_policy_always_positive_beta():
    pol = GaugePolicy(seed=1)
    for _ in range(200):
        A, E, W = _rand_sys()
        for theta in (pol.theta, 5.0*rng.standard_normal(pol.n), np.zeros(pol.n)):
            b = pol.beta(features(E, A, W, 2, 8), theta)
            assert b > 0.0 and np.isfinite(b), "policy emitted non-positive/inf beta"


def test_myopic_beta_tight_along_direction():
    A, E, W = _rand_sys()
    l = np.array([1.0, 0.4]); l /= np.linalg.norm(l)
    b = myopic_beta(E, A, W, l)
    G = gauge_step(E, A, W, b)
    AE = Ellipsoid(A @ E.q, A @ E.Q @ A.T)
    # tight along l: support equals sum of supports (KV tangency)
    assert np.isclose(G.rho(l), AE.rho(l) + W.rho(l), rtol=1e-8, atol=1e-8)
