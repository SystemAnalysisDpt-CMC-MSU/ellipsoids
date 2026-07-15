# Framework Extraction Plan + Python Reproducibility Decision

**Date:** 2026-07-15
**Decision rule from goal:** re-create portions in Python *only if needed*. Verdict below.

---

## 1. Do NOT revive the monolith

Reviving all ~1,470 MATLAB files to compete with CORA is the wrong bet (see audit §3). Instead, extract the **kernel** (audit §4, ~20–30 files of real math) as a small, focused, MIT/BSD-licensed library that *plugs into* the Python AI ecosystem (LiRPA/CROWN, conformal libraries) rather than replacing CORA.

## 2. Is a Python re-creation "needed"? — Yes, minimally.

**Needed**, because:
- All three papers target venues (L4DC, NeurIPS/ICML, CoRL) and communities that are **Python-first**; a MATLAB-only artifact suppresses adoption and citations.
- The NN-bounding glue (Paper 1) and conformal calibration (Paper 3) already live in Python (`auto_LiRPA`, conformal packages). Round-tripping to MATLAB is friction that will sink reproducibility.
- The MATLAB `mlunit` regression **etalons** (audit §5) make the port *test-driven and low-risk*: the legacy code becomes the oracle.

**Kept minimal**, because:
- Only the kernel is needed, not the plumbing (`smartdb`, `modgen`, config-patch system → replaced by NumPy/SciPy/pandas/pytest).
- Plotting, GUI, deployment code → out of scope.

## 3. Extraction scope (kernel only)

| Module (Python `ellreach/`) | Source (MATLAB) | Priority |
|---|---|---|
| `ellipsoid.py` — Ellipsoid(q,Q): support `rho`, linear map, `contains`/`isinternal`, volume, boundary sample | `@ellipsoid/{rho,isinternal,double,...}` | P0 |
| `minkowski.py` — `minksum_ea/_ia`, `minkdiff_ea/_ia` (direction-parametrized) | `@ellipsoid/mink*` | P0 |
| `tube_lti.py` — discrete + continuous tight external/internal tube (matrix ODE) | `+gras/+ellapx/+lreachplain/*` | P1 |
| `tube_minmax.py` — control-vs-disturbance ext/int tube + PD regularization | `+gras/+ellapx/+lreachuncert/ExtIntEllApxBuilder`, `+gras/+ode/ode45reg` | P2 |
| `nn_bounds.py` — glue to `auto_LiRPA`/CROWN → ellipsoidal input set (Paper 1) | new | P1 |
| `conformal.py` — Mahalanobis conformal error ellipsoid (Paper 3) | new | P2 |
| `oracle_tests/` — numeric regression vs. MATLAB etalons | `+uncertcalc/+test/+regr` | P0 |

**P0 (this session):** a runnable, *verified* proof-of-concept of `ellipsoid.py` + external Minkowski sum + a discrete LTI tube — enough to (a) prove the port is straightforward and (b) seed all three papers. Delivered in `python/` (see §5).

## 4. Milestones

1. **PoC (done here):** Ellipsoid + tight external sum + discrete LTI tube, self-validated by the exact tightness identity `ρ(E1⊕E2 external, l) = ρ(E1,l)+ρ(E2,l)`.
2. **Oracle harness:** export a handful of ET etalon tubes to `.mat`/`.npz`, add `pytest` comparisons (needs a MATLAB run of ET once).
3. **Continuous tube ODE:** port `ExtEllApxBuilder` ODE via `scipy.integrate.solve_ivp` (matrix-valued), validate vs. discrete + vs. etalon.
4. **Min-max + regularization:** port `ExtIntEllApxBuilder` with the PD-floor regularizer; hardest step, do last, with etalon oracle.
5. **Package + docs + one demo per paper.** Publish to PyPI + a JOSS submission (the port itself is a citable software artifact).

## 5. Python proof-of-concept delivered this session

`python/ellreach.py` — dependency-light (NumPy only) implementation of:
- `Ellipsoid(q, Q)` with support function `rho`, affine map, membership, volume.
- `minksum_ext(E1, E2, l)` — tight external ellipsoidal Minkowski sum, tight in direction `l`.
- `reach_tube_lti_discrete(A, E0, W, dirs, N)` — external reach tube of `x_{k+1}=A x_k + w`, `w∈W`.

`python/test_ellreach.py` — self-checks with **no MATLAB dependency**:
- Support function of a ball equals its radius.
- **Tightness identity:** external sum's support along `l` equals sum of supports (the defining KV property) — this is the correctness oracle that does not need the legacy code.
- Linear-map covariance transform correctness.
- Reach tube of a stable rotation-scaling system stays bounded and contains sampled true trajectories.

Run: `python3 research-ai-ellipsoids/python/test_ellreach.py` (see recorded output in `python/POC_RESULT.txt`).

## 6. Licensing / provenance note

ET ships under its own `COPYRIGHT.txt`; confirm terms before relicensing the extracted kernel. The Python code here is a clean-room re-implementation of published KV formulas (citable to Kurzhanski–Varaiya 2000 + ET docs), which keeps provenance clean, but the audit trail should record which files informed which functions.

## 7. Effort

- PoC: done (this session).
- Full P0–P1 kernel with oracle tests: ~3–4 weeks.
- Min-max (P2): ~2–3 weeks.
- Packaging + JOSS: ~1–2 weeks.
- **Total ~2 months** to a citable, pip-installable `ellreach` that backs all three papers.
