"""Oracle tests for the zonotope baseline: exact support/Minkowski identities,
sound outer-approximation of ellipsoids, and sound Girard order reduction."""
import numpy as np
from zonotope import Zonotope, reach_tube_zonotope
from ellreach import Ellipsoid

rng = np.random.default_rng(7)


def test_support_exact_vs_vertices():
    """For a small zonotope, rho(Z,l) must equal max over the 2^p vertices."""
    c = np.array([1.0, -0.5])
    G = np.array([[1.0, 0.3, -0.2], [0.2, 0.8, 0.5]])
    Z = Zonotope(c, G)
    p = G.shape[1]
    verts = []
    for k in range(2 ** p):
        b = np.array([1.0 if (k >> i) & 1 else -1.0 for i in range(p)])
        verts.append(c + G @ b)
    verts = np.array(verts)
    for _ in range(200):
        l = rng.standard_normal(2)
        assert np.isclose(Z.rho(l), np.max(verts @ l), atol=1e-9)


def test_minksum_exact():
    """Zonotope Minkowski sum is exact: rho(Z1⊕Z2,l)=rho(Z1,l)+rho(Z2,l)."""
    Z1 = Zonotope([0, 0], np.array([[1.0, 0.2], [0.0, 1.0]]))
    Z2 = Zonotope([1, 0], np.array([[0.5], [0.5]]))
    S = Z1.minksum(Z2)
    for _ in range(200):
        l = rng.standard_normal(2)
        assert np.isclose(S.rho(l), Z1.rho(l) + Z2.rho(l), atol=1e-12)


def test_affine_exact():
    Z = Zonotope([1, 2], np.array([[1.0, 0.0], [0.0, 1.0]]))
    A = np.array([[2.0, 1.0], [-1.0, 3.0]]); b = np.array([1.0, -1.0])
    Za = Z.affine(A, b)
    for _ in range(100):
        l = rng.standard_normal(2)
        # rho(A Z + b, l) = <l,b> + rho(Z, A^T l)
        assert np.isclose(Za.rho(l), l @ b + Z.rho(A.T @ l), atol=1e-10)


def test_outer_of_ellipsoid_contains_ellipsoid():
    """Zonotope over-approx must dominate the ellipsoid support in all directions."""
    for _ in range(50):
        n = int(rng.integers(2, 5))
        M = rng.standard_normal((n, n)); Q = M @ M.T + 0.2 * np.eye(n)
        E = Ellipsoid(np.zeros(n), Q)
        Z = Zonotope.outer_of_ellipsoid(np.zeros(n), Q)
        for _ in range(100):
            l = rng.standard_normal(n)
            assert Z.rho(l) + 1e-9 >= E.rho(l)


def test_reduce_is_sound_outer():
    """Order reduction must only inflate: rho(reduced,l) >= rho(original,l)."""
    n = 3
    G = rng.standard_normal((n, 20))
    Z = Zonotope(np.zeros(n), G)
    Zr = Z.reduce(max_order=3)
    assert Zr.G.shape[1] <= 3 * n
    for _ in range(500):
        l = rng.standard_normal(n)
        assert Zr.rho(l) + 1e-9 >= Z.rho(l)


def test_reach_tube_exact_for_box_uncertainty():
    """With box X0 and box W, the zonotope tube support equals the exact
    reference rho_R(m)=rho(X0,(A^N)^T m)+sum_j rho(W,(A^j)^T m) (no wrapping)."""
    A = 0.9 * np.array([[np.cos(0.6), -np.sin(0.6)], [np.sin(0.6), np.cos(0.6)]])
    Z0 = Zonotope.box([0, 0], [1.0, 1.0])
    W = Zonotope.box([0, 0], [0.2, 0.1])
    N = 12
    tube = reach_tube_zonotope(A, Z0, W, N, max_order=None)  # no reduction -> exact
    ZN = tube[-1]
    for _ in range(200):
        m = rng.standard_normal(2)
        ref = Z0.rho(np.linalg.matrix_power(A, N).T @ m)
        for j in range(N):
            ref += W.rho(np.linalg.matrix_power(A, j).T @ m)
        assert np.isclose(ZN.rho(m), ref, atol=1e-9)
