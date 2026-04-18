# Dotfiles

Personal Bash, Vim, cheat, and VS Code configuration for macOS and Linux hosts.

Dotfiles are managed with [GNU Stow](https://www.gnu.org/software/stow/). `install.sh` creates symlinks in `$HOME` rather than copying files, so edits to files in your home directory are immediately reflected in the repo.

## Quick Start

Install stow first (`apt install stow` / `brew install stow` / `dnf install stow`).

**First time on a host that previously used the old copy-based setup:**
```bash
bash migrate-to-stow.sh   # removes old copies so stow can create symlinks
bash install.sh
bash restore.sh           # optional, restores VS Code settings
```

**Fresh host:**
```bash
bash install.sh
bash restore.sh           # optional, restores VS Code settings
```

Use `copy.sh` only to capture VS Code settings from a live machine back into this repo. All other config (shell, vim, cheat) is live via symlinks — just edit in place.

## Repository Layout

Stow packages map directly to `$HOME`. Each top-level directory is a package:

- `bash/` — `.bashrc`, `.bash_profile`, macOS zsh files, and numbered fragments in `bash/.bash.d/`
- `vim/` — `.vimrc` and `.vim/` runtime files
- `aspell/` — `.aspell.en.pws` personal dictionary
- `cheat/` — `cheat` CLI config (`~/.config/cheat/conf.yml`)
- `home/` — everything that stows into `~/` but doesn't fit a dedicated package (e.g. `~/cheats/`)
- `vscode/` — host-specific VS Code settings snapshots (not stowed; restored via `restore.sh`)
- `desktop-setup/` — platform-specific setup guides, runbooks, and GUI app documentation
  - [`fedora-kde/`](desktop-setup/fedora-kde/) — Fedora KDE Plasma setup (including [Claude Desktop](desktop-setup/fedora-kde/claude-desktop/README.md))
  - [`application-runbooks/`](desktop-setup/application-runbooks/README.md) — per-app operational notes for desktop applications (Obsidian, etc.)

## Stow folding — why some symlinks are on directories, not files

Stow always folds as high as it can. If the target directory doesn't exist in `$HOME` before stow runs, stow symlinks the whole directory in one go rather than creating a symlink per file inside it. For example, `~/.bash.d/` didn't exist before stow first ran, so stow made `~/.bash.d` a single directory symlink → `.dotfiles/bash/.bash.d/` instead of 24 individual file symlinks.

Consequence: `ls -la ~/.bash.d/somefile` follows the directory symlink and shows a regular file with no `l` prefix or `->` target — it's the underlying real file in the repo. Don't mistake this for "not stowed". Check `readlink ~/.bash.d` or `ls -la ~ | grep bash.d` to see the directory symlink itself.

If stow needs to merge new files into an existing real `$HOME` subdirectory, it "unfolds" — breaks the directory symlink and creates per-file symlinks inside. Both behaviors produce the same end result (edits in `~/.dotfiles/…` are live), but the on-disk layout differs.

## Workflow

- `bash install.sh` — stows all packages (creates symlinks in `$HOME`)
- `bash restore.sh` — restores VS Code settings after `install.sh`
- `bash copy.sh` — copies VS Code config from the live system back into this repo

`restore.sh` contains hostname-specific logic. If you are adapting this repo for another system, update it before use.

## Private Local Dependencies

Some shell fragments expect files that are intentionally not tracked here:

- `~/bin/` for personal helper scripts such as prompt and completion helpers
- `~/.environment/` for machine-specific environment variables, aliases, and secrets

This repository is public-safe only if secrets and private tooling remain outside version control.

## Notes for Public Use

This repo is primarily a personal setup, not a generic dotfiles framework. Use it as a reference or starting point, and expect to change paths, hostnames, and tool-specific assumptions for your own environment.

## Fedora desktop

![Fastfetch logo](desktop-setup/fedora-kde/fastfetch/logo.png)

