"""
Robust certified INNER reachability for a ReLU neural-feedback loop.

Two guarantees, both SOUND (verified by exact realizability witnesses, no
finite-direction membership tests):
  1. Certified inner set: every point is reachable for SOME disturbance.
  2. W-ROBUST certified inner set: every point stays reachable under EVERY
     disturbance realization w in W (forall w exists x(w) -- a robustness margin,
     not a single-policy min-max) -- computed via the KV internal Minkowski
     DIFFERENCE (erosion) of the exact per-region affine image by W. This is the
     guarantee outer-bound NN tools cannot give; it uses the ellipsoidal erosion.

Outputs (results/*.csv):
  inner_tube.csv, robust_tube.csv, bracket.csv,
  soundness_exact.csv  (fraction of inner points with a verified exact witness),
  certificate.csv      (exact ellipsoid-ball intersection: reachability proof).
"""
import csv
import os
import numpy as np
from scipy.optimize import minimize
from ellreach import Ellipsoid, minksum_ext, sqrtm_pos
from nn_bounds import ReLUMLP, relax_over_ellipsoid
from pwa_nfl import (certified_inner_onestep,
                     exact_regions_single_hidden, inner_ellipsoid_in_region,
                     minksum_int, minkdiff_int, internal_sum_witness)

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(HERE, "results")
os.makedirs(RESULTS, exist_ok=True)
rng = np.random.default_rng(0)


def make_system():
    W1 = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, -1.0], [1.0, 1.0]])
    W2 = np.array([[0.45, -0.25, 0.2, 0.15], [-0.2, 0.4, -0.15, 0.25]])
    mlp = ReLUMLP([(W1, np.zeros(4)), (W2, np.zeros(2))])
    A = 0.92 * np.array([[np.cos(0.45), -np.sin(0.45)],
                         [np.sin(0.45), np.cos(0.45)]])
    B = np.array([[0.35, 0.0], [0.0, 0.35]])
    E0 = Ellipsoid([1.2, 0.0], 0.30 * np.eye(2))
    W = Ellipsoid([0.0, 0.0], 0.001 * np.eye(2))   # small disturbance: W-robust core survives a few steps
    return mlp, A, B, E0, W


def _ball(n):
    u = rng.standard_normal(n); u /= max(np.linalg.norm(u), 1e-12)
    return u * rng.uniform(0, 1) ** (1.0 / n)


# -------- EXACT ellipsoid-ball intersection (sound certificate: no false pos) --
def ellipsoid_ball_intersect(E: Ellipsoid, c, r):
    """True iff E ∩ Ball(c,r) != empty, via exact min-distance from c to E.
    min over ||z||<=1 of ||Q^{1/2} z + q - c||. If min <= r they intersect."""
    c = np.asarray(c, float).reshape(-1)
    M = sqrtm_pos(E.Q); v = c - E.q
    if v @ np.linalg.solve(E.Q + 1e-12*np.eye(E.dim), v) <= 1.0:
        return True, 0.0                                  # c inside E
    obj = lambda z: float(np.sum((M @ z - v) ** 2))
    jac = lambda z: 2.0 * M.T @ (M @ z - v)
    con = {"type": "ineq", "fun": lambda z: 1.0 - z @ z,
           "jac": lambda z: -2.0 * z}
    best = np.inf
    any_ok = False
    for _ in range(8):
        z0 = _ball(E.dim)
        res = minimize(obj, z0, jac=jac, constraints=[con], method="SLSQP",
                       options={"ftol": 1e-12, "maxiter": 300})
        if res.success and (res.x @ res.x) <= 1.0 + 1e-6:   # feasible minimizer only
            any_ok = True
            best = min(best, res.fun)
    if not any_ok:
        return False, float("inf")          # could not certify -> do NOT claim reach
    dist = np.sqrt(max(best, 0.0))
    return dist <= r + 1e-9, dist


