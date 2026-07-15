# Code Audit — Ellipsoidal Toolbox (ET): what is novel/reusable vs. what CORA already covers

**Date:** 2026-07-15
**Scope:** `products/+gras` (reach-tube kernel), `products/elltoolboxcore/@ellipsoid` (ellipsoidal calculus), `products/+elltool` (user-facing reach API).
**Purpose:** Ground the three paper proposals and the framework-extraction plan in what the code *actually* implements, verified by reading the source (not the README).

---

## 1. What ET actually is

ET is a faithful, well-engineered implementation of **Kurzhanski–Varaiya ellipsoidal calculus and reachability** for continuous- and discrete-time linear/PWA systems, with and without disturbances. It is not a thin wrapper — it contains a genuine numerical ODE-based reach-tube engine (`+gras`) beneath a relational/OO data layer (`smartdb`, `modgen`).

**Metrics:** ~1,470 `.m` files, ~2,900 commits, full `mlunit` test suite, Sphinx docs. Dormant since 2018. MATLAB-only.

**Layer map:**
- `elltoolboxcore/@ellipsoid`, `@hyperplane` — 71-method ellipsoid algebra (the "static" set operations).
- `+elltool/+core/@GenEllipsoid` — generalized (possibly degenerate/unbounded) ellipsoids.
- `+gras` — the reach-tube engine: `+la` (linear algebra), `+mat` (matrix-function interpolants + symbolic), `+ode` (matrix ODE solvers incl. a *regularizing* solver `ode45reg`), `+ellapx` (the ellipsoidal-approximation reach algorithms).
- `+elltool/+reach`, `+elltool/+linsys` — user-facing `reach` objects.

---

## 2. The three differentiated assets (verified in source)

### Asset A — Tight, direction-parametrized reach tubes via matrix ODEs
Files: `+gras/+ellapx/+lreachplain/ExtEllApxBuilder.m`, `IntEllApxBuilder.m`, `ATightEllApxBuilder.m`.

For each "good direction" `l(t)`, ET integrates a **matrix ODE** whose solution `Q(t)` is the shape matrix of an ellipsoid that is **tangent to the true reach set along `l(t)` at every `t`** (not merely a loose enclosure). Verified equations:

- **External** (`ExtEllApxBuilder.calcEllApxMatrixDeriv`):
  `dQ/dt = AQ + QAᵀ + π(t)·Q + π(t)⁻¹·BPBᵀ`,  with  `π(t) = √(lᵀBPBᵀl / lᵀQl)`.
  This is exactly the KV tight external tube. The intersection over a family of directions `{lᵢ}` gives the tight external estimate.
- **Internal** (`IntEllApxBuilder.calcEllApxMatrixDeriv`): a **square-root** matrix ODE
  `dQ^{1/2}/dt = A·Q^{1/2} + (BPBᵀ)^{1/2}·Sᵀ`, with `S` an orthogonal matrix from `getOrthTranslMatrix(...)`.
  The union over directions gives the tight internal estimate.

**Why this matters:** CORA supports ellipsoids as a set representation, but its ellipsoidal reachability is comparatively limited; the *touching-tube family* (a continuum of ellipsoids each tangent along a curve of directions, giving guaranteed inner **and** outer tubes that are tight in chosen directions) is ET's signature and is **not** a mainstream CORA capability. This is the reusable crown jewel.

### Asset B — Min-max (control-vs-disturbance) reach tubes
File: `+gras/+ellapx/+lreachuncert/ExtIntEllApxBuilder.m`.

Handles systems with **both** a control constraint (`B,P`) and a bounded disturbance (`C,Q`) simultaneously, integrating coupled internal/external shape ODEs:
- Internal derivative uses `−π_num·Q/π_den − π_den·CQCᵀ/π_num` terms (disturbance *shrinks* the guaranteed set).
- External derivative uses `+π_num·Q/π_den + π_den·BPBᵀ/π_num`.
- Includes an **on-line regularization** step (`calcRegEllApxMatrix`) with a dedicated regularizing ODE integrator (`+gras/+ode/ode45reg`) that keeps `Q` positive-definite (min-eigenvalue floor `minQMatEig`) — the practical detail that makes degenerate/uncertain cases survive numerically.

