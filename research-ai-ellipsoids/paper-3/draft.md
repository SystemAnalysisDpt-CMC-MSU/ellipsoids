# Conformalized Ellipsoidal Reach Tubes: Distribution-Free Multi-Step Prediction Regions for Learned Dynamical Systems

**Paper 3, Phase 3.** All numbers in this draft are copied verbatim from
`paper-3/results/*.csv`, produced by `bash paper-3/reproduce.sh` (exit 0).

---

## Abstract

We combine **split-conformal calibration** (distribution-free finite-sample
coverage) with **ellipsoidal set propagation** (the Kurzhanski–Varaiya
Minkowski algebra implemented in the `ellreach` kernel) to build **multi-step
prediction tubes** for learned/residual discrete-time dynamics. The per-step
primitive is a Mahalanobis (ellipsoidal) conformal error set calibrated on
held-out residuals; we propagate it through the (linearized) dynamics with the
kernel's tight external Minkowski sum over a horizon `H`. The resulting tube is
a **probabilistic conformal region**, not a deterministic sound
over-approximation: each per-step set contains its one-step error with
probability `≥ 1 − α`, and the horizon-level guarantee is the union bound
`P(traj ⊂ tube) ≥ 1 − Hα`.

We are careful about the baseline. A naïve comparison against an
**interval-arithmetic** box tube is unfair: most of that box's size is
**wrapping** (repeated axis-aligned re-enclosure of a rotated set), not a
genuine shape penalty. We therefore add a **wrapping-free** baseline — the
exact zonotope reachable set's axis-aligned bounding box — and **decompose** the
apparent advantage into a wrapping-elimination factor (which any non-wrapping
method, box or ellipsoid, captures) and the **genuine ellipsoidal-shape /
correlation** factor. On the strongly-correlated 3-D domain the honest
shape/correlation advantage is a **3.5× volume reduction** against the fair box;
on the 2-D domains it is modest (1.2–1.6× against the fair box's own affine
reachable set; the ellipsoid is actually slightly *larger* than the fair box at
equalized coverage on two of them). We also compare against a **per-timestep
quantile tube** (the closest distribution-free trajectory-prediction prior art)
and state precisely what ellipsoidal set arithmetic buys: closed-form
composable propagation from a *single* one-step calibration and the
`minkdiff_int` set-membership dual, **not** a smaller region per se.

---

## 1. Positioning (honest)

**Static ellipsoidal conformal prediction** is already well developed:
Mahalanobis nonconformity scores and ellipsoidal regions (Johnstone & Cox 2021;
Messoudi et al. 2022, *Ellipsoidal conformal inference for Multi-Target
Regression*; Conformalized Gaussian Scoring 2025; MultiDimSPCI for time series).
A static per-point ellipsoid contribution would be incremental.

**Conformal prediction for dynamical systems / trajectory prediction** is the
closest live prior art and must be engaged directly. Lindemann et al. (*Safe
Planning in Dynamic Environments using Conformal Prediction*, and follow-ups on
conformal prediction regions for learned trajectory predictors) already yield
**distribution-free multi-step tubes**: they calibrate a per-timestep (or joint,
via a union bound / normalization) nonconformity quantile directly on
calibration **trajectories** and wrap each predicted state in a region.
Data-driven reachability (e.g. sampling- and scenario-based reachable-set
estimation) likewise builds multi-step tubes without a white-box model. These
methods do **not** require ellipsoidal set arithmetic and are strong baselines,
so we implement a **per-timestep quantile ellipsoidal tube** and compare against
it head-to-head (§3.4).

**What ellipsoidal set arithmetic actually buys** (and what it does not):

- *Composable, closed-form propagation from ONE one-step calibration.* Given a
  single calibrated one-step error ellipsoid `W` and the (linearized) map `A`,
  the whole horizon tube is produced by closed-form affine images and Minkowski
  sums — no calibration data at intermediate steps is needed. A per-timestep
  quantile tube instead needs calibration deviations at **every** step `k`.