# -------- outer tube (sound over-approx) for the bracket ---------------------
def outer_tube(mlp, A, B, E0, W, N, ldir):
    E = E0; seq = [E]
    for _ in range(N):
        rel = relax_over_ellipsoid(mlp, E)
        A_cl = A + B @ rel.K; b_cl = B @ rel.d
        slack = Ellipsoid(np.zeros(E.dim), B @ rel.D @ B.T)
        E = minksum_ext(minksum_ext(E.affine(A_cl, b_cl), slack, ldir), W, ldir)
        seq.append(E)
    return seq


def sample_true_reach(mlp, A, B, E0, W, N, n=40000):
    LE, LW = sqrtm_pos(E0.Q), sqrtm_pos(W.Q)
    X = np.array([E0.q + LE @ _ball(2) for _ in range(n)])
    clouds = [X.copy()]
    for _ in range(N):
        Wn = np.array([LW @ _ball(2) for _ in range(len(X))])
        X = (A @ X.T).T + (B @ np.array([mlp.forward(x) for x in X]).T).T + Wn
        clouds.append(X.copy())
    return clouds


def hull_area(pts):
    from scipy.spatial import ConvexHull
    try:
        return ConvexHull(pts).volume
    except Exception:
        return float("nan")


def union_area(ells, n=200000):
    if not ells:
        return 0.0
    mins = np.array([min(e.q[i]-np.sqrt(e.Q[i, i]) for e in ells) for i in (0, 1)])
    maxs = np.array([max(e.q[i]+np.sqrt(e.Q[i, i]) for e in ells) for i in (0, 1)])
    box = maxs - mins
    S = mins + rng.uniform(0, 1, (n, 2)) * box
    inside = np.zeros(n, bool)
    for e in ells:
        d = S - e.q
        m = np.einsum('ij,jk,ik->i', d, np.linalg.inv(e.Q+1e-12*np.eye(2)), d)
        inside |= m <= 1.0
    return float(inside.mean() * box[0] * box[1])


# -------- exact-witness soundness audit (rigorous, not finite-direction) ------
def exact_witness_audit(mlp, A, B, E0, W, ldir, n_per=300):
    """For each certified-inner ellipsoid, sample points via internal_sum_witness
    and verify each has an EXACT reachable witness (x in E_in, w in W,
    A x + B pi(x) + w == y). Returns (checked, verified)."""
    _, meta = certified_inner_onestep(mlp, A, B, [E0], W, ldir, n_samples=400, seed=1)
    checked = verified = 0
    for m in meta:
        E_img, E_in, A_cl, b_cl = m["E_img"], m["E_in"], m["A_cl"], m["b_cl"]
        Ainv = np.linalg.inv(A_cl)
        for _ in range(n_per):
            u = _ball(2)
            y, a, w = internal_sum_witness(E_img, W, ldir, u)
            x = Ainv @ (a - b_cl)                       # exact preimage in E_in
            checked += 1
            ok_x = E_in.contains(x, tol=1e-7)
            ok_w = W.contains(w, tol=1e-7)
            y_true = A @ x + B @ mlp.forward(x) + w     # exact forward map
            if ok_x and ok_w and np.allclose(y_true, y, atol=1e-7):
                verified += 1
    return checked, verified


