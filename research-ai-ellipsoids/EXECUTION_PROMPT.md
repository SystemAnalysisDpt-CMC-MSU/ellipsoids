# EXECUTION PROMPT — AI + Ellipsoids research program

**Paste this as the task prompt for an autonomous run (e.g. `/goal`, `ralph`, or `autopilot`).**
It executes the program in the fixed order **Phase 0 → 1 → 2 → 3 → 4** and defines **hard gates**:
you may not stop, declare done, or advance a phase until that phase's gate is **green with pasted
evidence**. A gate is green ONLY when its verification command has been run and its literal output
is shown. Assertions without pasted command output do NOT satisfy a gate.

Repo root: `/Users/peter/_Git/_MSU/ellipsoids`  ·  Work dir: `research-ai-ellipsoids/`
Read `README.md` and `00-code-audit.md` first — they define the three assets (A tight tubes,
B min-max tubes, C Minkowski algebra incl. difference) every phase builds on.

---

## GLOBAL STOP CONTRACT (read before anything)

1. **Do not stop until every gate G0–G4 is green.** If blocked, do not exit — create a
   `BLOCKERS.md` entry describing the blocker and the smallest next action, then keep working
   other unblocked items. Only a hard external dependency (no MATLAB license AND no substitute)
   may pause a phase, and only after the substitute path in that phase has been tried.
2. **No fake completion.** `TODO`, `FIXME`, `pass`-only bodies, `pytest.skip`/`xfail`,
   `raise NotImplementedError`, stub figures, placeholder numbers, or "will add later" are
   **blockers, not progress**. Before claiming a gate, grep the changed files for these and
   resolve or log them.
3. **Evidence before assertion.** Every "done" claim pastes the exact command and its output.
   Coverage/accuracy/tightness numbers come from a run you show, never from memory.
4. **Author and verify in separate passes.** After implementing a phase, run an independent
   review/verify pass (a reviewer agent or a re-run from a clean state) before turning the gate green.
5. **Track with a live checklist.** Maintain `PROGRESS.md` with one line per gate item and its
   status; update it as you go. The run is complete only when `PROGRESS.md` shows all gates green
   AND `python3 research-ai-ellipsoids/run_all_gates.sh` (created in Phase 0) exits 0.

---

## Phase 0 — Foundation & harness  (prereq for all)

**Do:**
- Confirm the PoC still passes; expand `python/ellreach.py` to P0-P1 kernel from
  `framework-extraction-plan.md` §3: `minksum_ia`, `minkdiff_ea/_ia`, `intersection`, and the
  continuous tight external tube via `scipy.integrate.solve_ivp` (matrix-valued ODE).
- Add `pyproject.toml`, pin deps (numpy, scipy, pytest), make `pip install -e .` work.
- Create `run_all_gates.sh` that runs every phase's verification in sequence and exits nonzero
  on any failure. This script is the machine definition of "all done".
- Add oracle-test scaffold `python/oracle_tests/` (compare against ET etalons; if no MATLAB,
  substitute analytic identities as in `test_ellreach.py` and mark which tests are analytic vs.
  etalon-backed).

**GATE G0 (must be green to advance):**
- [ ] `python3 -m pytest research-ai-ellipsoids/python -q` → all pass, **0 skipped**, output pasted.
- [ ] `pip install -e research-ai-ellipsoids` succeeds, output pasted.
- [ ] `bash research-ai-ellipsoids/run_all_gates.sh` exists and runs Phase 0 checks green.
- [ ] Every new kernel function has ≥1 test asserting a KV identity or etalon match.
- [ ] Grep for fake-completion markers in `python/**` returns nothing (paste the grep + empty result).

---

## Phase 1 — Paper 2 (ET-vs-CORA benchmark) + ship the kernel

Rationale: lowest novelty risk, validates tooling, produces the artifact the other papers cite.
Spec: `paper-2-et-vs-cora-benchmark.md`.

**Do:**
- Implement the benchmark harness: common problem spec → drives the Python kernel (and CORA if a
  MATLAB license exists; otherwise document CORA numbers as "pending license" and compare kernel
  vs. a fine polytopic/Monte-Carlo reference truth).
- Run the regime sweeps (conditioning, rotation angle, disturbance ratio, dimension 2→20,
  safe-set geometry). Save raw results to `paper-2/results/*.csv` and figures to `paper-2/figs/`.
- Write `paper-2/draft.md`: intro, method, the regime map, honest both-directions findings,
  reproducibility appendix. Every number traces to a CSV.
- Package + tag the kernel `v0.1` and draft the JOSS `paper.md` + `paper.bib`.

**GATE G1:**
- [ ] `bash paper-2/reproduce.sh` regenerates every figure and table from raw data, output pasted.
- [ ] `paper-2/results/` contains real CSVs; spot-check ≥3 numbers appear verbatim in the draft.
- [ ] The draft states at least one regime where ellipsoids LOSE (honesty check — advocacy-only fails).
- [ ] Kernel `v0.1` importable + tagged; `python -c "import ellreach"` works, pasted.
- [ ] Independent verify pass re-ran `reproduce.sh` from clean checkout and matched figures.