- *Correlation propagation and compactness.* The off-diagonal `Σ̂` is carried
  forward exactly through `A Q Aᵀ`; the tube is a single compact object per
  step (one center + one shape matrix), convenient for downstream set
  operations (intersection, containment, control).
- *The `minkdiff_int` set-membership dual.* The estimation-side Minkowski
  **difference** (erosion) is rare in other set libraries and yields a
  guaranteed-inner consistent-state region (§3.5). **We are explicit that this
  erosion is pre-existing Kurzhanski–Varaiya set-membership estimation, not a
  conformal-prediction contribution;** our contribution is only that the same
  kernel serves both the CP prediction tube and its estimation dual.
- *It does NOT buy a smaller region for free.* On our data the per-timestep
  quantile tube is 2.8–5.0× **smaller** in final-step volume than the
  propagated ellipsoid (§3.4), because propagation is a sound outer bound that
  accumulates conservatism while the per-step quantile fits the true stationary
  spread directly. The trade is compactness + composability + a single
  calibration, not tightness.

Static ellipsoidal CP is our per-step *building block*, cited as such; the
dynamical *propagation* is the methodological home ground of the ET / `ellreach`
kernel (Asset C: `minksum_ext`, `minkdiff_int`, `rho`).

---

## 2. Method

### 2.1 Conformalized one-step ellipsoidal error set

Model `x_{k+1} = ĝ(x_k) + w_k` where `ĝ` is a learned surrogate (or the true
linear map) and `w_k` is the one-step model error. Split held-out residuals
into disjoint **fit** and **calibration** pools.

- **Shape** — estimate the residual covariance `Σ̂` on the fit split.
- **Radius** — compute Mahalanobis scores `s_i = √((r_i − μ̂)ᵀ Σ̂⁻¹ (r_i − μ̂))`
  on the *calibration* split and take the split-conformal quantile
  `r = s_{(k)}`, `k = ⌈(n+1)(1−α)⌉`.

The calibrated set is the ellipsoid
`W = { w : (w − μ̂)ᵀ Σ̂⁻¹ (w − μ̂) ≤ r² } = E(μ̂, r²Σ̂)`, returned as an
`ellreach.Ellipsoid` (`python/conformal.py: MahalanobisConformal`). By the
standard split-CP argument (Vovk et al. 2005; Lei et al. 2018) it satisfies
the finite-sample marginal guarantee `P(w_{n+1} ∈ W) ≥ 1 − α` on an
exchangeable held-out point. Our self-test confirms this empirically (below).

### 2.2 Baselines

We compare against **three** reference tubes so that wrapping and shape can be
separated:

1. **Interval (box) tube** — `BoxConformal` discards off-diagonal correlation:
   per coordinate `j` it calibrates a half-width `h_j` from `|r_{ij} − μ̂_j|` at
   the Bonferroni-corrected level `1 − α/d`, then propagates with sound interval
   arithmetic `half_{k+1} = |A| half_k + h_W`. This **wraps**: rotating a box by
   `A` and re-enclosing it axis-aligned every step inflates the region far
   beyond the true reachable set. It is the *unfair* baseline and is reported
   only to expose the wrapping effect.
2. **Fair (wrapping-free) box tube** — the *same* box error set propagated as an
   **exact zonotope** (`python/zonotope.py`: affine images and Minkowski sums of
   zonotopes are exact — zero wrapping), from which we take the **exact
   axis-aligned bounding box** each step. This is the tightest axis-aligned box
   that still soundly encloses the (box-init, box-error) affine reachable set.
   It is the honest apples-to-apples box baseline.
3. **Per-timestep quantile ellipsoidal tube** — the trajectory-prediction prior
   art (§1): a Mahalanobis conformal ellipsoid calibrated **independently at
   every horizon step** from calibration trajectories, at a Bonferroni-over-
   horizon level `α/H` for joint coverage. No propagation.

### 2.3 Ellipsoidal propagation (the method)

