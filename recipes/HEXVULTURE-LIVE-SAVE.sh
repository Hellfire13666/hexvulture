#!/usr/bin/env bash
set -euo pipefail
umask 077

RECIPES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" -ne 4 ] || [ "${3:-}" != "-o" ]; then
  echo "Usage: bash HEXVULTURE-LIVE-SAVE.sh MODE X_URL -o output.txt"
  echo "Modes: posts50 posts75 posts100 followers following usernames-auto"
  exit 2
fi

MODE="$1"
TARGET="$2"
OUTPUT="$4"

case "$MODE" in
  posts50|posts75|posts100|followers|following)
    COLLECTOR="$RECIPES/HEXVULTURE-RECIPES.sh"
    ;;
  usernames-auto)
    COLLECTOR="$RECIPES/HEXVULTURE-USERNAMES-AUTO.sh"
    ;;
  *)
    echo "[STOP] Unknown collection mode."
    exit 2
    ;;
esac

if [[ ! "$TARGET" =~ ^https://(x\.com|twitter\.com)/[A-Za-z0-9_]{1,15}/?$ ]]; then
  echo "[STOP] Enter a valid X profile URL."
  exit 2
fi

if [ ! -f "$COLLECTOR" ]; then
  echo "[STOP] Working collector not found."
  exit 1
fi

if [ -z "$OUTPUT" ] || [ -e "$OUTPUT" ]; then
  echo "[SAFE] Output path empty or file already exists."
  echo "Choose a new filename. Nothing overwritten."
  exit 1
fi

if [ ! -d "$(dirname "$OUTPUT")" ]; then
  echo "[STOP] Output folder does not exist."
  exit 1
fi

echo "===================================="
echo " HEXVULTURE // LIVE + SAVE"
echo "===================================="
echo "[MODE] $MODE"
echo "[SAVE] ON"
echo "[LIVE] Terminal output enabled"
echo

# tee prints results live while saving a copy.
# The original collectors are never modified.
if [ "$MODE" = "usernames-auto" ]; then
  bash "$COLLECTOR" "$TARGET" | tee "$OUTPUT"
else
  bash "$COLLECTOR" "$MODE" "$TARGET" | tee "$OUTPUT"
fi

echo
# HEXVULTURE-AUTO-HISTORY-v2
if [ -s "$OUTPUT" ]; then
  python3 "$RECIPES/HEXVULTURE-REFRESH-HISTORY.py" "$OUTPUT" || echo "[NOTICE] History refresh failed; TXT saved."
fi
echo "[PASS] Collection completed and output saved."
echo "[FILE] $OUTPUT"
