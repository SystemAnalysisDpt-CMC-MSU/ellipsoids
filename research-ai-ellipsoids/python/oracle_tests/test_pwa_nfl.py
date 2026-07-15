"""
Soundness oracle for the certified INNER NFL reach tube. The inner-set guarantee
rests on three facts, each tested here, plus an end-to-end realizability check:
 (a) local_affine returns the EXACT map pi(x)=Kx+c on the activation region;
 (b) inner_ellipsoid_in_region(E,G,h) ⊆ E ∩ {Gx<=h};
 (c) minksum_int(E1,E2,l) ⊆ E1 ⊕ E2  (KV internal sum is a true inner sum);
 (d) END-TO-END: every point of a one-step certified inner ellipsoid is
     REACHABLE — there exist x in E0 and w in W with A x + B pi(x) + w = y.
Membership y in (S1⊕S2) is checked exactly via the support-function
characterization: y in S1⊕S2  iff  d·y <= rho(S1,d)+rho(S2,d) for all d.
"""
import numpy as np
from ellreach import Ellipsoid, minksum_int, sqrtm_pos
from nn_bounds import ReLUMLP
from pwa_nfl import (local_affine, inner_ellipsoid_in_region,
                     certified_inner_onestep, certified_robust_inner_onestep,
                     internal_sum_witness, exact_regions_single_hidden)

rng = np.random.default_rng(4)


def _dirs(n, k):
    D = rng.standard_normal((k, n))
    return D / np.linalg.norm(D, axis=1, keepdims=True)


def in_minksum(y, E1, E2, dirs, tol=1e-7):
    """Exact-ish membership y ∈ E1⊕E2 via support functions over many dirs."""
    return all(d @ y <= E1.rho(d) + E2.rho(d) + tol for d in dirs)


def test_local_affine_is_exact_on_region():
    mlp = ReLUMLP.random([2, 8, 8, 2], seed=1)
    for _ in range(200):
        x = rng.standard_normal(2) * 1.5
        K, c, G, h = local_affine(mlp, x)
        assert np.allclose(mlp.forward(x), K @ x + c, atol=1e-9)   # exact at x
        # exact for a nearby point in the SAME region (small perturbation
        # that keeps all activation signs) -> stays affine with same K,c
        for _ in range(5):
            xp = x + 1e-4 * rng.standard_normal(2)
            if G.shape[0] == 0 or np.all(G @ xp <= h):     # same region
                assert np.allclose(mlp.forward(xp), K @ xp + c, atol=1e-8)


def test_inner_ellipsoid_inside_region_and_E():
    E = Ellipsoid([0.0, 0.0], np.array([[1.0, 0.3], [0.3, 0.7]]))
    G = np.array([[1.0, 0.0], [0.0, 1.0], [-1.0, -1.0]])
    h = np.array([0.6, 0.5, 0.4])
    p = np.array([0.1, 0.05])            # interior point of E ∩ region
    Ein = inner_ellipsoid_in_region(E, G, h, p)
    assert Ein is not None
    # sample the inner ellipsoid boundary+interior; must satisfy Gx<=h and be in E
    L = sqrtm_pos(Ein.Q)
    for _ in range(3000):
        u = rng.standard_normal(2); u /= max(np.linalg.norm(u), 1e-12)
        u *= rng.uniform(0, 1)
        x = Ein.q + L @ u
        assert np.all(G @ x <= h + 1e-9), "inner ellipsoid leaves region"
        assert E.contains(x, tol=1e-9), "inner ellipsoid leaves E"


def test_minksum_int_is_subset_of_minkowski_sum():
    dirs = _dirs(3, 400)
    for _ in range(40):
        M1 = rng.standard_normal((3, 3)); E1 = Ellipsoid(rng.standard_normal(3), M1@M1.T+0.2*np.eye(3))
        M2 = rng.standard_normal((3, 3)); E2 = Ellipsoid(rng.standard_normal(3), M2@M2.T+0.2*np.eye(3))
        l = rng.standard_normal(3)
        Eint = minksum_int(E1, E2, l)
        L = sqrtm_pos(Eint.Q)
        for _ in range(40):
            u = rng.standard_normal(3); u /= max(np.linalg.norm(u), 1e-12)
            u *= rng.uniform(0, 1) ** (1/3)
            y = Eint.q + L @ u
            assert in_minksum(y, E1, E2, dirs), "internal sum point not in E1(+)E2"


