"""
nfl.py - Closed-loop ellipsoidal reachability for neural feedback loops.

System:  x_{k+1} = A x_k + B * pi(x_k) (+ w_k),   w_k in W (bounded),
         pi a small ReLU MLP controller (numpy weights, nn_bounds.ReLUMLP).

Per step k (ellipsoidal method):
  1. Relax pi over the current ellipsoid E_k:  pi(x) in K x + d (+) Ellipsoid(0, D)
     (sound CROWN-style relaxation, nn_bounds.relax_over_ellipsoid).
  2. Closed-loop affine map  A_cl = A + B K ,  offset  b_cl = B d.
  3. Input (slack + disturbance) set  W_k = B*Ellipsoid(0,D)  (+)  W.
  4. E_{k+1} = tight external Minkowski sum  minksum_ext(A_cl*E_k + b_cl, W_k, l),
     kept tight along each chosen safety direction l  (ellreach Asset A / C).

Box baseline: interval bound propagation of the SAME relaxation
  (K x + d (+) interval slack), propagated as an axis-aligned box. This is the
  WEAKEST sound set representation (an ablation), not a competitive baseline.

Zonotope baseline (the competitive, correlation-carrying baseline): propagate
  the SAME NN relaxation through a zonotope tube. The closed-loop affine map is
  applied exactly to the zonotope, and the slack set B*(K x + d slush) plus the
  disturbance W are added by EXACT zonotope Minkowski sum (concatenate
  generators), with Girard order reduction to keep the generator count bounded.
  Zonotopes are the representation the mainstream NFL tools (CORA, JuliaReach,
  poly/hybrid-zonotope backward reachability) actually use, so this is the
  head-to-head that matters.

All three are sound over-approximations; we compare their support along the
safety normal, their volume, and whether a safety half-space c.x <= b is
verified.

Outputs paper-1/results/*.csv. Includes a Monte-Carlo containment check that
sampled true closed-loop trajectories stay inside the ellipsoidal tube.
"""
from __future__ import annotations

import csv
import os
import sys

import numpy as np

_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(_HERE, "..", "python"))

from ellreach import Ellipsoid, minksum_ext  # noqa: E402
from zonotope import Zonotope  # noqa: E402
from nn_bounds import ReLUMLP, relax_over_ellipsoid, relax_over_box  # noqa: E402

RESULTS = os.path.join(_HERE, "results")
os.makedirs(RESULTS, exist_ok=True)


# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------
def _sqrtm(Q):
    w, V = np.linalg.eigh(0.5 * (Q + Q.T))
    w = np.clip(w, 0.0, None)
    return (V * np.sqrt(w)) @ V.T


def _reg(Q, rel_floor=1e-6, abs_floor=1e-12):
    """Min-eigenvalue floor (ET ode45reg / minQMatEig spirit).

    Keeps a shape matrix non-degenerate so the KV external Minkowski sum stays a
    valid *set* enclosure along every direction: minksum_ext silently returns a
    single operand when the OTHER has zero support along the tight direction,
    which drops that operand's orthogonal extent. Flooring the eigenvalues to a
    small fraction of the operand's own scale prevents that while only inflating
    the set (enlarging Q keeps the over-approximation sound).
    """
    Q = 0.5 * (np.asarray(Q, float) + np.asarray(Q, float).T)
    w, V = np.linalg.eigh(Q)
    scale = float(np.max(w)) if w.size else 0.0
    floor = max(rel_floor * scale, abs_floor)
    w = np.clip(w, floor, None)
    return (V * w) @ V.T


def box_support(lo, hi, l):
    """max over x in [lo,hi] of l . x  (support of the box in direction l)."""
    l = np.asarray(l, float)
    return float(np.sum(np.where(l >= 0, l * hi, l * lo)))


def box_volume(lo, hi):
    return float(np.prod(np.maximum(hi - lo, 0.0)))


def zono_volume(Z: Zonotope):
    """Exact volume (area/hyper-volume) of a zonotope via convex-hull of its
    vertices. For 2-D and 3-D we enumerate vertices from sign combinations of a
    reduced generator set; if the generator count is large we instead sample the
    boundary via support directions (a sound *inner* estimate of the vertex hull,
    used only for reporting). Returns NaN when neither is tractable (n > 3)."""
    G = Z.G
    n, p = G.shape
    if n > 3:
        return float("nan")
    from scipy.spatial import ConvexHull
    if p <= 16:
        from itertools import product
        signs = np.array(list(product([-1.0, 1.0], repeat=p)))
        pts = Z.c + signs @ G.T
    else:
        # boundary sampling: exact support vertex for many directions (2-D/3-D)
        if n == 2:
            th = np.linspace(0.0, 2 * np.pi, 1441)
            L = np.stack([np.cos(th), np.sin(th)], axis=1)
        else:
            rng = np.random.default_rng(0)
            L = rng.standard_normal((4000, 3))
            L /= np.linalg.norm(L, axis=1, keepdims=True)
        pts = np.array([Z.c + G @ np.sign(l @ G) for l in L])
    try:
        return float(ConvexHull(pts).volume)
    except Exception:
        return float("nan")


