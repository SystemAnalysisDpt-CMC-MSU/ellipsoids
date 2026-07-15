"""
Neural gauge scheduling of certified ellipsoidal reach tubes -- experiment.

Three results (results/*.csv):
  1. gauge_gap.csv    -- per-system: myopic vs per-instance-optimized gauge schedule
                         (final log-volume); shows the gauge freedom is exploitable.
  2. amortized.csv    -- a learned gauge POLICY (small NN) trained on a set of
                         systems, evaluated on HELD-OUT systems vs myopic.
  3. soundness.csv    -- Monte-Carlo containment for the learned-policy tube
                         (every sampled true trajectory stays inside -> sound for
                         any policy output, as guaranteed structurally).
"""
import csv
import os
import numpy as np
from scipy.optimize import minimize
from ellreach import Ellipsoid, sqrtm_pos
from ell_gauge import (gauge_step, myopic_beta, rollout, tube_logvol,
                       features, GaugePolicy)

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(HERE, "results")
os.makedirs(RESULTS, exist_ok=True)


def make_system(rng):
    th = rng.uniform(0.3, 1.1)
    rho = rng.uniform(0.85, 0.95)
    A = rho * np.array([[np.cos(th), -np.sin(th)], [np.sin(th), np.cos(th)]])
    kap = rng.uniform(4.0, 40.0)                       # disturbance anisotropy
    ang = rng.uniform(0, np.pi)
    R = np.array([[np.cos(ang), -np.sin(ang)], [np.sin(ang), np.cos(ang)]])
    Qw = R @ np.diag([0.05, 0.05 / kap]) @ R.T
    W = Ellipsoid([0, 0], 0.5 * (Qw + Qw.T))
    E0 = Ellipsoid([0, 0], 0.1 * np.eye(2))
    return A, E0, W


def myopic_schedule(A, E0, W, N, l):
    E = E0; bs = []
    for _ in range(N):
        b = myopic_beta(E, A, W, l); bs.append(b)
        E = gauge_step(E, A, W, b)
    return np.array(bs)


def mc_contained(A, E0, W, betas, n=4000, seed=0):
    """Fraction of sampled true trajectories x_{k+1}=A x_k+w contained in the
    gauge tube at every step (must be ~1.0 -- soundness for any beta>0)."""
    rng = np.random.default_rng(seed)
    tube = rollout(A, E0, W, betas)
    LE, LW = sqrtm_pos(E0.Q), sqrtm_pos(W.Q)
    ok = 0
    for _ in range(n):
        u = rng.standard_normal(2); u = u/max(np.linalg.norm(u),1e-9)*rng.uniform(0,1)
        x = E0.q + LE @ u
        good = True
        for k in range(len(betas)):
            if not tube[k].contains(x, tol=1e-9):
                good = False; break
            uw = rng.standard_normal(2); uw = uw/max(np.linalg.norm(uw),1e-9)*rng.uniform(0,1)
            x = A @ x + (W.q + LW @ uw)
        if good and tube[-1].contains(x, tol=1e-9):
            ok += 1
    return ok / n


