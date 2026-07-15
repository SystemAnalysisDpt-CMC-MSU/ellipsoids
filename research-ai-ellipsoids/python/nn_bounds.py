"""
nn_bounds - self-contained, SOUND CROWN-style ReLU relaxation (no torch).

We implement, from scratch on NumPy:

  * ``ReLUMLP``  - a small feed-forward ReLU network with numpy weights.
  * ``ibp_box`` - interval bound propagation (sound pre/post-activation boxes).
  * ``crown_affine`` - CROWN-style *backward* linear relaxation that returns
    two valid affine functions ``AL x + bL <= pi(x) <= AU x + bU`` holding for
    every ``x`` in a given input box.
  * ``relax_over_box`` / ``relax_over_ellipsoid`` - convert the CROWN bounds
    into a controller over-approximation ``pi(x) in K x + d (+) D`` where ``K``
    is a single affine map (the mid of the lower/upper slopes), ``d`` its
    offset, and ``D`` a conservative *slack set* (interval or ellipsoid) that
    over-approximates the residual ``pi(x) - (K x + d)`` over the region.

Soundness (proved by the Monte-Carlo test ``test_nn_bounds.py`` and argued in
paper-1/theory.md):

    For a ReLU with pre-activation bounds [l, u] on x:
      - if u <= 0:  relu(x) = 0                      (exact)
      - if l >= 0:  relu(x) = x                      (exact)
      - else (unstable):  lambda_L * x  <=  relu(x)  <=  (u/(u-l)) * (x - l)
        with any lower slope lambda_L in [0,1]; the upper line is the chord
        through (l,0) and (u,u). Both are valid for all x in [l,u].

    Composing these per-layer relaxations backward through the affine layers
    yields global affine bounds valid over the whole input box (standard CROWN).
    Any x-region contained in that box therefore inherits the bounds, so a
    K x + d (+) D over-approximation built from them contains pi(x) for all x
    in the region -> sound.

References: Zhang et al., "Efficient Neural Network Robustness Certification
with General Activation Functions" (CROWN), NeurIPS 2018; interval bound
propagation (Gowal et al. 2018). Clean-room NumPy implementation.
"""
from __future__ import annotations

import numpy as np

__all__ = [
    "ReLUMLP",
    "ibp_box",
    "crown_affine",
    "relax_over_box",
    "relax_over_ellipsoid",
    "BoxRelaxation",
    "EllRelaxation",
]


# ---------------------------------------------------------------------------
class ReLUMLP:
    """Feed-forward ReLU network: y = W_L ( relu(... relu(W_1 x + b_1) ...) )+b_L.

    ``weights`` is a list of (W, b) with W of shape (out, in). The final layer
    is linear (no ReLU applied to the output), matching a controller pi: R^n->R^m.
    """

    def __init__(self, weights):
        self.weights = [(np.asarray(W, float), np.asarray(b, float).reshape(-1))
                        for (W, b) in weights]
        for i, (W, b) in enumerate(self.weights):
            if W.shape[0] != b.shape[0]:
                raise ValueError(f"layer {i}: W rows {W.shape[0]} != b {b.shape[0]}")
        self.n_in = self.weights[0][0].shape[1]
        self.n_out = self.weights[-1][0].shape[0]

    def __call__(self, x):
        return self.forward(x)

    def forward(self, x):
        """Batched forward pass. x: (..., n_in) -> (..., n_out)."""
        x = np.asarray(x, float)
        single = x.ndim == 1
        if single:
            x = x[None, :]
        h = x
        n = len(self.weights)
        for i, (W, b) in enumerate(self.weights):
            h = h @ W.T + b
            if i < n - 1:
                h = np.maximum(h, 0.0)
        return h[0] if single else h

    @staticmethod
    def random(sizes, seed=0, scale=0.6):
        """Random small MLP with the given layer sizes [n_in, h1, ..., n_out]."""
        rng = np.random.default_rng(seed)
        weights = []
        for a, b in zip(sizes[:-1], sizes[1:]):
            W = scale * rng.standard_normal((b, a)) / np.sqrt(a)
            bias = 0.1 * rng.standard_normal(b)
            weights.append((W, bias))
        return ReLUMLP(weights)


