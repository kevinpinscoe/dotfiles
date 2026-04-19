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