Given the one-step set `W` and the (linearized) map `A_k`, we propagate
`T_{k+1} = A_k · T_k ⊕ W` with the kernel's **tight external Minkowski sum**
`minksum_ext` (KV formula, tight along a chosen direction `l`). We keep a
family of good directions `{l_i}` and, per step, retain the **volume-minimizing
member** of `{ minksum_ext(A_k T_k, W, l_i) }` — a single compact ellipsoid per
step. Because `minksum_ext` is a **sound outer bound of `A_k T_k ⊕ W` for any
`l`**, the propagated ellipsoid soundly contains the composition of the per-step
sets; the *probabilistic* content of that composition is governed by the union
bound in §2.4.

### 2.4 Horizon coverage bookkeeping (union bound), stated honestly

The tube is a **probabilistic conformal region**, not a deterministic
reachable-set over-approximation of a *known* disturbance set. Each per-step
conformal set `W` contains the true one-step error with probability `≥ 1 − α`
(marginal split-CP guarantee). The propagation is a *conditionally*-sound
outer-approximation: **conditioned on all `H` one-step errors landing in `W`**,
the whole trajectory lies in the tube. A union bound over the `H` per-step
events then gives the horizon guarantee

> **P( trajectory ⊂ tube ) ≥ 1 − Hα.**

This is the correct, and deliberately conservative, statement. It is **not** a
claim that realized coverage dominates the nominal per-step `1 − α` at every
level: the guarantee is against the *union bound* `1 − Hα`, which for large
`Hα` is loose or even vacuous (`≤ 0`). We therefore report **realized coverage
vs. the union bound** (`results/coverage_vs_union_bound.csv`) and full
**calibration curves** (`results/calibration_curve.csv`) rather than lean on the
bound. Under exchangeable/Markov error structure realized coverage is far
tighter than `1 − Hα`; the observed over-coverage at the headline level is a
consequence of the conservative sound propagation, not a monotone-domination
property.

### 2.5 Set-membership dual (`minkdiff_int`) — pre-existing, reused

The estimation dual of the prediction tube uses the kernel's **Minkowski
difference** (erosion). We stress this is **pre-existing Kurzhanski–Varaiya
set-membership estimation**, not a CP contribution. Given a prior state set `X`
and an ellipsoidal measurement-error model `V`, the states consistent with an
observation are (a guaranteed-inner approximation of) the erosion `X ⊖ V`,
computed with `minkdiff_int`. The only novel point is that the *same* kernel
serves the CP prediction tube and this estimation dual.

---

## 3. Experiments

Three correlated-error domains (`cp_tubes.py`) plus one honest failure domain:

- **(A) `A_linear_correlated`** — stable linear system, correlated Gaussian
  process noise (true model), `d=2`, `H=8`.
- **(B) `B_learned_surrogate`** — coupled-quadratic true dynamics with a
  least-squares **linear surrogate** fit from 20k samples; the conformalized
  error is the surrogate one-step residual, `d=2`, `H=8`. Calibration residuals
  are now pooled from **every horizon step 0…H−1** (see §3.6), so the
  calibration pool is exchangeable with the per-step test residuals over the
  whole horizon.
- **(C) `C_var_timeseries`** — correlated multivariate AR(1)/VAR generator with
  strongly correlated innovations (off-diagonal corr ≈ 0.7), `d=3`, `H=10`.
- **(D) `D_multimodal_failure`** — bimodal (non-elliptical) residuals; reported
  as the failure regime, `d=2`, `H=6`.

For each: calibrate ellipsoid + interval box + fair box at nominal `1 − α =
0.90`, propagate tubes, and measure realized horizon coverage on 8 000 fresh
test trajectories plus per-step region volume.

### 3.1 Realized coverage vs. the union bound (soundness, stated correctly)

Verbatim from `results/coverage_vs_union_bound.csv` (nominal per-step `1 − α =
0.90`, `n_test = 8000`, Wilson 95% CI):