**Why this matters:** game-theoretic (min-max) reachability under disturbance is the genuinely hard case and the one most relevant to *robust* AI-in-the-loop control. The regularization machinery is battle-tested engineering that is expensive to re-derive.

### Asset C — Complete ellipsoidal Minkowski algebra, including *difference*
Directory: `elltoolboxcore/@ellipsoid` (71 methods). Verified operations:
- `minksum_ea/_ia` (Minkowski sum, external/internal), `minkdiff_ea/_ia` (**Minkowski/geometric difference — erosion**), `minkmp*` (sum-then-difference), `minkpm*`.
- Intersections: `intersection_ea/_ia` (ell∩ell), `hpintersection` (ell∩halfspace), `toPolytope`, `doesIntersectionContain`.
- Support/geometry: `rho` (support function), `polar`, `isinternal` (membership), `distance`, `getProjection`, boundary samplers (`ellbndr_2d/3d`).

**Why this matters:** most set libraries do Minkowski *sums* well and *differences* poorly or not at all. Robust erosion (`X ⊖ E`) is exactly what backward-reachability / robust-invariant-set / safety-margin computations need. This is a differentiator.

---

## 3. Honest assessment vs. CORA (the incumbent)

| Capability | ET | CORA (2026) |
|---|---|---|
| Ellipsoid set type + basic ops | ✅ mature (71 methods) | ✅ (degeneracy-aware, SDP-backed via MOSEK/SDPT3) |
| Tight KV touching-tube family (ext+int, direction-parametrized) | ✅ **signature** | ⚠️ not mainstream |
| Min-max control/disturbance ellipsoidal tubes + regularization | ✅ **signature** | ⚠️ partial |
| Minkowski **difference** of ellipsoids | ✅ | ⚠️ limited |
| Zonotopes / polynomial zonotopes / Taylor models | ❌ | ✅ **dominant** |
| Neural-network verification (open+closed loop, ONNX import) | ❌ | ✅ **dominant**, VNN-COMP entrant |
| GPU set-based robust training | ❌ | ✅ |
| Active maintenance / funded team | ❌ (dormant 2018) | ✅ |
| Language | MATLAB only | MATLAB (+ growing ecosystem) |

**Conclusion:** ET cannot out-compete CORA as a general reachability framework, and should not try. ET's edge is a *specific, mathematically deep, well-tested kernel* (Assets A–C) that the AI-verification world under-uses. The strategy is therefore: **use the kernel as leverage for papers**, and extract only the kernel (not the 1,470-file monolith) into a reproducible library.

---

## 4. Reusability / extraction ratings

| Component | Reuse value | Extraction difficulty | Notes |
|---|---|---|---|
| `@ellipsoid` Minkowski algebra (Asset C) | High | Low–Med | Self-contained numerics; portable to Python/NumPy+CVXPY. |
| Tight tube ODEs (Asset A) | **Very high** | Med | Depends on `+gras/+ode` matrix ODE solver + good-direction curves; ~10–15 files core. |
| Min-max tubes + `ode45reg` (Asset B) | High | Med–High | Regularizing solver is subtle; port carefully with tests as oracle. |
| `smartdb`/`modgen`/`mlunitext` infra | Low | — | Framework plumbing; **do not** port — replace with pandas/pytest. |
| `+elltool` user API, plotting, config-patch system | Low | — | MATLAB-idiomatic; re-design rather than port. |

**Minimal reproducible core ≈ 20–30 files**, dominated by `@ellipsoid/minksum_*`, `minkdiff_*`, `rho`, `isinternal`, plus `+gras/+ellapx/+lreachplain` and `+gras/+ode`.

---

## 5. Existing MATLAB code as a *test oracle*

The single most valuable reuse of the legacy code is as a **ground-truth oracle** for a Python re-implementation: the `mlunit` regression etalons under `+gras/+ellapx/+uncertcalc/+test/+regr` store precomputed reach-tube results. A Python port can be validated numerically against these frozen outputs — turning a risky rewrite into a test-driven one.

---

## 6. Recommendation feeding the other artifacts

1. Papers should lean on **Asset A (tight tubes)** and **Asset B (min-max)** — these are what nobody else productizes.
2. Paper 3 (ML uncertainty) leans on **Asset C** (ellipsoid algebra + support functions).
3. Framework extraction = **kernel only**, Python, validated against MATLAB etalons (§5).
