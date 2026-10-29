#!/usr/bin/env bash
set -euo pipefail

LINK="${1:-https://x.com/SmittyWrite}"
LINK="${LINK%/}"
LINK="${LINK#@}"

if [[ "$LINK" =~ ^https://(www\.)?(x\.com|twitter\.com)/([A-Za-z0-9_]{1,15})$ ]]; then
  HANDLE="${BASH_REMATCH[3]}"
elif [[ "$LINK" =~ ^[A-Za-z0-9_]{1,15}$ ]]; then
  HANDLE="$LINK"
else
  echo "[ERROR] Enter an X profile URL or username."
  exit 1
fi

GDL="$(command -v gallery-dl || true)"
if [[ ! -x "$GDL" ]]; then
  echo "[ERROR] Existing collector not found."
  exit 1
fi

echo "=== HEXVULTURE // FOLLOWING USERNAMES AUTO ==="
echo "[ACCOUNT] @$HANDLE"
echo "[MODE] No preset account count"
echo "[SAFETY] Maximum 60 seconds"

set +e
timeout 60s "$GDL" \
  --config-ignore \
  --cookies-from-browser "firefox/x.com" \
  -o 'extractor.twitter.users=https://x.com/{core[screen_name]}' \
  -o 'extractor.twitter.ratelimit=abort' \
  -g "https://x.com/$HANDLE/following" |
awk '
  /^https:\/\/x.com\/[A-Za-z0-9_]+\/?$/ {
    if (!seen[$0]++) {
      count++
      printf "[FOLLOWING %d] %s\n", count, $0
      fflush()
    }
  }
  END {
    printf "=== TOTAL UNIQUE USERNAMES: %d ===\n", count+0
  }'
result=("${PIPESTATUS[@]}")
set -e

case "${result[0]}" in
  0) echo "[STATUS] Collection finished" ;;
  124) echo "[STATUS] Time limit reached; partial results" ;;
  *) echo "[STATUS] Collection incomplete or interrupted" ;;
esac

echo "[SAVE] OFF"
echo "=== AUTO TEST COMPLETE ==="
