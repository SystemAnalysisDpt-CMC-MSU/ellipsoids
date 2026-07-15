# Paper 3 — Conformal Ellipsoidal Tubes for Learned Dynamics

**Working title:** *Conformalized Ellipsoidal Reach Tubes: Distribution-Free Multi-Step Prediction Regions for Learned Dynamical Systems*

**One-line thesis:** Marry **conformal calibration** (distribution-free coverage) with **ellipsoidal set propagation** (ET's Minkowski algebra + tight tubes) to produce *multi-step* prediction **tubes** for learned/residual dynamics that (i) carry statistical coverage guarantees and (ii) propagate correlation forward through the dynamics — something the existing *static* ellipsoidal conformal-prediction literature does not do.

---

## 1. Honest positioning (prior art is crowded — pick the open niche)

**Static ellipsoidal conformal prediction is already well-developed:** Mahalanobis nonconformity scores and ellipsoidal regions (Johnstone & Cox 2021; [Messoudi et al. 2022, "Ellipsoidal conformal inference for Multi-Target Regression"](https://proceedings.mlr.press/v179/messoudi22a/messoudi22a.pdf); [Conformalized Gaussian Scoring 2025](https://arxiv.org/pdf/2507.20941); MultiDimSPCI for time series). A *static per-point ellipsoid* paper would be incremental and likely rejected.

**The open gap** these works explicitly leave: they produce a *single-shot* region in output space. None *propagate* an ellipsoidal region **through a dynamical model over a horizon** using set arithmetic. That is exactly ET's home ground. So Paper 3 is deliberately the **dynamical** paper, not the static one.

## 2. Setup & contribution

Consider a learned discrete-time model `x_{k+1} = ĝ(x_k, u_k) + w_k`, where `ĝ` is an NN (or GP/linear-residual) surrogate and `w_k` is model error. We want a **prediction tube** `{T_k}` such that the true trajectory stays inside with calibrated probability over the horizon.

Contributions:
1. **Conformalized ellipsoidal error set.** Calibrate an ellipsoidal one-step model-error set `W = {w : wᵀ Σ̂⁻¹ w ≤ q̂_{1−α}}` using split-conformal on held-out residuals (Mahalanobis score → ellipsoid), giving a *distribution-free* one-step containment guarantee. (This reuses known static ellipsoidal CP as the **per-step primitive**.)
2. **Ellipsoidal propagation.** Propagate `T_k → T_{k+1}` by linearizing/bounding `ĝ` over `T_k` (Jacobian + sound remainder as in Paper 1) and applying ET's **tight external Minkowski sum** `T_{k+1} = A_k·T_k ⊕ W ⊕ R_k` (Asset A/C), keeping a direction family for tightness in the coordinates the user cares about.
3. **Coverage bookkeeping.** A horizon-level coverage statement combining per-step conformal validity with the (sound) set propagation — an over-coverage guarantee `P(traj ⊂ tube) ≥ 1 − Hα` (union bound) with a tighter analysis under exchangeable/Markov error assumptions; empirically report realized coverage vs. nominal.
4. **Robust set-membership variant (uses Asset C's Minkowski *difference*).** Given observations, the state set consistent with the ellipsoidal error model is an ellipsoidal intersection/erosion problem; `minkdiff` gives a *guaranteed-inner* consistent set. This is the estimation dual of the prediction tube and is unavailable in static CP tooling.

## 3. Why ellipsoids specifically (defensible)

- Ellipsoids are **closed enough** under the operations needed (linear map exact; Minkowski sum via tight over-approx; difference via erosion) to propagate a *single compact object* per step — zonotopes grow order, boxes lose correlation, poly-zonotopes are expensive to calibrate.
- Mahalanobis/ellipsoidal is the **natural geometry of Gaussian-ish residuals**, which learned-model errors often are locally — so the per-step primitive is well-calibrated and tight.
- The **correlation propagation** (off-diagonal `Σ`) is the whole point: boxes/coordinate-wise CP throw it away and over-cover; the paper's headline experiment is realized-volume-at-fixed-coverage vs. coordinate-wise conformal.

## 4. Experiments

- **Domains:** learned surrogates for physical systems (cart-pole, quadrotor, robot arm from offline data), multivariate time-series forecasting with a neural model, model-based RL rollouts.
- **Baselines:** coordinate-wise split conformal (box tubes), static ellipsoidal CP applied per-step *without* propagation, ensemble/quantile-regression tubes, Gaussian-process predictive covariance.
- **Metrics:** realized coverage vs. nominal (calibration curves), region **volume / support width at fixed coverage** (efficiency), horizon at which tube saturates, runtime. Ablate: with/without correlation, with/without tight-direction family.
- **Headline result target:** same coverage, smaller tubes than coordinate-wise CP on correlated-error systems; graceful degradation shown honestly where errors are non-elliptical/multimodal (cite the kernel-score critique and show where a box/kernel method wins).

## 5. Novelty risk & de-risking

- **Risk:** "static ellipsoidal CP exists." **Answer:** we are explicitly the *dynamical/propagation* extension + the Minkowski-difference set-membership dual; static CP is our per-step building block, cited as such.
- **Risk:** coverage guarantee under propagation is only a union bound. **Answer:** state it honestly; offer the tighter Markov analysis and strong *empirical* coverage; the practical efficiency gain stands regardless.
- **Risk:** non-elliptical residuals. **Answer:** report the failure regime; position ellipsoids as the efficient default for locally-Gaussian correlated errors, not a universal claim.

## 6. Target venues

- **ML:** NeurIPS/ICML/AISTATS (conformal & UQ community is very active there), or a UQ/distribution-free-inference workshop first.
- **Control/robotics crossover:** L4DC, CoRL (prediction tubes for model-based control/planning).
- **Journal:** *Journal of Machine Learning Research* or IEEE TAC for the control-flavored version.

## 7. Effort estimate

- Per-step conformal primitive: reuse existing methods, ~1–2 weeks.
- Propagation + coverage analysis: 3–4 weeks (the theoretical novelty).
- Experiments + writing: 5–6 weeks (ML empirical bar is high).
- **~3–3.5 months.** Highest ML-community bar of the three, but the crossover framing (CP × reachability) is fresh and fundable.

## 8. Dependencies on ET

Asset C (`minksum_ea`, `minkdiff_ia`, `rho`, `isinternal`) is central; Asset A (tight direction family) for efficient tubes. The set-membership dual specifically exploits ET's rare Minkowski-**difference** implementation.
