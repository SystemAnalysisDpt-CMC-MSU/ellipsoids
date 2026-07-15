"""
Soundness self-test for nn_bounds (pytest-collectable and runnable standalone).

Proves by Monte-Carlo that for random inputs sampled from the input region,
the TRUE network output lies within every bound the module returns:
  * CROWN affine envelope  AL x + bL <= pi(x) <= AU x + bU
  * box relaxation         K x + d  (+) [d_lo, d_hi]
  * ellipsoid relaxation   K x + d  (+) Ellipsoid(0, D)
"""
import numpy as np

from nn_bounds import (
    ReLUMLP,
    crown_affine,
    relax_over_box,
    relax_over_ellipsoid,
)
from ellreach import Ellipsoid


def _nets():
    return [
        ReLUMLP.random([2, 8, 2], seed=1),
        ReLUMLP.random([2, 16, 8, 1], seed=2),
        ReLUMLP.random([4, 12, 12, 4], seed=3, scale=0.8),
        ReLUMLP.random([2, 6, 6, 6, 2], seed=4),
    ]


def test_crown_affine_soundness():
    rng = np.random.default_rng(10)
    for net in _nets():
        for _ in range(20):
            c = rng.standard_normal(net.n_in)
            r = rng.uniform(0.2, 1.5, size=net.n_in)
            lo, hi = c - r, c + r
            AL, bL, AU, bU = crown_affine(net, lo, hi)
            X = rng.uniform(lo, hi, size=(4000, net.n_in))
            Y = net.forward(X)
            low = X @ AL.T + bL
            up = X @ AU.T + bU
            assert np.all(Y >= low - 1e-7), "CROWN lower bound violated"
            assert np.all(Y <= up + 1e-7), "CROWN upper bound violated"


def test_box_relaxation_soundness():
    rng = np.random.default_rng(11)
    for net in _nets():
        for _ in range(20):
            c = rng.standard_normal(net.n_in)
            r = rng.uniform(0.2, 1.5, size=net.n_in)
            lo, hi = c - r, c + r
            rel = relax_over_box(net, lo, hi)
            X = rng.uniform(lo, hi, size=(4000, net.n_in))
            Y = net.forward(X)
            resid = Y - (X @ rel.K.T + rel.d)
            assert np.all(resid >= rel.d_lo - 1e-7), "box slack lower violated"
            assert np.all(resid <= rel.d_hi + 1e-7), "box slack upper violated"


def test_ellipsoid_relaxation_soundness():
    rng = np.random.default_rng(12)
    for net in _nets():
        for _ in range(15):
            c = rng.standard_normal(net.n_in)
            M = rng.standard_normal((net.n_in, net.n_in))
            Q = M @ M.T + 0.3 * np.eye(net.n_in)
            E = Ellipsoid(c, Q)
            rel = relax_over_ellipsoid(net, E)
            D = Ellipsoid(np.zeros(net.n_out), rel.D)
            # sample points strictly inside E
            S = np.linalg.cholesky(Q)
            u = rng.standard_normal((3000, net.n_in))
            u = u / np.maximum(np.linalg.norm(u, axis=1, keepdims=True), 1e-12)
            radii = rng.uniform(0.0, 1.0, size=(3000, 1)) ** (1.0 / net.n_in)
            X = c + (u * radii) @ S.T
            Y = net.forward(X)
            resid = Y - (X @ rel.K.T + rel.d)
            # residual must lie in the slack ellipsoid D (centered at 0)
            for k in range(0, 3000, 7):
                assert D.contains(resid[k], tol=1e-9), "ell slack violated"


if __name__ == "__main__":
    test_crown_affine_soundness()
    test_box_relaxation_soundness()
    test_ellipsoid_relaxation_soundness()
    print("NN-BOUNDS SOUNDNESS: ALL CHECKS PASSED")
