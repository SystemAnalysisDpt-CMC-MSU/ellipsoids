"""
ellreach - dependency-light (NumPy; SciPy optional) re-creation of the
Ellipsoidal Toolbox (ET) kernel for reproducible AI + ellipsoids research.

Clean-room implementation of published Kurzhanski-Varaiya ellipsoidal-calculus
formulas (Kurzhanski & Varaiya, HSCC 2000) and the ET MATLAB sources
(elltoolboxcore/@ellipsoid/{minksum_ea,minksum_ia,minkdiff_ea,minkdiff_ia},
+gras/+la/mlorthtransl, +gras/+ellapx/+lreachplain/ExtEllApxBuilder).
Scope = the reusable kernel from 00-code-audit.md (Assets A & C).

Ellipsoid  E(q, Q) = { q + Q^(1/2) u : ||u|| <= 1 },  Q symmetric PSD.
Support function  rho(E, l) = l^T q + sqrt(l^T Q l).
"""
from __future__ import annotations
import numpy as np

__all__ = [
    "Ellipsoid", "minksum_ext", "minksum_int", "minksum_ext_multi",
    "minksum_int_multi", "minkdiff_ext", "minkdiff_int",
    "intersection_ext", "reach_tube_lti_discrete", "reach_tube_lti_discrete_tight",
    "reach_tube_lti_continuous", "sqrtm_pos", "orth_transl",
]


# ---------------------------------------------------------------------------
# linear-algebra helpers (port of gras.la.sqrtmpos and gras.la.mlorthtransl)
# ---------------------------------------------------------------------------
def sqrtm_pos(Q):
    """Symmetric PSD square root via eigendecomposition (ET: gras.la.sqrtmpos)."""
    Q = 0.5 * (np.asarray(Q, float) + np.asarray(Q, float).T)
    w, V = np.linalg.eigh(Q)
    w = np.clip(w, 0.0, None)
    return (V * np.sqrt(w)) @ V.T


def orth_transl(a, b):
    """
    Orthogonal matrix S with  S * unit(a) = unit(b)  (single-vector case of
    ET's gras.la.mlorthtransl). Rotation between two vectors (Rodrigues form),
    robust to the antipodal case.
    """
    a = np.asarray(a, float).reshape(-1)
    b = np.asarray(b, float).reshape(-1)
    n = a.shape[0]
    na, nb = np.linalg.norm(a), np.linalg.norm(b)
    if na < 1e-300 or nb < 1e-300:
        return np.eye(n)
    u, v = a / na, b / nb
    c = float(u @ v)
    if c > 1.0 - 1e-15:                     # already aligned
        return np.eye(n)
    if c < -1.0 + 1e-12:                    # antipodal: 180-deg rotation sending u -> -u
        # Householder reflection H = I - 2 u u' maps u -> -u and is orthogonal.
        return np.eye(n) - 2.0 * np.outer(u, u)
    # Rodrigues rotation sending u -> v
    K = np.outer(v, u) - np.outer(u, v)     # skew part
    S = np.eye(n) + K + (K @ K) / (1.0 + c)
    return S


