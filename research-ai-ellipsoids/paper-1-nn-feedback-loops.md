# Paper 1 — Tight Ellipsoidal Reach Tubes for Neural Feedback Loops

**Working title:** *Tight Ellipsoidal Tubes for Reachability of Neural-Network-Controlled Systems: Recovering Correlation the Box Loses*

**One-line thesis:** For neural feedback loops whose plant is linear/PWA, the Kurzhanski–Varaiya *tight, direction-parametrized* ellipsoidal tube (ET's Asset A/B) yields provably sound reachable-set enclosures that are **tighter in safety-relevant directions** than the axis-aligned interval/box bounds that dominate NN-controller reachability — because ellipsoids carry cross-state correlation that boxes discard.

---

## 1. Problem & why now

A *neural feedback loop* (NFL) is a closed loop `x_{k+1} = f(x_k, π(x_k))` where `π` is a trained NN controller. Verifying that the reachable set stays inside a safe set is a live, competitive research area (Rober et al., IEEE OJCS 2023; hybrid-zonotope backward reachability 2024–2025; VNN-COMP closed-loop track). The dominant set representations are **intervals, zonotopes, polynomial/hybrid zonotopes, star sets**. Ellipsoids are conspicuously **under-used** for NFLs, despite:
- linear/PWA plants being ellipsoids' best case, and
- the *closed loop* re-injecting the NN output as an additive/bounded term each step — exactly the "sum of a linear map of an ellipsoid with a bounded input set" that ET's tight tube ODEs are built for.

**The gap:** No current NFL tool combines (a) sound NN output bounding with (b) KV tight ellipsoidal tubes that are tangent to the true reach set along chosen directions. Reach-SDP (Hu et al., CDC 2020) produces *an* ellipsoidal bound via one SDP per step but not the tight direction-parametrized tube family, and it is not disturbance/min-max aware.

## 2. Contribution

1. **Method.** A discrete-time NFL reachability algorithm that, at each step:
   - bounds the NN controller output over the current ellipsoid `E_k` by a **linear-plus-ellipsoidal (or zonotopic) over-approximation** `π(x) ∈ K_k x ⊕ D_k` using standard sound NN bounding (CROWN/LiRPA-style local linear relaxation → convert to ellipsoidal input set), then
   - propagates `E_k` through the closed-loop linear map and adds `D_k` using ET's **tight external `minksum_ea` / tube ODE**, retaining the direction family `{l_i}` so the enclosure is tight in the user's chosen safety directions.
2. **Min-max variant.** When the plant also has a bounded disturbance, use Asset B (`ExtIntEllApxBuilder`) to get the *guaranteed* (internal) and *outer* (external) tubes simultaneously — a robustness guarantee interval, not just an over-approx.
3. **Theory.** Soundness proof (enclosure is a true over-approximation given sound NN bounds); tightness statement (tangency along `l_i(t)`); a characterization of the regime where the ellipsoidal tube's volume/support beats the zonotopic bound (well-conditioned, rotation-dominated, correlated dynamics — cf. ET intro's rotation example `A = [[cos1,−sin1],[sin1,cos1]]`).
4. **Tool + benchmarks.** Open reproducible implementation (Python port of the kernel, see framework-extraction-plan.md) evaluated on standard NFL benchmarks.

## 3. Method sketch (per step k)

```
Input: E_k = ellipsoid(q_k, Q_k), direction family L = {l_1..l_m}
1. Local NN relaxation over E_k's bounding box → affine bounds  low(x) ≤ π(x) ≤ up(x)
2. Convert relaxation to controller model  π(x) ∈ K_k·x ⊕ D_k   (D_k = ellipsoid or zonotope of relaxation slack)
3. Closed-loop map  A_cl = A + B·K_k ;  input set  W_k = B·D_k ⊕ (disturbance set)
4. E_{k+1} = tightExternalMinkSum( A_cl·E_k , W_k , L )      # ET Asset A/C
   (min-max: also tightInternal for guaranteed tube — ET Asset B)
5. Safety check: for each safety half-space c, rho(E_{k+1}, c) ≤ b ?   # ET support function
```

The direction family `L` is the knob that makes this *tight where it matters*: pick `l_i` = normals of the safety constraints, and the enclosure touches the true reach set exactly there.

## 4. Experiments

- **Benchmarks:** the NFL benchmark suite used in the closed-loop verification literature (double integrator, 4D/6D quadrotor linearizations, adaptive cruise control, pendulum with NN controller), plus a deliberately rotation-dominated linear plant to showcase the correlation advantage.
- **Baselines:** interval bound propagation, `auto_LiRPA`/CROWN-style box, zonotope propagation (CORA closed-loop), Reach-SDP, polynomial zonotope (CORA).
- **Metrics:** (i) tightness = directed Hausdorff / support-function gap along safety normals; (ii) volume; (iii) verified vs. falsified safety over horizon; (iv) runtime; (v) horizon length before the bound blows up.
- **Hypothesis to test honestly:** ellipsoidal tubes win on tightness-in-safety-direction and on well-conditioned correlated dynamics; lose on strongly non-convex reach sets (where poly-zonotopes win). Report both — the *characterization* of when-which is itself a contribution.

## 5. Novelty risk & de-risking

- **Risk:** Reach-SDP already gives ellipsoidal NFL bounds. **Answer:** we contribute the *tight tube family* (tangency in chosen directions), the *min-max/disturbance* case, and a *when-ellipsoids-win* characterization — none of which Reach-SDP provides.
- **Risk:** reviewers ask "why not just zonotopes?" **Answer:** the correlation/tightness-in-direction experiments + a regime characterization; ellipsoids are also cheaper to intersect with quadratic safe sets.
- **Reproducibility:** ship the Python kernel validated against ET's MATLAB etalons.

## 6. Target venues

- **Top:** L4DC, HSCC (Hybrid Systems: Computation & Control — KV's home venue), NeurIPS/ICML (safe RL / verification workshops then main track), IEEE TAC / Automatica (journal).
- **Fast path:** an NFL-verification workshop or ACC, then extend to journal.

## 7. Effort estimate

- Method + soundness proof: 3–4 weeks.
- Kernel port + NN-bounding glue (LiRPA is Python): 4–6 weeks.
- Experiments + writing: 4–6 weeks.
- **Feasible as a focused ~3-month single-author (or author+student) project** given ET already contains the hard numerical core.

## 8. Dependencies on ET

Asset A (tight external tube / `minksum_ea`), Asset B (min-max `ExtIntEllApxBuilder`), Asset C (`rho` support function for safety checks). All verified present in §2 of the audit.
