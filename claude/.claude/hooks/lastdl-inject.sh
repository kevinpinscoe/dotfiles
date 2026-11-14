#!/usr/bin/env bash
# lastdl-inject.sh — Claude Code UserPromptSubmit hook (AI-131).
#
# When a prompt contains the token @lastdl, print the absolute path of the
# most recent download so Claude Code adds it to the model's context. Same
# idea as the `lastdl` shell function in ~/.bash.d/20_bashrc_aliases, but
# self-contained: hooks run in a non-interactive shell where that function
# does not exist.
#
# Differences from `lastdl`, on purpose:
#   - every Downloads directory that exists is checked and the newest file
#     wins (mac-container can have an empty ~/Downloads beside /mac-home's);
#   - partial downloads (.part, .crdownload, .download) and dotfiles are
#     skipped, so a half-finished download is never offered.
#
# Portable: bash 3.2 (macOS) and GNU bash, BSD and GNU coreutils, no jq.
# A prompt without @lastdl costs one string match and prints nothing.
# This hook never blocks a prompt: every path out exits 0.

input=$(cat 2>/dev/null) || exit 0

# Fast path: no @lastdl anywhere in the payload.
case "$input" in
  *@lastdl*) ;;
  *) exit 0 ;;
esac

# Token check on the JSON text. JSON escapes (\n, \t, \r) become spaces
# first, so "@lastdl" at the start of a new line still counts; "x@lastdl"
# or "@lastdlfoo" do not.
flat=$(printf '%s' "$input" | sed 's/\\[ntr]/ /g')
if ! printf '%s' "$flat" | grep -Eq '(^|[^[:alnum:]_@.-])@lastdl([^[:alnum:]_-]|$)'; then
  exit 0
fi

mtime() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

best=""
best_m=0
searched=""
for d in "$HOME/Downloads" /mac-home/Downloads; do
  [ -d "$d" ] || continue
  searched="$searched $d"
  # Newest first; take the first entry that is not a partial download.
  while IFS= read -r f; do
    case "$f" in
      .* | *.part | *.crdownload | *.download) continue ;;
    esac
    p="$d/$f"
    [ -e "$p" ] || continue
    m=$(mtime "$p")
    if [ "$m" -gt "$best_m" ] 2>/dev/null; then
      best="$p"
      best_m="$m"
    fi
    break
  done < <(ls -t "$d" 2>/dev/null)
done

if [ -z "$best" ]; then
  if [ -z "$searched" ]; then
    echo "@lastdl: no Downloads directory exists on this host ($(hostname -s 2>/dev/null)); tell Kevin there is nothing for @lastdl to refer to."
  else
    echo "@lastdl: no completed download found in:$searched; tell Kevin there is nothing for @lastdl to refer to."
  fi
  exit 0
fi

when=$(date -r "$best" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "unknown time")
kind="file"
[ -d "$best" ] && kind="directory"

echo "@lastdl = $best"
echo "(Kevin's most recent download, a $kind modified $when. Wherever his prompt says @lastdl, it means this path. Open it with Read if the request needs its contents.)"
exit 0