# ---------------------------------------------------------------------------
class Ellipsoid:
    """Ellipsoid E(q, Q): center q (n,), shape matrix Q (n,n), Q = Q^T >= 0."""

    def __init__(self, q, Q):
        self.q = np.asarray(q, dtype=float).reshape(-1)
        self.Q = np.asarray(Q, dtype=float)
        n = self.q.shape[0]
        if self.Q.shape != (n, n):
            raise ValueError("Q must be n x n matching center length")
        self.Q = 0.5 * (self.Q + self.Q.T)

    @property
    def dim(self):
        return self.q.shape[0]

    @staticmethod
    def ball(center, radius):
        center = np.asarray(center, dtype=float).reshape(-1)
        return Ellipsoid(center, (radius ** 2) * np.eye(center.shape[0]))

    def rho(self, l):
        """Support value  rho(E, l) = l^T q + sqrt(l^T Q l)."""
        l = np.asarray(l, dtype=float).reshape(-1)
        return float(l @ self.q + np.sqrt(max(l @ self.Q @ l, 0.0)))

    def support_point(self, l):
        l = np.asarray(l, dtype=float).reshape(-1)
        Ql = self.Q @ l
        d = np.sqrt(max(l @ Ql, 0.0))
        return self.q.copy() if d == 0.0 else self.q + Ql / d

    def affine(self, A, b=None):
        """Exact image under x -> A x + b :  E(A q + b, A Q A^T)."""
        A = np.asarray(A, dtype=float)
        q = A @ self.q
        if b is not None:
            q = q + np.asarray(b, dtype=float).reshape(-1)
        return Ellipsoid(q, A @ self.Q @ A.T)

    def contains(self, x, tol=1e-9):
        x = np.asarray(x, dtype=float).reshape(-1)
        d = x - self.q
        Qr = self.Q + tol * np.eye(self.dim)
        return float(d @ np.linalg.solve(Qr, d)) <= 1.0 + 1e-6

    def is_bigger(self, other, tol=1e-9):
        """True if self ⊇ other when co-centered (ET isbigger): Q_self - Q_other >= 0."""
        w = np.linalg.eigvalsh(self.Q - other.Q)
        return bool(np.min(w) >= -tol)

    def volume(self):
        from math import gamma, pi
        n = self.dim
        c_n = pi ** (n / 2.0) / gamma(n / 2.0 + 1.0)
        return c_n * np.sqrt(max(np.linalg.det(self.Q), 0.0))

    def __repr__(self):
        return f"Ellipsoid(dim={self.dim}, q={self.q.round(3)})"


# ---------------------------------------------------------------------------
# Minkowski SUM  (Asset C)
# ---------------------------------------------------------------------------
def minksum_ext(E1: Ellipsoid, E2: Ellipsoid, l) -> Ellipsoid:
    """Tight EXTERNAL Minkowski sum, tight along l.

    Uses the family  Q_beta = (1 + 1/beta) Q1 + (1 + beta) Q2,  beta > 0, which
    is a SOUND outer bound of E1 ⊕ E2 for ANY beta > 0
    (l^T Q_beta l - (p1+p2)^2 = (p1/sqrt(beta) - p2 sqrt(beta))^2 >= 0),
    and is tight along l — rho = rho1 + rho2 — iff beta = p1/p2.
    When either support p_i is ~0 (a degenerate operand along l), use a
    scale-matched beta = sqrt(tr Q1 / tr Q2); the bound stays sound for any
    beta>0 (this fixes the earlier unsound branch that dropped a degenerate
    operand's orthogonal extent)."""
    l = np.asarray(l, float).reshape(-1)
    q = E1.q + E2.q
    p1 = np.sqrt(max(l @ E1.Q @ l, 0.0))
    p2 = np.sqrt(max(l @ E2.Q @ l, 0.0))
    tol = 1e-12
    if p1 <= tol or p2 <= tol:
        t1, t2 = np.trace(E1.Q), np.trace(E2.Q)
        if t1 <= tol and t2 <= tol:
            return Ellipsoid(q, np.zeros_like(E1.Q))
        if t1 <= tol:
            return Ellipsoid(q, E2.Q.copy())      # E1 is a point -> sum = E2 exactly
        if t2 <= tol:
            return Ellipsoid(q, E1.Q.copy())
        beta = np.sqrt(t1 / t2)                    # scale-matched, sound for any beta>0
    else:
        beta = p1 / p2                             # tight along l
    Q = (1.0 + 1.0 / beta) * E1.Q + (1.0 + beta) * E2.Q
    return Ellipsoid(q, 0.5 * (Q + Q.T))


