#!/usr/bin/env bash
# Master gate for the AI + ellipsoids program. Exits 0 only when every phase's
# verification passes. This is the machine definition of "all done" (G4).
set -uo pipefail
cd "$(dirname "$0")"
ROOT="$(pwd)"
PY="${ROOT}/.venv/bin/python"
[ -x "$PY" ] || PY="python3"
fail=0
section() { printf '\n=== %s ===\n' "$1"; }
check()   { if eval "$2"; then echo "  [OK]  $1"; else echo "  [FAIL] $1"; fail=1; fi; }

section "G0 Foundation kernel"
check "kernel + oracle tests pass (0 skips)" \
  "$PY -m pytest '$ROOT/python' -q >/tmp/ellreach_pytest.log 2>&1 && ! grep -q skipped /tmp/ellreach_pytest.log"
check "ellreach imports" "$PY -c 'import ellreach' >/dev/null 2>&1"

# run a paper's reproduce.sh end-to-end (PYTHON exported so scripts use the venv)
run_repro() { PYTHON="$PY" bash "$ROOT/$1/reproduce.sh" >"/tmp/gate_$1.log" 2>&1; }

section "G1 Paper 2 benchmark"
check "paper-2 draft present"            "[ -f '$ROOT/paper-2/draft.md' ]"
check "paper-2 reproduce.sh runs (exit 0)" "run_repro paper-2"
check "paper-2 results present"          "ls '$ROOT'/paper-2/results/*.csv >/dev/null 2>&1"

section "G2 Paper 1 neural feedback loops"
check "paper-1 draft present"            "[ -f '$ROOT/paper-1/draft.md' ]"
check "paper-1 reproduce.sh runs (exit 0)" "run_repro paper-1"
check "paper-1 results present"          "ls '$ROOT'/paper-1/results/*.csv >/dev/null 2>&1"

section "G3 Paper 3 conformal tubes"
check "paper-3 draft present"            "[ -f '$ROOT/paper-3/draft.md' ]"
check "paper-3 reproduce.sh runs (exit 0)" "run_repro paper-3"
check "paper-3 results present"          "ls '$ROOT'/paper-3/results/*.csv >/dev/null 2>&1"

section "G-inner Paper 4 certified inner NFL (novel)"
check "paper-4 draft present"            "[ -f '$ROOT/paper-4/draft.md' ]"
check "paper-4 reproduce.sh runs (exit 0)" "run_repro paper-4"
check "paper-4 results present"          "ls '$ROOT'/paper-4/results/*.csv >/dev/null 2>&1"

section "G4 Hygiene"
# fake-completion scan over PROJECT sources only (exclude venv, caches, legacy
# MATLAB tree, and the meta docs that legitimately name the markers).
grep -rnE 'TODO|FIXME|NotImplementedError|pytest\.(skip|xfail)|placeholder|XXX' \
  "$ROOT" --include='*.py' --include='*.md' 2>/dev/null \
  | grep -vE '/\.venv/|/__pycache__/|/review/|EXECUTION_PROMPT\.md|PROGRESS\.md|run_all_gates\.sh' \
  > /tmp/ellreach_scan.log || true
NSCAN="$(wc -l < /tmp/ellreach_scan.log | tr -d ' ')"
check "no fake-completion markers (found=$NSCAN, see /tmp/ellreach_scan.log)" "[ '$NSCAN' -eq 0 ]"

printf '\n'
if [ "$fail" -eq 0 ]; then echo "ALL GATES GREEN"; else echo "GATES INCOMPLETE (some phases pending)"; fi
exit "$fail"