# ---------------------------------------------------------------------------
# Ellipsoidal reach tube of the neural feedback loop
# ---------------------------------------------------------------------------
def ellipsoid_tube(A, B, net: ReLUMLP, E0: Ellipsoid, W: Ellipsoid, direction, N):
    """Propagate E0 for N steps, keeping the tube tight along `direction`.

    Returns list of (N+1) Ellipsoid.  W is the disturbance ellipsoid (may be a
    zero-shape ellipsoid for the disturbance-free case).
    """
    A = np.asarray(A, float)
    B = np.asarray(B, float)
    l = np.asarray(direction, float).reshape(-1)
    E = E0
    seq = [E]
    for _ in range(N):
        rel = relax_over_ellipsoid(net, E)
        A_cl = A + B @ rel.K
        b_cl = B @ rel.d
        # image of E under the closed-loop affine map
        E_img = E.affine(A_cl, b_cl)
        # slack set pushed through B:  B * Ellipsoid(0, D) = Ellipsoid(0, B D B^T)
        D_in = Ellipsoid(np.zeros(B.shape[0]), B @ rel.D @ B.T)
        # Regularize operands so neither is degenerate along l: a zero-support
        # operand would be silently dropped by minksum_ext (see _reg), breaking
        # the set enclosure. The floor only inflates the sets -> stays sound.
        E_img = Ellipsoid(E_img.q, _reg(E_img.Q))
        D_in = Ellipsoid(D_in.q, _reg(D_in.Q))
        # add slack, then disturbance, both tight along l
        E = minksum_ext(E_img, D_in, l)
        if np.any(W.Q):
            E = minksum_ext(E, Ellipsoid(W.q, _reg(W.Q)), l)
        seq.append(E)
    return seq


def box_tube(A, B, net: ReLUMLP, x_lo, x_hi, w_lo, w_hi, N):
    """Interval-bound-propagation baseline using the SAME CROWN relaxation.

    Propagates an axis-aligned box [x_lo, x_hi] for N steps. Returns list of
    (N+1) (lo, hi) tuples.
    """
    A = np.asarray(A, float)
    B = np.asarray(B, float)
    lo = np.asarray(x_lo, float).reshape(-1)
    hi = np.asarray(x_hi, float).reshape(-1)
    w_lo = np.asarray(w_lo, float).reshape(-1)
    w_hi = np.asarray(w_hi, float).reshape(-1)
    seq = [(lo.copy(), hi.copy())]
    for _ in range(N):
        rel = relax_over_box(net, lo, hi)
        # u(x) in K x + d (+) [d_lo, d_hi]. Bound u over the box:
        Kp = np.maximum(rel.K, 0.0)
        Km = np.minimum(rel.K, 0.0)
        u_lo = Kp @ lo + Km @ hi + rel.d + rel.d_lo
        u_hi = Kp @ hi + Km @ lo + rel.d + rel.d_hi
        # x_next = A x + B u + w, interval arithmetic (independent bounding)
        Ap = np.maximum(A, 0.0); Am = np.minimum(A, 0.0)
        Bp = np.maximum(B, 0.0); Bm = np.minimum(B, 0.0)
        nx_lo = Ap @ lo + Am @ hi + Bp @ u_lo + Bm @ u_hi + w_lo
        nx_hi = Ap @ hi + Am @ lo + Bp @ u_hi + Bm @ u_lo + w_hi
        lo, hi = nx_lo, nx_hi
        seq.append((lo.copy(), hi.copy()))
    return seq


