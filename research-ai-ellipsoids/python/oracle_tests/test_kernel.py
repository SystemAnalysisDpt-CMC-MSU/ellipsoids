"""
Oracle tests for the ellreach kernel. Correctness is checked against EXACT
analytic identities of Kurzhanski-Varaiya ellipsoidal calculus (tightness in the
support direction, containment ordering internal ⊆ true ⊆ external). These are
oracle-backed without needing a MATLAB run; where an ET etalon is later exported
it can be dropped into oracle_tests/etalons/ and compared the same way.
"""
import numpy as np
import pytest
from ellreach import (
    Ellipsoid, sqrtm_pos, orth_transl,
    minksum_ext, minksum_int, minksum_ext_multi, minksum_int_multi,
    minkdiff_ext, minkdiff_int,
    intersection_ext, reach_tube_lti_discrete, reach_tube_lti_discrete_tight,
)

rng = np.random.default_rng(12345)


def rand_ell(n, scale=1.0, center_scale=1.0):
    M = rng.standard_normal((n, n))
    Q = M @ M.T + 0.3 * np.eye(n)
    return Ellipsoid(center_scale * rng.standard_normal(n), scale * Q)


# --- helpers ---------------------------------------------------------------
def test_sqrtm_pos():
    for n in (2, 3, 5):
        E = rand_ell(n)
        S = sqrtm_pos(E.Q)
        assert np.allclose(S @ S, E.Q, atol=1e-9)
        assert np.allclose(S, S.T, atol=1e-12)


def test_orth_transl_is_orthogonal_and_aligns():
    for _ in range(100):
        n = rng.integers(2, 6)
        a = rng.standard_normal(n)
        b = rng.standard_normal(n)
        S = orth_transl(a, b)
        assert np.allclose(S @ S.T, np.eye(n), atol=1e-9)      # orthogonal
        assert np.isclose(abs(np.linalg.det(S)), 1.0, atol=1e-8)
        # S * unit(a) parallel to unit(b)
        Sa = S @ (a / np.linalg.norm(a))
        bb = b / np.linalg.norm(b)
        assert np.allclose(Sa, bb, atol=1e-7)


def test_orth_transl_antipodal():
    a = np.array([1.0, 0.0, 0.0])
    S = orth_transl(a, -a)
    assert np.allclose(S @ S.T, np.eye(3), atol=1e-9)
    assert np.allclose(S @ a, -a, atol=1e-9)


# --- support function ------------------------------------------------------
def test_ball_support():
    B = Ellipsoid.ball([1.0, -2.0], 3.0)
    l = np.array([0.6, 0.8])
    assert np.isclose(B.rho(l), l @ B.q + 3.0)


# --- Minkowski SUM tightness (external AND internal touch along l) ---------
def test_minksum_tightness_identity():
    for _ in range(200):
        n = int(rng.integers(2, 5))
        E1, E2 = rand_ell(n), rand_ell(n)
        l = rng.standard_normal(n)
        ext = minksum_ext(E1, E2, l)
        intl = minksum_int(E1, E2, l)
        target = E1.rho(l) + E2.rho(l)
        assert np.isclose(ext.rho(l), target, rtol=1e-9, atol=1e-9)
        assert np.isclose(intl.rho(l), target, rtol=1e-7, atol=1e-7)


def test_minksum_containment_ordering():
    """internal ⊆ (external) in every test direction: rho_int <= rho_ext."""
    for _ in range(50):
        n = 3
        E1, E2 = rand_ell(n), rand_ell(n)
        l = rng.standard_normal(n)
        ext = minksum_ext(E1, E2, l)
        intl = minksum_int(E1, E2, l)
        for _ in range(30):
            m = rng.standard_normal(n)
            assert intl.rho(m) <= ext.rho(m) + 1e-6


def test_minksum_ext_degenerate_operand_is_sound():
    """Regression: a rank-deficient operand must NOT have its orthogonal extent
    dropped. E1 ⊕ E2 support must be dominated in ALL directions even when the
    tight direction l lies in an operand's null space."""
    n = 3
    E1 = Ellipsoid([0, 0, 0], np.diag([4.0, 1.0, 1.0]))
    # E2 rank-1: extent only along axis 0 -> zero support along l=e2/e3
    v = np.array([0.0, 1.0, 0.0])
    E2 = Ellipsoid([0, 0, 0], 2.0 * np.outer(v, v))   # extent along axis 1 only
    l = np.array([1.0, 0.0, 0.0])                      # l in null space of E2.Q
    S = minksum_ext(E1, E2, l)
    for _ in range(2000):
        m = rng.standard_normal(n)
        assert S.rho(m) + 1e-9 >= E1.rho(m) + E2.rho(m), "dropped orthogonal extent"


def test_minksum_ext_tightness_matches_classic_formula():
    """New beta-form must equal the classic (p1+p2)(Q1/p1+Q2/p2) for non-degenerate."""
    for _ in range(100):
        n = 3
        E1, E2 = rand_ell(n), rand_ell(n)
        l = rng.standard_normal(n)
        p1 = np.sqrt(l @ E1.Q @ l); p2 = np.sqrt(l @ E2.Q @ l)
        classic = (p1 + p2) * (E1.Q / p1 + E2.Q / p2)
        got = minksum_ext(E1, E2, l).Q
        assert np.allclose(got, classic, rtol=1e-9, atol=1e-9)


