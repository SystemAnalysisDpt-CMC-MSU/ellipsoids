#!/usr/bin/env bash
# codex_review.sh <paper-id>
# Runs Codex (non-interactive) as an independent reviewer that must confirm the
# paper's result is (a) correct, (b) genuinely new/non-trivial, (c) legitimate
# (no fabricated numbers). Codex reads the files itself. It must end its reply
# with a line "VERDICT: APPROVE" or "VERDICT: REJECT".
#
# Writes the full transcript to review/<paper-id>.codex.md and prints the verdict.
set -uo pipefail
PID="${1:?usage: codex_review.sh <paper-id>}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${ROOT}/review/${PID}.codex.md"

case "$PID" in
  paper-1) TOPIC="tight ellipsoidal reach tubes for neural feedback loops"
           FILES="paper-1/draft.md paper-1/theory.md paper-1/nfl.py python/nn_bounds.py python/ellreach.py paper-1/results/summary.csv" ;;
  paper-2) TOPIC="when do ellipsoidal reach tubes beat zonotopes (pure-Python benchmark)"
           FILES="paper-2/draft.md paper-2/bench.py paper-2/bench_zono.py python/zonotope.py python/ellreach.py paper-2/results/ell_vs_zono.csv paper-2/results/sweep_kappa.csv" ;;
  paper-3) TOPIC="conformalized ellipsoidal reach tubes for learned dynamics"
           FILES="paper-3/draft.md paper-3/cp_tubes.py python/conformal.py python/ellreach.py paper-3/results/coverage_summary.csv" ;;
  paper-4) TOPIC="certified INNER reach tubes / reachability certificates for ReLU neural feedback loops via exact PWA decomposition + KV internal ellipsoids"
           FILES="paper-4/draft.md paper-4/inner_reach.py python/pwa_nfl.py python/ellreach.py python/oracle_tests/test_pwa_nfl.py paper-4/results/bracket.csv paper-4/results/soundness.csv paper-4/results/certificate.csv" ;;
  *) echo "unknown paper id: $PID"; exit 2 ;;
esac

PROMPT="You are an independent, skeptical scientific reviewer. Working directory is ${ROOT}.
Review the paper '${PID}' — ${TOPIC}. Read these files yourself before judging: ${FILES}.
Also read python/ellreach.py (the shared kernel) and 00-code-audit.md for context.

Decide THREE things, with evidence cited from the files/CSVs:
1) CORRECT: is the math sound and do the code + claimed numbers actually match the CSV results? Check for silent unsoundness, unfair baselines, cherry-picking.
2) NEW: is the core contribution genuinely novel and non-trivial vs prior art (Kurzhanski-Varaiya 2000, CORA, Reach-SDP 2020, ellipsoidal conformal prediction: Messoudi 2022 / Johnstone-Cox 2021 / Conformalized Gaussian Scoring 2025)? State the closest prior work and what precisely is new.
3) LEGIT: are the reported numbers real (traceable to the CSVs) and the failure regimes honestly reported?

Be concise but specific. End your reply with EXACTLY one line:
VERDICT: APPROVE   (only if correct AND non-trivially new AND legitimate)
or
VERDICT: REJECT   (otherwise, with the top reasons above it)"

echo "== codex review: ${PID} ==" | tee "$OUT"
timeout 900 codex exec --skip-git-repo-check "$PROMPT" 2>&1 | tee -a "$OUT"
echo "" | tee -a "$OUT"
VERDICT="$(grep -Eo 'VERDICT:[[:space:]]*(APPROVE|REJECT)' "$OUT" | tail -1)"
echo "---- ${PID} ${VERDICT:-VERDICT: (none found)} ----"