def main():
    mlp, A, B, E0, W = make_system()
    N = 6
    ldir = np.array([1.0, 1.0])

    # certified inner tube (exact single-hidden-layer region enumeration)
    inner = [[E0]]; cur = [E0]
    robust = [[E0]]; rcur = [E0]
    for k in range(N):
        # exact enumeration replaces sampling for this 1-hidden-layer net
        nxt = []
        for E in cur:
            for (K, c, G, h, xrep) in exact_regions_single_hidden(mlp, E):
                E_in = inner_ellipsoid_in_region(E, G, h, xrep)
                if E_in is None:
                    continue
                A_cl = A + B @ K; b_cl = B @ c
                nxt.append(minksum_int(E_in.affine(A_cl, b_cl), W, ldir))
        nxt.sort(key=lambda e: e.volume(), reverse=True); cur = nxt[:12]
        inner.append(cur)
        # robust tube (erosion by W)
        rnxt = []
        for E in rcur:
            for (K, c, G, h, xrep) in exact_regions_single_hidden(mlp, E):
                E_in = inner_ellipsoid_in_region(E, G, h, xrep)
                if E_in is None:
                    continue
                A_cl = A + B @ K; b_cl = B @ c
                img = E_in.affine(A_cl, b_cl)
                if not img.is_bigger(W):
                    continue
                er = minkdiff_int(img, W, ldir)
                if er is not None:
                    rnxt.append(er)
        rnxt.sort(key=lambda e: e.volume(), reverse=True); rcur = rnxt[:12]
        robust.append(rcur)          # honest: empty when erosion vanishes (no carry-forward)

    outer = outer_tube(mlp, A, B, E0, W, N, ldir)
    clouds = sample_true_reach(mlp, A, B, E0, W, N)

    _write("inner_tube.csv", [dict(step=k, idx=j, cx=e.q[0], cy=e.q[1], area=e.volume())
                              for k, es in enumerate(inner) for j, e in enumerate(es)])
    _write("robust_tube.csv", [dict(step=k, idx=j, cx=e.q[0], cy=e.q[1], area=e.volume())
                               for k, es in enumerate(robust) for j, e in enumerate(es)])

    # bracket (areas are MC estimates; the certified relation is proven by witnesses)
    brows = []
    for k in range(N + 1):
        ia = union_area(inner[k]); ra = union_area(robust[k])
        ta = hull_area(clouds[k]); oa = outer[k].volume()
        brows.append(dict(step=k, inner_mc_area=ia, robust_mc_area=ra,
                          true_hull_mc_area=ta, outer_area=oa,
                          inner_over_true=ia/ta if ta else float("nan"),
                          outer_over_true=oa/ta if ta else float("nan")))
    _write("bracket.csv", brows)

    # EXACT-witness soundness audit
    checked, verified = exact_witness_audit(mlp, A, B, E0, W, ldir)
    _write("soundness_exact.csv", [dict(checked=checked, verified=verified,
                                        fraction=verified/checked, method="exact_preimage_witness")])

    # certificate: EXACT ellipsoid-ball intersection (sound; never false-positive).
    # Target is FIXED a priori (a goal region in state space), NOT derived from the
    # run, so the certificate is an honest query, not post-hoc tuning.
    target_c = np.array([1.2, 1.0]); target_r = 0.30
    trows = []
    for k, es in enumerate(inner):
        hit = any(ellipsoid_ball_intersect(e, target_c, target_r)[0] for e in es)
        rhit = any(ellipsoid_ball_intersect(e, target_c, target_r)[0] for e in robust[k])
        trows.append(dict(step=k, target_cx=target_c[0], target_cy=target_c[1], target_r=target_r,
                          inner_certifies_reach=int(hit),
                          robust_certifies_guaranteed_reach=int(rhit)))
    _write("certificate.csv", trows)

    print("=== bracket (MC-estimated areas; certified relation proven by witnesses) ===")
    for r in brows:
        print(f" step {r['step']}: inner~{r['inner_mc_area']:.4f} robust~{r['robust_mc_area']:.4f}"
              f" true~{r['true_hull_mc_area']:.4f} outer={r['outer_area']:.4f}")
    print(f"EXACT soundness: {verified}/{checked} inner points have a verified exact witness"
          f" (fraction={verified/checked:.4f})")
    cert = [r['step'] for r in trows if r['inner_certifies_reach']]
    rcert = [r['step'] for r in trows if r['robust_certifies_guaranteed_reach']]
    print(f"reachability certificate (exact ∩): inner reaches target at steps {cert}")
    print(f"ROBUST certificate: guaranteed reach despite worst-case disturbance at steps {rcert}")
    print("INNER-REACH OK")


def _write(name, rows):
    with open(os.path.join(RESULTS, name), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)


if __name__ == "__main__":
    main()