| Domain | H | union bound `1−Hα` | realized ell coverage (95% CI) | ≥ union bound? |
|---|---|---|---|---|
| A_linear_correlated | 8 | 0.20 | **0.991625** [0.98938, 0.99340] | yes |
| B_learned_surrogate | 8 | 0.20 | **0.985** [0.98209, 0.98744] | yes |
| C_var_timeseries    | 10 | 0.00 | **0.951625** [0.94670, 0.95611] | yes |
| D_multimodal_failure| 6 | 0.40 | 0.958375 [0.95377, 0.96254] | yes |

Realized ellipsoidal coverage exceeds the honest union bound `1 − Hα` on all
four domains (the lower CI endpoint is above the bound everywhere). At the
headline level it also happens to exceed the per-step nominal `0.90`, but we do
**not** claim monotone domination of `y = x`: the calibration curve
(`results/calibration_curve.csv`) shows that at looser nominal levels realized
coverage can sit **below** the per-step line — e.g. domain C at nominal `0.70`
realizes **0.69675** (below `0.70`), while at nominal `0.85 → 0.901875` and
`0.90 → 0.952`. This is fully consistent with the guarantee, which is against
the union bound (`1 − Hα = −2` at `α = 0.30, H = 10`, i.e. vacuous), **not**
against `y = x`. We report the curve as-is and make no false monotonicity claim.

### 3.2 The interval-box "3–6×" headline was mostly WRAPPING (fair baseline)

Verbatim from `results/wrapping_shape_decomposition.csv` (final horizon step,
`α = 0.1`). `wrapping = interval_box / fair_box`; `shape = fair_box / ell`;
their product is the old `interval_box / ell` headline.

| Domain | one-step `W_ell/W_box` | interval box | fair box | ellipsoid | wrapping factor | shape factor (fair/ell) |
|---|---|---|---|---|---|---|
| A_linear_correlated | **0.894** | 324.514 | 82.117 | 50.735 | **3.95×** | 1.62× |
| B_learned_surrogate | **0.868** | 5.877 | 3.857 | 3.011 | **1.52×** | 1.28× |
| C_var_timeseries    | **0.412** | 49.802 | 49.802 | 14.371 | **1.00×** | **3.47×** |

Reading this honestly:

- **The one-step ellipsoid is barely smaller than the box** on the 2-D domains
  (`0.894×` on A, `0.868×` on B) — the shape advantage *before propagation* is
  ≈ 1.1×, not 3–6×. Only the strongly-correlated 3-D domain C shows a real
  one-step shape win (`0.412×`, i.e. 2.4× smaller).
- **On domain A the old "6.4× smaller" headline is ≈ 80% wrapping.** The
  interval box is 324.5; strip wrapping and the fair box is 82.1 (a `3.95×`
  reduction from wrapping alone, matching the KV analysis). The ellipsoid (50.7)
  beats the *fair* box by only `1.62×`, and — see §3.3 — that residual gap is
  partly a coverage difference, not shape.
- **Domain C has essentially no wrapping** at the final step (`1.00×`: the
  interval box already equals the exact affine bounding box for this `A`). Its
  entire `3.47×` ellipsoid advantage is **genuine correlation propagation** in
  3-D. This is the honest headline win.

A complementary shape-only number — the ellipsoid vs. **its own** axis-aligned
bounding box (i.e. how much the ellipsoidal shape saves *given* the ellipsoidal
reachable set) — is `1.27×` (A), `1.79×` (B), `5.62×` (C) from the
`shape_factor_ellbbox_over_ell` column.

### 3.3 Volume at EQUALIZED realized coverage (the correct comparison)

