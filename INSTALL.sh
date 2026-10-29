#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo " HEXVULTURE // GLITCHBYTE PHANTOM LABS"
echo " PUBLIC INSTALLER"
echo "======================================"

command -v python3 >/dev/null || {
  echo "[STOP] Python 3 required."
  exit 1
}

if [ ! -x "$ROOT/.venv/bin/python" ]; then
  python3 -m venv "$ROOT/.venv" || {
    echo "[STOP] Python venv support required."
    echo "Install the python3-venv package for your Linux system."
    exit 1
  }
fi

"$ROOT/.venv/bin/python" -m pip install --upgrade gallery-dl

"$ROOT/.venv/bin/gallery-dl" --version
echo "[PASS] HEXVULTURE dependency installed"
echo "[READY] Use ./RUN.sh --help"
