# Theory — Soundness and Tightness of Ellipsoidal Neural-Feedback-Loop Tubes

We treat the discrete-time neural feedback loop (NFL)

    x_{k+1} = A x_k + B · π(x_k) + w_k ,   x_0 ∈ E_0 ,   w_k ∈ W ,          (1)

where `π : ℝ^n → ℝ^m` is a ReLU MLP controller, `E_0 = E(q_0, Q_0)` an ellipsoid,
and `W = E(0, Q_w)` a (possibly zero) bounded disturbance ellipsoid.

The reachable set at step `k` is
`R_k = { x_k : x_0 ∈ E_0, w_j ∈ W for j<k, dynamics (1) }`.

---

## 1. The controller over-approximation is sound

**Lemma 1 (sound local relaxation).**
Let `S ⊆ ℝ^n` be contained in an axis-aligned box `[lo, hi]`. The CROWN-style
backward relaxation (`nn_bounds.crown_affine`) returns matrices `A_L, A_U` and
vectors `b_L, b_U` with

    A_L x + b_L  ≤  π(x)  ≤  A_U x + b_U      (component-wise)   for all x ∈ [lo, hi].   (2)

*Proof sketch.* Each ReLU neuron with pre-activation interval `[l,u]` (obtained
by interval bound propagation, which is itself sound for monotone-composed
affine+ReLU layers) satisfies

    λ_L · z  ≤  relu(z)  ≤  (u/(u−l)) · (z − l)      for all z ∈ [l,u],  any λ_L ∈ [0,1].   (3)

For `u ≤ 0` both sides collapse to `0 = relu(z)`; for `l ≥ 0` they collapse to
`z = relu(z)`; for the unstable case the upper line is the chord through `(l,0)`
and `(u,u)` (convexity of relu on `[l,u]` ⇒ chord ≥ relu), and the lower line
`λ_L z` lies below relu because relu ≥ 0 ≥ λ_L z for z<0 and relu(z)=z ≥ λ_L z
for z≥0. Composing (3) backward through the linear layers, choosing the lower or
upper neuron line according to the sign of the accumulated coefficient (so each
inequality direction is preserved), yields (2). This is the standard CROWN
argument; the implementation mirrors it exactly. ∎

**Corollary 1 (K–d–slack form).** Define `K = (A_L+A_U)/2`, `d = (b_L+b_U)/2`.
The residual `r(x) := π(x) − (Kx+d)` satisfies, for all `x ∈ [lo,hi]`,

    (A_L−K)x + (b_L−d)  ≤  r(x)  ≤  (A_U−K)x + (b_U−d).

Bounding these two affine envelopes over the box by interval arithmetic gives a
constant box `[r_lo, r_hi] ⊇ { r(x) : x ∈ [lo,hi] }`. Hence

    π(x) ∈ Kx + d ⊕ [r_lo, r_hi]        for all x ∈ [lo, hi].               (4)

For the ellipsoidal method we enclose the residual box by the smallest
axis-aligned ellipsoid containing it, `D = diag((r̂ · √m)²)` with `r̂` the box
half-widths, so `[r_lo−r_c, r_hi−r_c] ⊆ E(0, D)` (a box of half-widths `r̂` in
`ℝ^m` is contained in the ellipsoid with semi-axes `r̂·√m`). Folding the residual
center `r_c` into `d`,

    π(x) ∈ Kx + d ⊕ E(0, D)             for all x ∈ [lo, hi].               (5)

Because we always take `[lo,hi]` to be a box that **contains** the current
region (the ellipsoid's axis-aligned bounding box in the ellipsoidal method, or
the current box in the interval baseline), (4)/(5) hold on the region. ∎

---

## 2. The propagated set is a true over-approximation

**Theorem 1 (soundness of the ellipsoidal tube).**
Suppose at step `k` we have `R_k ⊆ E_k`. Using the relaxation (5) over `E_k`,
form `A_cl = A + BK`, `b_cl = Bd`, `D_in = B·E(0,D) = E(0, B D Bᵀ)`, and

    E_{k+1} := ext-minksum( A_cl·E_k + b_cl ,  D_in ⊕ W ,  ℓ ).

Then `R_{k+1} ⊆ E_{k+1}`.

*Proof.* Take any reachable `x_{k+1}`. It equals `A x_k + B π(x_k) + w_k` for
some `x_k ∈ R_k ⊆ E_k` and `w_k ∈ W`. By (5) there is `s ∈ E(0,D)` with
`π(x_k) = K x_k + d + s`. Substituting,

    x_{k+1} = (A+BK) x_k + Bd + Bs + w_k
            = A_cl x_k + b_cl + (B s) + w_k .

