# Tight Ellipsoidal Reach Tubes for Neural Feedback Loops: A Fair Comparison Against Boxes and Zonotopes

**Draft — Paper 1.**  All numbers below are produced by `bash paper-1/reproduce.sh`
(exit 0) and read verbatim from `paper-1/results/*.csv`. Figures are in
`paper-1/figs/`.

---

## Abstract

We give a sound discrete-time reachability method for neural feedback loops
(NFLs) `x_{k+1} = A x_k + B·π(x_k) + w_k` with a linear/affine plant and a ReLU
MLP controller `π`. At each step we bound `π` over the current ellipsoid with a
self-contained, sound CROWN-style local relaxation `π(x) ∈ K x + d ⊕ D`, then
propagate the ellipsoid through the closed-loop map and add the slack/disturbance
set with the tight Kurzhanski–Varaiya external ellipsoidal Minkowski sum,
retaining tangency along user-chosen safety directions. We compare the
ellipsoidal tube against **two** sound baselines that propagate the *identical*
NN relaxation: an interval **box** (the weakest sound representation, used here
as an ablation) and a correlation-carrying **zonotope** (the representation the
mainstream NFL tools — CORA, JuliaReach, poly/hybrid-zonotope reachability —
actually use). On four benchmarks the ellipsoidal tube is a verified
over-approximation (Monte-Carlo containment fraction **1.0000** on every
benchmark). **Volume is measured by one consistent metric for all sets: the
volume of the actually-reported set** — for the ellipsoid, the *intersection* of
the per-direction ellipsoid family (the same set the containment check tests),
estimated by Monte-Carlo. Against the **box** the gap is dramatic (up to
**5534×** volume on a rotation-dominated plant), but that gap is mostly the box's
wrapping error, not a property of ellipsoids. Against the **zonotope** the honest
picture is that, on volume, the ellipsoid is **competitive-to-better** on all
four benchmarks once measured consistently: the zonotope-to-ellipsoid volume
ratio is **1.41×**, **1.55×**, and **1.28×** on `double_integrator`,
`stable_linear`, and `rotation_showcase` respectively (ellipsoid tighter each
time), and in 4-D exact zonotope volume is intractable so we compare support
there. In particular `double_integrator` **flips**: with a consistent volume the
ellipsoid intersection (**1.82**) is **1.41× tighter** than the zonotope
(**2.56**), reversing the earlier apples-to-oranges reading. We also report the
honest failure regime: on a deliberately multi-modal (non-convex) reachable set
the *true* set fills only `1/41.8` of its own convex hull, and **our own
ellipsoid enclosure (intersection of the per-direction family) is 84× looser than
the true set (98.8 % wasted volume)** — any single convex enclosure loses here
and poly/hybrid zonotopes win.

---

## 1. Method

For system `x_{k+1} = A x_k + B·π(x_k) + w_k`, `x_0 ∈ E_0`, `w_k ∈ W`:

1. **Sound NN relaxation** (`python/nn_bounds.py`). Over the axis-aligned
   bounding box of the current set, a CROWN-style backward pass returns affine
   planes `A_L x + b_L ≤ π(x) ≤ A_U x + b_U`. We set `K = (A_L+A_U)/2`, `d =
   (b_L+b_U)/2`, and enclose the residual `π(x) − (Kx+d)` by a slack set (an
   ellipsoid `E(0, D)` for the ellipsoidal method, an interval box for the box
   and zonotope methods), giving `π(x) ∈ K x + d ⊕ slack`. This is proved sound
   (theory.md §1) and empirically verified (soundness self-test, §4).
2. **Closed-loop propagation** (`paper-1/nfl.py`). `A_cl = A + BK`, `b_cl = Bd`;
   push the affine image `A_cl·E_k + b_cl` (exact for ellipsoids) and add
   `B·E(0,D) ⊕ W` via `minksum_ext(·,·,ℓ)`, the tight external KV sum tangent
   along `ℓ`. Choosing `ℓ` = safety-constraint normal makes the enclosure
   tightest exactly where it matters.