def main():
    N = 8
    l = np.array([1.0, 0.3]); l /= np.linalg.norm(l)
    rng = np.random.default_rng(1)

    # ---- 1. gauge gap: myopic vs per-instance optimized ----
    gap_rows = []
    for i in range(20):
        A, E0, W = make_system(rng)
        b_my = myopic_schedule(A, E0, W, N, l)
        v_my = tube_logvol(A, E0, W, b_my)
        res = minimize(lambda z: tube_logvol(A, E0, W, np.exp(z)), np.log(b_my),
                       method="Nelder-Mead",
                       options={"maxiter": 4000, "xatol": 1e-6, "fatol": 1e-9})
        v_opt = res.fun
        gap_rows.append(dict(system=i, myopic_logvol=v_my, optimized_logvol=v_opt,
                             volume_ratio_myopic_over_opt=float(np.exp(v_my - v_opt))))
    _write("gauge_gap.csv", gap_rows)
    mean_gap = float(np.mean([r["volume_ratio_myopic_over_opt"] for r in gap_rows]))

    # ---- 2. amortized learned policy: train on a set, test on held-out ----
    rng_tr = np.random.default_rng(100)
    train = [make_system(rng_tr) for _ in range(40)]
    rng_te = np.random.default_rng(200)
    test = [make_system(rng_te) for _ in range(40)]
    pol = GaugePolicy(n_feat=7, hidden=6, seed=0)

    def batch_loss(theta, systems):
        return float(np.mean([pol.rollout_logvol(A, E0, W, N, theta)
                              for (A, E0, W) in systems]))

    res = minimize(lambda th: batch_loss(th, train), pol.theta,
                   method="Powell", options={"maxiter": 4000, "xtol": 1e-5, "ftol": 1e-7})
    theta_star = res.x

    amo_rows = []
    for split, systems in (("train", train), ("test", test)):
        for j, (A, E0, W) in enumerate(systems):
            b_my = myopic_schedule(A, E0, W, N, l)
            v_my = tube_logvol(A, E0, W, b_my)
            v_pol = pol.rollout_logvol(A, E0, W, N, theta_star)
            # per-instance ORACLE (Nelder-Mead on the raw schedule) as the upper bound
            r = minimize(lambda z: tube_logvol(A, E0, W, np.exp(z)), np.log(b_my),
                         method="Nelder-Mead",
                         options={"maxiter": 3000, "xatol": 1e-6, "fatol": 1e-9})
            v_or = r.fun
            amo_rows.append(dict(split=split, system=j, myopic_logvol=v_my,
                                 policy_logvol=v_pol, oracle_logvol=v_or,
                                 volume_ratio_myopic_over_policy=float(np.exp(v_my - v_pol)),
                                 gap_capture=float((v_my - v_pol) / (v_my - v_or))
                                 if (v_my - v_or) > 1e-9 else 1.0))
    _write("amortized.csv", amo_rows)
    test_ratios = [r["volume_ratio_myopic_over_policy"] for r in amo_rows if r["split"] == "test"]
    test_win = float(np.mean([r > 1.0 for r in test_ratios]))
    test_mean = float(np.mean(test_ratios))
    test_capture = float(np.mean([max(0.0, min(1.0, r["gap_capture"]))
                                  for r in amo_rows if r["split"] == "test"]))

    # ---- 3. soundness of the learned-policy tube (must be ~1.0) ----
    snd_rows = []
    for j, (A, E0, W) in enumerate(test[:10]):
        # reconstruct the policy's beta schedule for this system
        E = E0; bs = []
        for k in range(N):
            b = pol.beta(features(E, A, W, k, N), theta_star); bs.append(b)
            E = gauge_step(E, A, W, b)
        frac = mc_contained(A, E0, W, bs, n=3000, seed=j)
        snd_rows.append(dict(system=j, mc_containment=frac, min_beta=float(min(bs))))
    _write("soundness.csv", snd_rows)
    min_frac = min(r["mc_containment"] for r in snd_rows)

    print(f"[gauge gap]   mean volume ratio (myopic/optimized) = {mean_gap:.4f}  (>1 => optimizable)")
    print(f"[amortized]   held-out: policy beats myopic on {100*test_win:.0f}% of systems, "
          f"mean volume ratio (myopic/policy) = {test_mean:.4f}, "
          f"captures {100*test_capture:.0f}% of the myopic->oracle gap")
    print(f"[soundness]   min MC containment over learned-policy tubes = {min_frac:.4f} "
          f"(1.0 => sound for the learned schedule; all beta>0)")
    print("GAUGE-EXPERIMENT OK")


def _write(name, rows):
    with open(os.path.join(RESULTS, name), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)


if __name__ == "__main__":
    main()
