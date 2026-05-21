# Marky

## Summary

Marky is a fast, native, lightweight markdown viewer for macOS and Linux, built with Tauri v2, React, and markdown-it. It is CLI-first — `marky FILENAME` opens a single file in a viewer window, and `marky FOLDER` opens a folder as a persistent Obsidian-style workspace. Files reload live as they change on disk, which makes it well suited for previewing Claude-generated plans, documentation, and notes while they are being written. It supports GFM, syntax highlighting via Shiki, KaTeX math, Mermaid diagrams, a Cmd+K fuzzy command palette, and light/dark themes. Rendering is sanitized through DOMPurify, and the production `.dmg` is under 15 MB.

## Links

- Main website / source repo: https://github.com/GRVYDEV/marky
- Installation docs (macOS): https://github.com/GRVYDEV/marky#homebrew-macos
- Releases: https://github.com/GRVYDEV/marky/releases
- Issues / feature requests: https://github.com/GRVYDEV/marky/issues
- Demo video: https://youtu.be/nGBxt8uOVjc

## Operation

### Install (macOS, Apple Silicon, via Homebrew cask)

```bash
brew tap GRVYDEV/tap
brew install --cask GRVYDEV/tap/marky

# Temporary: the app is not yet Apple-notarized (developer review pending).
# Strip the quarantine attribute so macOS will let it launch.
xattr -cr /Applications/Marky.app
```

### Configuration

Marky has no user-editable dotfile-style config. State that survives across launches (open folders, last session, theme preference) is managed by the app itself and stored in the standard macOS app-support locations under `~/Library/Application Support/` and `~/Library/Preferences/` (Tauri v2 default). There is nothing to stow.

### Post-install

- Launch from Spotlight (`Marky`) or via the CLI:
  ```bash
  marky README.md      # open a single file
  marky ./docs/        # open a folder as a workspace
  marky                # restore the last session
  ```
- The `marky` CLI shim is installed by the Homebrew cask; no PATH changes required when installed this way.

### Upgrade

```bash
brew update
brew upgrade --cask GRVYDEV/tap/marky
# Re-strip quarantine if Homebrew replaces the bundle and the app is still unsigned
xattr -cr /Applications/Marky.app
```

### Uninstall

```bash
brew uninstall --cask GRVYDEV/tap/marky
brew untap GRVYDEV/tap   # optional, only if no other casks from this tap are installed
```

### Set as default app for markdown files

macOS Launch Services does not recognise Marky as a registered `.md` handler, so the Finder "Always Open With" preference reverts after one use. Fix it via `duti`, which writes directly to the Launch Services database.

```bash
brew install duti
duti -s dev.marky.app .md all
duti -s dev.marky.app .markdown all
```

Verify:

```bash
duti -x md
# should print: Marky.app / /Applications/Marky.app / dev.marky.app
```

## Troubleshooting
