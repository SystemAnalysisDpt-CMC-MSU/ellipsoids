"""
pwa_nfl.py - Certified INNER-approximation of the reachable set of a ReLU
neural-feedback loop, via exact piecewise-affine (PWA) region decomposition and
Kurzhanski-Varaiya INTERNAL ellipsoidal tubes (ET "Asset B").

Novel point vs. mainstream NN reachability (CROWN, zonotope, Reach-SDP, POLAR):
those compute OUTER approximations (a superset of what the system can reach).
This computes a certified INNER approximation: a set every point of which is
*provably reachable*. That is the guarantee needed to CERTIFY reachability /
falsify safety ("the system can reach this unsafe region"), which an outer bound
can never provide.

System:  x_{k+1} = A x_k + B pi(x_k) + w_k,  w_k in W = Ellipsoid(0, Qw),
         pi a ReLU MLP (nn_bounds.ReLUMLP).

Soundness (by construction):
  A ReLU MLP is exactly affine on each activation region R (a polytope):
  pi(x) = K x + c  for x in R. Hence the closed loop is exactly affine there:
      x_{k+1} = A_cl x + b_cl + w,  A_cl = A + B K,  b_cl = B c.
  For a set S subset of R, the EXACT image {A_cl x + b_cl + w : x in S, w in W}
  is contained in the true one-step reachable set. If E_in is an ellipsoid with
  E_in subset (E_k intersect R), then:
      minksum_int(A_cl*E_in + b_cl, W, l)  subset  (A_cl E_in + b_cl) (+) W
                                            subset  true reachable set,
  because the KV internal sum is a subset of the exact Minkowski sum. The UNION
  over regions of such inner ellipsoids is therefore a certified inner set, for
  ANY subset of regions (anytime: more regions -> tighter, always sound).
"""
from __future__ import annotations
import numpy as np
from itertools import product
from ellreach import Ellipsoid, minksum_int, minkdiff_int, sqrtm_pos, orth_transl
from nn_bounds import ReLUMLP


def local_affine(mlp: ReLUMLP, x):
    """Return (K, c, G, h): the exact affine map pi(x)=K x + c valid on the
    activation region of x, and that region as {z : G z <= h} (row-normalised
    strict interior test uses G x < h). Built from the ReLU activation pattern."""
    x = np.asarray(x, float).reshape(-1)
    A_run = np.eye(mlp.n_in)          # affine map x -> current pre-activation input
    b_run = np.zeros(mlp.n_in)
    G_rows, h_rows = [], []
    n_layers = len(mlp.weights)
    K = np.zeros((mlp.n_out, mlp.n_in)); c = np.zeros(mlp.n_out)
    for i, (W, b) in enumerate(mlp.weights):
        z_map_A = W @ A_run            # pre-activation z = z_map_A x + z_map_b
        z_map_b = W @ b_run + b
        z = z_map_A @ x + z_map_b
        if i < n_layers - 1:           # hidden layer: ReLU
            active = z > 0
            # region constraints: active neuron -> z>=0 i.e. -z_row.x <= z_b;
            # inactive -> z<=0 i.e. z_row.x <= -z_b
            for j in range(len(z)):
                if active[j]:
                    G_rows.append(-z_map_A[j]); h_rows.append(z_map_b[j])
                else:
                    G_rows.append(z_map_A[j]); h_rows.append(-z_map_b[j])
            mask = active.astype(float)
            A_run = (mask[:, None] * z_map_A)
            b_run = mask * z_map_b
        else:                          # output layer: linear
            K, c = z_map_A, z_map_b
    G = np.array(G_rows) if G_rows else np.zeros((0, mlp.n_in))
    h = np.array(h_rows) if h_rows else np.zeros(0)
    return K, c, G, h


def inner_ellipsoid_in_region(E: Ellipsoid, G, h, p, margin=1e-9):
    """SOUND inner ellipsoid  E(p, s Q) subset  E intersect {Gx<=h},  centered at
    an interior point p (in E, strictly inside the region). Same shape Q as E,
    scaled by the largest s that keeps it inside BOTH E and every halfspace:

      * inside halfspace g.x<=h_i:  sqrt(s) <= (h_i - g.p)/sqrt(g'Qg);
      * inside E(q,Q):              sqrt(s) <= 1 - ||p-q||_{Q^{-1}}   (needs p in E).

    Centering at p (not at E's center q) is what lets DISTINCT regions each
    contribute an inner ellipsoid even when q lies on a region boundary. Returns
    None if p is not strictly interior to E and the region."""
    q, Q = E.q, E.Q
    p = np.asarray(p, float).reshape(-1)
    # inside-E budget: 1 - Mahalanobis distance of p from q
    Qr = Q + 1e-12 * np.eye(E.dim)
    d = float(np.sqrt(max((p - q) @ np.linalg.solve(Qr, (p - q)), 0.0)))
    if d >= 1.0 - margin:
        return None                        # p not strictly inside E
    sqrt_s = 1.0 - d
    if G.shape[0] > 0:
        slack = h - G @ p                  # >0 required (p strictly in region)
        if np.any(slack <= margin):
            return None
        gQg = np.maximum(np.einsum('ij,jk,ik->i', G, Q, G), 1e-300)
        sqrt_s = min(sqrt_s, float(np.min(slack / np.sqrt(gQg))))
    if sqrt_s <= 0:
        return None
    return Ellipsoid(p.copy(), (sqrt_s ** 2) * Q)