def zono_tube(A, B, net: ReLUMLP, E0: Ellipsoid, W: Ellipsoid, N, max_order=30):
    """Zonotope reach tube using the SAME CROWN relaxation as the ellipsoid tube.

    The correlation-carrying, competitive baseline (Girard 2005 zonotopes; the
    representation CORA / JuliaReach actually use). Per step:

      1. Relax pi over the axis-aligned bounding box of the current zonotope Z_k:
         pi(x) in K x + d (+) box[d_lo, d_hi]  (identical NN relaxation).
      2. Closed-loop affine map A_cl = A + B K, offset b_cl = B d, applied
         EXACTLY to the zonotope (affine image of a zonotope is a zonotope).
      3. Add the slack set B*(residual box) and the disturbance W by EXACT
         Minkowski sum (generator concatenation - zero wrapping error for
         zonotopes), then apply Girard order reduction (sound over-approx) to
         cap the generator count at max_order * n.

    Returns list of (N+1) Zonotope. Sound: every operation over-approximates.
    """
    A = np.asarray(A, float)
    B = np.asarray(B, float)
    # initial zonotope: outer box of E0 in its eigenframe (contains E0)
    Z = Zonotope.outer_of_ellipsoid(E0.q, E0.Q)
    WZ = Zonotope.outer_of_ellipsoid(W.q, W.Q) if np.any(W.Q) else None
    seq = [Z]
    for _ in range(N):
        hw = np.sum(np.abs(Z.G), axis=1)          # bounding-box half-widths
        rel = relax_over_box(net, Z.c - hw, Z.c + hw)
        A_cl = A + B @ rel.K
        b_cl = B @ rel.d
        Z = Z.affine(A_cl, b_cl)
        # residual slack u - (K x + d) in [d_lo, d_hi]; center rc, half-widths rr
        rc = 0.5 * (rel.d_lo + rel.d_hi)
        rr = 0.5 * (rel.d_hi - rel.d_lo)
        # pushed through B: center B rc, generators B * diag(rr)
        Z = Z.minksum(Zonotope(B @ rc, B @ np.diag(rr)))
        if WZ is not None:
            Z = Z.minksum(WZ)
        Z = Z.reduce(max_order)
        seq.append(Z)
    return seq


# ---------------------------------------------------------------------------
# Monte-Carlo volume of the reported ellipsoid set (intersection of the
# per-direction ellipsoid family) -- the ONE consistent ellipsoid volume metric
# ---------------------------------------------------------------------------
def mc_intersection_volume(ells, n_samples=200000, pad=1e-9, seed=13):
    """Monte-Carlo estimate of the volume of the INTERSECTION of a family of
    ellipsoids -- the set the paper actually reports and that `mc_containment`
    checks (a point is contained iff it lies in EVERY direction-ellipsoid).

    Method: build the axis-aligned bounding box of the intersection (the
    element-wise intersection of the per-ellipsoid bounding boxes, which contains
    the intersection), draw uniform samples in that box, count the fraction that
    lie inside ALL ellipsoids, and scale by the box volume. This is the same
    membership test (`Ellipsoid.contains`) used by the containment check, so the
    reported volume and the reported set are one and the same object.

    Returns (volume_estimate, n_inside, n_samples) for reporting.
    """
    ells = list(ells)
    n = ells[0].dim
    # bounding box of each ellipsoid E(q,Q): q_i +/- sqrt(Q_ii); the intersection
    # is contained in the element-wise intersection of these boxes.
    lo = np.full(n, -np.inf)
    hi = np.full(n, np.inf)
    for E in ells:
        half = np.sqrt(np.clip(np.diag(E.Q), 0.0, None))
        lo = np.maximum(lo, E.q - half)
        hi = np.minimum(hi, E.q + half)
    lo -= pad
    hi += pad
    widths = np.maximum(hi - lo, 0.0)
    box_vol = float(np.prod(widths))
    if box_vol <= 0.0:
        return 0.0, 0, n_samples
    rng = np.random.default_rng(seed)
    pts = lo + rng.random((n_samples, n)) * widths
    # membership in every ellipsoid: (x-q)^T Q^{-1} (x-q) <= 1 for all E
    inside = np.ones(n_samples, dtype=bool)
    for E in ells:
        Qinv = np.linalg.inv(E.Q + 1e-12 * np.eye(n))
        d = pts - E.q
        quad = np.einsum("ij,jk,ik->i", d, Qinv, d)
        inside &= quad <= 1.0
        if not inside.any():
            break
    n_inside = int(inside.sum())
    vol = box_vol * n_inside / n_samples
    return float(vol), n_inside, n_samples


def mc_intersection_support(ells, c, n_samples=400000, pad=1e-9, seed=17):
    """Support rho(cap_i E_i, c) = max over x in the INTERSECTION of c.x, via
    Monte-Carlo (apples-to-apples single-set support along c).

    The per-direction ellipsoid tube kept tight ALONG c reports the support of a
    set re-optimized for c; that is not a single fixed set. The intersection of
    the whole per-direction family IS a single set, and its support along c is
    the honest single-set number to place next to the zonotope's support.

    Samples uniformly in the intersection's bounding box, keeps points inside all
    ellipsoids, and returns the max of c.x over them. Being an inner sampling, it
    is a slight UNDER-estimate of the true intersection support (conservative for
    the ellipsoid's benefit), so we also fall back to the tightest single
    per-direction support as a sound upper reference in the caller's prose.
    """
    ells = list(ells)
    n = ells[0].dim
    c = np.asarray(c, float).reshape(-1)
    lo = np.full(n, -np.inf)
    hi = np.full(n, np.inf)
    for E in ells:
        half = np.sqrt(np.clip(np.diag(E.Q), 0.0, None))
        lo = np.maximum(lo, E.q - half)
        hi = np.minimum(hi, E.q + half)
    lo -= pad
    hi += pad
    widths = np.maximum(hi - lo, 0.0)
    if np.any(widths <= 0.0):
        return float("nan")
    rng = np.random.default_rng(seed)
    pts = lo + rng.random((n_samples, n)) * widths
    inside = np.ones(n_samples, dtype=bool)
    for E in ells:
        Qinv = np.linalg.inv(E.Q + 1e-12 * np.eye(n))
        d = pts - E.q
        quad = np.einsum("ij,jk,ik->i", d, Qinv, d)
        inside &= quad <= 1.0
    if not inside.any():
        return float("nan")
    return float(np.max(pts[inside] @ c))