---

## Phase 2 — Paper 1 (neural feedback loops)  [flagship]

Spec: `paper-1-nn-feedback-loops.md`. Depends on Phase 1 kernel.

**Do:**
- Add `nn_bounds.py`: glue to `auto_LiRPA`/CROWN → sound affine relaxation → ellipsoidal input set.
- Implement the per-step NFL algorithm (audit Assets A/C) + min-max variant (Asset B).
- Prove soundness (write the argument in `paper-1/theory.md`) and state the tangency/tightness claim.
- Run the NFL benchmark suite (double integrator, quadrotor linearization, ACC, pendulum-NN, plus
  the rotation-dominated correlation showcase). Baselines: interval, zonotope (CORA if available),
  Reach-SDP. Save `paper-1/results/`, `paper-1/figs/`.
- Write `paper-1/draft.md` with the when-ellipsoids-win characterization.

**GATE G2:**
- [ ] Soundness argument written and checked by an independent (reviewer) pass; note any gap.
- [ ] `bash paper-1/reproduce.sh` regenerates all NFL results/figures, output pasted.
- [ ] For ≥1 benchmark, ellipsoidal tube verifies a safety property that the box baseline cannot
      (or tighter support along the safety normal) — shown with numbers.
- [ ] Failure regime reported honestly (where poly-zonotopes win).
- [ ] No `NotImplementedError`/skip in `nn_bounds.py` or the NFL solver (grep pasted).

---

## Phase 3 — Paper 3 (conformal ellipsoidal tubes for learned dynamics)

Spec: `paper-3-ellipsoidal-uncertainty-ml.md`. Highest ML bar; do last.

**Do:**
- Implement `conformal.py`: split-conformal Mahalanobis error ellipsoid (per-step primitive).
- Implement horizon propagation via the kernel (Asset A/C) + the Minkowski-difference
  set-membership dual (Asset C).
- Experiments: learned surrogates (cart-pole/quadrotor/arm from offline data) + a neural
  multivariate time-series model. Baselines: coordinate-wise conformal, static ellipsoidal CP
  per-step, GP predictive covariance.
- Report calibration curves (realized vs. nominal coverage) and volume-at-fixed-coverage.
- Write `paper-3/draft.md` including the union-bound coverage statement + empirical coverage.

**GATE G3:**
- [ ] `bash paper-3/reproduce.sh` regenerates calibration curves + efficiency tables, pasted.
- [ ] Realized coverage ≥ nominal (within CI) on ≥3 domains — shown from the run, not asserted.
- [ ] Ellipsoidal tube beats coordinate-wise conformal on volume-at-fixed-coverage for ≥1
      correlated-error system — numbers shown.
- [ ] Non-elliptical failure regime reported.

---

## Phase 4 — Final consolidation & completion

**Do:**
- Ensure `README.md` links all three drafts, the kernel, and reproduce scripts.
- Fill `PROGRESS.md` (all gate items) and `BLOCKERS.md` (empty or only external-dependency notes).
- Run the master gate.

**GATE G4 (run is complete ONLY when this is green):**
- [ ] `bash research-ai-ellipsoids/run_all_gates.sh` exits 0 — paste full output.
- [ ] `PROGRESS.md` shows G0–G3 all green with evidence links.
- [ ] Repo-wide grep for fake-completion markers across `research-ai-ellipsoids/**` is empty, pasted.
- [ ] Three paper drafts exist, each with a working `reproduce.sh` and a results/ dir of real data.
- [ ] Kernel installs clean and all tests pass with 0 skips.

**Only after G4 is green may you stop.** If a phase is externally blocked (e.g. no MATLAB for CORA),
the run may reach G4 with that item explicitly marked `BLOCKED-EXTERNAL` in `PROGRESS.md` and a
substitute (Monte-Carlo/polytopic reference) used — but every non-external item must be green.

---

## Verification command cheat-sheet

```bash
cd /Users/peter/_Git/_MSU/ellipsoids
# per-phase
python3 -m pytest research-ai-ellipsoids/python -q
bash research-ai-ellipsoids/paper-2/reproduce.sh
bash research-ai-ellipsoids/paper-1/reproduce.sh
bash research-ai-ellipsoids/paper-3/reproduce.sh
# fake-completion scan (must print nothing)
grep -rnE "TODO|FIXME|NotImplementedError|pytest\.(skip|xfail)|placeholder|XXX" \
  research-ai-ellipsoids --include='*.py' --include='*.md' | grep -v EXECUTION_PROMPT.md
  # note: quote the globs (zsh expands them otherwise); empty output + exit 1 = clean
# master gate — the single source of truth for "all done"
bash research-ai-ellipsoids/run_all_gates.sh; echo "exit=$?"
```