# ---------------------------------------------------------------------------
def ibp_box(net: ReLUMLP, lo, hi):
    """Interval bound propagation over the input box [lo, hi].

    Returns ``pre`` = list of (l, u) pre-activation bounds per layer (the last
    entry is the network output bounds), which the CROWN pass consumes.
    """
    lo = np.asarray(lo, float).reshape(-1)
    hi = np.asarray(hi, float).reshape(-1)
    cur_lo, cur_hi = lo, hi
    pre = []
    n = len(net.weights)
    for i, (W, b) in enumerate(net.weights):
        Wp = np.maximum(W, 0.0)
        Wm = np.minimum(W, 0.0)
        z_lo = Wp @ cur_lo + Wm @ cur_hi + b
        z_hi = Wp @ cur_hi + Wm @ cur_lo + b
        pre.append((z_lo.copy(), z_hi.copy()))
        if i < n - 1:
            cur_lo = np.maximum(z_lo, 0.0)
            cur_hi = np.maximum(z_hi, 0.0)
    return pre


def _relu_relax(l, u):
    """Per-neuron ReLU linear relaxation coefficients.

    Returns (a_l, b_l, a_u, b_u) such that for all x in [l, u]:
        a_l * x + b_l  <=  relu(x)  <=  a_u * x + b_u.
    Vectorized over arrays l, u.
    """
    l = np.asarray(l, float)
    u = np.asarray(u, float)
    a_l = np.zeros_like(l)
    b_l = np.zeros_like(l)
    a_u = np.zeros_like(l)
    b_u = np.zeros_like(l)

    active = l >= 0.0                       # relu(x) = x exactly
    inactive = u <= 0.0                     # relu(x) = 0 exactly
    unstable = ~(active | inactive)

    a_l[active] = 1.0
    a_u[active] = 1.0

    # inactive -> all zero (already)

    # unstable: upper chord through (l,0)-(u,u); lower slope = adaptive (CROWN):
    #   choose lower slope 1 if u>=|l| else 0 (minimizes relaxation area).
    lu = l[unstable]
    uu = u[unstable]
    denom = uu - lu
    denom = np.where(np.abs(denom) < 1e-30, 1e-30, denom)
    slope_u = uu / denom
    a_u[unstable] = slope_u
    b_u[unstable] = -slope_u * lu
    lam = np.where(uu >= -lu, 1.0, 0.0)
    a_l[unstable] = lam
    b_l[unstable] = 0.0
    return a_l, b_l, a_u, b_u


def crown_affine(net: ReLUMLP, lo, hi):
    """CROWN-style backward relaxation over the input box [lo, hi].

    Returns (AL, bL, AU, bU) with shapes (n_out, n_in), (n_out,) such that
        AL @ x + bL  <=  net(x)  <=  AU @ x + bU     for all x in [lo, hi].
    """
    lo = np.asarray(lo, float).reshape(-1)
    hi = np.asarray(hi, float).reshape(-1)
    pre = ibp_box(net, lo, hi)
    n_layers = len(net.weights)
    n_out = net.n_out

    # Backward pass: maintain lower/upper linear maps from the OUTPUT to the
    # activation *after* the current layer. Start at the output (identity).
    AL = np.eye(n_out)
    AU = np.eye(n_out)
    cL = np.zeros(n_out)
    cU = np.zeros(n_out)

    for i in reversed(range(n_layers)):
        W, b = net.weights[i]
        # incorporate the affine layer z = W h + b (h = previous activation)
        # bounds so far are on the post-affine value of layer i (pre-activation
        # for the ReLU that follows, or the network output for the last layer).
        # First fold the constant b, then map through W.
        cL = cL + AL @ b
        cU = cU + AU @ b
        AL = AL @ W
        AU = AU @ W
        if i == 0:
            break
        # Now AL,AU act on the ReLU output of layer (i-1). Relax that ReLU
        # using its pre-activation bounds pre[i-1].
        pl, pu = pre[i - 1]
        a_l, b_l, a_u, b_u = _relu_relax(pl, pu)
        # For each column j (a neuron), pick lower or upper line depending on
        # the sign of the coefficient so the inequality direction is preserved.
        # Lower bound of output: rows of AL.
        posL = AL > 0.0
        slopeL = np.where(posL, a_l, a_u)
        biasL = np.where(posL, b_l, b_u)
        cL = cL + np.sum(AL * biasL, axis=1)
        AL = AL * slopeL
        # Upper bound of output: rows of AU.
        posU = AU > 0.0
        slopeU = np.where(posU, a_u, a_l)
        biasU = np.where(posU, b_u, b_l)
        cU = cU + np.sum(AU * biasU, axis=1)
        AU = AU * slopeU

    return AL, cL, AU, cU