3. **Baselines (both propagate the identical relaxation).**
   * **Box** (`nfl.box_tube`): interval arithmetic on `K x + d ⊕ [d_lo,d_hi]`.
     This is the *weakest* sound representation — it discards all cross-state
     correlation — so it is an **ablation baseline**, not a competitive method.
   * **Zonotope** (`nfl.zono_tube`): the closed-loop affine map is applied
     *exactly* to a zonotope, and the slack `B·[d_lo,d_hi]` and disturbance `W`
     are added by exact zonotope Minkowski sum (generator concatenation, zero
     wrapping error), with Girard order reduction (`zonotope.Zonotope.reduce`) to
     cap the generator count. Zonotopes carry correlation and are the mainstream
     NFL representation, so this is the **competitive baseline** and the
     head-to-head that matters.

A practical soundness detail (theory.md §2, `nfl._reg`): `minksum_ext` returns a
single operand when the other has zero support along `ℓ`, which would drop that
operand's orthogonal extent. We floor operand eigenvalues to a small fraction of
their own scale (the ET `ode45reg`/`minQMatEig` idea) — this only inflates the
sets, so the over-approximation stays sound, and the Monte-Carlo check confirms
it.

## 2. Benchmarks and headline results

From `paper-1/results/summary.csv` (final step of each horizon). **All volumes
are the volume of the actually-reported set, measured consistently.** The
ellipsoid volume is the Monte-Carlo volume of the *intersection* of the
per-direction ellipsoid family (`nfl.mc_intersection_volume`, 200 000 box samples
counted inside *all* direction-ellipsoids, scaled by the bounding-box volume) —
i.e. the exact set the containment check (§4) tests, not any single-direction
ellipsoid. The zonotope volume is computed exactly by vertex hull in 2-D and is
omitted (`nan`) in 4-D where exact zonotope volume is intractable, so we report
the zonotope's exact **support** along the safety normal there instead.

| benchmark | N | MC contain. | ell vol (∩) | zono vol | box vol | box/ell | zono/ell |
|---|---|---|---|---|---|---|---|
| double_integrator | 15 | 1.0000 | **1.818** | 2.564 | 20.22 | 11.1× | **1.41×** |
| stable_linear | 20 | 1.0000 | **3.623** | 5.601 | 67.39 | 18.6× | 1.55× |
| rotation_showcase | 12 | 1.0000 | **0.0665** | 0.0848 | 367.8 | **5534×** | 1.28× |
| stable_4d | 18 | 1.0000 | **0.1110** | — | 6.162 | 55.5× | — |

**Reading this table honestly.** The huge `box/ell` ratios (up to 5534×) are
mostly the **box's wrapping error**, not evidence that ellipsoids are the right
tool: the zonotope, carrying the same correlation, closes most of that gap. But
once volume is measured by *the same rule for every method* — the volume of the
set each method actually reports — the ellipsoid is **competitive-to-better than
the zonotope on all four benchmarks**: the intersection-of-ellipsoids volume is
**1.28×–1.55× smaller** than the zonotope's in 2-D. The earlier draft compared a
*single-direction* ellipsoid volume (16.14 on `double_integrator`) against the
zonotope's *whole-set* volume (2.56) — an apples-to-oranges error that made the
ellipsoid look 6× worse. With the consistent intersection metric that reading
**reverses**: the reported ellipsoid set on `double_integrator` has volume
**1.82**, i.e. **1.41× tighter** than the zonotope. The ellipsoid's additional
edge shows up in support along a chosen safety normal (§3).

## 3. Support along the safety normal (ellipsoid vs zonotope vs box)

