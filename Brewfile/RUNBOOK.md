# Brewfile RUNBOOK

## What is a Brewfile?

A `Brewfile` is a declarative manifest for [Homebrew](https://brew.sh) — it lists every tap, formula, cask, Mac App Store app, and VS Code extension that should be installed on a machine. It is read by the `brew bundle` subcommand (shipped with Homebrew itself; no separate install needed).

Think of it as `requirements.txt` / `package.json` for a Mac's system-level tooling. It lets you:

- Record the current state of a machine's Homebrew installs.
- Replay that state on a new machine with one command.
- Diff against the live system to see what drifted.
- Clean up anything installed ad-hoc that isn't in the manifest.

File format (one entry per line):

```ruby
tap "homebrew/bundle"
brew "git"
brew "tenv"
cask "ghostty"
mas "Xcode", id: 497799835
vscode "ms-python.python"
```

## This repo

The `Brewfile` in this directory is the source of truth for what should be installed via Homebrew on this user's Macs. It was generated with `brew bundle dump` and should be updated whenever new tools are installed or removed.

## Commands

### Dump (save current system state to the Brewfile)

```bash
brew bundle dump --file=~/.dotfiles/Brewfile/Brewfile --force
```

`--force` overwrites the existing file. Run this after installing or removing anything via `brew` that you want tracked.

### Restore (install everything listed in the Brewfile)

```bash
brew bundle install --file=~/.dotfiles/Brewfile/Brewfile
```

Idempotent — already-installed items are skipped. Safe to re-run.

### Check (show what's missing, without installing)

```bash
brew bundle check --file=~/.dotfiles/Brewfile/Brewfile --verbose
```

### Cleanup (remove anything installed but not in the Brewfile)

```bash
brew bundle cleanup --file=~/.dotfiles/Brewfile/Brewfile           # dry-run
brew bundle cleanup --file=~/.dotfiles/Brewfile/Brewfile --force   # actually remove
```

Destructive — review the dry-run output first.

## Tips

- After `brew install <something>` that you want to keep, re-run the dump command to update the Brewfile and commit the change.
- If a formula conflicts with another (e.g. `tenv` vs `opentofu`/`terragrunt`, which both ship the same binary), remove the losing entry from the Brewfile so `brew bundle install` doesn't re-introduce the conflict on a fresh machine.
- The dump includes VS Code extensions via the `code` CLI — make sure `code` is on your `PATH` before dumping or those lines will be missing.
