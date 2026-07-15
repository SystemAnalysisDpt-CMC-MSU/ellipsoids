---
title: 'ellreach: A reproducible Kurzhanski–Varaiya ellipsoidal reachability kernel'
tags:
  - Python
  - reachability analysis
  - ellipsoidal calculus
  - formal verification
  - set-based computing
authors:
  - name: Ellipsoidal Toolbox authors (ellreach port)
    affiliation: 1
affiliations:
  - name: Moscow State University, Faculty of CMC, System Analysis Department (original ET)
    index: 1
date: 2026-07-15
bibliography: paper.bib
---

# Summary

`ellreach` is a dependency-light (NumPy; SciPy optional) Python re-implementation of the
mathematical core of the MATLAB **Ellipsoidal Toolbox (ET)**: Kurzhanski–Varaiya ellipsoidal
calculus and tight reach-tube computation for linear systems with bounded control/disturbance.
It exposes the ellipsoid algebra that reachability and set-membership methods need — support
functions, tight external/internal Minkowski **sum and difference**, ellipsoidal intersection —
plus discrete and continuous tight reach tubes parametrized by "good directions". Correctness is
checked against exact Kurzhanski–Varaiya analytic identities (support-direction tangency,
internal ⊆ external ordering, erosion soundness) rather than only against reference outputs, so
the test suite doubles as an executable specification.

# Statement of need

Set-based reachability underpins formal verification of control and, increasingly, of neural
feedback loops. The dominant open tools (CORA, JuliaReach) center on zonotopes; mature ellipsoidal
machinery lives mostly in the dormant, MATLAB-only ET. `ellreach` makes ET's differentiated
kernel — tight direction-parametrized tubes, min-max tubes, and the (rare) ellipsoidal Minkowski
difference — available to the Python AI ecosystem, so researchers can combine ellipsoidal
reachability with neural-network bounding and conformal prediction without a MATLAB round-trip.

# Functionality

- `Ellipsoid` with support function, affine image, membership, containment ordering, volume.
- `minksum_ext/int`, `minkdiff_ext/int`, `intersection_ext` (Assets A/C of the port audit).
- `reach_tube_lti_discrete` (external/internal) and `reach_tube_lti_continuous` (matrix ODE).
- Companion modules `nn_bounds` (sound ReLU relaxation) and `conformal` (Mahalanobis conformal sets)
  that build the neural-feedback-loop and conformal-tube applications on top of the kernel.

# Provenance & tagging

Version 0.1.0 (see `VERSION` and `pyproject.toml`). Clean-room implementation of published
Kurzhanski–Varaiya formulas and the ET sources; provenance recorded in `00-code-audit.md`.

# Acknowledgements

Built on the Ellipsoidal Toolbox by A. Kurzhanskiy and P. Gagarinov (MSU / UC Berkeley).
