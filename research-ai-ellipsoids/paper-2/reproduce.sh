#!/usr/bin/env bash
# reproduce.sh — regenerate all CSVs and figures from scratch.
# Usage:
#   bash paper-2/reproduce.sh
#   PYTHON=/path/to/python bash paper-2/reproduce.sh
#
# Exits 0 on success, non-zero on any failure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="${PYTHON:-${SCRIPT_DIR}/../.venv/bin/python}"

echo "=== Paper-2 reproduce.sh ==="
echo "Python: $PYTHON"
echo "Script dir: $SCRIPT_DIR"
echo ""

# Clean previous results and figures so output is always fresh
rm -rf "${SCRIPT_DIR}/results" "${SCRIPT_DIR}/figs"
mkdir -p "${SCRIPT_DIR}/results" "${SCRIPT_DIR}/figs"

echo "[1/6] Running ellipsoid regime benchmark (bench.py) ..."
"$PYTHON" "${SCRIPT_DIR}/bench.py"

echo ""
echo "[2/6] Running naive-vs-tight wrapping-artifact benchmark (bench_tight_vs_naive.py) ..."
"$PYTHON" "${SCRIPT_DIR}/bench_tight_vs_naive.py"

echo ""
echo "[3/6] Running ellipsoid-vs-zonotope head-to-head (bench_zono.py) ..."
"$PYTHON" "${SCRIPT_DIR}/bench_zono.py"

echo ""
echo "[4/6] Generating regime plots (plots.py) ..."
"$PYTHON" "${SCRIPT_DIR}/plots.py"

echo ""
echo "[5/6] Generating naive-vs-tight plot (plot_tight_vs_naive.py) ..."
"$PYTHON" "${SCRIPT_DIR}/plot_tight_vs_naive.py"

echo ""
echo "[6/6] Generating ellipsoid-vs-zonotope plot (plot_zono.py) ..."
"$PYTHON" "${SCRIPT_DIR}/plot_zono.py"

echo ""
echo "=== Results ==="
ls -1 "${SCRIPT_DIR}/results/"
echo ""
echo "=== Figures ==="
ls -1 "${SCRIPT_DIR}/figs/"
echo ""
echo "=== reproduce.sh complete (exit 0) ==="
