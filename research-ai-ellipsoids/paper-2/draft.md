# Tightness-Equivalence of KV Ellipsoidal and Zonotope Reach Tubes for Linear Systems: A Reproducible Benchmark and a Wrapping-Artifact Cautionary Note

**Working title:** *Ellipsoid or Zonotope for Linear Reachability? A Reproducible Benchmark Showing Per-Direction Tightness-Equivalence, and Why Naive Recursion Falsely Penalizes Ellipsoids*

**Authors:** [TBD]
**Version:** Draft with pure-Python ellipsoid-vs-zonotope head-to-head (no MATLAB/CORA dependency)

> **Scope note.** This is a **benchmark / reproducibility / methods note**, not a theoretical
> novelty. The tightness properties of the Kurzhanski–Varaiya (KV) ellipsoidal calculus and of
> Girard zonotope reachability are both classical and previously published. Our contribution is
> (i) a clean, MATLAB-free, exactly-referenced empirical comparison, and (ii) an explicit cautionary
> demonstration that a *naive implementation* of the ellipsoidal tube manufactures a large, entirely
> artificial "loss" that is easy to mistake for a property of the theory. We make no claim of new
> theory.

---

## Abstract

Ellipsoidal reach tubes, as implemented in the Kurzhanski–Varaiya (KV) ellipsoidal calculus, provide
*direction-tight* outer **and** inner approximations of reachable sets for discrete-time linear
systems under bounded disturbances. Despite this, practitioners routinely default to zonotopes. We
provide a reproducible, MATLAB-free empirical reference that compares the two representations against
an **exact** support-function truth. Our central, corrected finding is a **per-direction
tightness-equivalence**: for a linear system with convex ellipsoidal uncertainty, the KV joint
*k*-fold tight tube reproduces the **exact** reach-set support in *every* queried direction — the
support-function gap is machine epsilon (≤ 1.1×10⁻¹³ across a rotation-angle sweep, a
disturbance-conditioning sweep up to condition number κ=200, a disturbance-magnitude sweep, and a
state-dimension sweep to n=12). This matches the zonotope's exactness on its native (box) geometry.
Consequently the choice between the two representations is **not** decided by tightness on convex
sets; it is decided by (i) whether a *certified inner* bound is required (KV provides one directly;
zonotope tools do not), (ii) complexity scaling (fixed shape matrix / directions vs. growing
generator count), and (iii) downstream operations.

We further report a **cautionary methods finding**. A *naive* pairwise recursion for the ellipsoidal
tube — re-approximating each step with a single fixed direction — accumulates wrapping error and
manufactures a spurious blow-up: at κ=200 the naive tube's maximum support-function gap reaches
**904.74** (a **63.1×** over-approximation factor in the worst direction at the final step), while the
correct joint *k*-fold tight tube stays exact (max gap **9.6×10⁻¹⁴**) on the *same* problem. An
earlier version of this study attributed that blow-up to "ellipsoids losing at high anisotropy." That
was **wrong**: it was an artifact of the naive recursion, not a property of KV theory. We state this
correction explicitly and quantify the artifact as the paper's honest cautionary contribution.

Finally, in a direct pure-Python head-to-head we confirm that each representation is machine-epsilon
exact on its *native* uncertainty geometry (ellipsoid on ellipsoidal W, zonotope on box W), and that
the only residual gap is the one-off cost of fitting a *mismatched* primitive (a box to an ellipsoid,
or an ellipsoid to a box) — a fixed-complexity, single-object effect, not a wrapping loss.

---

## 1. Introduction

Set-based reachability analysis underlies formal safety verification for control systems, autonomous
vehicles, and neural-network-controlled plants. The choice of set representation — ellipsoid,
zonotope, polynomial zonotope, interval — affects tightness, certifiability, and cost. A common
informal belief is that zonotopes are simply "tighter" than ellipsoids for reachability. This note
examines that belief for *linear* systems and finds it does not survive contact with a correct
implementation and an exact reference.