# ---------------------------------------------------------------------------
class BoxRelaxation:
    """Controller over-approximation  pi(x) in K x + d  (+)  box[d_lo, d_hi].

    ``K``, ``d`` define the nominal affine map; ``d_lo``/``d_hi`` bound the
    residual slack ``pi(x) - (K x + d)`` component-wise over the region.
    """

    def __init__(self, K, d, d_lo, d_hi):
        self.K = np.asarray(K, float)
        self.d = np.asarray(d, float).reshape(-1)
        self.d_lo = np.asarray(d_lo, float).reshape(-1)
        self.d_hi = np.asarray(d_hi, float).reshape(-1)


class EllRelaxation:
    """Controller over-approximation  pi(x) in K x + d  (+)  Ellipsoid(0, D).

    ``D`` is the shape matrix of a slack ellipsoid centered at 0 that contains
    the residual set (built to enclose the interval slack box -> sound).
    """

    def __init__(self, K, d, D):
        self.K = np.asarray(K, float)
        self.d = np.asarray(d, float).reshape(-1)
        self.D = np.asarray(D, float)


def _affine_and_slack(net, lo, hi):
    """Shared core: returns K, d, and residual box [r_lo, r_hi] over [lo, hi].

    K,d = midpoint affine map of the CROWN lower/upper planes evaluated as a
    single linear map; the residual box bounds pi(x)-(Kx+d) soundly.
    """
    lo = np.asarray(lo, float).reshape(-1)
    hi = np.asarray(hi, float).reshape(-1)
    AL, bL, AU, bU = crown_affine(net, lo, hi)
    K = 0.5 * (AL + AU)
    d = 0.5 * (bL + bU)

    # Residual r(x) = pi(x) - (K x + d). Since  AL x + bL <= pi(x) <= AU x + bU,
    # we have  (AL-K) x + (bL-d) <= r(x) <= (AU-K) x + (bU-d)  for x in box.
    # Bound each affine envelope over the box by interval arithmetic.
    dLo = AL - K
    dUp = AU - K
    lo_env = _affine_box_min(dLo, bL - d, lo, hi)   # lower plane minimum
    hi_env = _affine_box_max(dUp, bU - d, lo, hi)   # upper plane maximum
    return K, d, lo_env, hi_env


def _affine_box_min(A, b, lo, hi):
    """min over x in [lo,hi] of A x + b, component-wise (rows of A)."""
    Ap = np.maximum(A, 0.0)
    Am = np.minimum(A, 0.0)
    return Ap @ lo + Am @ hi + b


def _affine_box_max(A, b, lo, hi):
    Ap = np.maximum(A, 0.0)
    Am = np.minimum(A, 0.0)
    return Ap @ hi + Am @ lo + b


def relax_over_box(net: ReLUMLP, lo, hi) -> BoxRelaxation:
    """Sound controller over-approximation over the input box [lo, hi]."""
    K, d, r_lo, r_hi = _affine_and_slack(net, lo, hi)
    return BoxRelaxation(K, d, r_lo, r_hi)


def relax_over_ellipsoid(net: ReLUMLP, E) -> EllRelaxation:
    """Sound controller over-approximation over an ellipsoid input region E.

    The CROWN bounds are computed over E's axis-aligned bounding box (which
    contains E), so they hold on E. The residual slack box is then enclosed by
    an ellipsoid (the smallest axis-aligned ellipsoid containing the box), so
    ``pi(x) in K x + d (+) Ellipsoid(0, D)`` for all x in E -> sound.
    """
    n = E.dim
    # axis-aligned bounding box of E: q_i +/- sqrt(Q_ii)
    half = np.sqrt(np.clip(np.diag(E.Q), 0.0, None))
    lo = E.q - half
    hi = E.q + half
    K, d, r_lo, r_hi = _affine_and_slack(net, lo, hi)
    # residual box [r_lo, r_hi] has center rc, half-widths rr.
    rc = 0.5 * (r_lo + r_hi)
    rr = 0.5 * (r_hi - r_lo)
    m = rc.shape[0]
    # Smallest axis-aligned ellipsoid containing box [-rr,rr] (centered at rc):
    #   {u : sum (u_i/(rr_i*sqrt(m)))^2 <= 1}  -> D = diag((rr*sqrt(m))^2).
    # Fold the residual center rc into d (it is a constant offset).
    d = d + rc
    D = np.diag((rr * np.sqrt(max(m, 1))) ** 2)
    return EllRelaxation(K, d, D)
