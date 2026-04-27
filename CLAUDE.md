# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Personal dotfiles for Linux hosts (Fedora, Raspberry Pi) and Mac. Dotfiles are managed with **GNU Stow** — `install.sh` creates symlinks in `$HOME` rather than copying files. Editing a file under `~/` edits the repo directly.

Scripts:
- `install.sh` — stows all packages (creates symlinks in `$HOME`); also auto-repairs a stow-folded `~/.config/git` directory symlink (converts it to per-file symlinks) so git can write runtime files alongside tracked config
- `migrate-to-stow.sh` — one-time migration on hosts that used the old copy-based setup; run before `install.sh`
- `copy.sh` — saves VS Code config **from the live system** into this repo (shell/vim/cheat are symlinks, no copying needed)
- `restore.sh` — restores VS Code configuration from this repo to the live system (run after `install.sh`)

## Git commit signing

All commits and tags in this repo are signed using **gitsign** (Sigstore) with Google OAuth (`gpgsign = true`, `format = x509`, `program = gitsign`). Signing opens a browser window to complete the OAuth flow.

**IMPORTANT — SSH sessions:** If you are connected to this machine via SSH from another host, `gitsign` cannot open a browser and any `git commit` or `git tag` will fail. Before asking Claude to commit anything, confirm you are sitting at the machine's physical desktop (or using a local terminal session on it). Claude must remind you of this requirement every time you request a commit.

## Key workflows

**First-time setup on a host previously using copy-based install:**
```bash
bash migrate-to-stow.sh
bash install.sh
bash restore.sh   # optional
```

**Fresh host:**
```bash
bash install.sh
bash restore.sh   # optional
```

**Save VS Code changes back to repo:**
```bash
bash copy.sh
```

## Directory structure and purpose

Stow packages — each directory is stowed into `$HOME`:

| Package | Path in repo | Live destination | Notes |
|---------|-------------|-----------------|-------|
| `bash` | `bash/.bashrc` | `~/.bashrc` | Main bash config, sources `.bash.d/` fragments |
| `bash` | `bash/.bash_profile` | `~/.bash_profile` | Login shell config |
| `bash` | `bash/.zshrc` | `~/.zshrc` | Zsh config (macOS only) |
| `bash` | `bash/.zprofile` | `~/.zprofile` | Zsh login shell config (macOS only) |
| `bash` | `bash/.bash.d/` | `~/.bash.d/` | Numbered bash fragments loaded in order |
| `vim` | `vim/.vimrc` + `vim/.vim/` | `~/.vimrc`, `~/.vim/` | Vim config |
| `aspell` | `aspell/.aspell.en.pws` | `~/.aspell.en.pws` | Personal spell-check dictionary |
| `cspell` | `cspell/.cspell.json` | `~/.cspell.json` | cspell global config (auto-discovered); points to custom word list |
| `cspell` | `cspell/.config/cspell/custom-words.txt` | `~/.config/cspell/custom-words.txt` | Personal cspell word list |
| `cheat` | `cheat/.config/cheat/conf.yml` | `~/.config/cheat/conf.yml` | Cheat CLI config |
| `home` | `home/cheats/` | `~/cheats/` | Personal cheatsheets by platform |
| `tmux` | `tmux/.tmux.conf` | `~/.tmux.conf` | tmux config; shared across platforms |
| `tmux` | `tmux/.config/tmux/status/` | `~/.config/tmux/status/` | Status bar scripts (workingon, git, aws, k8s) |
| `opensessions` | `opensessions/.config/opensessions/config.json` | `~/.config/opensessions/config.json` | opensessions sidebar config (sidebarPosition, width, theme, etc.) |
| `yazi` | `yazi/.config/yazi/plugins/ls-deluxe-colors.yazi/` | `~/.config/yazi/plugins/ls-deluxe-colors.yazi/` | Yazi linemode plugin: colors mtime by age and file size (lsd-style) |
| `git` | `git/.gitconfig` | `~/.gitconfig` | Global git config; shared across all platforms |
| `git` | `git/.config/git/ignore` | `~/.config/git/ignore` | Global gitignore |
| `git` | `git/.config/git/hooks/` | `~/.config/git/hooks/` | Global git hooks (pre-push, post-commit) |
| `ghostty-fedora` | `ghostty-fedora/.config/ghostty/config` | `~/.config/ghostty/config` | Ghostty config for Fedora (absolute tmux path) |
| `ghostty-mac` | `ghostty-mac/.config/ghostty/config` | `~/.config/ghostty/config` | Ghostty config for macOS (Homebrew tmux path) |
| — | `vscode/personal/` | Fedora VS Code config | Hostname `kevin`; restored via `restore.sh` |
| — | `vscode/professional/` | Mac VS Code config | Hostname `MacBook`; restored via `restore.sh` |

