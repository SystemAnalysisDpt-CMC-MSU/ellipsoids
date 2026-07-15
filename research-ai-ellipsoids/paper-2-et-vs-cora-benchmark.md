# Paper 2 — When Do Ellipsoidal Reach Tubes Win? An Honest Empirical Study

**Working title:** *When Do Ellipsoidal Tubes Beat Zonotopes? A Reproducible Benchmark of Set Representations for Linear Reachability under Uncertainty*

**One-line thesis:** A rigorous, reproducible head-to-head study mapping the *regimes* (conditioning, rotation content, disturbance level, dimension, safe-set geometry) in which tight ellipsoidal reach tubes give tighter/faster guarantees than zonotopes, polynomial zonotopes, and intervals — filling the community's missing "which representation, when?" reference.

---

## 1. Why this paper exists

Practitioners choose a set representation largely by folklore ("zonotopes for everything"). There is **no careful, reproducible study** that answers *when ellipsoids are actually the right tool* for linear/PWA reachability under uncertainty. Because ET implements the tight KV tubes (external **and** internal, plain **and** min-max) and CORA implements the zonotope family, a fair comparison is finally possible with two mature codebases. This is a **low-novelty-risk, high-utility** contribution — the kind that gets cited as the reference table.

## 2. Contributions

1. A **benchmark harness** with a common problem spec (LTI/LTV/PWA + control/disturbance sets + safe sets + horizon) that drives both ET and CORA and normalizes outputs to a common comparison basis (support functions along a shared direction set, volume proxies, containment checks).
2. A **regime map**: for a parameterized family of systems, which representation is Pareto-optimal on (tightness, runtime, memory) — visualized as phase diagrams over (condition number, rotation angle per step, disturbance-to-control ratio, state dimension).
3. A set of **failure-mode findings** (e.g., ellipsoid Minkowski-sum wrapping vs. zonotope order explosion vs. poly-zonotope cost) documented with reproducible scripts.
4. **Internal + external tubes** as a first-class axis: ET uniquely provides *guaranteed inner* tubes; we quantify the inner–outer gap as a certified conservativeness measure that zonotope tools cannot report directly.

## 3. Experimental design

**System families (parameterized, so we sweep regimes):**
- Rotation-dominated 2D/nD (`A = rot(θ) ⊗ scale`), sweep θ and conditioning.
- Stable/marginal/unstable spectra; symmetric vs. non-normal `A`.
- Disturbance-to-control ratio sweep (drives the min-max advantage question).
- Dimension sweep 2 → 20 (curse-of-dimension crossover).
- PWA systems (switching) for the piecewise case.
- Safe sets: half-spaces (ellipsoid-friendly), boxes (zonotope-friendly), quadratic (ellipsoid-friendly) — to expose geometry interaction.

**Methods compared:**
- ET: tight external tube, tight internal tube, min-max ext/int (Assets A, B).
- CORA: zonotope, polynomial zonotope, interval, (ellipsoid where available) — same problem spec.
- Optional: JuliaReach/LazySets support-function sets for a third-ecosystem cross-check.

**Metrics (all reproducible):**
- Tightness: support-function gap along a fixed shared direction grid; directed Hausdorff to a high-fidelity reference (fine polytopic/simulation reach set).
- Volume (or log-volume) where computable.
- Verified/falsified for a battery of safety queries.
- Runtime and memory vs. horizon and dimension.
- **Inner–outer certified gap** (ET only) as an honesty metric.

**Reference "truth":** dense Monte-Carlo / boundary-sampling reach set for low dim; for higher dim, cross-validated tightest-of-all-methods lower/upper support bounds.

## 4. What makes it credible (and publishable)

- **Fairness protocol:** identical problem specs, identical direction grids, identical tolerances, warm/cold timing, pinned versions, containerized. Pre-registered hypotheses.
- **Both directions of the result reported:** where zonotopes/poly-zonotopes dominate is stated as loudly as where ellipsoids do. Reviewers reward honesty studies; advocacy studies get desk-rejected.
- **Artifact:** a released benchmark + harness others can extend → durable citations, and a natural companion to the Python kernel (framework-extraction-plan.md).

## 5. Risks

- **Fairness disputes** (the classic "you tuned your tool better than theirs"). Mitigate by co-opting default settings, publishing configs, and inviting the CORA authors to review the CORA configuration (or at least following their published examples verbatim).
- **CORA API drift / MATLAB licensing** for the harness. Mitigate by pinning CORA version and scripting through documented entry points.

## 6. Target venues

- **Tool/benchmark tracks:** HSCC (repeatability/tool), CAV artifact/tool track, ARCH-COMP-style report, or a journal like *Nonlinear Analysis: Hybrid Systems* / IEEE TAC (technical note).
- Strong fit for an **ARCH-COMP friendly** framing (the reachability community runs annual competitions; a rigorous cross-representation study is welcome).

## 7. Effort estimate

- Harness + spec normalization: 3–5 weeks (the fiddly part is the common comparison basis).
- Sweeps + reference truth: 3–4 weeks compute + curation.
- Analysis + writing: 3–4 weeks.
- **~2.5–3 months.** Lowest-risk of the three papers; can be done largely with **existing ET + CORA code, minimal new math.**

## 8. Dependencies on ET

Assets A and B directly (this paper *is* an evaluation of them). Uses `rho`, `isinternal`, volume utilities from Asset C for metrics.