def minksum_int(E1: Ellipsoid, E2: Ellipsoid, l) -> Ellipsoid:
    """Tight INTERNAL Minkowski sum, tight along l (ET minksum_ia).
    Q = (Q1^1/2 + S Q2^1/2)^T (...),  S orthogonal s.t. S Q2^1/2 l ∥ Q1^1/2 l."""
    l = np.asarray(l, float).reshape(-1)
    S1 = sqrtm_pos(E1.Q)
    S2 = sqrtm_pos(E2.Q)
    src = S1 @ l                       # reference direction (first ellipsoid)
    dst = S2 @ l
    S = orth_transl(dst, src)          # S * dst  ∥  src
    sub = S1 + S @ S2
    return Ellipsoid(E1.q + E2.q, sub.T @ sub)


def minksum_ext_multi(ells, l) -> Ellipsoid:
    """Tight EXTERNAL approximation of the k-fold Minkowski sum E_1 ⊕ ... ⊕ E_m,
    tight along l (KV / ET minksum_ea for arrays):
        q = sum q_i,  Q = (sum p_i) * (sum Q_i / p_i),  p_i = sqrt(l^T Q_i l).
    Support along l equals sum_i rho(E_i, l) exactly. This is the CORRECT joint
    construction; iterating pairwise minksum_ext instead accumulates wrapping and
    is strictly looser (the artifact flagged in review). Degenerate terms
    (p_i ~ 0) are handled by dropping their in-l component and adding their shape
    scale-matched, preserving soundness."""
    ells = list(ells)
    if len(ells) == 1:
        return Ellipsoid(ells[0].q.copy(), ells[0].Q.copy())
    l = np.asarray(l, float).reshape(-1)
    q = np.sum([E.q for E in ells], axis=0)
    ps = np.array([np.sqrt(max(l @ E.Q @ l, 0.0)) for E in ells])
    tol = 1e-12
    if np.all(ps <= tol):
        return Ellipsoid(q, np.sum([E.Q for E in ells], axis=0))
    # scale-matched floor for degenerate terms keeps the bound sound
    floor = tol * np.sqrt(np.array([max(np.trace(E.Q), tol) for E in ells]))
    ps = np.maximum(ps, floor)
    psum = float(np.sum(ps))
    Q = psum * np.sum([E.Q / p for E, p in zip(ells, ps)], axis=0)
    return Ellipsoid(q, 0.5 * (Q + Q.T))


def minksum_int_multi(ells, l) -> Ellipsoid:
    """Tight INTERNAL approximation of the k-fold Minkowski sum, tight along l
    (ET minksum_ia for arrays): Q^(1/2) = sum_i S_i Q_i^(1/2), with S_1 = I and
    S_i orthogonal aligning Q_i^(1/2) l with Q_1^(1/2) l; Q = (.)^T(.)."""
    ells = list(ells)
    if len(ells) == 1:
        return Ellipsoid(ells[0].q.copy(), ells[0].Q.copy())
    l = np.asarray(l, float).reshape(-1)
    sqrts = [sqrtm_pos(E.Q) for E in ells]
    src = sqrts[0] @ l
    sub = sqrts[0].copy()
    for Si in sqrts[1:]:
        sub = sub + orth_transl(Si @ l, src) @ Si
    q = np.sum([E.q for E in ells], axis=0)
    return Ellipsoid(q, sub.T @ sub)


