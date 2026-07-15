#!/usr/bin/env bash
# Reproduce Paper 3 (Conformalized Ellipsoidal Reach Tubes) end-to-end.
#   1. conformal split-conformal self-test (marginal one-step coverage)
#   2. cp_tubes.py  -> paper-3/results/*.csv
#   3. plots.py     -> paper-3/figs/*.png
# Uses ${PYTHON:-../.venv/bin/python}. Exits 0 on success.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

PYTHON="${PYTHON:-../.venv/bin/python}"
echo "== Paper 3 reproduce =="
echo "python: $PYTHON"
"$PYTHON" --version

# Make the ellreach + conformal modules importable even without an editable
# install (they live in ../python and are declared in pyproject py-modules).
export PYTHONPATH="$HERE/../python:${PYTHONPATH:-}"

echo
echo "-- [1/3] conformal self-test (distribution-free coverage) --"
"$PYTHON" ../python/conformal.py

echo
echo "-- [2/3] cp_tubes.py experiments --"
"$PYTHON" cp_tubes.py

echo
echo "-- [3/3] plots.py figures --"
"$PYTHON" plots.py

echo
echo "-- artifacts --"
ls -1 results
ls -1 figs

echo
echo "PAPER-3 REPRODUCE OK"