The Kurzhanski–Varaiya (KV) ellipsoidal calculus provides *direction-tight* external and internal
approximation families for linear systems with ellipsoidal uncertainty: for a chosen direction the
outer ellipsoid is tangent to the true reachable set at that direction's support point, and the inner
ellipsoid touches it from inside. These are genuine guarantees. The subtlety that motivates this note
is *how* the tube is computed. At step *k* the reachable set is a *k*-fold Minkowski sum,
`A^k E₀ ⊕ A^{k-1} W ⊕ ... ⊕ A⁰ W`. The correct KV construction applies the **joint** *k*-fold
tight sum (`minksum_ea`/`minksum_ia` over the whole array) for each query direction; a *naive*
implementation instead recurses pairwise, `E_{k+1} = minksum(A E_k, W, l)`, re-approximating an
already-approximated ellipsoid at every step with a *fixed* direction. The naive recursion wraps and
loses tightness; the joint construction does not. Confusing the two is exactly the trap this note
documents.

The most-cited zonotope reachability tool, CORA, is MATLAB-only. Rather than take a proprietary
dependency, we implement a compact zonotope reach tube (Girard's method: exact linear map, exact
Minkowski sum, Girard box order-reduction) in **pure Python** (`python/zonotope.py`, NumPy only) and
run the head-to-head directly. The zonotope baseline is validated against exact 2ᵖ-vertex enumeration
and the exact Minkowski-sum identity (`python/oracle_tests/test_zonotope.py`), so its numbers are
trustworthy independent of CORA.

**Contributions (all empirical / methodological, not theoretical):**
1. An exact support-function reference for discrete-time LTI reach sets requiring no Monte-Carlo.
2. A four-regime empirical map showing the KV **joint** *k*-fold tight tube is machine-epsilon exact
   per direction — including at high disturbance anisotropy, where a naive tube fails.
3. A cautionary quantification of the naive-recursion wrapping artifact (up to 904.74 max gap / 63.1×
   at κ=200), with the explicit correction that this is an implementation deficiency, **not** a
   property of KV theory.
4. A pure-Python ellipsoid-vs-zonotope head-to-head confirming per-direction tightness-equivalence on
   convex sets and isolating the real differentiators (inner bounds, complexity).
5. A reproducible harness (`reproduce.sh`) that regenerates every number in this paper from scratch.

---

## 2. Method

### 2.1 System and Exact Reference

We study discrete-time LTI systems:

```
x_{k+1} = A x_k + w_k,   x_0 ∈ E_0,   w_k ∈ W
```

where E_0 = Ellipsoid(0, Q_0) and W = Ellipsoid(0, Q_w) are ellipsoids centered at the origin. The
*true* reachable set at step k has support function along direction m:

```
ρ_k(m) = ρ(A^k E_0, m) + Σ_{j=0}^{k-1} ρ(A^j W, m)
```

with ρ(Ellipsoid(q,Q), m) = q^T m + sqrt(m^T Q m). This formula is **exact** — it incurs no
approximation error. All support-function gaps in this paper are measured against this reference.

A Monte-Carlo cloud (2,000 point trajectories sampled uniformly from E_0 and W at each step) provides
a cross-check column (`mc_gap_ext`) in the CSVs. MC systematically *under*estimates the support due to
finite sampling, so `mc_gap_ext` (tube − MC) is always positive; it is a sanity column, not a
tightness metric.

### 2.2 Ellipsoidal Tubes (the correct joint k-fold construction)

We compute KV external (`approx="ext"`) and internal (`approx="int"`) reach tubes via
**`reach_tube_lti_discrete_tight`** from the `ellreach` kernel. For each query direction l this builds
*one* ellipsoid per time step as the **joint** *k*-fold tight Minkowski sum
(`minksum_ext_multi` / `minksum_int_multi`) of the terms `A^k E_0, A^{k-1} W, …, A^0 W`, tight along l.
Because the KV per-direction ellipsoid is tight along its own direction, evaluating its support along
that direction reproduces the exact reach-set support. Tightness metrics:

- **mean_gap_ext / max_gap_ext**: mean/max over directions and steps of (ext_ρ − exact_ρ) — ≥ 0.
- **mean_gap_int / max_gap_int**: mean/max over directions and steps of (exact_ρ − int_ρ) — ≥ 0.
- **vol_ext_final / vol_int_final**: volume of the direction-0 tube ellipsoid at the final step
  (reported for n ≤ 8; `nan` above, where the isotropic tube ellipsoid volume is not the metric of
  interest).

The *naive* pairwise tube (`reach_tube_lti_discrete`) is used **only** in §5 to quantify the artifact;
it is not used to produce the regime map in §3.

### 2.3 Regime Sweeps

Four sweeps are run; all results are in `paper-2/results/*.csv`.

| Sweep | Parameter | Fixed settings |
|---|---|---|
| 1 | Rotation angle θ ∈ [0, π] | n=2, ρ=0.95, N=10, σ_w=0.05 I |
| 2 | Disturbance conditioning κ ∈ [1, 200] | n=2, θ=π/4, N=10 |
| 3 | Disturbance-to-initial ratio r ∈ [0.001, 2] | n=2, θ=π/4, N=10, isotropic W |
| 4 | State dimension n ∈ {2, …, 12} | random orthogonal A×0.95, N=8 |

Each sweep uses 32 uniformly-spaced directions on the sphere (24 for the dimension sweep).

---

## 3. Results — the KV joint tight tube is exact in every regime

### 3.1 Regime 1: Rotation Angle

For A = 0.95·rot(θ) with isotropic disturbance W = 0.05·I, the external and internal tube gaps are
machine epsilon across all 17 angles from θ=0 to θ=π.

**Concrete numbers from `sweep_theta.csv`:**
- θ=0.000: mean_gap_ext = −7.01×10⁻¹⁷, max_gap_ext = 4.44×10⁻¹⁶, mean_gap_int = 3.05×10⁻¹⁶
- θ=π/4 (0.785): mean_gap_ext = 8.67×10⁻¹⁷, mean_gap_int = 8.74×10⁻¹⁷
- worst max gap over all θ: max_gap_int = 1.33×10⁻¹⁵

Verdict: exact for rotation-dominated isotropic systems (the reachable set is itself an ellipsoid at
each step).

### 3.2 Regime 2: Disturbance Conditioning (the corrected headline regime)

When the disturbance ellipsoid W has aspect ratio κ (σ_1/σ_2 = κ, area held fixed), the KV **joint**
tight tube remains machine-epsilon exact — including at extreme anisotropy. This directly corrects the
earlier version of this study, which reported large gaps here; those gaps were a naive-recursion
artifact (see §5).

**Concrete numbers from `sweep_kappa.csv`:**
- κ=1.0 (isotropic): mean_gap_ext = 1.32×10⁻¹⁷, max_gap_ext = 4.44×10⁻¹⁶
- κ=10.0: mean_gap_ext = 2.91×10⁻¹⁷, max_gap_ext = 1.78×10⁻¹⁵
- κ=100.0: mean_gap_ext = 6.27×10⁻¹⁶, max_gap_ext = 1.95×10⁻¹⁴
- κ=200.0: mean_gap_ext = **2.19×10⁻¹⁵**, max_gap_ext = **1.10×10⁻¹³**;
  mean_gap_int = −6.67×10⁻¹⁶, max_gap_int = 8.88×10⁻¹⁵

The external and internal tubes are exact along every queried direction at every κ, so the certified
inner–outer gap is also machine epsilon. (The `vol_ext_final` / `vol_int_final` columns grow with κ
because the reach set itself grows more anisotropic — this is the true set's shape, not an
approximation error; the direction-wise support gap is what measures tightness, and it is zero.)

Verdict: **disturbance anisotropy does not hurt the KV tight tube.** The representation is tight per
direction regardless of κ.

### 3.3 Regime 3: Disturbance-to-Initial Ratio

For isotropic W = r²·I and E_0 = I, sweeping r from 0.001 to 2.0, all gaps remain machine epsilon.

