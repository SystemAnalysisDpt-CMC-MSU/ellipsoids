# PROGRESS — AI + Ellipsoids program (EXECUTION_PROMPT.md)

Legend: [x] green with evidence · [~] in progress · [ ] not started · [B] blocked-external

## Gate G0 — Foundation kernel & harness  ✅ GREEN
- [x] `pytest python -q` → **18 passed, 0 skipped, 0 failed** (evidence: `bash run_all_gates.sh`).
- [x] `pip install -e .` succeeds; `import ellreach` OK (10 public funcs).
- [x] `run_all_gates.sh` exists and runs; G0 + G4-hygiene green.
- [x] Every kernel fn has ≥1 oracle test (KV tightness identity / containment ordering / soundness).
- [x] Fake-completion scan over project sources = 0 matches.

Kernel delivered (`python/ellreach.py`): `Ellipsoid` (rho, affine, contains, is_bigger, volume),
`minksum_ext/int`, `minkdiff_ext/int` (erosion), `intersection_ext`, `sqrtm_pos`, `orth_transl`
(mlorthtransl port), `reach_tube_lti_discrete` (ext/int), `reach_tube_lti_continuous` (SciPy ODE).

## Gate G1 — Paper 2 (ET-vs-CORA benchmark)  ✅ GREEN (CORA item blocked-external)
- [x] `paper-2/reproduce.sh` regenerates figures+tables from raw data — **verified exit 0**,
      4 CSVs + 6 PNGs (independently re-run by orchestrator).
- [x] `paper-2/results/*.csv` real; numbers traced into draft (κ=1 gap≈1.7e-16 exact;
      κ=200 mean_gap_ext=26.4, max=904.7; runtime n=2→12: 0.002→0.003s).
- [x] draft states losing regime: high disturbance anisotropy (κ≳5) — wrapping loss ∝ √κ−1;
      rule "switch to zonotopes above condition number ~5".
- [B] CORA head-to-head — **blocked-external** (no MATLAB/Octave); substitute = exact
      support-function reference truth + Monte-Carlo (sanctioned by EXECUTION_PROMPT §Phase 4).
      Bridge spec (`cora_bridge.m`) documented in draft appendix for future runs.
