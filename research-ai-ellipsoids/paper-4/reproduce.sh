#!/usr/bin/env bash
# Regenerate all certified-inner-NFL results and figures from scratch. Exit 0 on success.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="${PYTHON:-${SCRIPT_DIR}/../.venv/bin/python}"

echo "=== Paper-4 reproduce.sh ==="; echo "Python: $PYTHON"
if ! "$PYTHON" -c "import scipy" 2>/dev/null; then
  echo "ERROR: SciPy is required (scipy.spatial.ConvexHull). Install: pip install scipy" >&2
  exit 1
fi
rm -rf "${SCRIPT_DIR}/results" "${SCRIPT_DIR}/figs"
mkdir -p "${SCRIPT_DIR}/results" "${SCRIPT_DIR}/figs"

echo "[1/2] certified-inner reachability (inner_reach.py) ..."
"$PYTHON" "${SCRIPT_DIR}/inner_reach.py"
echo ""
echo "[2/2] figures (plots.py) ..."
"$PYTHON" "${SCRIPT_DIR}/plots.py"
echo ""
echo "=== Results ==="; ls -1 "${SCRIPT_DIR}/results/"
echo "=== Figures ==="; ls -1 "${SCRIPT_DIR}/figs/"
echo "PAPER-4 REPRODUCE OK"
