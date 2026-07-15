"""
Smoke test for the ellreach PoC (pytest-collectable and runnable standalone).
Full oracle coverage lives in oracle_tests/test_kernel.py.
"""
import numpy as np
from ellreach import Ellipsoid, minksum_ext, reach_tube_lti_discrete


def test_ball_support_fn():
    B = Ellipsoid.ball([1.0, -2.0], 3.0)
    l = np.array([0.6, 0.8])
    assert np.isclose(B.rho(l), l @ B.q + 3.0)


def test_kv_tightness_identity():
    rng = np.random.default_rng(0)
    for _ in range(200):
        n = 3
        M1 = rng.standard_normal((n, n)); Q1 = M1 @ M1.T + 0.1 * np.eye(n)
        M2 = rng.standard_normal((n, n)); Q2 = M2 @ M2.T + 0.1 * np.eye(n)
        E1 = Ellipsoid(rng.standard_normal(n), Q1)
        E2 = Ellipsoid(rng.standard_normal(n), Q2)
        ld = rng.standard_normal(n)
        Es = minksum_ext(E1, E2, ld)
        assert np.isclose(Es.rho(ld), E1.rho(ld) + E2.rho(ld), rtol=1e-10, atol=1e-10)


def test_reach_tube_bounded_and_sound():
    rng = np.random.default_rng(1)
    theta = 1.0
    R = 0.9 * np.array([[np.cos(theta), -np.sin(theta)],
                        [np.sin(theta),  np.cos(theta)]])
    E0 = Ellipsoid.ball([0.0, 0.0], 1.0)
    W = Ellipsoid.ball([0.0, 0.0], 0.2)
    dirs = [[1, 0], [0, 1], [1, 1], [1, -1]]
    N = 40
    tubes = reach_tube_lti_discrete(R, E0, W, dirs, N)
    assert all(np.isfinite(t[-1].volume()) and t[-1].volume() < 1e3 for t in tubes)
    for _ in range(200):
        x = E0.q + (E0.support_point(rng.standard_normal(2)) - E0.q) * rng.uniform(0, 1)
        for k in range(N + 1):
            for t in tubes:
                assert t[k].contains(x)
            w = W.q + (W.support_point(rng.standard_normal(2)) - W.q) * rng.uniform(0, 1)
            x = R @ x + w


if __name__ == "__main__":
    test_ball_support_fn()
    test_kv_tightness_identity()
    test_reach_tube_bounded_and_sound()
    print("ALL SMOKE CHECKS PASSED")