def test_minksum_ext_is_outer_bound():
    """External sum dominates the true Minkowski-sum support in ALL directions."""
    n = 3
    E1, E2 = rand_ell(n), rand_ell(n)
    l_tight = rng.standard_normal(n)
    ext = minksum_ext(E1, E2, l_tight)
    for _ in range(500):
        m = rng.standard_normal(n)
        assert ext.rho(m) + 1e-9 >= E1.rho(m) + E2.rho(m)


# --- Minkowski DIFFERENCE tightness (rho = rho1 - rho2 along l) ------------
def test_minkdiff_tightness_identity():
    n = 3
    hits = 0
    for _ in range(400):
        big = rand_ell(n, scale=4.0)
        small = rand_ell(n, scale=0.3)
        # co-center for a clean difference
        small = Ellipsoid(big.q, small.Q)
        if not big.is_bigger(small):
            continue
        l = rng.standard_normal(n)
        ext = minkdiff_ext(big, small, l)
        intl = minkdiff_int(big, small, l)
        if ext is None or intl is None:
            continue
        target = big.rho(l) - small.rho(l)
        assert np.isclose(ext.rho(l), target, rtol=1e-7, atol=1e-7)
        assert np.isclose(intl.rho(l), target, rtol=1e-7, atol=1e-7)
        hits += 1
    assert hits > 20, f"too few admissible difference directions ({hits})"


def test_minkdiff_empty_when_not_bigger():
    n = 3
    small = rand_ell(n, scale=0.2)
    big = rand_ell(n, scale=5.0)
    l = rng.standard_normal(n)
    # small ⊖ big is empty -> None
    assert minkdiff_ext(small, big, l) is None
    assert minkdiff_int(small, big, l) is None


def test_minkdiff_erosion_soundness():
    """(E1 ⊖ E2) ⊕ E2 ⊆ E1 : erosion then dilation stays inside (support check)."""
    n = 2
    E1 = Ellipsoid([0, 0], np.array([[9.0, 0.0], [0.0, 4.0]]))
    E2 = Ellipsoid([0, 0], 0.5 * np.eye(2))
    for _ in range(200):
        l = rng.standard_normal(n)
        D = minkdiff_int(E1, E2, l)     # internal (guaranteed-inside) difference
        if D is None:
            continue
        # rho((E1⊖E2), l) + rho(E2, l) <= rho(E1, l) + tiny
        assert D.rho(l) + E2.rho(l) <= E1.rho(l) + 1e-6


# --- affine map ------------------------------------------------------------
def test_affine_transform():
    A = np.array([[2.0, 0.5], [-1.0, 1.0]])
    b = np.array([1.0, 1.0])
    E = Ellipsoid([0.0, 0.0], np.array([[4.0, 1.0], [1.0, 2.0]]))
    Ea = E.affine(A, b)
    assert np.allclose(Ea.q, A @ E.q + b)
    assert np.allclose(Ea.Q, A @ E.Q @ A.T)


# --- intersection external bound ------------------------------------------
def test_intersection_ext_soundness():
    """Any point in BOTH ellipsoids must be in the external intersection bound."""
    n = 2
    E1 = Ellipsoid([0.0, 0.0], np.array([[4.0, 0.0], [0.0, 1.0]]))
    E2 = Ellipsoid([1.0, 0.0], np.array([[1.0, 0.0], [0.0, 4.0]]))
    X = intersection_ext(E1, E2)
    ok = 0
    for _ in range(5000):
        x = rng.uniform(-3, 4, size=n)
        if E1.contains(x) and E2.contains(x):
            assert X.contains(x), f"{x} in both but not in intersection bound"
            ok += 1
    assert ok > 50


# --- discrete reach tube soundness ----------------------------------------
def test_reach_tube_discrete_soundness_and_bounded():
    theta = 1.0
    R = 0.9 * np.array([[np.cos(theta), -np.sin(theta)],
                        [np.sin(theta),  np.cos(theta)]])
    E0 = Ellipsoid.ball([0.0, 0.0], 1.0)
    W = Ellipsoid.ball([0.0, 0.0], 0.2)
    dirs = [[1, 0], [0, 1], [1, 1], [1, -1]]
    N = 40
    tubes = reach_tube_lti_discrete(R, E0, W, dirs, N, approx="ext")
    assert all(np.isfinite(t[-1].volume()) and t[-1].volume() < 1e3 for t in tubes)
    for _ in range(300):
        x = E0.q + (E0.support_point(rng.standard_normal(2)) - E0.q) * rng.uniform(0, 1)
        for k in range(N + 1):
            for t in tubes:
                assert t[k].contains(x)
            w = W.q + (W.support_point(rng.standard_normal(2)) - W.q) * rng.uniform(0, 1)
            x = R @ x + w