def _regions_in_ellipsoid(mlp, E: Ellipsoid, n_samples, rng):
    """Sample points inside E, return distinct activation regions as
    (K, c, G, h, representative_point). More samples -> more regions found."""
    L = sqrtm_pos(E.Q)
    seen = {}
    for _ in range(n_samples):
        u = rng.standard_normal(E.dim)
        u = u / max(np.linalg.norm(u), 1e-12) * (rng.uniform(0, 1) ** (1.0 / E.dim))
        x = E.q + L @ u
        K, c, G, h = local_affine(mlp, x)
        # key by activation region identity (its exact local affine map)
        key = (G.shape[0], hash(np.round(K, 6).tobytes()), hash(np.round(c, 6).tobytes()))
        if key not in seen:
            seen[key] = (K, c, G, h, x)
    return list(seen.values())


def certified_inner_onestep(mlp, A, B, E_list, W: Ellipsoid, ldir=None,
                            n_samples=200, seed=0):
    """One certified-inner step. E_list: union of ellipsoids (current inner set).
    Returns (out_list, meta) where meta[i] carries the region map for auditing."""
    A = np.asarray(A, float); B = np.asarray(B, float)
    rng = np.random.default_rng(seed)
    out, meta = [], []
    for E in E_list:
        for (K, c, G, h, xrep) in _regions_in_ellipsoid(mlp, E, n_samples, rng):
            E_in = inner_ellipsoid_in_region(E, G, h, xrep)   # inscribe at region interior point
            if E_in is None:
                continue
            A_cl = A + B @ K
            b_cl = B @ c
            E_img = E_in.affine(A_cl, b_cl)          # exact affine image (ellipsoid)
            l = ldir if ldir is not None else np.ones(E.dim)
            E_next = minksum_int(E_img, W, l)         # KV inner sum (Asset B)
            out.append(E_next)
            meta.append(dict(A_cl=A_cl, b_cl=b_cl, E_in=E_in, E_img=E_img))
    return out, meta


def internal_sum_witness(E_img: Ellipsoid, W: Ellipsoid, l, u):
    """Exact decomposition of a point of minksum_int(E_img,W,l). For |u|<=1,
    returns (y, a, w) with y in the internal sum, a in E_img, w in W, and
    y == a + w EXACTLY. Uses  E_int = { c + sub^T u },  sub = L_img + S L_W,
    a = c_img + L_img u,  w = c_W + L_W S^T u  (|S^T u|=|u|<=1 since S orthogonal).
    This gives an exact realizability witness -- no finite-direction membership test."""
    l = np.asarray(l, float).reshape(-1)
    u = np.asarray(u, float).reshape(-1)
    L_img = sqrtm_pos(E_img.Q)
    L_W = sqrtm_pos(W.Q)
    S = orth_transl(L_W @ l, L_img @ l)          # same S as minksum_int
    sub = L_img + S @ L_W
    y = (E_img.q + W.q) + sub.T @ u
    a = E_img.q + L_img @ u
    w = W.q + L_W @ (S.T @ u)
    return y, a, w


def certified_robust_inner_onestep(mlp, A, B, E_list, W: Ellipsoid, ldir=None,
                                   n_samples=200, seed=0):
    """ROBUST (min-max) certified inner step: the set of states GUARANTEED
    reachable despite a worst-case adversarial disturbance w in W. For a chosen
    x in E_in the nominal image point is A_cl x + b_cl; the states reachable for
    EVERY disturbance realization are  (A_cl E_in + b_cl) ⊖ W  (Minkowski
    difference / erosion). We inner-approximate the erosion with the KV internal
    difference minkdiff_int (ET Asset C's rare erosion), so the union is a sound
    inner-approximation of the robust (guaranteed-reachable) set. Regions where
    the erosion is empty (disturbance too large for that region) are dropped."""
    A = np.asarray(A, float); B = np.asarray(B, float)
    rng = np.random.default_rng(seed)
    out, meta = [], []
    for E in E_list:
        for (K, c, G, h, xrep) in _regions_in_ellipsoid(mlp, E, n_samples, rng):
            E_in = inner_ellipsoid_in_region(E, G, h, xrep)
            if E_in is None:
                continue
            A_cl = A + B @ K
            b_cl = B @ c
            E_img = E_in.affine(A_cl, b_cl)
            l = ldir if ldir is not None else np.ones(E.dim)
            if not E_img.is_bigger(W):            # erosion empty -> no robust core here
                continue
            E_rob = minkdiff_int(E_img, W, l)     # (image) ⊖ W , inner
            if E_rob is None:
                continue
            out.append(E_rob)
            meta.append(dict(A_cl=A_cl, b_cl=b_cl, E_in=E_in, E_img=E_img))
    return out, meta