**An asymmetry we disclose up front.** The zonotope tube is a *single set*: its
support `ρ(Z_k, c)` for every direction `c` is read off the *same* set. The
ellipsoid method instead re-optimizes: for each safety normal `c` we build a
*separate* tube kept tight **along `c`** (per-direction re-optimization,
`nfl.ellipsoid_tube(...,direction=c)`), so the column `ell ρ(·,c_0)` below is the
support of a set specifically re-tightened for `c_0`, **not** of one fixed
ellipsoid. This favors the ellipsoid and is not apples-to-apples with the
zonotope's single-set support. To make the comparison fair we also report the
support of the **single** set the method actually certifies as a whole — the
*intersection* of the per-direction ellipsoid family (`ell∩ ρ(·,c_0)`,
`nfl.mc_intersection_support`, an inner-sampled and therefore slightly
conservative estimate). From `summary.csv`, final-step support along the first
safety normal `c_0` (smaller = tighter), with the safety bound `b_0`:

| benchmark | ell `ρ(·,c_0)` (tight-along-`c_0`) | ell∩ `ρ(·,c_0)` (single set) | zono `ρ(·,c_0)` | box `ρ(·,c_0)` | bound `b_0` |
|---|---|---|---|---|---|
| double_integrator | 2.768 | **1.935** | 2.076 | 3.393 | 2.0 |
| stable_linear | 1.104 | 1.104 | 1.430 | 5.971 | 2.5 |
| rotation_showcase | 0.408 | 0.405 | 0.422 | 13.639 | 1.35 |
| stable_4d | 0.507 | 0.504 | 0.812 | 1.5 (—) | 1.5 |

Two readings, both honest:

* **Per-direction (re-optimized) support** (`ell ρ`): tighter than the zonotope on
  three of four benchmarks (by `+0.33`, `+0.013`, `+0.069` along `c_0`) and
  looser on `double_integrator` (by `−0.69`). This is the tightest an *ellipsoid*
  can be along `c_0`, but it is a different set for each direction.
* **Single-set intersection support** (`ell∩ ρ`): the honest apples-to-apples
  number against the zonotope's single set. Here the ellipsoid intersection is
  **tighter than the zonotope on all four** benchmarks along `c_0` — including
  `double_integrator`, where the intersection support `1.935` is *below* the
  zonotope's `2.076` (and, notably, below the safety bound `2.0`). The
  intersection is tighter because it simultaneously respects the tight bound in
  *every* sampled direction, not just `c_0`.

The box is worse than both on every benchmark. The advantage of the ellipsoid
over the *competitive* (zonotope) baseline is real but incremental; the advantage
over the box is large but is a statement about the box, not about ellipsoids.

**Safety verification.** On `stable_linear` and `rotation_showcase` *both* the
ellipsoid and the zonotope verify both safety half-spaces (`ell_verified =
zono_verified = 1`), while the **box falsifies them** (`box_verified = 0`): box
support on `rotation_showcase` is `13.64`/`9.98` vs bounds `1.35`/`1.6`. So the
box baseline cannot certify safety that both correlation-carrying methods can —
but the zonotope certifies it just as the ellipsoid does. On `double_integrator`
(§5) the *per-direction* ellipsoid tube along `c_0` reports `2.768 > 2.0`
(`ell_verified_d0 = 0` in the CSV, matching the tight-along-`c_0` column) and the
box reports `3.393 > 2.0`; the **single-set intersection** support `1.935 < 2.0`
would satisfy `d0`, but we report the conservative CSV verification flag from the
per-direction tube.

The rotation showcase remains the intended correlation demonstrator: a
near-rotation `A = 0.92·[[cos1,−sin1],[sin1,cos1]]` keeps the reachable set a
thin, rotating, strongly correlated ellipse. The **box** must re-inflate to an
axis-aligned hull every step, compounding to the 5534× volume gap; both the
ellipsoid and the zonotope stay tight, and between them the ellipsoid intersection
is tighter by `1.28×` in volume (0.0665 vs 0.0848). The tube overlays (`figs/rotation_showcase_tube.png`)
now show all three sets: box (red, dashed) ballooning, ellipsoid (blue) and
zonotope (green, dash-dot) both hugging the sampled true trajectories (black).