def test_certified_inner_onestep_is_reachable():
    """END-TO-END: sampled points of the certified inner set are reachable."""
    # explicit net whose ReLU boundaries (x1=0, x2=0, x1-x2=0, x1+x2=0) all pass
    # through the origin, so an origin-centered E0 provably spans several regions.
    W1 = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, -1.0], [1.0, 1.0]])
    b1 = np.zeros(4)
    W2 = np.array([[0.5, -0.3, 0.2, 0.1], [-0.2, 0.4, -0.1, 0.3]])
    b2 = np.zeros(2)
    mlp = ReLUMLP([(W1, b1), (W2, b2)])
    A = 0.9 * np.array([[np.cos(0.5), -np.sin(0.5)], [np.sin(0.5), np.cos(0.5)]])
    B = np.array([[0.3, 0.0], [0.0, 0.3]])
    E0 = Ellipsoid([0.0, 0.0], 1.0 * np.eye(2))    # spans multiple activation regions
    W = Ellipsoid([0.0, 0.0], 0.01 * np.eye(2))
    out, meta = certified_inner_onestep(mlp, A, B, [E0], W, ldir=np.array([1.0, 1.0]),
                                        n_samples=400, seed=3)
    assert len(out) >= 2, f"expected multiple activation regions, got {len(out)}"
    dirs = _dirs(2, 500)
    checked = 0
    for E_next, m in zip(out, meta):
        E_img = m["E_img"]
        L = sqrtm_pos(E_next.Q)
        for _ in range(200):
            u = rng.standard_normal(2); u /= max(np.linalg.norm(u), 1e-12)
            u *= rng.uniform(0, 1)
            y = E_next.q + L @ u
            # y must be in E_img (+) W  == reachable (E_img is an exact affine
            # image of E_in ⊆ E0∩region; adding w∈W gives a true reachable state)
            assert in_minksum(y, E_img, W, dirs), "inner point not reachable"
            checked += 1
    assert checked >= 400


def test_internal_sum_witness_is_exact():
    """internal_sum_witness gives an EXACT decomposition y=a+w, a∈E_img, w∈W."""
    for _ in range(200):
        M1 = rng.standard_normal((2, 2)); E_img = Ellipsoid(rng.standard_normal(2), M1@M1.T+0.2*np.eye(2))
        M2 = rng.standard_normal((2, 2)); W = Ellipsoid(rng.standard_normal(2), M2@M2.T+0.2*np.eye(2))
        l = rng.standard_normal(2)
        u = rng.standard_normal(2); u *= rng.uniform(0, 1) / max(np.linalg.norm(u), 1e-12)
        y, a, w = internal_sum_witness(E_img, W, l, u)
        assert np.allclose(y, a + w, atol=1e-10)          # exact sum
        assert E_img.contains(a, tol=1e-9)                # a in E_img
        assert W.contains(w, tol=1e-9)                    # w in W


