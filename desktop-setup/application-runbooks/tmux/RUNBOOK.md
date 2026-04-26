# Runbook for tmux

tmux provides the persistent status bar and session management layer. Every Ghostty window auto-attaches to (or creates) a tmux session named `main` via the `command` setting in the Ghostty config.

---

## Status Bar

The status bar polls six scripts every 2 seconds from `~/.config/tmux/status/`:

| Script | Displays | Data source |
|--------|----------|-------------|
| `workingon.sh` | `$WORKINGON` value | Shell environment (via tmux env) |
| `git.sh` | Branch name + dirty flag | `git` in the pane's current directory |
| `aws.sh` | Active AWS profile name | `~/.aws/active_profile` (file) |
| `k8s.sh` | Current kubectl context | `~/.kube/config` via `kubectl` |

### How the AWS segment works

The tmux server process runs outside any shell session and cannot see shell environment variables like `AWS_PROFILE`. The `aws.sh` script instead reads `~/.aws/active_profile`, a plain-text file that is kept in sync by two mechanisms:

1. **`sso-unity` / profile aliases** — `~/.environment/env.sh` generates `~/.environment/.env_set.sh` which includes a `printf` line that writes `~/.aws/active_profile` when sourced. This fires automatically whenever you run `sso-unity`, `realm-prod`, or any similar alias.

2. **`PROMPT_COMMAND` hook** (`~/.bash.d/40_bashrc_aws`) — writes `~/.aws/active_profile` on every shell prompt. This catches manual `export AWS_PROFILE=...` and any other path that bypasses `env.sh`.

If `~/.aws/active_profile` is absent, `aws.sh` falls back to `$AWS_PROFILE` (useful if tmux was started with the var already set), then to `~/.environment/what_aws_env_am_i.sh` for legacy key-based credentials.

### Status scripts must be executable

The four scripts (`aws.sh`, `git.sh`, `k8s.sh`, `workingon.sh`) must have the execute bit set (`chmod +x`). Their mode is committed as `100755` in this repo — a fresh `git checkout` will always produce executable files.

If you ever add a new status script, stage its mode before committing:

```bash
git update-index --chmod=+x tmux/.config/tmux/status/<new-script>.sh
git commit
```

Do **not** use `git config core.fileMode false` in this repo — that would prevent git from tracking permission changes.

---

## Configuration

tmux config is managed via GNU Stow from the `tmux` package.

| File | Live path |
|------|-----------|
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `tmux/.config/tmux/status/*.sh` | `~/.config/tmux/status/*.sh` (symlinks) |

Apply config changes live (no restart needed):

```bash
tmux source-file ~/.tmux.conf
```

---

## Clipboard (RPi5 over SSH)

On the Raspberry Pi 5 there is no real display, so the standard X11/Wayland clipboard tools don't work. The clipboard stack has three layers that must all be intact for yanked text to reach the machine you SSHed from.

### Architecture

```
tmux yank (y / DoubleClick / TripleClick)
    │
    ▼
DISPLAY=:99 copyq copy -        ← copyq running headless on Xvfb :99
    │
    ├─► OSC 52 escape sequence → SSH tunnel → outer terminal (Ghostty)
    │       requires: terminal-overrides Ms capability (see below)
    │
    └─► ~/.local/bin/broadcast_clip_from_pi.sh  (runs in background)
            printf '%s' "$clip" | ssh fedora "wl-copy"    (Wayland)
            printf '%s' "$clip" | ssh mac    "pbcopy"     (macOS)
```

**copyq on Xvfb** (`DISPLAY=:99`) is the clipboard store. Xvfb and copyq are started as systemd user services (or at login). tmux-yank is configured to pipe selected text directly into copyq rather than using xsel/xclip, which require a real display.

**OSC 52** is the terminal escape sequence that lets tmux push text into the SSH client's clipboard. It requires the client terminal to support OSC 52 (Ghostty does) and the tmux `Ms` capability to be set for that terminal type.

**broadcast_clip_from_pi.sh** is a belt-and-suspenders fallback that pushes the clipboard to Fedora and Mac over SSH, bypassing OSC 52 entirely. It fires on every yank via the copy command, so the clipboard reliably reaches Fedora even when OSC 52 can't traverse the full chain.

### The nested-tmux problem

When you SSH to the Pi **from inside Ghostty on Fedora**, Ghostty is running inside Fedora's tmux, so your shell's `$TERM` is `tmux-256color`, not `ghostty` or `xterm-256color`. The Pi's tmux sees `client_termname=tmux-256color` and checks whether any `terminal-overrides` entry matches. Without a `tmux*` entry, none match, so `Ms` is never added and OSC 52 is never sent.

Fix already applied in `~/.tmux.conf`:

```
set -ag terminal-overrides ',tmux*:Ms=\E]52;%p1%s;%p2%s\007'
```

This is why there are three entries (`xterm*`, `ghostty*`, `tmux*`) — they cover direct Ghostty SSH, SSH from a non-tmux shell on Fedora, and SSH from inside Fedora's tmux respectively.

Even with `tmux*:Ms=...` set on the Pi, the OSC 52 sequence arrives at Fedora's tmux (not directly at Ghostty). For Fedora's tmux to forward it to Ghostty, Fedora's `~/.tmux.conf` would also need `terminal-overrides` with `Ms` for `ghostty*`. The broadcast script sidesteps this entirely.

### Troubleshooting: clipboard not working over SSH

**1. Check that Xvfb and copyq are running on the Pi:**

```bash
pgrep -a Xvfb          # should show: Xvfb :99 ...
pgrep -a copyq         # should show multiple copyq processes
DISPLAY=:99 copyq clipboard   # should print the current clipboard content
```