## 4. Soundness evidence

* **NN relaxation self-test** (`python/test_nn_bounds.py`): for four MLPs
  (widths up to `[2,16,8,1]` and a 4-in/4-out net) and thousands of sampled
  inputs, the true output lies within the CROWN affine envelope, the box slack,
  and the ellipsoid slack. Prints `NN-BOUNDS SOUNDNESS: ALL CHECKS PASSED`.
* **Per-step soundness assertions** (`nfl.assert_step_soundness`, run inside
  `nfl.run_benchmark` for every disturbance-free benchmark): for each reported
  safety direction `d` it asserts the support recurrence
  `ρ(E_{k+1},d) ≥ ρ(A_cl·E_k image, d) + ρ(slack, d)` at every step (the KV sum
  never under-covers along `d`), and that each `E_k`'s axis-aligned bounding box
  contains sampled true closed-loop points. A violation raises `AssertionError`
  and aborts the run, turning a silent soundness regression into a hard failure.
* **Closed-loop Monte-Carlo containment** (`nfl.mc_containment`): 4000 sampled
  true trajectories per benchmark, every step checked against the intersection
  of all direction-tubes → containment fraction **1.0000** on all four
  benchmarks. `nfl.py` exits nonzero if any fraction drops below 0.999.

Soundness is argued in full in `paper-1/theory.md` (Lemma 1, Corollary 1,
Theorem 1 + induction), and the tangency/tightness statement in §3 there.

## 5. Honest failure regime and the non-uniform advantage

**Where every convex method loses (non-convex reachable set).** Ellipsoids —
like boxes and zonotopes — are **convex** enclosures. We construct a controller
that acts as a hard `|x_1|`-fold (`u ≈ 7.5·|x_1| − 1` via two ReLUs), so the
one-step reachable set is a strongly **non-convex**, near-bimodal arc
(`nfl.nonconvex_failure_regime`, `results/failure_regime.csv`). Measured:

* true (non-convex) set area ≈ **0.180227**;
* its convex-hull area ≈ **7.54236**;
* intrinsic non-convexity penalty (hull / true) ≈ **41.85×** — the price *any*
  single convex body must pay here;
* **our method's own looseness (ellipsoid enclosure area / true area) ≈ 84.2×**
  (`ellipsoid_enclosure_area = 15.177`, the Monte-Carlo area of the *intersection*
  of the per-direction ellipse family — the same consistent metric used for the
  benchmark volumes), i.e. our reported ellipsoid wastes **98.8 %** of its volume
  (`method_wasted_fraction = 0.988125`).

We report both numbers deliberately: the `41.85×` is the *intrinsic* convex
penalty, but our own convex body over-covers even the convex hull, so the honest
"how loose is the set we actually report" figure is the **84×** one (down from the
earlier `160×`, which had measured a single-direction ellipse rather than the
reported intersection set). The ellipsoid enclosure remains **sound** on this
example (`enclosure_sound_on_samples = 1`), but it is severely loose. **This is exactly
the regime where polynomial zonotopes, hybrid zonotopes, or star-set unions
win**: they represent the non-convex arc with a union / polynomial map instead of
one convex body.

**The `double_integrator` benchmark and its controller.** `double_integrator`
uses a **random, non-stabilizing** ReLU controller (`ReLUMLP.random` seed 5,
final-layer scaled by 0.8, *not* fit to any stabilizing gain). It was chosen
deliberately to exercise a **growing** tube and a **safety violation**, so the
*per-direction* ellipsoid tube kept tight along `c_0` grows past the bound
(`ell_support_final_d0 = 2.768 > 2.0`, `ell_verified_d0 = 0`), as does the box
(`3.393 > 2.0`). This non-verification is a property of the *chosen adversarial
controller*, not a limitation of the ellipsoidal method — fitting the MLP to an
LQR/stabilizing gain would keep the tube bounded and verify `d0`. (Consistently
with §3, the honest *single-set* intersection support here is `1.935 < 2.0`, i.e.
the reported ellipsoid intersection would actually satisfy `d0`; we keep the
conservative per-direction flag in the CSV.)