**Concrete numbers from `sweep_dist_ratio.csv`:**
- r=0.001: mean_gap_ext = −2.29×10⁻¹⁷
- r=1.0: mean_gap_ext = 5.97×10⁻¹⁷, max_gap_ext = 1.78×10⁻¹⁵
- r=2.0: mean_gap_ext = −4.44×10⁻¹⁷, max_gap_ext = 5.33×10⁻¹⁵

Verdict: disturbance magnitude does not affect tightness for spherical disturbances.

### 3.4 Regime 4: State Dimension

For random orthogonal A (scaled by 0.95) and isotropic W = 0.05·I, sweeping n from 2 to 12 over N=8
steps with 24 directions, the support-function gaps remain machine epsilon at all dimensions.

**Concrete numbers from `sweep_dim.csv`:**
- n=2: mean_gap_ext = −6.36×10⁻¹⁷, runtime_ext = 0.010s, runtime_int = 0.020s
- n=6: mean_gap_ext = −1.62×10⁻¹⁷, runtime_ext = 0.010s, runtime_int = 0.022s
- n=12: mean_gap_ext = 2.78×10⁻¹⁷, runtime_ext = 0.013s, runtime_int = 0.033s

Runtime grows modestly (internal tube 0.020s → 0.033s from n=2 to n=12). The MC cross-check column
`mc_gap_ext` grows from 0.985 (n=2) to 1.442 (n=12), reflecting the curse of dimensionality for
Monte-Carlo *sampling coverage*, not for the ellipsoidal tube (whose gap is machine epsilon at every
n).

Verdict: the KV tight tube scales well and stays exact with dimension for isotropic problems.

---

## 4. Regime Map Summary

| Regime | KV joint tight tube | Note |
|---|---|---|
| Isotropic disturbance, any rotation | **Exact** (≤ 1.3×10⁻¹⁵) | tightness-equivalent to zonotope |
| Anisotropic disturbance, κ up to 200 | **Exact** (≤ 1.1×10⁻¹³) | no anisotropy penalty — see §5 for the naive artifact |
| Varying disturbance magnitude (isotropic) | **Exact** (≤ 5.3×10⁻¹⁵) | — |
| High dimension (to n=12), isotropic | **Exact** (≤ 1.8×10⁻¹⁵), modest runtime growth | — |

For linear systems with convex ellipsoidal uncertainty, the discriminator between ellipsoid and
zonotope is **not** tightness. It is (i) certified inner bounds, (ii) complexity scaling, and
(iii) downstream operations. See §6.

---

## 5. Cautionary methods finding: the naive-recursion wrapping artifact

The KV tube must be built with the **joint** *k*-fold tight sum. If instead one recurses pairwise —
`E_{k+1} = minksum(A E_k, W, l)`, re-approximating the running ellipsoid at each step with a single
fixed direction — the outer bound wraps, and the wrapping error accumulates over N steps. This is a
classic pitfall, and it is easy to mis-diagnose as a shortcoming of the ellipsoidal *representation*.

`bench_tight_vs_naive.py` measures both tubes on the *same* system (n=2, θ=π/4, ρ=0.95, N=10) and
disturbance, against the *same* exact reference, sweeping κ.

**Concrete numbers from `tight_vs_naive.csv`** (external tube; `naive_max_overapprox_ratio` is the
worst-direction naive-ρ / exact-ρ at the final step):

| κ | naive mean gap | naive max gap | tight max gap | naive over-approx factor |
|---|---|---|---|---|
| 1 | −1.2×10⁻¹⁷ | 4.4×10⁻¹⁶ | 8.9×10⁻¹⁶ | 1.00× |
| 5 | 0.318 | 2.624 | 1.3×10⁻¹⁵ | 1.85× |
| 10 | 0.719 | 9.332 | 1.8×10⁻¹⁵ | 3.40× |
| 50 | 4.384 | 116.350 | 1.1×10⁻¹⁴ | 16.23× |
| 100 | 10.515 | 325.899 | 2.5×10⁻¹⁴ | 32.04× |
| **200** | **26.419** | **904.744** | **9.6×10⁻¹⁴** | **63.14×** |

At κ=200 the naive tube over-approximates by up to **904.74** in absolute support (a **63.1×** factor
in the worst direction), while the correct joint tight tube is exact to **9.6×10⁻¹⁴**. Figure
`fig8_tight_vs_naive.png` plots both.