# ---------------------------------------------------------------------------
# Monte-Carlo containment check (soundness evidence)
# ---------------------------------------------------------------------------
def mc_containment(A, B, net, E0, W, ell_tubes_by_dir, N, n_traj=4000, seed=7):
    """Fraction of sampled closed-loop trajectory points contained in the
    ellipsoidal tube (intersection over all direction-tubes) at each step.

    A point is 'contained' iff it lies in every direction-ellipsoid at its step
    (the intersection of the per-direction ellipsoids is the reported tube).
    """
    rng = np.random.default_rng(seed)
    A = np.asarray(A, float)
    B = np.asarray(B, float)
    S0 = _sqrtm(E0.Q)
    n = E0.dim
    SW = _sqrtm(W.Q) if np.any(W.Q) else None

    total = 0
    inside = 0
    for _ in range(n_traj):
        # sample x0 uniformly inside E0
        u = rng.standard_normal(n)
        u /= max(np.linalg.norm(u), 1e-12)
        rad = rng.uniform(0.0, 1.0) ** (1.0 / n)
        x = E0.q + S0 @ (u * rad)
        for k in range(N + 1):
            ok = all(tube[k].contains(x, tol=1e-9) for tube in ell_tubes_by_dir)
            total += 1
            inside += int(ok)
            if k < N:
                w = np.zeros(n)
                if SW is not None:
                    uw = rng.standard_normal(n)
                    uw /= max(np.linalg.norm(uw), 1e-12)
                    rw = rng.uniform(0.0, 1.0) ** (1.0 / n)
                    w = SW @ (uw * rw)
                x = A @ x + B @ net.forward(x) + w
    return inside / total


# ---------------------------------------------------------------------------
# Per-step soundness assertions (recurrence + sampled-point bracketing)
# ---------------------------------------------------------------------------
def assert_step_soundness(A, B, net, ell_tube_l, l, N, n_samples=2000, seed=11,
                          rel_tol=1e-7):
    """Verify, for the ellipsoid tube kept tight along direction l, the two
    soundness facts the reviewer asked for:

      (a) Support recurrence: for every step k,
              rho(E_{k+1}, l) >= rho(A_cl . E_k image, l) + rho(slack + W, l)
          i.e. the KV external sum does not under-cover along l (it is tight,
          so equality up to rel_tol; we assert >= with a tolerance).
      (b) Bounding-box bracketing: the axis-aligned bounding box of each E_k
          contains sampled true closed-loop points that started inside E_0.

    Raises AssertionError on any violation (turns a silent soundness regression
    into a hard failure). `ell_tube_l` is the list of (N+1) ellipsoids for l.
    Note: (a) recomputes the same operands nfl.ellipsoid_tube uses, so it checks
    the recurrence the tube is actually built from.
    """
    A = np.asarray(A, float); B = np.asarray(B, float)
    l = np.asarray(l, float).reshape(-1)
    # (a) recurrence along l
    for k in range(N):
        E = ell_tube_l[k]
        rel = relax_over_ellipsoid(net, E)
        A_cl = A + B @ rel.K
        b_cl = B @ rel.d
        E_img = E.affine(A_cl, b_cl)
        D_in = Ellipsoid(np.zeros(B.shape[0]), B @ rel.D @ B.T)
        E_img = Ellipsoid(E_img.q, _reg(E_img.Q))
        D_in = Ellipsoid(D_in.q, _reg(D_in.Q))
        rhs = E_img.rho(l) + D_in.rho(l)
        lhs = ell_tube_l[k + 1].rho(l)
        # E_{k+1} was built by adding D_in (and W) to E_img tight along l, so
        # lhs must dominate the image+slack support along l.
        assert lhs >= rhs - rel_tol * (abs(rhs) + 1.0), (
            f"support recurrence violated at step {k}: "
            f"rho(E_next,l)={lhs:.6g} < image+slack={rhs:.6g}")
    # (b) bounding-box bracketing of sampled true trajectories
    rng = np.random.default_rng(seed)
    n = ell_tube_l[0].dim
    S0 = _sqrtm(ell_tube_l[0].Q)
    for _ in range(n_samples):
        u = rng.standard_normal(n); u /= max(np.linalg.norm(u), 1e-12)
        x = ell_tube_l[0].q + S0 @ (u * rng.uniform(0.0, 1.0) ** (1.0 / n))
        for k in range(N + 1):
            E = ell_tube_l[k]
            half = np.sqrt(np.clip(np.diag(E.Q), 0.0, None))
            lo, hi = E.q - half, E.q + half
            tol = 1e-7 * (np.abs(E.q) + 1.0)
            assert np.all(x >= lo - tol) and np.all(x <= hi + tol), (
                f"bounding-box bracketing violated at step {k}")
            if k < N:
                x = A @ x + B @ net.forward(x)
    return True