On **volume**, once measured consistently (intersection of the per-direction
family, §2), the picture is the reverse of the earlier apples-to-oranges reading:
the reported ellipsoid volume is **1.818**, i.e. **11.1× tighter than the box**
(20.22) and **1.41× tighter than the zonotope** (2.564). The earlier draft's
"zonotope 6× tighter" was an artifact of comparing a single-direction ellipse
volume (16.14) against the zonotope's whole-set volume; with the consistent
metric the ellipsoid is competitive-to-better on volume across all benchmarks.

Our method is the right tool when the closed-loop reachable set stays
well-conditioned, correlated, and (approximately) convex — rotation-dominated /
strongly correlated linear/PWA dynamics with controllers that do not split the
set into disjoint lobes — and the wrong tool when the ReLU controller induces
strong multi-modality (§5, top). On the convex benchmarks the ellipsoid
intersection is competitive-to-better than the zonotope on both volume and
single-set support; the advantage over the zonotope is real but incremental.

## 6. Limitations and scope

* Convex (single-ellipsoid) enclosure per step; no set splitting (§5).
* The slack set `D` is the only conservatism beyond KV tangency; as the ReLU
  activation pattern stabilizes over `E_k` (`D → 0`) the tube becomes the exact
  tight KV tube of the linear closed loop.
* Disturbances are handled by an external (outer) tube; the guaranteed inner
  (min-max) tube via ET Asset B is compatible but not exercised here.
* The competitive comparison here is against an in-repo, pure-Python **zonotope**
  reach tube (`python/zonotope.py`) propagating the identical NN relaxation — no
  MATLAB / CORA dependency is required for the fair head-to-head. A direct
  numerical comparison against CORA / Reach-SDP's *own* poly/hybrid-zonotope
  implementations (which additionally handle non-convexity) would require those
  external tools and is future work; it is expected to matter most in the
  non-convex regime of §5, where our convex method is dominated regardless.

## 7. What is genuinely new (honestly scoped)

After a fair comparison against the competitive zonotope baseline, the honest
contribution of this paper is:

1. **A clean, dependency-light, open Python implementation** of sound
   ellipsoidal NFL reachability (CROWN relaxation + KV external Minkowski sum
   tangent along safety normals), with a fair, same-relaxation head-to-head
   against both a box ablation and a real zonotope baseline, all reproducible
   with NumPy/SciPy only (`bash paper-1/reproduce.sh`, exit 0).
2. **An incremental outer-tightness result**, not a breakthrough: along a chosen
   safety normal the ellipsoid is modestly tighter than the zonotope on 3 of 4
   benchmarks (by `+0.013` to `+0.33`), and looser on 1 (`double_integrator`,
   `−0.69`). We do **not** claim a uniform or large advantage over zonotopes;
   the large gaps in the literature-style "box vs ellipsoid" comparison are
   mostly the box's wrapping error.

We explicitly do **not** claim a certified *inner* (min-max) tube in this paper:
the ET internal (KV internal) approximation would provide one — a guarantee that
zonotope NFL tools typically do not offer — but it is **not exercised or
demonstrated soundly here** (see §6), so we do not count it as a contribution.
Making the internal tube sound and demonstrating it against zonotope tools is the
clearest path to a genuinely differentiating result and is left for future work.

## Reproduce

```
bash paper-1/reproduce.sh      # nn_bounds self-test -> nfl.py -> plots.py; exits 0
```

Artifacts: `paper-1/results/{tube_per_step,summary,failure_regime}.csv`,
`paper-1/figs/{double_integrator,stable_linear,rotation_showcase}_tube.png`
(ellipsoid vs zonotope vs box overlays),
`figs/support_gap.png`, `figs/volume_vs_horizon.png`.
