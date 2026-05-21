#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMPHTML=$(mktemp /tmp/fastfetch_XXXXXX.html)
TMPPNG=$(mktemp /tmp/fastfetch_XXXXXX.png)
trap 'rm -f "$TMPHTML" "$TMPPNG"' EXIT

fastfetch --pipe false 2>/dev/null \
  | aha --black --title "fastfetch" \
  | sed 's|<head>|<head><style>body{background-color:#0d1117;color:#c9d1d9;font-family:"JetBrains Mono","Fira Code","DejaVu Sans Mono",monospace;font-size:14px;padding:24px 32px;margin:0;white-space:pre}pre{margin:0;}</style>|' \
  > "$TMPHTML"

google-chrome --headless=new --disable-gpu \
  --screenshot="$TMPPNG" \
  --window-size=1100,1200 \
  "file://$TMPHTML" 2>/dev/null

magick "$TMPPNG" -trim +repage -bordercolor "#0d1117" -border 20 \
  "$SCRIPT_DIR/logo.png"

echo "Saved: $SCRIPT_DIR/logo.png"