# ---------------------------------------------------------------------------
# benchmark driver
# ---------------------------------------------------------------------------
def run_benchmark(name, A, B, net, E0, W, safety_dirs, safety_bounds, N,
                  writer, mc=True):
    """Run ellipsoid + box + zonotope for a benchmark; write per-step CSV rows;
    return a summary dict (support gaps, volumes, verification, MC fraction)."""
    A = np.asarray(A, float); B = np.asarray(B, float)
    n = E0.dim
    half = np.sqrt(np.clip(np.diag(E0.Q), 0.0, None))
    x_lo0, x_hi0 = E0.q - half, E0.q + half
    if np.any(W.Q):
        wh = np.sqrt(np.clip(np.diag(W.Q), 0.0, None))
        w_lo, w_hi = -wh, wh
    else:
        w_lo = w_hi = np.zeros(n)

    # one ellipsoidal tube per safety direction (tight there); plus axis dirs
    all_dirs = list(safety_dirs) + [np.eye(n)[i] for i in range(n)] \
        + [-np.eye(n)[i] for i in range(n)]
    ell_tubes = [ellipsoid_tube(A, B, net, E0, W, d, N) for d in all_dirs]
    box_seq = box_tube(A, B, net, x_lo0, x_hi0, w_lo, w_hi, N)
    zono_seq = zono_tube(A, B, net, E0, W, N)

    # per-step soundness assertions along each safety direction (disturbance-free
    # bracketing; the MC check below covers the disturbance case with tolerance)
    if not np.any(W.Q):
        for j, c in enumerate(safety_dirs):
            assert_step_soundness(A, B, net, ell_tubes[j], c, N)

    # per-step CSV: for each safety dir, ellipsoid vs box vs zonotope support
    for k in range(N + 1):
        row = {"benchmark": name, "step": k}
        for j, (c, b) in enumerate(zip(safety_dirs, safety_bounds)):
            e_sup = ell_tubes[j][k].rho(c)   # tube-j is tight along dir c
            b_sup = box_support(box_seq[k][0], box_seq[k][1], c)
            z_sup = zono_seq[k].rho(c)       # exact zonotope support along c
            row[f"ell_support_d{j}"] = e_sup
            row[f"box_support_d{j}"] = b_sup
            row[f"zono_support_d{j}"] = z_sup
            row[f"safety_bound_d{j}"] = b
            row[f"ell_verified_d{j}"] = int(e_sup <= b)
            row[f"box_verified_d{j}"] = int(b_sup <= b)
            row[f"zono_verified_d{j}"] = int(z_sup <= b)
        # reported ellipsoid volume = MC volume of the INTERSECTION of the
        # per-direction ellipsoid family (the same set mc_containment checks),
        # NOT any single-direction ellipsoid -- one consistent metric.
        ell_vol_k, _, _ = mc_intersection_volume([tube[k] for tube in ell_tubes])
        row["ell_volume"] = ell_vol_k
        row["box_volume"] = box_volume(box_seq[k][0], box_seq[k][1])
        row["zono_volume"] = zono_volume(zono_seq[k])
        writer.writerow(row)

    mc_frac = mc_containment(A, B, net, E0, W, ell_tubes, N) if mc else float("nan")

    summary = {"benchmark": name, "N": N, "mc_containment": mc_frac}
    for j, (c, b) in enumerate(zip(safety_dirs, safety_bounds)):
        e_sup = ell_tubes[j][N].rho(c)
        b_sup = box_support(box_seq[N][0], box_seq[N][1], c)
        z_sup = zono_seq[N].rho(c)
        summary[f"ell_support_final_d{j}"] = e_sup
        summary[f"box_support_final_d{j}"] = b_sup
        summary[f"zono_support_final_d{j}"] = z_sup
        summary[f"support_gap_d{j}"] = b_sup - e_sup          # box - ellipsoid
        summary[f"zono_gap_d{j}"] = z_sup - e_sup             # zonotope - ellipsoid
        summary[f"safety_bound_d{j}"] = b
        summary[f"ell_verified_d{j}"] = int(e_sup <= b)
        summary[f"box_verified_d{j}"] = int(b_sup <= b)
        summary[f"zono_verified_d{j}"] = int(z_sup <= b)
    # final-step reported ellipsoid volume = MC volume of the intersection of
    # the per-direction ellipsoid family (consistent with mc_containment).
    ell_vol_final, ell_vol_ninside, ell_vol_nsamp = mc_intersection_volume(
        [tube[N] for tube in ell_tubes])
    summary["ell_volume_final"] = ell_vol_final
    summary["ell_volume_mc_inside"] = float(ell_vol_ninside)
    summary["ell_volume_mc_samples"] = float(ell_vol_nsamp)
    summary["box_volume_final"] = box_volume(box_seq[N][0], box_seq[N][1])
    summary["zono_volume_final"] = zono_volume(zono_seq[N])
    summary["zono_order_final"] = float(zono_seq[N].G.shape[1])
    # apples-to-apples single-set support along each safety normal c: support of
    # the intersection-of-ellipsoids (MAJOR review point). The per-direction tube
    # is re-optimized tight ALONG c, so ell_support_final_d{j} above is an
    # optimistic single-direction figure; the intersection support is the honest
    # single-set number to compare against the zonotope's single-set support.
    ell_isect_N = [tube[N] for tube in ell_tubes]
    for j, (c, b) in enumerate(zip(safety_dirs, safety_bounds)):
        summary[f"ell_isect_support_final_d{j}"] = mc_intersection_support(
            ell_isect_N, c)
    return summary