Now `A_cl x_k + b_cl ∈ A_cl·E_k + b_cl` (exact affine image of an ellipsoid is
an ellipsoid — `ellreach.Ellipsoid.affine`), `Bs ∈ E(0, BDBᵀ)`, and `w_k ∈ W`.
The external ellipsoidal Minkowski sum `ext-minksum` produces an ellipsoid
containing the Minkowski sum of its arguments (KV property; `minksum_ext`
satisfies `ρ(E_{k+1},ℓ') ≥ ρ(A_cl E_k + b_cl, ℓ') + ρ(D_in⊕W, ℓ')` for the
tight direction and dominates for all others by construction), so `x_{k+1} ∈
E_{k+1}`. Since `x_{k+1}` was arbitrary, `R_{k+1} ⊆ E_{k+1}`. ∎

**Corollary 2 (whole-tube soundness).** With `E_0 ⊇ R_0` by construction,
induction on Theorem 1 gives `R_k ⊆ E_k` for all `k ≤ N`. The Monte-Carlo
containment experiment (`nfl.mc_containment`) samples true closed-loop
trajectories and confirms every sampled point lies in every step's tube —
containment fraction `1.0000` on all four benchmarks (see `results/summary.csv`),
empirical corroboration of the proof. The box baseline propagates the same sound
relaxation with interval arithmetic and is sound by the identical argument.

---

## 3. Tightness / tangency

**Proposition 1 (tangency along the chosen direction).**
`ext-minksum(E, F, ℓ)` returns the KV external sum that is *tight* along `ℓ`:

    ρ( ext-minksum(E,F,ℓ), ℓ )  =  ρ(E, ℓ) + ρ(F, ℓ)  =  ρ(E ⊕ F, ℓ),

i.e. the enclosing ellipsoid **touches** the true Minkowski sum `E ⊕ F` in the
supporting hyperplane with normal `ℓ` (equality of support functions along `ℓ`;
verified as a KV identity in `python/test_ellreach.py::test_kv_tightness_identity`
to `rtol=1e-10`). Choosing `ℓ` equal to a safety constraint normal `c` makes the
enclosure exactly tangent to the (relaxed) reachable set along `c` at that step,
so the reported support `ρ(E_{k+1}, c)` is the tightest an ellipsoidal enclosure
of `A_cl E_k + b_cl ⊕ D_in ⊕ W` can be in direction `c`.

The residual coming from the NN relaxation (`D`) is the only conservatism beyond
tangency: as `D → 0` (exact affine controller, e.g. all ReLUs stable over `E_k`)
the enclosure is the exact KV tight tube of the linear closed loop.

**Why ellipsoids beat the box — but only tie the zonotope.** The box (interval)
enclosure discards all cross-state correlation: it reports
`Σ_i |c_i|·(halfwidth_i)` along `c`, which for a rotation-dominated / strongly
correlated reachable ellipse over-counts by a factor that grows with the
condition number of `Q_k` and with the misalignment between the coordinate axes
and the ellipse's principal axes. The ellipsoid carries `Q_k` (the full
correlation) and reports `√(cᵀ Q_k c)`, tangent along `c`. The experiments
quantify this: on the rotation showcase the box support along the safety normal
is `13.64` vs the ellipsoid's `0.41` at `N=12`, a box/ellipsoid volume ratio of
`367.8 / 0.067 ≈ 5.5·10³`.

**Crucial caveat: that gap is the box's wrapping error, not an ellipsoid
advantage.** The box is the *weakest* sound set representation and is used here
only as an ablation. A **zonotope** (`python/zonotope.py`) also carries
cross-state correlation and adds Minkowski terms *exactly* (generator
concatenation, zero wrapping error). Propagating the identical NN relaxation
through a zonotope tube closes almost the entire box–ellipsoid gap: on the
rotation showcase the zonotope support along `c` is `0.42` (ellipsoid `0.41`) and
the zonotope volume `0.085` (ellipsoid `0.067`, a `1.27×` gap, not `5522×`). On
`double_integrator` the zonotope is actually *tighter* than the ellipsoid
(support `2.08` vs `2.77`; volume `2.56` vs `16.14`). So the tangency property
above makes the ellipsoid the tightest *ellipsoidal* enclosure along `c`, but its
advantage over the competitive zonotope baseline is incremental and not uniform;
the correct framing is **box = weakest ablation, zonotope = competitive
baseline**.

---

## 4. Scope of the guarantee

* Soundness holds for **any** ReLU MLP `π` and any linear/affine plant `(A,B)`;
  it does not require stability. Instability shows up as a growing (but still
  valid) tube.
* The disturbance case is handled by adding `W` in the same external sum
  (external/outer tube). A guaranteed *inner* (min-max) tube would use the ET
  internal builder (Asset B); not exercised here but compatible.
* The bound is a convex (ellipsoidal) over-approximation. When the true
  reachable set is strongly **non-convex** (multi-modal, produced by many
  simultaneously-active ReLU regions that split the set), a single ellipsoid —
  like a single box — must enclose the convex hull and can be loose; polynomial
  or hybrid zonotopes then win. This regime is reported honestly in the draft.
