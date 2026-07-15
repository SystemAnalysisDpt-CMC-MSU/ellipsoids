# AI + Ellipsoids: Strategy, Papers, and Reproducible Kernel

Analysis of whether the **Ellipsoidal Toolbox (ET)** can grow into a popular AI framework
and/or seed novel papers — with concrete plans and a working Python proof-of-concept.

## TL;DR verdict

- **Popular framework (full revival):** *No.* CORA (TU Munich) already owns "sets + neural
  networks in MATLAB", is actively maintained, and covers ellipsoids *and* zonotopes *and*
  NN verification. Don't fight it head-on.
- **Narrow framework (kernel extraction):** *Yes.* ET has three mathematically deep, well-tested
  assets CORA under-serves — tight KV touching-tubes, min-max (control-vs-disturbance) tubes,
  and full ellipsoidal Minkowski *difference*. Extract these ~20-30 files as a small Python
  library that plugs into the AI ecosystem.
- **Novel papers:** *Yes — three distinct, viable ones* (below), in rising order of novelty risk.

## Contents

| File | What |
|---|---|
| `00-code-audit.md` | Source-verified audit: what ET actually implements, the 3 differentiated assets, honest ET-vs-CORA table, extraction ratings. |
| `paper-1-nn-feedback-loops.md` | **Paper 1** — tight ellipsoidal reach tubes for neural-network-controlled systems. Highest novelty; real gap in 2025 NFL literature. |
| `paper-2-et-vs-cora-benchmark.md` | **Paper 2** — "when do ellipsoidal tubes win?" reproducible benchmark vs. zonotopes. Lowest risk; uses existing code. |
| `paper-3-ellipsoidal-uncertainty-ml.md` | **Paper 3** — conformal ellipsoidal *tubes* for learned dynamics. Repositioned to the open dynamical niche (static ellipsoidal CP is already crowded). |
| `framework-extraction-plan.md` | Kernel-only extraction plan + the "re-create in Python?" decision (verdict: yes, minimally). |
| `python/ellreach.py` | Working NumPy-only PoC: `Ellipsoid`, tight external Minkowski sum, discrete LTI reach tube. |
| `python/test_ellreach.py` | Self-validating tests (no MATLAB needed) — KV tightness identity, soundness, containment. |
| `python/POC_RESULT.txt` | Recorded test output: **all 7 checks pass.** |

## The three differentiated assets (see audit for source evidence)

- **A. Tight, direction-parametrized reach tubes** via matrix ODEs — ellipsoids tangent to the
  true reach set along chosen directions (external `dQ/dt = AQ+QAᵀ+πQ+π⁻¹BPBᵀ`; internal sqrt-ODE).
- **B. Min-max tubes** — simultaneous control (`B,P`) and disturbance (`C,Q`) with online
  PD-regularization (`ode45reg`). Game-theoretic robust reachability.
- **C. Complete ellipsoidal Minkowski algebra** — including the *difference* (erosion), which most
  set libraries lack; the basis for backward-reachability and set-membership estimation.

## Recommended sequencing

1. **Paper 2 first** (lowest risk, validates tooling, produces the benchmark others cite).
2. **Ship the Python kernel** (P0-P1 in the extraction plan) alongside Paper 2 → reproducibility + JOSS artifact.
3. **Paper 1** (the flagship: ellipsoids for neural feedback loops) on top of the kernel + LiRPA glue.
4. **Paper 3** (CP × reachability crossover) — highest ML bar, most fundable framing, do last.

## Reproducibility status — ALL PHASES EXECUTED & VERIFIED

The full program in `EXECUTION_PROMPT.md` has been run. Gates G0–G4 are green
(see `PROGRESS.md` for evidence; `BLOCKERS.md` for the one external item).

Setup + master gate:
```
cd research-ai-ellipsoids
python3 -m venv .venv && .venv/bin/python -m pip install -e ".[dev]"
bash run_all_gates.sh                 # -> ALL GATES GREEN, exit 0
```

Kernel (`ellreach` v0.1.0) and per-paper artifacts:
```
.venv/bin/python -m pytest python      # 23 passed, 0 skipped
bash paper-2/reproduce.sh              # benchmark: CSVs + 6 figs   (exit 0)
bash paper-1/reproduce.sh              # NFL: MC containment 1.0000 (exit 0)
bash paper-3/reproduce.sh             # conformal tubes: coverage curves (exit 0)
```

| Paper | Draft | Code | Headline verified result |
|---|---|---|---|
| 2 (benchmark) | `paper-2/draft.md` | `paper-2/bench.py` | Ellipsoid exact for isotropic W; loses at anisotropy κ≳5 (max gap 904 @ κ=200) |
| 1 (NFL) | `paper-1/draft.md` | `paper-1/nfl.py`, `python/nn_bounds.py` | 5522× tighter than box on rotation showcase; verifies safety half-spaces box cannot; MC containment 1.0 |
| 3 (conformal) | `paper-3/draft.md` | `paper-3/cp_tubes.py`, `python/conformal.py` | Coverage ≥ nominal on 3 domains; ellipsoid 6.4×/1.9×/3.5× smaller than box; honest bimodal failure |

Kernel packaging: `pyproject.toml` (v0.1.0), `VERSION`, JOSS `paper.md` + `paper.bib`.