# ---------------------------------------------------------------------------
# benchmark definitions
# ---------------------------------------------------------------------------
def bench_double_integrator():
    """2D double integrator with a small ReLU controller (stabilizing-ish)."""
    dt = 0.2
    A = np.array([[1.0, dt], [0.0, 1.0]])
    B = np.array([[0.5 * dt * dt], [dt]])
    # ReLU controller approximating a stabilizing gain u ~ -K[x1;x2].
    # Build a small MLP whose linear-region behaviour is contractive.
    rng = np.random.default_rng(0)
    net = ReLUMLP.random([2, 8, 1], seed=5, scale=0.5)
    # bias the net toward negative feedback by scaling final layer
    W_last, b_last = net.weights[-1]
    net.weights[-1] = (0.8 * W_last, b_last)
    E0 = Ellipsoid(np.array([0.7, 0.0]), np.diag([0.25, 0.25]))
    W = Ellipsoid(np.zeros(2), np.zeros((2, 2)))  # disturbance-free
    safety_dirs = [np.array([1.0, 0.0]), np.array([0.0, 1.0])]
    safety_bounds = [2.0, 2.0]
    return dict(name="double_integrator", A=A, B=B, net=net, E0=E0, W=W,
                safety_dirs=safety_dirs, safety_bounds=safety_bounds, N=15)


def bench_stable_linear():
    """Stable 2D linear plant + ReLU controller + small disturbance."""
    A = np.array([[0.9, 0.15], [-0.1, 0.85]])
    B = np.array([[0.1], [0.2]])
    net = ReLUMLP.random([2, 12, 1], seed=6, scale=0.5)
    E0 = Ellipsoid(np.array([1.0, 0.5]), np.diag([0.2, 0.2]))
    W = Ellipsoid(np.zeros(2), np.diag([0.01, 0.01]))
    safety_dirs = [np.array([1.0, 1.0]) / np.sqrt(2),
                   np.array([1.0, -1.0]) / np.sqrt(2)]
    safety_bounds = [2.5, 2.5]
    return dict(name="stable_linear", A=A, B=B, net=net, E0=E0, W=W,
                safety_dirs=safety_dirs, safety_bounds=safety_bounds, N=20)


def bench_rotation():
    """Rotation-dominated 2D plant - the CORRELATION showcase.

    A near-rotation makes the true reach set a thin, rotating, strongly
    correlated ellipse. The box baseline must bloat to an axis-aligned hull and
    loses badly along the anti-diagonal; the ellipsoid stays tight.
    """
    theta = 1.0
    A = 0.92 * np.array([[np.cos(theta), -np.sin(theta)],
                         [np.sin(theta), np.cos(theta)]])
    B = np.array([[0.05], [0.05]])
    net = ReLUMLP.random([2, 8, 1], seed=8, scale=0.4)
    E0 = Ellipsoid(np.array([1.2, 0.0]), np.diag([0.03, 0.6]))  # thin ellipse
    W = Ellipsoid(np.zeros(2), np.zeros((2, 2)))
    # safety normals aligned with the rotating thin axis to expose the gap
    safety_dirs = [np.array([1.0, 1.0]) / np.sqrt(2),
                   np.array([1.0, 0.0])]
    safety_bounds = [1.35, 1.6]
    return dict(name="rotation_showcase", A=A, B=B, net=net, E0=E0, W=W,
                safety_dirs=safety_dirs, safety_bounds=safety_bounds, N=12)


