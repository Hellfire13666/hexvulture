#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$ROOT/.venv/bin:$PATH"

if [ "${1:-}" = "--help" ] || [ "$#" -eq 0 ]; then
  echo "HEXVULTURE // COMMANDS"
  echo
  echo './RUN.sh posts50 https://x.com/ACCOUNT'
  echo './RUN.sh posts75 https://x.com/ACCOUNT'
  echo './RUN.sh posts100 https://x.com/ACCOUNT'
  echo './RUN.sh followers https://x.com/ACCOUNT'
  echo './RUN.sh following https://x.com/ACCOUNT'
  echo './RUN.sh usernames-auto https://x.com/ACCOUNT'
  echo
  echo 'OPTIONAL SAVE:'
  echo './RUN.sh posts50 https://x.com/ACCOUNT -o output.txt'
  echo './RUN.sh usernames-auto https://x.com/ACCOUNT -o names.txt'
  exit 0
fi

if [ ! -x "$ROOT/.venv/bin/gallery-dl" ]; then
  echo "[STOP] Run ./INSTALL.sh first."
  exit 1
fi

MODE="$1"
shift

case "$MODE" in
  posts50|posts75|posts100|followers|following|usernames-auto)
    ;;
  *)
    echo "[STOP] Unknown mode. Use ./RUN.sh --help"
    exit 2
    ;;
esac

if [ "$#" -eq 1 ]; then
  if [ "$MODE" = "usernames-auto" ]; then
    exec bash "$ROOT/recipes/HEXVULTURE-USERNAMES-AUTO.sh" "$1"
  else
    exec bash "$ROOT/recipes/HEXVULTURE-RECIPES.sh" "$MODE" "$1"
  fi
elif [ "$#" -eq 3 ] && [ "$2" = "-o" ]; then
  exec bash "$ROOT/recipes/HEXVULTURE-LIVE-SAVE.sh" \
    "$MODE" "$1" -o "$3"
else
  echo "[STOP] Usage: ./RUN.sh MODE X_URL [-o output.txt]"
  exit 2
fi
