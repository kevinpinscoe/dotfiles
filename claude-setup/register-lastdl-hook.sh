#!/usr/bin/env bash
# register-lastdl-hook.sh — install the @lastdl Claude Code hook on this host (AI-131).
#
# What it does:
#   1. Fast-forwards ~/.dotfiles from origin (refuses on a dirty or diverged tree).
#   2. Restows the dotfiles `claude` package, which links
#      ~/.claude/hooks/lastdl-inject.sh to the repo copy.
#   3. Adds a UserPromptSubmit entry for that hook to ~/.claude/settings.json,
#      after backing the file up. Running it again changes nothing.
#
# Why Kevin runs it rather than an AI: ~/.claude/settings.json is per host and
# never reaches git, so each host (FLDW, core, the Mac, mac-container) needs
# this run once, on that host. Usage:  bash ~/.dotfiles/claude-setup/register-lastdl-hook.sh
#
# Options:  --no-pull   skip step 1 (use the dotfiles tree as it is)

set -euo pipefail

DOTFILES="$HOME/.dotfiles"
SETTINGS="$HOME/.claude/settings.json"
HOOK="$HOME/.claude/hooks/lastdl-inject.sh"
CMD="bash \"$HOOK\""
PULL=true
[ "${1:-}" = "--no-pull" ] && PULL=false

die() { echo "register-lastdl-hook: $*" >&2; exit 1; }

# --- preconditions ---------------------------------------------------------
[ -e "$DOTFILES/.git" ] || die "$DOTFILES is not a git checkout"
command -v jq   >/dev/null || die "jq is required (dnf/apt/brew install jq)"
command -v stow >/dev/null || die "stow is required (dnf/apt/brew install stow)"
[ -f "$SETTINGS" ] || die "$SETTINGS not found — start Claude Code once on this host first"
jq empty "$SETTINGS" 2>/dev/null || die "$SETTINGS is not valid JSON; not touching it"

# --- 1. update dotfiles ----------------------------------------------------
if $PULL; then
  branch=$(git -C "$DOTFILES" rev-parse --abbrev-ref HEAD)
  [ "$branch" = "main" ] || die "$DOTFILES is on '$branch', not main; rerun with --no-pull if that is intended"
  git -C "$DOTFILES" pull --ff-only --quiet origin main || die "git pull --ff-only failed; resolve it, then rerun"
  echo "dotfiles: at $(git -C "$DOTFILES" log -1 --format='%h %s')"
fi
[ -f "$DOTFILES/claude/.claude/hooks/lastdl-inject.sh" ] || die "hook not in $DOTFILES yet (is the AI-131 PR merged?)"

# --- 2. link the hook ------------------------------------------------------
mkdir -p "$HOME/.claude/hooks"   # real directory, so stow links per file
stow -d "$DOTFILES" -t "$HOME" --restow claude
[ -x "$HOOK" ] || die "$HOOK is missing or not executable after stow"
echo "hook:     $HOOK -> $(readlink "$HOOK")"

# --- 3. register in settings.json ------------------------------------------
if jq -e --arg c "$CMD" \
     '[.hooks.UserPromptSubmit[]?.hooks[]?.command] | index($c) != null' \
     "$SETTINGS" >/dev/null; then
  echo "settings: already registered in $SETTINGS — nothing changed"
  exit 0
fi

backup="$SETTINGS.bak-$(date +%Y%m%d-%H%M%S)"
cp -p "$SETTINGS" "$backup"
tmp=$(mktemp "$SETTINGS.XXXXXX")
jq --arg c "$CMD" \
   '.hooks.UserPromptSubmit = ((.hooks.UserPromptSubmit // []) + [{"hooks":[{"type":"command","command":$c,"timeout":5}]}])' \
   "$SETTINGS" > "$tmp"
jq empty "$tmp" || { rm -f "$tmp"; die "generated settings were invalid; original untouched"; }
chmod --reference="$SETTINGS" "$tmp" 2>/dev/null || chmod "$(stat -f %Lp "$SETTINGS")" "$tmp"
mv "$tmp" "$SETTINGS"

echo "settings: added UserPromptSubmit hook to $SETTINGS"
echo "backup:   $backup"
echo "Done. New Claude Code sessions on $(hostname -s) will expand @lastdl."
