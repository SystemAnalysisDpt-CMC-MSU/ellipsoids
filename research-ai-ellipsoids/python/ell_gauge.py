"""
ell_gauge.py -- Neural gauge scheduling for certified ellipsoidal reach tubes.

Core idea (novel): the ellipsoidal external reach tube has a CONTINUOUS gauge
freedom absent from zonotopes/polytopes. For the one-step Minkowski sum of the
propagated set with the disturbance, the family

    Q_beta = (1 + 1/beta) * (A Q Aᵀ) + (1 + beta) * Q_W ,   beta > 0

is a SOUND outer bound of  (A E) ⊕ W  for EVERY beta > 0
(it dominates the true support in every direction; equality along the tight
direction iff beta matches the KV per-step value). The scalar schedule
{beta_1,...,beta_N} is thus a gauge: ANY positive schedule yields a valid outer
reach tube, but different schedules give different tightness. Classical KV picks
beta myopically (tight along a fixed direction each step). We instead LEARN a
policy beta_theta(features) -- a small NN whose output is mapped through softplus
so beta>0 always -- trained across many systems to minimize a global objective
(final-set log-volume). Soundness is a HARD STRUCTURAL INVARIANT: it holds for
ANY theta, so the learned policy improves tightness with certified-by-construction
soundness. This is amortized optimal ellipsoidal reachability.
"""
from __future__ import annotations
import numpy as np
from ellreach import Ellipsoid

__all__ = ["gauge_step", "myopic_beta", "rollout", "GaugePolicy",
           "tube_logvol", "features"]


def gauge_step(E: Ellipsoid, A, W: Ellipsoid, beta) -> Ellipsoid:
    """One sound gauge step: Q_beta = (1+1/beta) A Q Aᵀ + (1+beta) Q_W, beta>0."""
    A = np.asarray(A, float)
    beta = float(max(beta, 1e-9))
    Q1 = A @ E.Q @ A.T
    Q = (1.0 + 1.0 / beta) * Q1 + (1.0 + beta) * W.Q
    return Ellipsoid(A @ E.q + W.q, 0.5 * (Q + Q.T))


def myopic_beta(E: Ellipsoid, A, W: Ellipsoid, l) -> float:
    """KV-style myopic gauge: tight along fixed direction l (beta = p1/p2)."""
    A = np.asarray(A, float); l = np.asarray(l, float).reshape(-1)
    Q1 = A @ E.Q @ A.T
    p1 = np.sqrt(max(l @ Q1 @ l, 1e-300))
    p2 = np.sqrt(max(l @ W.Q @ l, 1e-300))
    return p1 / p2


def rollout(A, E0: Ellipsoid, W: Ellipsoid, betas):
    """Apply the gauge steps; return the tube (list of ellipsoids)."""
    E = E0; seq = [E]
    for b in betas:
        E = gauge_step(E, A, W, b); seq.append(E)
    return seq


def tube_logvol(A, E0, W, betas):
    """Final-set log-volume proxy log det Q_N (lower = tighter)."""
    return float(np.log(max(np.linalg.det(rollout(A, E0, W, betas)[-1].Q), 1e-300)))


def features(E: Ellipsoid, A, W: Ellipsoid, k, N):
    """Per-step features for the gauge policy (small, scale-aware)."""
    A = np.asarray(A, float)
    Q1 = A @ E.Q @ A.T
    wl = np.linalg.eigvalsh(W.Q)
    ql = np.linalg.eigvalsh(Q1)
    return np.array([
        np.log(max(ql.max(), 1e-12)),
        np.log(max(ql.min(), 1e-12)),
        np.log(max(wl.max(), 1e-12)),
        np.log(max(wl.min(), 1e-12)),
        0.5 * np.log(max(ql.max() / max(ql.min(), 1e-12), 1.0)),  # log anisotropy of AQAᵀ
        k / max(N, 1),
        1.0,                                                       # bias
    ])


class GaugePolicy:
    """Tiny numpy MLP: features -> scalar -> softplus -> beta>0 (sound for any weights)."""
    def __init__(self, n_feat=7, hidden=6, seed=0):
        rng = np.random.default_rng(seed)
        self.shapes = [(hidden, n_feat), (hidden,), (1, hidden), (1,)]
        self.n = sum(int(np.prod(s)) for s in self.shapes)
        self.theta = 0.1 * rng.standard_normal(self.n)

    def _unpack(self, theta):
        out, i = [], 0
        for s in self.shapes:
            k = int(np.prod(s)); out.append(theta[i:i+k].reshape(s)); i += k
        return out

    def beta(self, feat, theta=None):
        W1, b1, W2, b2 = self._unpack(self.theta if theta is None else theta)
        h = np.tanh(W1 @ feat + b1)
        z = float((W2 @ h + b2).reshape(-1)[0])
        return np.log1p(np.exp(np.clip(z, -30, 30))) + 1e-6      # softplus > 0

    def rollout_logvol(self, A, E0, W, N, theta=None):
        E = E0
        for k in range(N):
            b = self.beta(features(E, A, W, k, N), theta)
            E = gauge_step(E, A, W, b)
        return float(np.log(max(np.linalg.det(E.Q), 1e-300)))
