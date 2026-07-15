"""
Ellipsoid vs. zonotope reach-tube head-to-head (pure Python; replaces the CORA
comparison, which would require a MATLAB license). Both methods are measured
against the SAME exact reference support of the true reachable set, so the gap
each incurs is exactly its representation cost on the given uncertainty geometry.

Reference (exact for any convex uncertainty set W with known support):
  rho_R(m) = rho(X0, (A^N)^T m) + sum_{j=0}^{N-1} rho(W, (A^j)^T m).

Tube construction: the ellipsoidal tube is the CORRECT joint k-fold KV tight sum
`reach_tube_lti_discrete_tight`. That construction is tight along ONE query
direction only: for each query direction m we must build a SEPARATE
direction-specific ellipsoid (the ellipsoid tight along m) and evaluate its
support along that same m. "Machine-epsilon exact" therefore means
per-QUERY-direction: the ellipsoidal reach tube is a FAMILY (intersection) of
direction-specific ellipsoids, one per direction, and each member reproduces the
EXACT reach-set support of a convex ellipsoidal uncertainty set along its own
direction — matching the zonotope's exactness on box uncertainty. (The earlier
apparent ellipsoid loss at high anisotropy was the naive FIXED-direction pairwise
recursion `reach_tube_lti_discrete` holding the query direction constant across
steps, not a deficiency of KV theory; see bench_tight_vs_naive.py.)

Fairness protocol: the SAME system, SAME W, SAME X0. Each method uses its native
representation of W/X0 where possible, and a SOUND over-approximation of the
other geometry where not (ellipsoid<-box via Loewner n-blowup; zonotope<-ellipsoid
via eigen-box). The remaining gap therefore isolates the pure representation-vs-
geometry mismatch (fitting an ellipsoid to a box, or a box to an ellipsoid), NOT
any wrapping loss — both native tubes are tight on their matching geometry.

Runtime fairness (added in round 2): because the ellipsoid method needs ONE tube
per query direction, an apples-to-apples runtime comparison must build the FULL
tube for BOTH methods. The zonotope builds a single tube that answers ALL
directions; the ellipsoid must build one tube per direction. We therefore report
`ell_full_runtime` = time to build the ellipsoidal tube family for ALL query
directions (n_dirs=120 here) against `zono_runtime` = the single zonotope tube.
`ell_per_dir_runtime` (one representative direction) is retained only for context.
The honest full-tube-vs-full-tube ratio shows the ellipsoid is ~290x slower over
120 directions: ellipsoid cost scales LINEARLY with the number of query
directions, a real disadvantage versus the single all-directions zonotope tube.
"""
import csv
import os
import time
import numpy as np
from ellreach import Ellipsoid, reach_tube_lti_discrete_tight
from zonotope import Zonotope, reach_tube_zonotope

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(HERE, "results")
os.makedirs(RESULTS, exist_ok=True)
rng = np.random.default_rng(2024)


def rot_scale(theta, rho, n):
    A = np.eye(n)
    R = np.array([[np.cos(theta), -np.sin(theta)], [np.sin(theta), np.cos(theta)]])
    A[:2, :2] = R
    return rho * A


def ref_support(A, X0_supp, W_supp, N, m):
    """Exact support of the true reach set at step N along m.
    X0_supp, W_supp are callables l->rho."""
    val = X0_supp(np.linalg.matrix_power(A, N).T @ m)
    for j in range(N):
        val += W_supp(np.linalg.matrix_power(A, j).T @ m)
    return val


def unit_dirs(n, k):
    if n == 2:
        ang = np.linspace(0, 2 * np.pi, k, endpoint=False)
        return [np.array([np.cos(a), np.sin(a)]) for a in ang]
    D = rng.standard_normal((k, n))
    return [d / np.linalg.norm(d) for d in D]


def gaps(method_supp, A, X0_supp, W_supp, N, dirs):
    """Relative support gap (method - ref)/ref over dirs at step N (>=0 if sound)."""
    g = []
    for m in dirs:
        ref = ref_support(A, X0_supp, W_supp, N, m)
        val = method_supp(m)
        g.append((val - ref) / max(abs(ref), 1e-12))
    g = np.array(g)
    return float(np.mean(g)), float(np.max(g)), float(np.min(g))