The interval box **over-covers** (0.998 on A vs. the ellipsoid's 0.992), so a
raw volume ratio is not at matched coverage. We equalize **realized** horizon
coverage between the ellipsoid (at nominal) and the **fair** box (scaling its
error half-widths until realized coverage matches within CI), then compare
final-step volumes. Verbatim from `results/equalized_coverage.csv`:

| Domain | equalized coverage | ellipsoid vol | fair-box vol (scale) | ratio ell/fair-box |
|---|---|---|---|---|
| A_linear_correlated | 0.991625 | 50.735 | 42.069 (t=0.706) | **1.206** |
| B_learned_surrogate | 0.985 | 3.011 | 1.729 (t=0.649) | **1.742** |
| C_var_timeseries    | 0.951625 | 14.371 | 30.962 (t=0.852) | **0.464** |

At **equal realized coverage**:

- On **A** and **B** the propagated ellipsoid is actually **larger** than the
  wrapping-free box (`1.21×`, `1.74×`) — the single-ellipsoid propagation
  accumulates enough conservatism to lose to an exact affine box in 2-D. The
  earlier apparent ellipsoid win on these domains was **wrapping in the box
  baseline, not ellipsoidal superiority.**
- On **C** the ellipsoid is genuinely **2.15× smaller** (`0.464×`) than the fair
  box at equalized coverage — the real, wrapping-free, correlation-driven
  advantage, in the high-dimensional strongly-correlated regime where
  axis-alignment is most wasteful.

**Honest headline:** ellipsoidal propagation delivers a genuine multiplicative
volume reduction (≈ 2× at equalized coverage, 3.5× at nominal) **only when
correlation is strong and dimension is higher (domain C)**; in low-dimensional /
weakly-correlated settings a wrapping-free box is competitive or better, and the
correlation-aware ellipsoid's value there is compactness and composability, not
volume.

### 3.4 Comparison against a per-timestep quantile tube (closest prior art)

Verbatim from `results/perstep_quantile_tube.csv` (final-step volume; the
per-timestep tube is calibrated per step from 6 000 calibration trajectories at
level `α/H`):

| Domain | propagated ell (cov, vol) | per-timestep quantile (cov, vol) | ratio prop/per-step |
|---|---|---|---|
| A_linear_correlated | 0.9916, 50.735 | 0.9254, 14.536 | 3.49 |
| B_learned_surrogate | 0.9850, 3.011 | 0.9200, 1.060 | 2.84 |
| C_var_timeseries    | 0.9516, 14.371 | 0.9098, 2.880 | 4.99 |

The per-timestep quantile tube is **2.8–5.0× smaller** in region volume. This is
expected and reported honestly: it fits the true per-step spread directly rather
than propagating a sound outer bound. What our method offers over it is **not**
tightness but (i) a single one-step calibration instead of calibration data at
every horizon step, (ii) closed-form composable set objects (one ellipsoid per
step) suitable for downstream set operations, and (iii) the erosion dual (§3.5).
When calibration trajectories over the full horizon are available and only a
prediction region is needed, the per-timestep quantile tube is the better choice
and we say so.

### 3.5 Set-membership dual works and is sound (pre-existing KV erosion)

Verbatim from `results/set_membership_demo.csv`:

- prior state-set volume **4.4555**, measurement-error-set volume **0.6683**,
  guaranteed-inner consistent-set volume **1.6726**;
- `erosion_sound = True`, with **22/22** tested directions yielding a valid
  inner erosion. A 3 000-sample check confirms `(X ⊖ V) ⊕ V ⊆ X` (every
  `s + v` with `s ∈ X⊖V`, `v ∈ V` lies in `X`).

Again: the erosion itself is standard KV set-membership estimation; the point is
that the CP tube and its estimation dual share one kernel.

### 3.6 Domain B: horizon exchangeability

Earlier the domain-B surrogate residuals were sampled ≈ 2 steps out while the
tube is tested over `H = 8`. We now pool calibration residuals from **every**
horizon step `0…H−1` (`domain_learned_surrogate.sample_horizon_residual_pool`),
so the calibration pool is exchangeable with the per-step test residuals along
the full horizon. This is the exchangeability-clean version; the coverage and
volume numbers above are from it.

---

## 4. Honest failure regime: non-elliptical / multimodal residuals

A single ellipsoid is the wrong shape for **multimodal** residuals: it must
span both modes at matched coverage and therefore swallows a large empty region
between them. We keep **two clearly separated comparisons** for domain D:

**(i) The one-step single-ellipsoid-vs-mixture test (where the failure shows).**
We compare the single Mahalanobis conformal ellipsoid against a **two-component
mixture oracle** (per-mode Mahalanobis sets, union), both calibrated to ≈ 0.90
one-step coverage. Verbatim from `results/failure_regime.csv`:

- single-ellipsoid area **6.2289** at coverage **0.8905**;
- mixture-oracle area **1.2479** at coverage **0.8985**;
- **area ratio ellipsoid / mixture = 4.9914**.

So on genuinely non-elliptical residuals the single ellipsoid is **~5× larger**
than a mixture at the same coverage. This is the honest failure signal.

**(ii) The propagated box comparison, which MASKS the failure.** In the
propagated-tube table (`results/coverage_summary.csv`) domain D's ellipsoid
looks `4.2×` *smaller* than the interval box (`vol_ratio_final = 0.239`). This
is **not** evidence that the ellipsoid handles multimodality well — it is the
same **wrapping** artifact as in §3.2: the interval box wraps so badly that even
a poorly-shaped single ellipsoid beats it. The multimodal failure is real and is
visible **only** in the wrapping-free one-step comparison (i), not in the
box-tube ratio. We keep the two comparisons separate and state explicitly that
the box-tube ratio for D says nothing about ellipsoidal adequacy for
multimodal errors.

The novelty of this paper is *not* a better static region — it is the
**dynamical propagation** through the kernel (compactness + composability +
single-calibration) plus the reuse of the KV **Minkowski-difference**
set-membership dual, both agnostic to the per-step shape.

---

## 5. Reproducibility

```
bash paper-3/reproduce.sh          # exit 0; PYTHON=${PYTHON:-../.venv/bin/python}
```

Runs the conformal self-test (`python/conformal.py`), the experiments
(`cp_tubes.py` → `results/*.csv`), and the figures (`plots.py` → `figs/*.png`):
`calibration_curves.png`, `volume_at_coverage.png`,
`wrapping_shape_decomposition.png`, `failure_regime.png`.

Files:
- `python/conformal.py` — `MahalanobisConformal`, `BoxConformal`,
  `empirical_coverage`, split-conformal quantile index; self-tests.
- `python/zonotope.py` — exact (wrapping-free) zonotope reach tube used for the
  fair box baseline.
- `paper-3/cp_tubes.py` — four domains, tube propagation, fair-baseline
  wrapping/shape decomposition, equalized-coverage comparison, per-timestep
  quantile-tube comparison, calibration curves, failure-regime analysis,
  `minkdiff_int` set-membership demo.
- `paper-3/plots.py` — figures from the CSVs.
- `paper-3/results/*.csv` — `coverage_summary`, `coverage_vs_union_bound`,
  `tube_volumes`, `wrapping_shape_decomposition`, `equalized_coverage`,
  `perstep_quantile_tube`, `calibration_curve`, `failure_regime`,
  `set_membership_demo`.

---

## 6. Limitations & future work

- The genuine ellipsoidal-shape/correlation advantage over a **wrapping-free**
  baseline is decisive only in higher-dimensional, strongly-correlated regimes
  (domain C); in 2-D weakly-correlated regimes a fair box is competitive or
  better, and the ellipsoid's value is compactness/composability, not volume.
- The horizon guarantee is a union bound `1 − Hα`; a tighter Markov / adaptive
  (ACI-style) analysis is future work. Realized coverage is already far above
  the bound, but realized coverage can sit below the *per-step* line at loose
  nominal levels (this is consistent with the union-bound guarantee).
- Propagation uses a single volume-minimizing ellipsoid per step; the full KV
  *touching-tube* direction family (Asset A) would give per-direction tightness
  and narrow the gap to the per-timestep quantile tube.
- A per-timestep quantile tube is tighter when full-horizon calibration
  trajectories are available; our method targets the single-one-step-calibration
  + composable-propagation regime.
- The surrogate here is a global least-squares linear map; a locally-linearized
  Jacobian-plus-sound-remainder bound (as in Paper 1) would tighten domain B.
- Multimodal errors need a mixture/kernel per-step primitive; the propagation
  machinery is agnostic to the per-step shape.
