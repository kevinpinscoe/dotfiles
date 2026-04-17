# Dotfiles

Personal Bash, Vim, cheat, and VS Code configuration for macOS and Linux hosts.

## Quick Start

Review the scripts before running them. They copy files into your home directory and use `rsync --delete`, so they can overwrite or remove local config.

```bash
bash install.sh
bash restore.sh   # optional, restores VS Code settings
```

Use `copy.sh` only when you want to capture changes from a live machine back into this repository.

## Repository Layout

- `bash/` contains `.bashrc`, `.bash_profile`, macOS zsh files, and numbered fragments in `bash/.bash.d/`.
- `vim/` stores `.vimrc` and the `.vim/` runtime files.
- `cheats/` contains custom cheatsheets for the `cheat` CLI, split by platform (`all/`, `mac/`, `fedora/`, `rpi/`).
- `.config/cheat/` contains `cheat` configuration.
- `vscode/` stores host-specific VS Code settings snapshots.
- `desktop-setup/` contains platform-specific desktop application setup guides and runbooks (currently: [Claude Desktop on Fedora KDE](desktop-setup/fedora-kde/claude-desktop/README.md)).
- `copy.sh`, `install.sh`, and `restore.sh` drive sync and restore workflows.

## Workflow

- `bash install.sh` applies shell, Vim, and cheat configuration from this repo to the local machine.
- `bash restore.sh` restores VS Code settings after `install.sh`.
- `bash copy.sh` copies live system config back into this repo.

`copy.sh` and `restore.sh` contain hostname-specific logic for supported machines. If you are adapting this repo for another system, update those scripts before using them.

## Private Local Dependencies

Some shell fragments expect files that are intentionally not tracked here:

- `~/bin/` for personal helper scripts such as prompt and completion helpers
- `~/.environment/` for machine-specific environment variables, aliases, and secrets

This repository is public-safe only if secrets and private tooling remain outside version control.

## Notes for Public Use

This repo is primarily a personal setup, not a generic dotfiles framework. Use it as a reference or starting point, and expect to change paths, hostnames, and tool-specific assumptions for your own environment.

## Fedora desktop

![Fastfetch logo](desktop-setup/fedora-kde/fastfetch/logo.png)