# ---------------------------------------------------------------------------
# Minkowski DIFFERENCE / erosion  (Asset C — rare in other libraries)
# ---------------------------------------------------------------------------
def _diff_nonempty(E1, E2, l, tol=1e-12):
    """Direction l admissible for E1 ⊖ E2 : P = sqrt(l'Q1 l/l'Q2 l) < min root of det(Q1-R Q2)."""
    l = np.asarray(l, float).reshape(-1)
    d1 = l @ E1.Q @ l
    d2 = l @ E2.Q @ l
    if d2 <= tol:
        return False, 0.0
    P = np.sqrt(d1 / d2)
    # minimal root R of det(Q1 - R Q2) = 0, i.e. min generalized eigenvalue of
    # the symmetric-definite pencil (Q1, Q2): eigvals of L^-1 Q1 L^-T, Q2 = L L^T.
    L = np.linalg.cholesky(E2.Q)
    M = np.linalg.solve(L, np.linalg.solve(L, E1.Q).T).T
    R = float(np.min(np.linalg.eigvalsh(0.5 * (M + M.T))))
    return (P < R - 1e-12), P


def minkdiff_ext(E1: Ellipsoid, E2: Ellipsoid, l) -> Ellipsoid | None:
    """Tight EXTERNAL geometric difference E1 ⊖ E2 along l (ET minkdiff_ea).
    Requires E1 ⊇ E2 (co-centered). Q = (Q1^1/2 - S Q2^1/2)^T(...). rho = rho1 - rho2."""
    if not E1.is_bigger(E2):
        return None
    ok, _ = _diff_nonempty(E1, E2, l)
    if not ok:
        return None
    l = np.asarray(l, float).reshape(-1)
    S1 = sqrtm_pos(E1.Q)
    S2 = sqrtm_pos(E2.Q)
    S = orth_transl(S2 @ l, S1 @ l)     # S * Q2^1/2 l ∥ Q1^1/2 l
    sh = S1 - S @ S2
    return Ellipsoid(E1.q - E2.q, sh.T @ sh)


def minkdiff_int(E1: Ellipsoid, E2: Ellipsoid, l) -> Ellipsoid | None:
    """Tight INTERNAL geometric difference along l (ET minkdiff_ia).
    Q = (1 - 1/P) Q1 + (1 - P) Q2,  P = sqrt(l'Q1 l / l'Q2 l)."""
    if not E1.is_bigger(E2):
        return None
    ok, P = _diff_nonempty(E1, E2, l)
    if not ok:
        return None
    Q = (1.0 - 1.0 / P) * E1.Q + (1.0 - P) * E2.Q
    return Ellipsoid(E1.q - E2.q, Q)


# ---------------------------------------------------------------------------
# Ellipsoidal intersection (external) — Ros et al. 2002 "ellipsoidal
# intersection"; sound outer bound of E1 ∩ E2 for any lambda in [0,1].
# ---------------------------------------------------------------------------
def intersection_ext(E1: Ellipsoid, E2: Ellipsoid, n_lambda=51) -> Ellipsoid:
    """External ellipsoid enclosing E1 ∩ E2, minimizing volume over lambda∈[0,1]."""
    W1 = np.linalg.inv(E1.Q)
    W2 = np.linalg.inv(E2.Q)
    c1, c2 = E1.q, E2.q
    best = None
    best_logdet = np.inf
    for lam in np.linspace(0.0, 1.0, n_lambda):
        Wl = lam * W1 + (1 - lam) * W2
        Ql = np.linalg.inv(Wl)
        cl = Ql @ (lam * W1 @ c1 + (1 - lam) * W2 @ c2)
        dc = c2 - c1
        kappa = 1.0 - lam * (1 - lam) * float(dc @ W1 @ Ql @ W2 @ dc)
        kappa = max(kappa, 0.0)
        Qshaped = kappa * Ql
        ld = np.log(np.linalg.det(Qshaped) + 1e-300)
        if ld < best_logdet:
            best_logdet = ld
            best = Ellipsoid(cl, Qshaped)
    return best


