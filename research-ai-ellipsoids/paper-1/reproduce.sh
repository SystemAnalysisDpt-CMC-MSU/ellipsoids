#!/usr/bin/env bash
# Reproduce all Paper 1 (neural feedback loops) artifacts.
# Runs: nn_bounds soundness self-test -> nfl.py (results/*.csv) -> plots.py (figs/*.png).
# Exits 0 only if every stage succeeds.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
PYTHON="${PYTHON:-$ROOT/.venv/bin/python}"

echo "== Paper 1 reproduce =="
echo "python: $PYTHON"
"$PYTHON" --version

echo
echo "-- [0/3] dependency check (SciPy is REQUIRED) --"
# nfl.py uses scipy.spatial.ConvexHull for the exact zonotope volume and the
# non-convex failure-regime hull area; without SciPy the run would die mid-way
# with an ImportError traceback. Fail fast with a clear message instead.
if ! "$PYTHON" -c "import scipy.spatial" 2>/dev/null; then
    echo "ERROR: SciPy is required but not importable in this interpreter." >&2
    echo "       nfl.py uses scipy.spatial.ConvexHull; install it, e.g.:" >&2
    echo "         $PYTHON -m pip install scipy" >&2
    exit 1
fi
"$PYTHON" -c "import scipy; print('scipy', scipy.__version__)"

echo
echo "-- [1/3] nn_bounds soundness self-test --"
"$PYTHON" "$ROOT/python/test_nn_bounds.py"

echo
echo "-- [2/3] closed-loop NFL reachability (ellipsoid vs box) --"
"$PYTHON" "$HERE/nfl.py"

echo
echo "-- [3/3] figures --"
"$PYTHON" "$HERE/plots.py"

echo
echo "-- artifacts --"
ls -1 "$HERE/results"
ls -1 "$HERE/figs"

echo
echo "Paper 1 reproduce OK"