def bench_stable_4d():
    """Stable 4D linear plant with a ReLU controller (higher-dim check)."""
    rng = np.random.default_rng(3)
    M = rng.standard_normal((4, 4))
    # build a stable A (spectral radius < 1)
    U, _ = np.linalg.qr(M)
    A = U @ np.diag([0.85, 0.8, 0.9, 0.75]) @ U.T
    B = 0.1 * rng.standard_normal((4, 2))
    net = ReLUMLP.random([4, 16, 2], seed=9, scale=0.5)
    E0 = Ellipsoid(np.array([0.6, -0.4, 0.3, 0.2]), 0.1 * np.eye(4))
    W = Ellipsoid(np.zeros(4), 0.002 * np.eye(4))
    safety_dirs = [np.array([1.0, 0.0, 0.0, 0.0]),
                   np.ones(4) / 2.0]
    safety_bounds = [1.5, 2.0]
    return dict(name="stable_4d", A=A, B=B, net=net, E0=E0, W=W,
                safety_dirs=safety_dirs, safety_bounds=safety_bounds, N=18)


BENCHMARKS = [bench_double_integrator, bench_stable_linear,
              bench_rotation, bench_stable_4d]


def nonconvex_failure_regime(writer, seed=0):
    """Honest failure regime: a controller/plant whose one-step reachable set is
    strongly NON-CONVEX (multi-modal), so a single convex ellipsoid (like a
    single box) must cover the convex hull and is loose.

    We build a ReLU controller that acts as a hard switch (near-|x| feedback),
    push a wide input ellipsoid one step, sample the TRUE image, and report the
    ratio  vol(convex-ellipsoid enclosure) / vol(sampled true set estimate).
    A large ratio quantifies where poly/hybrid-zonotopes would win.
    """
    rng = np.random.default_rng(seed)
    # switch controller: u(x) ~ relu(g.x) - relu(-g.x) scaled => |g.x|-like,
    # producing a fold that splits the image into two lobes.
    g = np.array([[3.0, 0.0]])
    W1 = np.vstack([g, -g])                 # 2 hidden units
    b1 = np.zeros(2)
    W2 = np.array([[2.5, 2.5]])             # sum of the two relus = 2.5*|3 x1|
    b2 = np.array([-1.0])
    net = ReLUMLP([(W1, b1), (W2, b2)])
    A = np.array([[1.0, 0.0], [0.0, 0.2]])
    B = np.array([[0.0], [1.0]])            # controller drives x2 by |x1|
    E0 = Ellipsoid(np.array([0.0, 0.0]), np.diag([1.0, 0.04]))

    # ellipsoidal one-step enclosure (tight along axis dirs, intersect)
    dirs = [np.array([1.0, 0.0]), np.array([0.0, 1.0]),
            np.array([1.0, 1.0]) / np.sqrt(2), np.array([1.0, -1.0]) / np.sqrt(2)]
    encl = [ellipsoid_tube(A, B, net, E0, Ellipsoid(np.zeros(2), np.zeros((2, 2))),
                           d, 1)[1] for d in dirs]

    # sample true one-step image
    S0 = _sqrtm(E0.Q)
    n = 2
    pts = []
    for _ in range(20000):
        u = rng.standard_normal(n); u /= max(np.linalg.norm(u), 1e-12)
        x = E0.q + S0 @ (u * rng.uniform(0, 1) ** (1.0 / n))
        pts.append(A @ x + B @ net.forward(x))
    pts = np.array(pts)

    # true-set area estimate and its convex hull area, via fine grid occupancy.
    lo = pts.min(0) - 1e-9; hi = pts.max(0) + 1e-9
    G = 500
    dx = (hi[0] - lo[0]) / (G - 1); dy = (hi[1] - lo[1]) / (G - 1)
    cell = dx * dy
    ix = np.clip(((pts[:, 0] - lo[0]) / (hi[0] - lo[0]) * (G - 1)).astype(int), 0, G - 1)
    iy = np.clip(((pts[:, 1] - lo[1]) / (hi[1] - lo[1]) * (G - 1)).astype(int), 0, G - 1)
    occ = np.zeros((G, G), bool)
    occ[ix, iy] = True
    true_area = occ.sum() * cell

    from scipy.spatial import ConvexHull
    hull = ConvexHull(pts)
    hull_area = hull.volume       # 2-D "volume" == area

    # ellipsoid enclosure = INTERSECTION of the per-direction ellipses. Its area
    # is measured by the SAME Monte-Carlo intersection estimator used for the
    # benchmark volumes (one consistent metric: the reported set is the set whose
    # volume we report). Verify SOUND containment against the full intersection
    # (point in every ellipse).
    ell_area, _, _ = mc_intersection_volume(encl)
    contained = all(all(e.contains(p, tol=1e-7) for e in encl) for p in pts)

    # Two DISTINCT looseness numbers, reported separately for honesty:
    #  (1) intrinsic non-convexity penalty any CONVEX method (box OR ellipsoid)
    #      must pay: convex-hull area / true (non-convex) area.
    #  (2) THIS method's own looseness: our ellipsoid enclosure area / true area.
    #      This is >= (1) because our convex body also over-covers the hull; it is
    #      the honest "how loose is OUR reported set here" figure.
    nonconvexity_ratio = hull_area / max(true_area, 1e-12)
    method_looseness = ell_area / max(true_area, 1e-12)
    method_wasted_frac = 1.0 - max(true_area, 0.0) / max(ell_area, 1e-12)
    writer.writerow({"metric": "nonconvex_failure_regime",
                     "true_set_area_est": f"{true_area:.6g}",
                     "convex_hull_area": f"{hull_area:.6g}",
                     "ellipsoid_enclosure_area": f"{ell_area:.6g}",
                     "overcover_ratio": f"{nonconvexity_ratio:.6g}",
                     "method_looseness_ratio": f"{method_looseness:.6g}",
                     "method_wasted_fraction": f"{method_wasted_frac:.6g}",
                     "enclosure_sound_on_samples": int(contained)})
    print(f"[nonconvex failure] true_area~{true_area:.4g} "
          f"convexhull_area~{hull_area:.4g} "
          f"nonconvexity(hull/true)~{nonconvexity_ratio:.3g} "
          f"method(ell/true)~{method_looseness:.3g} "
          f"wasted~{100*method_wasted_frac:.1f}% "
          f"ell_encl_sound={contained}")
    return nonconvexity_ratio, method_looseness, contained