If either process is missing, check the systemd user services or re-run whatever starts them at login.

**2. Verify the terminal-overrides are loaded:**

```bash
tmux show-options -g terminal-overrides
```

You should see three `Ms=` entries for `xterm*`, `ghostty*`, and `tmux*`. If missing, reload the config:

```bash
tmux source-file ~/.tmux.conf
```

**3. Check which terminal tmux sees for your session:**

```bash
tmux display-message -p "#{client_termname}"
```

If this returns `tmux-256color`, you are SSHing from inside Fedora's tmux. OSC 52 will pass through tmux on the Pi, but Fedora's tmux must also forward it to Ghostty. The broadcast script is the reliable path in this case.

**4. Test the broadcast script manually:**

```bash
printf 'test-clip' | DISPLAY=:99 copyq copy -
~/.local/bin/broadcast_clip_from_pi.sh
```

Then try pasting in Ghostty on Fedora. If it fails, check SSH connectivity:

```bash
ssh -o ConnectTimeout=5 -o BatchMode=yes 10.1.10.40 echo ok
```

**5. Check that broadcast_clip_from_pi.sh is executable:**

```bash
ls -la ~/.local/bin/broadcast_clip_from_pi.sh
```

If it lacks the `x` bit: `chmod +x ~/.local/bin/broadcast_clip_from_pi.sh`

**6. Fedora wl-copy path:**

The broadcast script uses:
```bash
printf '%s' "$CLIP" | ssh 10.1.10.40 "XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-0 wl-copy"
```

If it stops working on Fedora, verify that the Wayland socket still exists at `/run/user/1000/wayland-0` and that `wl-clipboard` is installed (`dnf install wl-clipboard`).

---

## opensessions sidebar

The opensessions plugin adds an AI session sidebar toggled with `prefix + o + t`.

### Keybindings

| Binding | Action |
|---------|--------|
| `prefix + o + t` | Toggle sidebar |
| `prefix + o + s` | Focus sidebar |
| `prefix + o + e` | Even horizontal layout |

### Configuration

Config is managed via the `opensessions` Stow package:

| File in repo | Live path |
|--------------|-----------|
| `opensessions/.config/opensessions/config.json` | `~/.config/opensessions/config.json` |

Current settings:

```json
{
  "plugins": [],
  "sidebarPosition": "right",
  "sidebarWidth": 26
}
```

- `sidebarWidth` — width in **columns** (character cells). Default: 26. Setting it to 74 takes roughly half the screen.
- `sidebarPosition` — `"left"` or `"right"`.

### Restarting the opensessions server

The server reads config at startup. After editing `config.json`, restart it so the new width takes effect:

```bash
kill $(cat /tmp/opensessions.*.pid)
```

The server restarts automatically the next time you toggle the sidebar (`prefix + o + t`).

If the PID file is missing, kill by process name:

```bash
pkill -f "main.ts"
```

---

## Troubleshooting: Status bar not showing expected items

Work through these checks in order.

### 1. Are the status scripts executable?

```bash
ls -la ~/.config/tmux/status/
```

All scripts should show `-rwxrwxr-x` (or similar with `x` bits). If any show `-rw-` instead:

```bash
chmod +x ~/.dotfiles/tmux/.config/tmux/status/*.sh
```

Then confirm the real files got the bit (the paths in `~/.config/tmux/status/` are symlinks into `~/.dotfiles`).

### 2. Does the script produce output when run directly?

```bash
~/.config/tmux/status/aws.sh
~/.config/tmux/status/k8s.sh
~/.config/tmux/status/git.sh /path/to/a/git/repo
~/.config/tmux/status/workingon.sh
```

If a script exits silently, the segment is intentionally blank (e.g. not in a git repo, no AWS profile set). If it errors, check the dependencies below.

### 3. AWS segment is blank after running `sso-unity`

Check whether `~/.aws/active_profile` was written:

```bash
cat ~/.aws/active_profile
```

If the file is missing:
- The `PROMPT_COMMAND` hook may not be loaded. Source it and press Enter once:
  ```bash
  source ~/.bash.d/40_bashrc_aws
  ```
- Or write the file manually for an immediate fix:
  ```bash
  printf '%s' "$AWS_PROFILE" > ~/.aws/active_profile
  ```

If the file exists but the bar still shows nothing, the script lost its execute bit — see check 1.

### 4. k8s segment is blank

```bash
kubectl config current-context
```

If this errors, `kubectl` is not installed or `~/.kube/config` does not exist. The segment is intentionally suppressed when no context is set.

### 5. `workingon` segment is blank

`$WORKINGON` is not set in tmux's environment. Set it in your shell and it will appear on the next prompt (the `PROMPT_COMMAND` hook propagates it via the file-based pattern if wired up, otherwise set it with):

```bash
export WORKINGON="my task"
```

Note: `WORKINGON` is a shell env var and has the same tmux visibility limitation as `AWS_PROFILE` — it will only appear if the tmux status script can read it, which requires either a file-based sync or `tmux set-environment`.

### 6. Status bar not refreshing

Check the poll interval:

```bash
tmux show-option -g status-interval
```

Should be `2`. If it is set to a large value or `0`:

```bash
tmux set-option -g status-interval 2
```

### 7. Status bar gone entirely

```bash
tmux show-option -g status
```

If it returns `off`:

```bash
tmux set-option -g status on
```

To make it permanent, confirm `set -g status on` is present in `~/.tmux.conf`, then:

```bash
tmux source-file ~/.tmux.conf
```
