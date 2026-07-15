# BLOCKERS

## B1 — CORA head-to-head  [RESOLVED — replaced by pure-Python zonotope baseline]
- **Original impact:** CORA is MATLAB-only; no MATLAB/Octave in this environment.
- **Resolution (per user directive "compare with a Python framework, do not invest in MATLAB"):**
  implemented a self-contained zonotope reach tube (Girard's method) in `python/zonotope.py`
  (NumPy only, ~120 lines), validated against exact vertex-enumeration + Minkowski-sum identities
  (`python/oracle_tests/test_zonotope.py`, 6 tests). Paper 2 now contains a real ellipsoid-vs-
  zonotope head-to-head (`paper-2/bench_zono.py` → `results/ell_vs_zono.csv`, `figs/fig7_*.png`).
- **Outcome:** the "which representation, when?" question is answered directly in Python; no MATLAB
  needed and none planned. B1 is no longer a blocker.
- **ET etalon export** (separate, minor): still needs MATLAB to export legacy regression etalons,
  but the kernel is already validated against exact KV analytic identities (23 kernel tests), so
  etalon export is a nicety, not a gate. Marked wontfix unless a MATLAB machine is used later.

## B2 — No torch / auto_LiRPA (Paper 1 NN bounding)  [worked around]
- **Impact:** cannot use the auto_LiRPA/CROWN library directly.
- **Resolution:** implemented a self-contained, sound CROWN-style interval+linear ReLU relaxation
  in `python/nn_bounds.py` (dependency-light, reproducible). Not a blocker.
