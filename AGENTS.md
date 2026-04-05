# Repository Guidelines

## Project Structure & Module Organization
This repository stores personal dotfiles and sync scripts. Shell configuration lives in `bash/`, with numbered fragments in `bash/.bash.d/` loaded in order. Vim config is in `vim/`, cheat CLI config and custom cheatsheets are in `.config/cheat/` and `cheats/`, and host-specific VS Code settings live in `vscode/personal/` (Fedora) and `vscode/professional/` (macOS).

Top-level scripts drive the workflow:
- `copy.sh`: capture live system changes into this repo
- `install.sh`: apply repo-managed dotfiles to a machine
- `restore.sh`: restore VS Code settings after `install.sh`

## Build, Test, and Development Commands
There is no build step. Use the shell scripts directly:

```bash
bash copy.sh
bash install.sh
bash restore.sh
bash -n copy.sh install.sh restore.sh
```

`bash -n` is the main syntax check for script changes. Run commands from the repo root. Review any `rsync --delete` targets before executing; these scripts intentionally overwrite live files.

## Coding Style & Naming Conventions
Write Bash with `#!/usr/bin/env bash` and `set -euo pipefail`, matching the existing scripts. Use two-space indentation inside conditionals and keep quoting strict (`"$HOME"`, `"$dotfiles_vscode"`). Name shell fragments with numeric prefixes to preserve load order, for example `20_bashrc_aliases` or `98_zsh_prompt`.

Keep platform-specific logic explicit. This repo currently uses `hostname -s` values `kevin` and `MacBook`; follow that pattern when extending host-aware behavior.

## Testing Guidelines
There is no formal test framework or coverage gate. Validate changes by:
- running `bash -n` on edited scripts
- testing the affected workflow on the target host
- checking copied destinations and hostname branches before merging

For cheatsheets, confirm files render correctly in `cheat` and are placed under the correct platform directory such as `cheats/all/` or `cheats/mac/`.

## Commit & Pull Request Guidelines
This repository currently has no commit history, so use concise imperative commit subjects such as `Add macOS zsh aliases` or `Update VS Code restore paths`. Keep commits scoped to one workflow or tool.

Pull requests should summarize the affected area, call out any destructive sync behavior, and note which host(s) were verified. Include screenshots only for VS Code UI changes when they add clarity.
