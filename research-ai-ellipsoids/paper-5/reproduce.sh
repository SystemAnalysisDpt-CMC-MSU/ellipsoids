#!/usr/bin/env bash
# Regenerate the neural-gauge-scheduling results from scratch. Exit 0 on success.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="${PYTHON:-${SCRIPT_DIR}/../.venv/bin/python}"
echo "=== Paper-5 reproduce.sh ==="; echo "Python: $PYTHON"
if ! "$PYTHON" -c "import scipy" 2>/dev/null; then
  echo "ERROR: SciPy is required. Install: pip install scipy" >&2; exit 1
fi
rm -rf "${SCRIPT_DIR}/results"; mkdir -p "${SCRIPT_DIR}/results"
echo "[1/1] neural gauge scheduling experiment ..."
"$PYTHON" "${SCRIPT_DIR}/gauge_experiment.py"
echo "=== Results ==="; ls -1 "${SCRIPT_DIR}/results/"
echo "PAPER-5 REPRODUCE OK"