def ell_tight_supp(A, X0e, W_ell, N):
    """Return a callable m -> rho of the KV tight ellipsoidal tube at step N,
    evaluated per-QUERY-direction: for each query m we build the SEPARATE
    ellipsoid that is tight along m (joint k-fold KV sum) and return its support
    along m. This is the exact reach-set support of the convex ellipsoidal set in
    direction m. Note that one ellipsoid answers ONE direction: the full reach
    tube is the FAMILY (intersection) of these per-direction ellipsoids."""
    def supp(m):
        tube = reach_tube_lti_discrete_tight(A, X0e, W_ell, [m], N, approx="ext")[0]
        return tube[-1].rho(m)
    return supp


def ell_full_tube_time(A, X0e, W_ell, N, dirs):
    """Wall-clock time to build the FULL ellipsoidal tube family for ALL query
    directions (one direction-specific KV tight tube per direction). This is the
    fair apples-to-apples cost against the single zonotope tube, because the
    ellipsoid method needs one tube per query direction."""
    t0 = time.perf_counter()
    for m in dirs:
        reach_tube_lti_discrete_tight(A, X0e, W_ell, [m], N, approx="ext")
    return time.perf_counter() - t0


def run():
    rows = []
    N = 15
    n = 2
    A = rot_scale(0.7, 0.9, n)
    dirs = unit_dirs(n, 120)
    X0_Q = 0.25 * np.eye(n)               # isotropic initial ellipsoid (r=0.5)

    scenarios = []
    # 1. isotropic ellipsoidal disturbance
    scenarios.append(("ellipsoid_isotropic", 1.0, np.diag([0.04, 0.04])))
    # 2. anisotropic ellipsoidal disturbance (condition number kappa)
    for kappa in (10.0, 100.0):
        scenarios.append((f"ellipsoid_aniso_k{int(kappa)}", kappa,
                          np.diag([0.04, 0.04 / kappa])))
    # 3. box disturbance (zonotope-native geometry)
    scenarios.append(("box", 1.0, None))   # handled specially below

    for name, kappa, WQ in scenarios:
        if WQ is not None:
            # ---- ellipsoidal disturbance W = E(0, WQ) ----
            W_ell = Ellipsoid(np.zeros(n), WQ)
            W_supp = W_ell.rho
            # ellipsoid tube (native, per-direction KV tight sum)
            X0e = Ellipsoid(np.zeros(n), X0_Q)
            ell_supp = ell_tight_supp(A, X0e, W_ell, N)
            # per-direction representative cost (one direction-specific tube)
            t0 = time.perf_counter()
            _ = ell_supp(dirs[0])
            t_ell_per_dir = time.perf_counter() - t0
            # FAIR full-tube cost: build the ellipsoidal tube for ALL query
            # directions (the ellipsoid method needs one tube per direction)
            t_ell_full = ell_full_tube_time(A, X0e, W_ell, N, dirs)
            # zonotope tube (W over-approximated by eigen-box zonotope; sound)
            Z0 = Zonotope.outer_of_ellipsoid(np.zeros(n), X0_Q)
            Wz = Zonotope.outer_of_ellipsoid(np.zeros(n), WQ)
            t0 = time.perf_counter()
            ztube = reach_tube_zonotope(A, Z0, Wz, N, max_order=None)
            t_zono = time.perf_counter() - t0
            zono_supp = ztube[-1].rho
            X0_supp = X0e.rho
        else:
            # ---- box disturbance W = box(0, r) ----
            r = np.array([0.2, 0.2])
            Wz = Zonotope.box(np.zeros(n), r)
            W_supp = Wz.rho
            # zonotope tube (native, exact)
            Z0 = Zonotope.box(np.zeros(n), np.array([0.5, 0.5]))
            t0 = time.perf_counter()
            ztube = reach_tube_zonotope(A, Z0, Wz, N, max_order=None)
            t_zono = time.perf_counter() - t0
            zono_supp = ztube[-1].rho
            X0_supp = Z0.rho
            # ellipsoid tube: outer ellipsoid of the box (Loewner n-blowup)
            W_ell = Ellipsoid(np.zeros(n), n * np.diag(r ** 2))
            X0e = Ellipsoid(np.zeros(n), n * np.diag(np.array([0.5, 0.5]) ** 2))
            ell_supp = ell_tight_supp(A, X0e, W_ell, N)
            t0 = time.perf_counter()
            _ = ell_supp(dirs[0])
            t_ell_per_dir = time.perf_counter() - t0
            t_ell_full = ell_full_tube_time(A, X0e, W_ell, N, dirs)

        e_mean, e_max, e_min = gaps(ell_supp, A, X0_supp, W_supp, N, dirs)
        z_mean, z_max, z_min = gaps(zono_supp, A, X0_supp, W_supp, N, dirs)
        # Native geometry = the representation that matches the disturbance set
        # exactly (ellipsoid for ellipsoidal W, zonotope for box W). On its
        # native geometry the tube is machine-epsilon exact per query direction;
        # the mismatched one pays only the one-off cost of fitting a mismatched
        # primitive (box<-ellipsoid eigen-box, or ellipsoid<-box Loewner
        # blow-up), NOT any wrapping loss.
        native = "zonotope" if WQ is None else "ellipsoid"
        # native_geometry_match: which representation matches the disturbance
        # geometry exactly (this decides the tightness contest tautologically, so
        # it is reported as a fact about the scenario, NOT as a "winner").
        native_geometry_match = native
        # fair full-tube-vs-full-tube slowdown of the ellipsoid method
        ell_full_vs_zono = t_ell_full / t_zono if t_zono > 0 else float("nan")
        rows.append(dict(scenario=name, kappa=kappa, dim=n, N=N, n_dirs=len(dirs),
                         ell_mean_gap=e_mean, ell_max_gap=e_max, ell_min_gap=e_min,
                         zono_mean_gap=z_mean, zono_max_gap=z_max, zono_min_gap=z_min,
                         ell_per_dir_runtime=t_ell_per_dir,
                         ell_full_runtime=t_ell_full,
                         zono_runtime=t_zono,
                         ell_full_vs_zono_slowdown=ell_full_vs_zono,
                         native_geometry_match=native_geometry_match))
        print(f"{name:24s} ell_mean={e_mean:12.4e} zono_mean={z_mean:9.4f} "
              f"native={native:9s}  ell_full/zono={ell_full_vs_zono:7.1f}x "
              f"over {len(dirs)} dirs")

    path = os.path.join(RESULTS, "ell_vs_zono.csv")
    with open(path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {path}")
    # sanity: both methods must be SOUND (min gap >= -tiny) on every scenario
    for r in rows:
        assert r["ell_min_gap"] >= -1e-6, f"ellipsoid unsound in {r['scenario']}"
        assert r["zono_min_gap"] >= -1e-6, f"zonotope unsound in {r['scenario']}"
    print("soundness OK (both methods over-approximate the exact reach set)")


def _nonnormal_A(n, rho_spec, rng):
    """Build a NON-NORMAL (non-orthogonal) stable matrix in R^n.

    A = V diag(lambda) V^{-1} with a random, well-conditioned but NON-orthogonal
    similarity V and real eigenvalues inside the unit disk scaled to spectral
    radius rho_spec. Because V is not orthogonal, A A^T != A^T A, so the dynamics
    genuinely mix directions and rotate anisotropy across steps — unlike an
    orthogonal A, which preserves isotropy of an isotropic disturbance."""
    V = np.eye(n) + 0.6 * rng.standard_normal((n, n))
    # keep V well away from singular
    while abs(np.linalg.det(V)) < 0.1:
        V = np.eye(n) + 0.6 * rng.standard_normal((n, n))
    lam = rng.uniform(0.3, 1.0, size=n)
    lam = rho_spec * lam / lam.max()
    A = V @ np.diag(lam) @ np.linalg.inv(V)
    return A


def run_highdim():
    """High-dimension sweep with a NON-NORMAL A and an ANISOTROPIC disturbance.

    Orthogonal A keeps an isotropic disturbance isotropic and never stresses
    anisotropic accumulation; a non-normal A rotates and mixes an anisotropic W
    across steps, which is the regime that actually taxes a box/ellipsoid fit.
    Ellipsoid uses its native (per-QUERY-direction) KV tight tube; the zonotope
    over-approximates the ellipsoidal W by its eigen-box (sound). Both are scored
    against the SAME exact reach-set support."""
    rows = []
    N = 12
    rng_local = np.random.default_rng(31)
    dims = [4, 8, 16, 32]
    for n in dims:
        A = _nonnormal_A(n, 0.9, rng_local)
        dirs = unit_dirs(n, 120)
        # anisotropic ellipsoidal disturbance: eigenvalues spanning kappa=100
        d = np.geomspace(0.04, 0.04 / 100.0, n)
        rot = np.linalg.qr(rng_local.standard_normal((n, n)))[0]
        WQ = rot @ np.diag(d) @ rot.T
        WQ = 0.5 * (WQ + WQ.T)
        W_ell = Ellipsoid(np.zeros(n), WQ)
        W_supp = W_ell.rho
        X0_Q = 0.25 * np.eye(n)
        X0e = Ellipsoid(np.zeros(n), X0_Q)
        X0_supp = X0e.rho

        ell_supp = ell_tight_supp(A, X0e, W_ell, N)
        t0 = time.perf_counter()
        _ = ell_supp(dirs[0])
        t_ell_per_dir = time.perf_counter() - t0
        t_ell_full = ell_full_tube_time(A, X0e, W_ell, N, dirs)

        Z0 = Zonotope.outer_of_ellipsoid(np.zeros(n), X0_Q)
        Wz = Zonotope.outer_of_ellipsoid(np.zeros(n), WQ)
        t0 = time.perf_counter()
        ztube = reach_tube_zonotope(A, Z0, Wz, N, max_order=None)
        t_zono = time.perf_counter() - t0
        zono_supp = ztube[-1].rho

        e_mean, e_max, e_min = gaps(ell_supp, A, X0_supp, W_supp, N, dirs)
        z_mean, z_max, z_min = gaps(zono_supp, A, X0_supp, W_supp, N, dirs)
        ell_full_vs_zono = t_ell_full / t_zono if t_zono > 0 else float("nan")
        rows.append(dict(scenario=f"nonnormal_aniso_n{n}", kappa=100.0, dim=n,
                         N=N, n_dirs=len(dirs),
                         ell_mean_gap=e_mean, ell_max_gap=e_max, ell_min_gap=e_min,
                         zono_mean_gap=z_mean, zono_max_gap=z_max, zono_min_gap=z_min,
                         ell_per_dir_runtime=t_ell_per_dir,
                         ell_full_runtime=t_ell_full,
                         zono_runtime=t_zono,
                         ell_full_vs_zono_slowdown=ell_full_vs_zono,
                         native_geometry_match="ellipsoid"))
        print(f"nonnormal_aniso_n{n:<3d} ell_mean={e_mean:12.4e} "
              f"zono_mean={z_mean:9.4f}  ell_full/zono={ell_full_vs_zono:7.1f}x "
              f"over {len(dirs)} dirs")

    path = os.path.join(RESULTS, "ell_vs_zono_highdim.csv")
    with open(path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {path}")
    for r in rows:
        assert r["ell_min_gap"] >= -1e-6, f"ellipsoid unsound in {r['scenario']}"
        assert r["zono_min_gap"] >= -1e-6, f"zonotope unsound in {r['scenario']}"
    print("high-dim soundness OK (non-normal A, anisotropic W)")


if __name__ == "__main__":
    run()
    print()
    print("=== high-dimension non-normal / anisotropic sweep ===")
    run_highdim()