## External dependencies (not tracked in this repo)

These directories must be populated separately on each host:

- `~/bin/` — Personal scripts (AWS helpers, EKS tools, git utilities including `git-prompt.sh`, `git-completion.bash`). Not tracked because scripts contain host-specific or work-specific tooling.
- `~/.environment/` — Environment scripts and configs (AWS credentials, EKS cluster list, work aliases). Not tracked because they contain secrets and site-specific configuration. Scripts sourced from `.bash.d/` fragments: `replace.sh`, `aws_aliases.sh`, `work_aliases.sh`, `what_aws_env_am_i.sh`, `.env_set.sh`.

## Bash fragments loading order (`bash/.bash.d/`)

Files are numbered to control load order:
- `00_bashrc_env` / `01_bashrc_mac_env` — environment variables
- `02_core_path_env` / `02_fedora_path_env` — PATH setup
- `10_cd` — cd helpers
- `20_bashrc_aliases` / `21_bashrc_mac_aliases` / `22_bashrc_fedora_aliases` — aliases
- `30_bash_autocomplete` / `30_zsh_autocomplete` — tab completion (bash/zsh)
- `31_bash_mac_autocomplete` / `31_zsh_mac_autocomplete` — macOS tab completion (bash/zsh)
- `40_bashrc_aws` / `41_bashrc_timezone` / `41_bashrc_tofu_and_terragrunt` — tool configs
- `42_askpass` — SSH askpass
- `50_bashrc_terminal` — terminal settings
- `98_bash_prompt` / `98_zsh_prompt` — PS1/PROMPT prompt (sources `~/bin/git-prompt.sh` and `~/bin/git-completion.bash` from the external `~/bin/` dependency)

## Cheatsheets system