def test_minksum_ext_multi_soundness():
    """k-fold external must contain all sums of points drawn from each E_i."""
    n = 3
    ells = [rand_ell(n) for _ in range(4)]
    l = rng.standard_normal(n)
    S = minksum_ext_multi(ells, l)
    for _ in range(3000):
        pts = []
        for E in ells:
            u = rng.standard_normal(n); u /= max(np.linalg.norm(u), 1e-9)
            pts.append(E.q + sqrtm_pos(E.Q) @ (u * rng.uniform(0, 1)))
        assert S.contains(sum(pts), tol=1e-9)


def test_tight_tube_exact_along_direction_high_kappa():
    """The CORRECT k-fold tube's support along l equals the exact reach-set
    support even for highly anisotropic disturbances (the critic's key point:
    the earlier blow-up was a naive-recursion artifact, not KV theory)."""
    theta = 0.7
    A = 0.9 * np.array([[np.cos(theta), -np.sin(theta)],
                        [np.sin(theta),  np.cos(theta)]])
    E0 = Ellipsoid([0, 0], 0.25 * np.eye(2))
    N = 15
    for kappa in (1.0, 100.0, 1000.0):
        W = Ellipsoid([0, 0], np.diag([0.04, 0.04 / kappa]))
        for l in ([1.0, 0.0], [0.3, 1.0], [1.0, -0.7]):
            l = np.asarray(l, float)
            tube = reach_tube_lti_discrete_tight(A, E0, W, [l], N, approx="ext")[0]
            # exact reference support at step N along l
            ref = E0.rho(np.linalg.matrix_power(A, N).T @ l)
            for j in range(N):
                ref += W.rho(np.linalg.matrix_power(A, j).T @ l)
            got = tube[-1].rho(l)
            assert abs(got - ref) <= 1e-8 * max(1.0, abs(ref)), \
                f"kappa={kappa} l={l}: got {got} vs exact {ref}"


def test_tight_tube_beats_naive_recursion():
    """Sanity: naive pairwise recursion is looser than the joint k-fold tube
    along the tight direction (quantifies the artifact)."""
    theta = 0.7
    A = 0.9 * np.array([[np.cos(theta), -np.sin(theta)],
                        [np.sin(theta),  np.cos(theta)]])
    E0 = Ellipsoid([0, 0], 0.25 * np.eye(2))
    W = Ellipsoid([0, 0], np.diag([0.04, 0.0004]))   # kappa=100
    N = 15
    l = np.array([0.3, 1.0])
    tight = reach_tube_lti_discrete_tight(A, E0, W, [l], N, "ext")[0][-1]
    naive = reach_tube_lti_discrete(A, E0, W, [l], N, "ext")[0][-1]
    assert tight.rho(l) <= naive.rho(l) + 1e-9   # tight is at least as tight


def test_reach_tube_internal_subset_external():
    theta = 0.5
    R = 0.85 * np.array([[np.cos(theta), -np.sin(theta)],
                         [np.sin(theta),  np.cos(theta)]])
    E0 = Ellipsoid.ball([0.0, 0.0], 1.0)
    W = Ellipsoid.ball([0.0, 0.0], 0.3)
    dirs = [[1, 0], [0, 1]]
    N = 20
    ext = reach_tube_lti_discrete(R, E0, W, dirs, N, approx="ext")
    intl = reach_tube_lti_discrete(R, E0, W, dirs, N, approx="int")
    for di, l in enumerate(dirs):
        for k in range(N + 1):
            assert intl[di][k].rho(l) <= ext[di][k].rho(l) + 1e-6


# --- continuous reach tube (SciPy) ----------------------------------------
def test_reach_tube_continuous_soundness():
    scipy = pytest.importorskip("scipy")  # skip only if SciPy truly absent
    from ellreach import reach_tube_lti_continuous
    A = np.array([[0.0, 1.0], [-1.0, -0.4]])     # stable-ish oscillator
    X0 = Ellipsoid.ball([0.0, 0.0], 0.5)
    G = 0.1 * np.eye(2)                           # disturbance shape
    l0 = np.array([1.0, 0.0])
    t, C, Q = reach_tube_lti_continuous(A, X0, G, l0, (0.0, 3.0), n_pts=120)
    # soundness: simulate dx/dt = A x + w, ||G^-1/2 w|| <= 1, check containment
    dt = t[1] - t[0]
    contained = 0
    total = 0
    for _ in range(60):
        x = X0.q + (X0.support_point(rng.standard_normal(2)) - X0.q) * rng.uniform(0, 1)
        for k in range(len(t)):
            E = Ellipsoid(C[:, k], Q[:, :, k])
            total += 1
            if E.contains(x, tol=1e-6):
                contained += 1
            # admissible disturbance: sample inside unit G-ball
            wdir = rng.standard_normal(2)
            wdir = wdir / max(np.linalg.norm(wdir), 1e-9) * rng.uniform(0, 1)
            w = sqrtm_pos(G) @ wdir
            x = x + dt * (A @ x + w)
    frac = contained / total
    # single-direction outer tube; allow slight numeric slack from Euler sim
    assert frac > 0.97, f"continuous tube containment only {frac:.3f}"