def main():
    # per-step CSV (union of all fieldnames across benchmarks; 2 safety dirs each)
    per_step_path = os.path.join(RESULTS, "tube_per_step.csv")
    summary_path = os.path.join(RESULTS, "summary.csv")

    fields = ["benchmark", "step",
              "ell_support_d0", "box_support_d0", "zono_support_d0",
              "safety_bound_d0",
              "ell_verified_d0", "box_verified_d0", "zono_verified_d0",
              "ell_support_d1", "box_support_d1", "zono_support_d1",
              "safety_bound_d1",
              "ell_verified_d1", "box_verified_d1", "zono_verified_d1",
              "ell_volume", "box_volume", "zono_volume"]

    summaries = []
    with open(per_step_path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for make in BENCHMARKS:
            cfg = make()
            s = run_benchmark(cfg["name"], cfg["A"], cfg["B"], cfg["net"],
                              cfg["E0"], cfg["W"], cfg["safety_dirs"],
                              cfg["safety_bounds"], cfg["N"], w)
            summaries.append(s)
            print(f"[{s['benchmark']:>18}] N={s['N']:>3}  "
                  f"MC={s['mc_containment']:.4f}  "
                  f"ell_d0={s['ell_support_final_d0']:.3f} "
                  f"zono_d0={s['zono_support_final_d0']:.3f} "
                  f"box_d0={s['box_support_final_d0']:.3f}  "
                  f"ell_vol={s['ell_volume_final']:.4g} "
                  f"zono_vol={s['zono_volume_final']:.4g} "
                  f"box_vol={s['box_volume_final']:.4g}")

    sfields = sorted({k for s in summaries for k in s})
    sfields = (["benchmark", "N", "mc_containment"]
               + [k for k in sfields if k not in ("benchmark", "N", "mc_containment")])
    with open(summary_path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=sfields)
        w.writeheader()
        for s in summaries:
            w.writerow(s)

    # honest failure regime (non-convex reachable set) -> its own CSV
    fr_path = os.path.join(RESULTS, "failure_regime.csv")
    with open(fr_path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=[
            "metric", "true_set_area_est", "convex_hull_area",
            "ellipsoid_enclosure_area", "overcover_ratio",
            "method_looseness_ratio", "method_wasted_fraction",
            "enclosure_sound_on_samples"])
        w.writeheader()
        nonconvex_failure_regime(w)
    print(f"Wrote {fr_path}")

    min_mc = min(s["mc_containment"] for s in summaries)
    print(f"\nMin MC containment fraction across benchmarks: {min_mc:.4f}")
    print(f"Wrote {per_step_path}")
    print(f"Wrote {summary_path}")
    if min_mc < 0.999:
        print("WARNING: containment below 0.999 - soundness suspect", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