Uses the [`cheat`](https://github.com/cheat/cheat) CLI. Cheatsheets live in `home/cheats/` (stowed to `~/cheats/`) and are organized by platform:
- `home/cheats/all/` — platform-agnostic (tagged `all`)
- `home/cheats/mac/` — macOS only (tagged `mac`)
- `home/cheats/fedora/` — Fedora Linux (tagged `fedora`)
- `home/cheats/rpi/` (not in repo but referenced in config) — Raspberry Pi

Community cheatsheets are cloned separately and not tracked in this repo.

### Generating a new cheatsheet

Edit `GENERATE-CHEAT.MD`, fill in the template variables, then run:
```bash
bash home/cheats/generate-cheat.sh
```
This calls Claude with `CLAUDE.md` and `GENERATE-CHEAT.MD` as context. Templates are in `home/cheats/templates/` (`all.md`, `fedora.md`).

## Desktop setup and application runbooks

`desktop-setup/` contains platform-specific GUI environment documentation and is not a Stow package — nothing here is symlinked into `$HOME`.

`desktop-setup/application-runbooks/` holds per-app operational notes for GUI/desktop applications that cannot carry colocated documentation. Each app gets its own subdirectory with a `RUNBOOK.md`:

```
desktop-setup/application-runbooks/
└── <AppName>/
    ├── RUNBOOK.md
    └── <supporting files>
```

To add a runbook for a new app, create `desktop-setup/application-runbooks/<AppName>/RUNBOOK.md` and add a row to the table in `application-runbooks/README.md`.

## Third-party binary install paths

On Fedora, third-party binaries that are not installed via `dnf` go into `~/.local/bin/`, never `/usr/local/bin/`. Download the raw binary and place it there:

```bash
curl -sSfL <url> -o ~/.local/bin/<binary> && chmod +x ~/.local/bin/<binary>
```

On macOS, prefer `brew install` — Homebrew manages the path automatically.
On Raspberry Pi (Debian), same convention as Fedora: `~/.local/bin/` for binaries not installed via `apt`.

## Platform-conditional logic

`copy.sh` detects the OS with `uname -s` to find the VS Code config directory:
- `Linux` → Fedora, reads from `~/.config/Code/User/`
- `Darwin` → macOS, reads from `~/Library/Application Support/Code/User/`

`install.sh` is platform-agnostic — stow handles all packages the same way on every host.

## MANDATORY: cross-machine todo entries

This repo is stowed on three machines (macOS, Fedora, Raspberry Pi 5). When a change made here requires a follow-up command (e.g. `bash install.sh`, `bash migrate-to-stow.sh`, `bash restore.sh`, or any manual step) on machines **other than the one you are currently working on**, append a one-line entry to `~/todo/<os>/TODO.md` for each target machine so Kevin sees the pending task the next time he is on that host.

Folder mapping (match the directories that already exist under `~/todo/`):

| Target machine | Current OS detection | Todo file |
|----------------|---------------------|-----------|
| macOS | `uname -s` == `Darwin` | `~/todo/mac/TODO.md` |
| Fedora workstation | `uname -s` == `Linux`, `/etc/os-release` contains `fedora` | `~/todo/fedora/TODO.md` |
| Raspberry Pi 5 (Debian) | `uname -s` == `Linux`, `/etc/os-release` contains `debian` | `~/todo/rpi/TODO.md` |

### Rules

1. Detect the current host with `uname -s` (and `/etc/os-release` on Linux). **Do not** append to the current host's TODO.md — the change is already applied here.
2. Append to **every** other host's TODO.md that is affected by the change. Cross-platform package changes (e.g. a new entry in the `PACKAGES=(...)` array in `install.sh`) affect all three; platform-specific changes may only affect one.
3. Entry format — one line per task:
   ```
   YYYY-MM-DD <command to run>  # <short reason>
   ```
   Example: `2026-04-22 cd ~/.dotfiles && git pull && bash install.sh  # new stow package 'foo' added`
4. Create `~/todo/<os>/TODO.md` if it does not exist. Do not create anything else in those folders.
5. Kevin removes the line himself after running the command — do not touch existing entries.
6. Mention the appended entries in your response so Kevin can sanity-check the target list.

## MANDATORY: adding a new stow package

**Every time you create a new stow package in this repository, you must update `install.sh` in the same change.** This repo targets three platforms and all three must work after a `git pull && bash install.sh`:

| Platform | OS detection | stow install |
|----------|-------------|-------------|
| Fedora workstation | `uname -s` == `Linux`, `/etc/os-release` contains `fedora` | `sudo dnf install stow` |
| macOS | `uname -s` == `Darwin` | `brew install stow` |
| Raspberry Pi 5 Debian Trixie | `uname -s` == `Linux`, `/etc/os-release` contains `debian` | `sudo apt install stow` |

### Checklist for every new package

1. Place files under `<package>/<path-relative-to-home>/` following the existing layout convention.
2. If the package writes into `~/.config/<dir>/` and other tools may also write there, add `mkdir -p "$HOME/.config/<dir>"` to `install.sh` **before** the stow loop so stow folds per-file rather than symlinking the whole directory.
3. If the package is **cross-platform** (same files on all three hosts), add its name to the `PACKAGES=(...)` array in `install.sh`.
4. If the package is **platform-specific** (like ghostty), add a detection block in `install.sh` mirroring the existing `GHOSTTY_PKG` pattern — check `uname -s`, then check `/etc/os-release` for Fedora vs Debian on Linux.
5. Update the packages table in this file (the `## Directory structure and purpose` section).
6. Update `README.md` — add a row to the repository layout table.
7. Run `bash -n install.sh` to syntax-check before committing.

## MANDATORY: cspell word list changes

The personal cspell word list lives at `cspell/.config/cspell/custom-words.txt` (stowed to `~/.config/cspell/custom-words.txt`). Words are added here whenever the commit-msg hook or a spell-check run flags an unknown word that is valid.

**Every time words are added to `custom-words.txt`, immediately offer to commit and push the change to the remote repo.** Do not leave word list edits uncommitted — they accumulate silently and the commit-msg hook will re-flag the same words on the next unrelated commit.
