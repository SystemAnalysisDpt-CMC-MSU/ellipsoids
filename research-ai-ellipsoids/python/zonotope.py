"""
zonotope - minimal self-contained zonotope reachability (Girard 2005) used as a
pure-Python baseline for the ellipsoid-vs-zonotope head-to-head in Paper 2.
No MATLAB / CORA dependency. NumPy only.

Zonotope  Z(c, G) = { c + G b : ||b||_inf <= 1 },  c in R^n, G in R^{n x p}.
Support function:  rho(Z, l) = <l, c> + sum_i |<l, g_i>|   (exact, cheap).
Key fact used throughout: for a linear system x_{k+1}=A x_k + w with zonotopic
sets, the reachable set is EXACTLY a zonotope (Minkowski sum is exact, only the
generator count grows) -- so zonotopes have zero wrapping error there.
"""
from __future__ import annotations
import numpy as np

__all__ = ["Zonotope", "reach_tube_zonotope"]


class Zonotope:
    def __init__(self, c, G):
        self.c = np.asarray(c, float).reshape(-1)
        self.G = np.asarray(G, float)
        if self.G.ndim == 1:
            self.G = self.G.reshape(-1, 1)
        if self.G.shape[0] != self.c.shape[0]:
            raise ValueError("generator rows must match center dim")

    @property
    def dim(self):
        return self.c.shape[0]

    @property
    def order(self):
        return self.G.shape[1] / self.dim

    def rho(self, l):
        """Support value (exact): <l,c> + sum |<l, g_i>|."""
        l = np.asarray(l, float).reshape(-1)
        return float(l @ self.c + np.sum(np.abs(l @ self.G)))

    def affine(self, A, b=None):
        A = np.asarray(A, float)
        c = A @ self.c
        if b is not None:
            c = c + np.asarray(b, float).reshape(-1)
        return Zonotope(c, A @ self.G)

    def minksum(self, other: "Zonotope") -> "Zonotope":
        """EXACT Minkowski sum: concatenate generators, add centers."""
        return Zonotope(self.c + other.c, np.hstack([self.G, other.G]))

    @staticmethod
    def box(center, half_widths):
        center = np.asarray(center, float).reshape(-1)
        hw = np.asarray(half_widths, float).reshape(-1)
        return Zonotope(center, np.diag(hw))

    @staticmethod
    def outer_of_ellipsoid(center, Q):
        """Zonotope OUTER-approximation of E(center,Q): the bounding box in the
        eigenframe (generators = eigvec_i * sqrt(lambda_i)). Contains the
        ellipsoid (each |u_i| <= sqrt(lambda_i) on the ellipsoid). n generators."""
        w, V = np.linalg.eigh(0.5 * (np.asarray(Q, float) + np.asarray(Q, float).T))
        w = np.clip(w, 0.0, None)
        G = V * np.sqrt(w)          # columns scaled eigenvectors
        return Zonotope(center, G)

    def reduce(self, max_order):
        """Girard box-reduction: keep the largest generators, over-approximate the
        rest by an axis-aligned box (interval hull of the discarded generators).
        Preserves soundness (result contains the original zonotope)."""
        n = self.dim
        p = self.G.shape[1]
        if p <= max_order * n:
            return Zonotope(self.c, self.G.copy())
        norms1 = np.sum(np.abs(self.G), axis=0)
        norms_inf = np.max(np.abs(self.G), axis=0)
        metric = norms1 - norms_inf            # Girard's selection metric
        order = np.argsort(metric)             # smallest metric = most box-like -> reduce
        n_keep = int(max_order * n) - n        # leave room for the n box generators
        n_keep = max(n_keep, 0)
        keep_idx = order[len(order) - n_keep:] if n_keep > 0 else np.array([], int)
        red_idx = order[:len(order) - n_keep] if n_keep > 0 else order
        Gkeep = self.G[:, keep_idx]
        box_hw = np.sum(np.abs(self.G[:, red_idx]), axis=1)   # interval hull half-widths
        Gbox = np.diag(box_hw)
        return Zonotope(self.c, np.hstack([Gkeep, Gbox]) if Gkeep.size else Gbox)


def reach_tube_zonotope(A, Z0: Zonotope, W: Zonotope, N, max_order=None):
    """Exact (up to optional order reduction) zonotope reach tube of
    x_{k+1}=A x_k + w, x0 in Z0, w in W. Returns list of N+1 zonotopes."""
    A = np.asarray(A, float)
    Z = Z0
    seq = [Z]
    for _ in range(N):
        Z = Z.affine(A).minksum(W)
        if max_order is not None:
            Z = Z.reduce(max_order)
        seq.append(Z)
    return seq