def exact_regions_single_hidden(mlp, E: Ellipsoid):
    """COMPLETE activation-pattern enumeration for a SINGLE-hidden-layer ReLU net:
    iterates all 2^m hidden sign patterns (exhaustive, not sampled) and keeps those
    not separated from E by any single region constraint (a necessary support test)
    for which an interior point in E is found. NOTE: soundness does not depend on
    completeness -- a missed region only shrinks the (still-sound) inner set; the
    'complete' part is the exhaustive 2^m pattern loop, while the per-region
    interior-point search (_interior_point) is a sound heuristic. Only valid when
    len(mlp.weights)==2."""
    assert len(mlp.weights) == 2, "exact enumeration implemented for 1 hidden layer"
    (W1, b1), (W2, b2) = mlp.weights
    m = W1.shape[0]
    regions = []
    for pat in product([0, 1], repeat=m):
        pat = np.array(pat, float)
        # region: for active j: (W1 x + b1)_j >= 0 ; inactive: <= 0
        G = np.array([(-W1[j] if pat[j] > 0 else W1[j]) for j in range(m)])
        hh = np.array([(b1[j] if pat[j] > 0 else -b1[j]) for j in range(m)])
        # feasible in E iff no constraint separates E: for each row, min over E of
        # (h - g.x) must be >=0 somewhere jointly -> necessary check per-row here,
        # then confirm by an interior point search.
        if np.any(hh - (G @ E.q) + np.sqrt(np.einsum('ij,jk,ik->i', G, E.Q, G)) < 0):
            continue                              # a row separates E entirely -> empty
        # exact affine map on this pattern
        K = W2 @ (pat[:, None] * W1)
        c = W2 @ (pat * b1) + b2
        # representative interior point: project E center toward feasibility
        xrep = _interior_point(E, G, hh)
        if xrep is None:
            continue
        regions.append((K, c, G, hh, xrep))
    return regions


def _interior_point(E: Ellipsoid, G, h, n_try=800):
    """Find a point p in E ∩ {Gx<=h} that MAXIMIZES the inscribed-ellipsoid scale
    sqrt(s) = min( min_i (h_i - g_i p)/sqrt(g_i Q g_i),  1 - ||p-q||_{Q^-1} ),
    i.e. the p giving the largest sound inner ellipsoid E(p,sQ) in E∩region. Sound
    heuristic: failure to find a feasible p only drops the region (stays sound)."""
    q, Q = E.q, E.Q
    Qr = Q + 1e-12 * np.eye(E.dim)
    if G.shape[0] > 0:
        gQg = np.sqrt(np.maximum(np.einsum('ij,jk,ik->i', G, Q, G), 1e-300))
    L = sqrtm_pos(Q)
    rng = np.random.default_rng(0)

    def scale(p):
        d = np.sqrt(max((p - q) @ np.linalg.solve(Qr, (p - q)), 0.0))
        if d >= 1.0:
            return -1.0
        s = 1.0 - d
        if G.shape[0] > 0:
            slack = h - G @ p
            if np.any(slack <= 0):
                return -1.0
            s = min(s, float(np.min(slack / gQg)))
        return s

    best, best_s = None, 0.0
    if scale(q) > best_s:
        best, best_s = q.copy(), scale(q)
    for _ in range(n_try):
        u = rng.standard_normal(E.dim); u /= max(np.linalg.norm(u), 1e-12)
        p = q + L @ (u * rng.uniform(0, 1) ** (1.0 / E.dim))
        s = scale(p)
        if s > best_s:
            best, best_s = p, s
    return best


def certified_inner_tube(mlp, A, B, E0: Ellipsoid, W: Ellipsoid, N,
                         ldir=None, n_samples=200, cap=8, seed=0):
    """Multi-step certified inner tube. Caps the union to the `cap` largest-volume
    ellipsoids per step (dropping ellipsoids keeps the set inner -> still sound)."""
    tube = [[E0]]
    cur = [E0]
    for k in range(N):
        nxt, _ = certified_inner_onestep(mlp, A, B, cur, W, ldir,
                                         n_samples, seed + k)
        if not nxt:
            break
        nxt.sort(key=lambda e: e.volume(), reverse=True)
        cur = nxt[:cap]
        tube.append(cur)
    return tube
