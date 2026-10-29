#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-help}"
LINK="${2:-https://x.com/SmittyWrite}"
GDL="$(command -v gallery-dl || true)"

if [[ "$MODE" == "help" ]]; then
  echo "HEXVULTURE // EASY RECIPE CENTER"
  echo "Usage: bash HEXVULTURE-RECIPES.sh MODE X_LINK"
  echo "Modes: posts50 posts75 posts100 followers following"
  exit 0
fi

LINK="${LINK%/}"
LINK="${LINK#@}"

if [[ "$LINK" =~ ^https://(www\.)?(x\.com|twitter\.com)/([A-Za-z0-9_]{1,15})$ ]]; then
  HANDLE="${BASH_REMATCH[3]}"
elif [[ "$LINK" =~ ^[A-Za-z0-9_]{1,15}$ ]]; then
  HANDLE="$LINK"
else
  echo "[ERROR] Use a profile link like https://x.com/SmittyWrite"
  exit 1
fi

if [[ ! -x "$GDL" ]]; then
  echo "[ERROR] Existing collector not found"
  exit 1
fi

echo "=== HEXVULTURE // @$HANDLE // $MODE ==="

case "$MODE" in
  posts50|posts75|posts100)
    LIMIT="${MODE#posts}"
    "$GDL" \
      --config-ignore \
      --cookies-from-browser "firefox/x.com" \
      --post-range "1-$LIMIT" \
      -o "extractor.twitter.text-tweets=true" \
      -o "extractor.twitter.include=tweets" \
      -o "extractor.twitter.cursor=true" \
      --no-download \
      --print 'post:ID={tweet_id} | DATE={date} | TEXT={content}' \
      "https://x.com/$HANDLE"
    ;;
  followers|following)
    timeout 30s "$GDL" \
      --config-ignore \
      --cookies-from-browser "firefox/x.com" \
      --range 1-15 \
      -g "https://x.com/$HANDLE/$MODE" |
    awk -v mode="$MODE" '
      /\/i\/user\/[0-9]+/ && !seen[$0]++ {
        print "[" toupper(mode) "] " $0
        fflush()
      }'
    ;;
  *)
    echo "[ERROR] Choose posts50, posts75, posts100, followers or following"
    exit 1
    ;;
esac

echo "=== COMPLETE // NOTHING SAVED ==="