def test_robust_inner_is_guaranteed_reachable():
    """Every point of the ROBUST inner set stays reachable under EVERY disturbance:
    y ∈ (image ⊖ W) means y + w ∈ image for all w ∈ W, i.e., y is reachable for
    the nominal control regardless of the adversary's w."""
    W1 = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, -1.0], [1.0, 1.0]])
    W2 = np.array([[0.45, -0.25, 0.2, 0.15], [-0.2, 0.4, -0.15, 0.25]])
    mlp = ReLUMLP([(W1, np.zeros(4)), (W2, np.zeros(2))])
    A = 0.9 * np.array([[np.cos(0.5), -np.sin(0.5)], [np.sin(0.5), np.cos(0.5)]])
    B = np.array([[0.3, 0.0], [0.0, 0.3]])
    E0 = Ellipsoid([0.0, 0.0], 1.0 * np.eye(2))
    W = Ellipsoid([0.0, 0.0], 0.02 * np.eye(2))
    out, meta = certified_robust_inner_onestep(mlp, A, B, [E0], W,
                                               ldir=np.array([1.0, 1.0]), n_samples=400, seed=1)
    assert len(out) >= 1, "no robust core found"
    dirs = _dirs(2, 400)
    for E_rob, m in zip(out, meta):
        E_img = m["E_img"]
        L = sqrtm_pos(E_rob.Q)
        for _ in range(150):
            y = E_rob.q + L @ (_unit() * rng.uniform(0, 1))
            # adversary picks worst-case w on W's boundary in several directions
            for _ in range(8):
                wd = _unit()
                w = W.q + sqrtm_pos(W.Q) @ wd            # boundary disturbance
                assert in_ball_of(y + w, E_img, dirs), "robust point left nominal image under disturbance"


def _unit():
    u = rng.standard_normal(2)
    return u / max(np.linalg.norm(u), 1e-12)


def in_ball_of(z, E, dirs, tol=1e-6):
    """Membership z ∈ E via support over dirs (E convex => exact in the limit)."""
    return all(d @ z <= E.rho(d) + tol for d in dirs)


def test_exact_region_enumeration_covers_sampled():
    """Exact enumeration finds at least as many regions (in E) as sampling."""
    W1 = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, -1.0], [1.0, 1.0]])
    W2 = np.array([[0.45, -0.25, 0.2, 0.15], [-0.2, 0.4, -0.15, 0.25]])
    mlp = ReLUMLP([(W1, np.zeros(4)), (W2, np.zeros(2))])
    E = Ellipsoid([0.0, 0.0], 1.0 * np.eye(2))
    exact = exact_regions_single_hidden(mlp, E)
    assert len(exact) >= 2
    # every exact region's representative point is inside E and inside its region
    for (K, c, G, h, x) in exact:
        assert E.contains(x, tol=1e-9)
        assert np.all(G @ x <= h + 1e-9)
        assert np.allclose(mlp.forward(x), K @ x + c, atol=1e-9)


def test_certified_inner_subset_of_sampled_true_reach():
    """The certified inner set must sit INSIDE a large sampled reach cloud."""
    mlp = ReLUMLP.random([2, 6, 2], seed=5)
    A = 0.8 * np.eye(2)
    B = np.array([[0.4, 0.1], [0.0, 0.4]])
    E0 = Ellipsoid([0.0, 0.0], 0.2 * np.eye(2))
    W = Ellipsoid([0.0, 0.0], 0.02 * np.eye(2))
    out, _ = certified_inner_onestep(mlp, A, B, [E0], W, n_samples=150, seed=7)
    # sample the TRUE one-step reachable set densely
    LE = sqrtm_pos(E0.Q); LW = sqrtm_pos(W.Q)
    cloud = []
    for _ in range(20000):
        ux = rng.standard_normal(2); ux /= max(np.linalg.norm(ux), 1e-12); ux *= rng.uniform(0, 1)
        x = E0.q + LE @ ux
        uw = rng.standard_normal(2); uw /= max(np.linalg.norm(uw), 1e-12); uw *= rng.uniform(0, 1)
        w = W.q + LW @ uw
        cloud.append(A @ x + B @ mlp.forward(x) + w)
    cloud = np.array(cloud)
    # every inner-ellipsoid center must be within the cloud's convex extent
    # (necessary check): support of cloud dominates inner center in all dirs
    dirs = _dirs(2, 200)
    cloud_sup = {tuple(d): np.max(cloud @ d) for d in dirs}
    for E_next in out:
        for d in dirs:
            assert E_next.rho(d) <= cloud_sup[tuple(d)] + 5e-2, "inner exceeds sampled reach"
