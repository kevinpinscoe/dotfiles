# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Personal dotfiles for Linux hosts (Fedora, Raspberry Pi) and Mac. The repo uses two scripts for synchronization:

- `copy.sh` — copies files **from the live system** into this repo (run when you've made changes on the system and want to save them)
- `install.sh` — copies files **from this repo** to the live system (run to apply dotfiles to a new or existing host)
- `restore.sh` — restores VS Code configuration from this repo to the live system (VS Code is excluded from `install.sh`; run this separately after `install.sh`)

## Key workflows

**Save system changes to repo:**
```bash
bash copy.sh
```

**Apply dotfiles to system:**
```bash
bash install.sh
```

**Restore VS Code config to system:**
```bash
bash restore.sh
```

## Directory structure and purpose

| Path | Live destination | Notes |
|------|-----------------|-------|
| `bash/.bashrc` | `~/.bashrc` | Main bash config, sources `.bash.d/` fragments |
| `bash/.bash_profile` | `~/.bash_profile` | Login shell config |
| `bash/.zshrc` | `~/.zshrc` | Zsh config (macOS only) |
| `bash/.zprofile` | `~/.zprofile` | Zsh login shell config (macOS only) |
| `bash/.bash.d/` | `~/.bash.d/` | Numbered bash fragments loaded in order |
| `vim/.vimrc` + `vim/.vim/` | `~/.vimrc`, `~/.vim/` | Vim config |
| `.config/cheat/conf.yml` | `~/.config/cheat/conf.yml` | Cheat CLI config |
| `cheats/` | `~/cheats/` | Personal cheatsheets by platform |
| `vscode/personal/` | Fedora VS Code config | Hostname `kevin` |
| `vscode/professional/` | Mac VS Code config | Hostname `MacBook` |

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

Uses the [`cheat`](https://github.com/cheat/cheat) CLI. Cheatsheets are organized by platform:
- `cheats/all/` — platform-agnostic (tagged `all`)
- `cheats/mac/` — macOS only (tagged `mac`)
- `cheats/fedora/` — Fedora Linux (tagged `fedora`)
- `cheats/rpi/` (not in repo but referenced in config) — Raspberry Pi

Community cheatsheets are cloned separately and not tracked in this repo.

### Generating a new cheatsheet

Edit `GENERATE-CHEAT.MD`, fill in the template variables, then run:
```bash
bash cheats/generate-cheat.sh
```
This calls Claude with `CLAUDE.md` and `GENERATE-CHEAT.MD` as context. Templates are in `cheats/templates/` (`all.md`, `fedora.md`).

## Platform-conditional logic

`copy.sh` detects the host with `hostname -s`:
- `kevin` → Fedora, copies from `~/.config/Code/User/`
- `MacBook` → macOS, copies from `~/Library/Application Support/Code/User/`

`install.sh` is platform-agnostic (no hostname detection).