**Explicit correction.** An earlier draft of this study reported these naive numbers as evidence that
"ellipsoidal tubes lose badly under high disturbance anisotropy," and even reported a κ-driven
"crossover" against zonotopes. **That attribution was incorrect.** The blow-up is a property of the
*naive pairwise recursion*, not of KV ellipsoidal theory: the same problem, computed with the joint
*k*-fold KV tight sum, has zero gap at every κ (§3.2). We retain the naive numbers *only* as a
cautionary demonstration of an implementation trap, and we do not attribute the implementation
deficiency to the theory. The previously-claimed crossover is withdrawn — it does not exist once the
tube is computed correctly.

---

## 6. Ellipsoid vs. Zonotope: a pure-Python head-to-head

We compare the KV tight ellipsoidal tube against a Girard zonotope reach tube (exact linear map, exact
Minkowski sum, box order-reduction), both in pure Python (`python/zonotope.py`), on the *same* system
(2-D rotation-scaling, spectral radius 0.9, N=15), measured against the *same* exact reference. The
ellipsoidal tube is built **per direction** with the joint *k*-fold tight sum: for each query
direction m we construct the ellipsoid tight along m and read its support along m. Each method uses its
native representation of the uncertainty set where possible and a **sound** over-approximation of the
other geometry otherwise (ellipsoid←box via the Löwner √n-blow-up; zonotope←ellipsoid via the
eigen-frame bounding box).

**Fairness & soundness.** The reference is exact for any convex disturbance `W`:
`ρ_R(m) = ρ(X₀, (Aᴺ)ᵀm) + Σⱼ ρ(W, (Aʲ)ᵀm)`. Both tubes are verified to over-approximate it in every
tested direction (min relative gap ≥ −1×10⁻⁶), so all reported gaps are honest one-sided
conservativeness.

**Results** (mean relative support gap vs. exact reach set, `results/ell_vs_zono.csv`,
`figs/fig7_ell_vs_zono.png`):

| Disturbance geometry | KV tight ellipsoidal tube | Zonotope tube | Native geometry | Winner |
|---|---|---|---|---|
| Ellipsoidal, isotropic | **−4.2×10⁻¹⁷** (exact) | 0.273 | ellipsoid | Ellipsoid |
| Ellipsoidal, anisotropic κ=10 | **−3.1×10⁻¹⁷** (exact) | 0.199 | ellipsoid | Ellipsoid |
| Ellipsoidal, anisotropic κ=100 | **−2.7×10⁻¹⁷** (exact) | 0.100 | ellipsoid | Ellipsoid |
| Box | 0.111 | **−2.2×10⁻¹⁶** (exact) | zonotope | Zonotope |

**Interpretation — tightness-equivalence on native geometry; no crossover.** Each representation is
machine-epsilon **exact** on the convex uncertainty geometry it represents natively: the KV tight tube
is exact on ellipsoidal W for *all* κ tested (including κ=100, where the earlier draft wrongly claimed
the zonotope wins), and the Girard zonotope tube is exact on box W. There is **no** anisotropy-driven
crossover — the earlier crossover was the naive-recursion artifact of §5. The only residual gap is the
one-off cost of fitting a *mismatched* primitive:

- Zonotope on ellipsoidal W pays the eigen-box over-approximation (0.100–0.273 mean gap here).
- Ellipsoid on box W pays the Löwner √n blow-up (0.111 mean gap here).

This box/ellipsoid **geometry-matching** effect is real, but it is precisely a *single-object,
fixed-complexity* mismatch — "which primitive best fits this one convex set" — **not** a wrapping loss
that accumulates over the horizon. It is the correct thing to weigh only when the disturbance is
genuinely non-ellipsoidal (e.g. a true box) and one is forced to fit an ellipsoid to it, or vice
versa.

**The real differentiators.** Since tightness is equivalent on convex sets, the representation choice
for *linear* reachability hinges on:

1. **Certified inner bounds.** The KV framework provides a guaranteed *inner* tube directly (the
   `approx="int"` family), which is machine-epsilon tight per direction here. Standard zonotope
   reachability tools do not directly report a certified inner approximation. If the application needs
   an under-approximation (e.g. for reach-avoid / must-reach guarantees), this is a decisive advantage
   for ellipsoids.
2. **Complexity scaling.** The ellipsoidal tube keeps a fixed n×n shape matrix per direction; its cost
   scales with the number of *directions* queried and the horizon (runtime 0.010–0.033s across n=2..12,
   N=8; §3.4). The exact zonotope tube's generator count grows with the horizon (Minkowski sum
   concatenates generators), so exactness is retained only until order-reduction is applied — at which
   point the zonotope, too, incurs approximation. The trade is *directions vs. generators*.
3. **Downstream operations.** Intersections, geometric differences (erosion), and containment checks
   have closed-form ellipsoidal analogues in the KV calculus (`minkdiff_*`, `intersection_ext`,
   `is_bigger`); the natural operations differ for zonotopes. The best representation depends on which
   downstream operations dominate the pipeline.

The KV *internal* tube remains a capability zonotope tools do not offer directly, orthogonal to the
tightness contest.

**Why not CORA?** CORA is MATLAB-only and would introduce engineering-parity confounds
(order-reduction settings, solver back-ends) without changing this geometric conclusion. The Python
zonotope baseline is small, auditable, and validated by exact identities — which is the whole point of
porting the ellipsoidal core to Python in the first place.

---

## 7. Discussion

The corrected picture for **linear** systems with **convex** uncertainty is:

1. **Tightness is not the differentiator.** The KV joint *k*-fold tight tube reproduces the exact
   reach-set support in every direction, matching zonotopes on their native geometry. Claims that one
   representation is intrinsically "tighter" than the other on convex sets do not hold once the
   ellipsoidal tube is computed correctly.

2. **Implementation matters more than representation.** The single largest effect we observed
   (up to 904.74 / 63.1× at κ=200) was an *implementation* artifact of naive pairwise recursion, not a
   representational property. Reviewers and practitioners should be wary of benchmarks that compare a
   correctly-implemented method against a naively-implemented competitor.

3. **Choose by capability and cost, not tightness:** prefer ellipsoids when a certified inner bound is
   needed or when few directions suffice; prefer zonotopes when the uncertainty is genuinely a box or
   when many-generator exactness within a bounded horizon is convenient; weigh downstream operations.

4. **Geometry-matching is a single-object effect.** The box↔ellipsoid mismatch cost (0.111 for
   ellipsoid-on-box; 0.100–0.273 for zonotope-on-ellipsoid) is the cost of fitting one primitive to
   one mismatched convex set at fixed complexity — not a horizon-accumulating wrapping loss. It applies
   only when the true uncertainty set is not representable natively.

We emphasize again that none of this is new theory; it is a reproducible, honestly-referenced
restatement of known tightness properties, plus a cautionary note about a common implementation trap.

---

## 8. Reproducibility

All numbers in this paper are generated by:

```bash
PYTHON=/abs/path/.venv/bin/python bash paper-2/reproduce.sh
```

This script cleans `paper-2/results/` and `paper-2/figs/`, then runs, in order:
`bench.py` (four regime sweeps, joint tight tube), `bench_tight_vs_naive.py` (the §5 artifact),
`bench_zono.py` (the §6 head-to-head), and the plotting scripts `plots.py`, `plot_tight_vs_naive.py`,
`plot_zono.py` (eight figures: `fig1`–`fig8`). The only dependencies are `numpy`, `scipy`,
`matplotlib`, and the `ellreach` kernel. No MATLAB, no CORA, no internet access required. The script
exits 0 on success. Every quantitative claim above is sourced from a regenerated CSV in
`paper-2/results/`.

Pinned environment: Python venv at `.venv/` in the repository root.

---

*Draft generated by the autonomous research pipeline. All quantitative claims sourced from
`paper-2/results/*.csv` produced by `paper-2/bench.py`, `paper-2/bench_tight_vs_naive.py`, and
`paper-2/bench_zono.py`.*