- [x] kernel v0.1 importable; version 0.1.0 in `pyproject.toml` + `VERSION`; JOSS `paper.md`/`paper.bib`
      drafted. Git tag deferred (avoids mutating the legacy repo's tag namespace without request).

## Gate G2 — Paper 1 (neural feedback loops)  ✅ GREEN
- [x] soundness argument in `paper-1/theory.md`; empirically confirmed by MC.
- [x] `paper-1/reproduce.sh` → **verified exit 0** (re-run after kernel fix); results + 5 figs.
- [x] MC containment fraction = **1.0000** on all 4 benchmarks (script aborts if <0.999).
- [x] ellipsoid beats box on a safety property the box CANNOT verify: stable_linear
      (ell support 1.10/1.20 vs box 5.97/5.95, bound 2.5) and rotation_showcase
      (ell 0.41/0.55 vs box 13.64/9.98) — ell_verified=1, box_verified=0. Rotation showcase
      volume 0.0666 vs box 367.8 (**5522× tighter**).
- [x] failure regime: non-convex |x1|-fold reachable set, non-convexity penalty 41.85× — any
      single convex enclosure loose; poly/hybrid zonotopes + star sets win (draft §5).
- [x] Self-contained CROWN-style ReLU relaxation (`python/nn_bounds.py`, +3 soundness tests).
- [x] **Kernel hardening**: Paper 1's MC caught an unsound `minksum_ext` branch (dropped a
      degenerate operand's orthogonal extent). Fixed in `ellreach.py` with the sound Q_beta
      family (tight beta=p1/p2); added 2 regression tests. Suite now **23 passed, 0 skipped**;
      all three reproduce.sh re-verified exit 0 with numbers unchanged in non-degenerate cases.

## Gate G3 — Paper 3 (conformal ellipsoidal tubes)  ✅ GREEN
- [x] `paper-3/reproduce.sh` → **verified exit 0** (independently re-run); 5 CSVs + 3 PNGs.
- [x] realized coverage ≥ nominal (0.90) on 3 domains: A 0.9916, B 0.9854, C 0.9516 (Wilson CIs).
- [x] ellipsoid beats box on volume-at-coverage: A 0.156 (6.4×), B 0.515 (1.9×), C 0.289 (3.5×).
- [x] non-elliptical failure regime: bimodal residuals → single ellipsoid 4.99× larger than
      mixture oracle at matched coverage; novelty = dynamical propagation + minkdiff_int dual.
- [x] set-membership dual demo (minkdiff_int erosion): prior vol 4.456 → guaranteed-inner 1.673, sound.
- Added `python/conformal.py` (3 new tests; suite now 21 passed).

## Gate G4 — Consolidation & master gate  ✅ GREEN
- [x] `bash run_all_gates.sh` → **ALL GATES GREEN, exit 0** (now actually RUNS each
      reproduce.sh end-to-end + pytest + hygiene, not just existence checks).
- [x] this file all-green with evidence (G0–G4).
- [x] repo-wide fake-completion scan over project sources = 0 matches.
- [x] three drafts + working reproduce.sh + real results/ + figs/ each (verified exit 0).
- [x] kernel installs clean (`pip install -e .`), tests **23 passed, 0 skipped**.
- [x] README links all drafts, kernel, reproduce scripts; JOSS paper.md/paper.bib present.

### Remaining (external, non-blocking)
- CORA head-to-head — **RESOLVED**: replaced by a validated pure-Python zonotope baseline
  (`python/zonotope.py`, 6 tests); no MATLAB used or planned (see BLOCKERS.md B1).

---

## Review round (critic xhigh + Codex sign-off) — in progress

**Kernel correctness fix (from xhigh critic round 1):** the naive pairwise reach-tube recursion
was replaced/augmented with the correct joint k-fold KV tight tube
(`minksum_ext_multi`, `minksum_int_multi`, `reach_tube_lti_discrete_tight`). Verified exact
(≤1e-8) even at κ=1000. Suite now **32 passed, 0 skipped**.

**Critic round 1 verdicts:** Paper 1 revise, Paper 2 **reject** (headline was a recursion
artifact), Paper 3 revise. All findings addressed:
- Paper 2: tight tube → exact for all convex disturbances; "ellipsoids lose" retracted as an
  implementation artifact; reframed as a benchmark/cautionary methods note (naive 904.7/63× vs exact).
- Paper 1: added fair zonotope baseline → ellipsoid advantage is modest-to-negative (zonotope wins
  double_integrator); removed false "box is dominant" claim; §5 reports method's own 160× looseness.
- Paper 3: decomposed wrapping (~4×) vs genuine shape gain (domain C 3.47×, real); fixed "matched
  coverage" and "sound" language (probabilistic/union-bound); engaged Lindemann et al. prior art.

**Codex verdicts (round 1, the gate):** Paper 1/2/3 all **REJECT** — all on **NEW: No**
(competent compositions of classical KV + CROWN/conformal; no new theorem). Correct/legit issues
also found (some from stalled fix agents: stale draft-vs-CSV numbers). Conclusion: the 3 papers are
legit-once-fixed but **structurally not novel**; the "new" gate is unreachable for them.

## PIVOT — novel result (user-directed): certified INNER reach tube for ReLU NFLs

Both reviewers pointed to the same untapped differentiator: the certified **inner / min-max** tube
(ET Asset B) that outer-bound NN tools lack. Built it as `paper-4`:
- `python/pwa_nfl.py`: exact ReLU PWA activation-region decomposition + KV **internal** ellipsoids;
  sound inner-approximation for ANY subset of regions (anytime). Theorem 1 + proof in draft.
- **Soundness VERIFIED**: `test_pwa_nfl.py` (5 tests) — exact local affine, inner⊆E∩region,
  minksum_int⊆E⊕W, and end-to-end **600/600 inner points reachable (fraction 1.0000)**.
- Demonstration (`paper-4/inner_reach.py`): two-sided bracket inner⊆true⊆outer; a **reachability
  CERTIFICATE** (proves the NFL reaches a target region at steps 1–2) — impossible with outer bounds.
- Honest limitation reported: inner set tight early (0.225 of true at step 1), conservative later (0.008 by step 6).
- Suite now **37 passed, 0 skipped**; `run_all_gates.sh` **ALL GATES GREEN** (paper-4 integrated).

**Paper-4 round 1:** critic **revise** (soundness CONFIRMED by exact oracle; novelty overstated,
audit method finite-direction). Codex **REJECT** (core sound, but certificate impl could false-positive,
audit sampled wrong set, novelty = Asset-C packaging).

**Paper-4 round 2 (user directive "push it, need publishable new results"):** upgraded to the
differentiated machinery + fixed all bugs:
- **Robust (min-max) inner set** via KV internal Minkowski **difference/erosion** (`certified_robust_inner_onestep`):
  states GUARANTEED reachable despite worst-case disturbance (Theorem 2, tested sound).
- **Exact realizability witnesses** (`internal_sum_witness`): closed-form y=a+w decomposition →
  **600/600 verified exact** (not finite-direction). Fixes Codex legit critique.
- **Exact region enumeration** (single-hidden-layer) replaces sampling. Fixes "sampled not exact".
- **Exact ellipsoid-ball certificate** (SLSQP min-distance) — never false-positive. Fixes cert bug.
- Honest related work vs BURNS (2505.03643, backward MILP), Rober et al. (2209.14076), RPM, hybrid
  zonotopes; precise delta = forward + closed-form ellipsoidal + robust-via-erosion + anytime.
- Suite **40 passed**; master gate **ALL GATES GREEN**. Certificate: inner reaches goal steps 1-3;
  robust guaranteed-reach step 1.

**Paper-4 round 3 (final in-session):** Codex re-review still REJECT (NEW: No is structural across
all 5 results + both reviewers), but confirmed the one-step inner inclusion SOUND and flagged real
fixable bugs — all fixed:
- Stale robust carry-forward removed (robust set now reported honestly, empty when erosion vanishes).
- `∀w∃x` vs `∃x∀w` semantics corrected throughout (dropped "min-max"; it's a W-robustness margin).
- Scale-maximizing interior point → inner set much less conservative (0.72→2.09) and **W-robust set
  now non-trivial across the horizon (0.484→0.189), robust certificate fires steps 1–3**.
- SLSQP certificate now checks solver success (no uncertified claims); "exact enumeration" reworded
  to "complete pattern enumeration + sound interior-point heuristic"; "true area" reworded to
  "sampled-reach hull over-estimate".
- Suite **40 passed**; master gate **ALL GATES GREEN**; draft numbers verified against CSVs.

### FINAL HONEST VERDICT
Two independent xhigh reviewers (OMC critic + Codex), across 5 distinct results and ~6 rounds,
converge: everything is **sound, reproducible, and legit** but **not novel** by a top-venue bar —
all are compositions of *classical* Kurzhanski–Varaiya calculus (which ET already implements) with
known NN/conformal techniques. A Codex "NEW: yes" was not reached and is judged structurally
unreachable without a genuinely new theorem/algorithm. **Publishable level: workshop / tool /
reproducibility** (JOSS software paper for `ellreach`; verification-workshop short paper for the
certified-robust-inner-NFL result), NOT a top-venue methods breakthrough.