# ---------------------------------------------------------------------------
# Reach tubes  (Asset A)
# ---------------------------------------------------------------------------
def reach_tube_lti_discrete(A, E0: Ellipsoid, W: Ellipsoid, dirs, N,
                            approx="ext"):
    """External/internal reach tube of x_{k+1}=A x_k + w, x0∈E0, w∈W.
    Returns list-over-directions of length-(N+1) ellipsoid sequences."""
    A = np.asarray(A, float)
    fn = minksum_ext if approx == "ext" else minksum_int
    tubes = []
    for l in dirs:
        l = np.asarray(l, float).reshape(-1)
        E = E0
        seq = [E]
        for _ in range(N):
            E = fn(E.affine(A), W, l)
            seq.append(E)
        tubes.append(seq)
    return tubes


def reach_tube_lti_discrete_tight(A, E0: Ellipsoid, W: Ellipsoid, dirs, N,
                                  approx="ext"):
    """CORRECT KV tight reach tube of x_{k+1}=A x_k + w, x0∈E0, w∈W.

    At step k the reachable set is the k-fold Minkowski sum
        X_k = A^k E0 ⊕ A^{k-1} W ⊕ ... ⊕ A^0 W,
    so for each direction l we build ONE ellipsoid via the joint k-fold tight
    approximation (minksum_ext_multi / minksum_int_multi), tight along l. Unlike
    reach_tube_lti_discrete (naive pairwise recursion, which wraps and loses
    tightness), the support along l here equals the exact reach-set support
    sum_j rho(A^j W, l) + rho(A^k E0, l) for the external case.
    Returns list-over-directions of length-(N+1) ellipsoid sequences."""
    A = np.asarray(A, float)
    fn = minksum_ext_multi if approx == "ext" else minksum_int_multi
    # precompute A^j E0 and A^j W
    Apow = [np.eye(A.shape[0])]
    for _ in range(N):
        Apow.append(A @ Apow[-1])
    tubes = []
    for l in dirs:
        l = np.asarray(l, float).reshape(-1)
        seq = [E0]
        for k in range(1, N + 1):
            terms = [E0.affine(Apow[k])]
            terms += [W.affine(Apow[j]) for j in range(k)]  # A^0 W .. A^{k-1} W
            seq.append(fn(terms, l))
        tubes.append(seq)
    return tubes


def reach_tube_lti_continuous(A, X0: Ellipsoid, G, l0, t_span, n_pts=200):
    """
    External ellipsoidal reach tube (single good direction l0) of the
    continuous system  dx/dt = A x + w,  w(t)^T G^{-1} w(t) <= 1,  x0 in X0.

    Ports ExtEllApxBuilder:  dQ/dt = A Q + Q A^T + pi Q + (1/pi) G,
    pi = sqrt(l^T G l / l^T Q l);   good direction  dl/dt = -A^T l.
    Requires SciPy. Returns (times, centers[n, nt], Q_arr[n,n,nt]).
    """
    from scipy.integrate import solve_ivp
    A = np.asarray(A, float)
    G = np.asarray(G, float)
    n = A.shape[0]
    q0 = X0.q.copy()
    Q0 = X0.Q.copy()
    l0 = np.asarray(l0, float).reshape(-1)
    y0 = np.concatenate([q0, l0, Q0.reshape(-1)])

    def rhs(t, y):
        q = y[:n]
        l = y[n:2 * n]
        Q = y[2 * n:].reshape(n, n)
        dq = A @ q
        dl = -A.T @ l
        num = max(l @ G @ l, 0.0)
        den = max(l @ Q @ l, 1e-300)
        pi = np.sqrt(num / den)
        dQ = A @ Q + Q @ A.T + pi * Q + (1.0 / max(pi, 1e-300)) * G
        dQ = 0.5 * (dQ + dQ.T)
        return np.concatenate([dq, dl, dQ.reshape(-1)])

    t_eval = np.linspace(t_span[0], t_span[1], n_pts)
    sol = solve_ivp(rhs, t_span, y0, t_eval=t_eval, rtol=1e-8, atol=1e-10,
                    method="RK45")
    centers = sol.y[:n, :]
    Qarr = sol.y[2 * n:, :].reshape(n, n, -1)
    return sol.t, centers, Qarr
