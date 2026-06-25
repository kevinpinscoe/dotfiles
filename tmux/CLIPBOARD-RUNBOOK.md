# Clipboard / copy-on-select RUNBOOK (tmux + Ghostty + copyq)

Cross-machine reference for AI assistants and for Kevin. Shared via the dotfiles
repo (Fedora, macOS, Raspberry Pi 5). This file is **stow-ignored** — it lives in
the repo but is not symlinked into `$HOME`.

## What this is

How a tmux mouse selection (copy-on-select) reaches the clipboard of whatever
machine you are actually sitting at when SSH-ing into another host (typically the
Raspberry Pi 5).

There are **two delivery paths**. The first is primary and robust; the second is
a fragile fallback.

| Path | Mechanism | Requirement |
|---|---|---|
| 1. OSC 52 (primary) | tmux emits OSC 52 → Ghostty writes the local clipboard natively | `set -g set-clipboard on` **and** `Ms` in `terminal-overrides` for `xterm*`/`ghostty*`/`tmux*` |
| 2. copyq → broadcast (fallback) | copy lands in copyq on the Pi, then `~/.local/bin/broadcast_clip_from_pi.sh` SSH-pushes to Fedora/Mac | network reachability to `10.1.10.40` (wl-copy) and `10.1.10.84` (pbcopy) |

**Key fact:** the `Ms` overrides do nothing unless `set-clipboard` is `on` — tmux
only emits OSC 52 when `set-clipboard` is `on`. They are not independent.

## How it is wired

- Copy command: `~/.config/tmux/copy.sh` (in this package, under `.config/tmux/`).
  Strips CR/LF, then `copyq copy -`, else `wl-copy`/`xsel` fallback, then fires
  the broadcast script in the background.
- `copy.sh` is referenced three ways in `~/.tmux.conf`:
  - tmux-yank `@override_copy_command`
  - the manual root-table `DoubleClick1Pane` / `TripleClick1Pane` bindings
    (tmux-yank's defaults use bare `copy-pipe-and-cancel`, which skips the override)
  - the `copy-mode-vi` `MouseDragEnd1Pane` binding (drag-select)
- copyq runs headless on **xvfb display `:99`** (`xvfb-run --auto-servernum`).
  On the Pi the copyq server is reachable with **or** without `DISPLAY=:99`.

## RECURRING REGRESSION — check this first

`~/.tmux.conf` line `set -g set-clipboard ...` keeps drifting back to **`off`**,
which kills the OSC 52 path. copyq on the Pi still updates, so it *looks* like a
copy happened — but nothing reaches the remote Ghostty clipboard.

Because `.tmux.conf` is a **shared stow package**, flipping it off on any one of
the three machines re-breaks all of them after the next `git pull`.

- Last fixed: 2026-06-25 (`set-clipboard off` → `on`, committed + pushed).
- The correct value is `set -g set-clipboard on`.

## How to troubleshoot it

Run these in order — stop at the first that is wrong.

```bash
# 1. Is OSC 52 enabled in the running server? (usual culprit — must be 'on')
tmux show -gv set-clipboard

# 2. Are the OSC 52 overrides present for ghostty/xterm?
tmux show -g terminal-overrides | grep -i Ms

# 3. Is copyq alive on the Pi? (fallback path + local paste)
DISPLAY=:99 copyq clipboard

# 4. Ghostty side (the Fedora/Mac you are sitting at), in ~/.config/ghostty/config:
#    clipboard-write = allow
#    Without this, Ghostty silently DROPS OSC 52 writes.
```

If `set-clipboard` is `off`, fix it live and in the repo:

```bash
tmux set -g set-clipboard on            # apply to the running server now
tmux source-file ~/.tmux.conf           # reload full config
# in the dotfiles repo, flip the committed value so it survives the next sync:
#   ~/.dotfiles/tmux/.tmux.conf  ->  set -g set-clipboard on
git -C ~/.dotfiles commit -am "fix: re-enable tmux OSC 52 for clipboard" && git -C ~/.dotfiles push
```

Then drag-select text in tmux and paste locally (Ctrl/Cmd-V) to confirm.

## Hosts referenced by the broadcast fallback

- Fedora workstation (`FLDW`): `10.1.10.40` — receives via `wl-copy` (Wayland).
- macOS (work MacBook): `10.1.10.84` — receives via `pbcopy`.
- The broadcast script swallows all errors (`2>/dev/null &`), so its failures are
  invisible. Prefer the OSC 52 path; treat broadcast as best-effort only.
