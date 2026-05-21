# Marky

## Operation

<!-- Personal usage notes go here -->

## Summary

Marky is a fast, native, lightweight markdown viewer built with Tauri v2, React, and markdown-it. It is CLI-first — `marky FILENAME` opens a single file in a viewer window, and `marky FOLDER` opens a folder as a persistent Obsidian-style workspace. Files reload live as they change on disk — well suited for previewing Claude-generated plans and documentation while they are being written. Supports GFM, syntax highlighting via Shiki, KaTeX math, Mermaid diagrams, a Cmd+K fuzzy command palette, and light/dark themes. Rendering is sanitized through DOMPurify. The production `.dmg` is under 15 MB.

## Links

- Main website / source repo: https://github.com/GRVYDEV/marky
- Releases: https://github.com/GRVYDEV/marky/releases
- Issues / feature requests: https://github.com/GRVYDEV/marky/issues
- Demo video: https://youtu.be/nGBxt8uOVjc

## Install

### macOS (Apple Silicon, via Homebrew cask)

```bash
brew tap GRVYDEV/tap
brew install --cask GRVYDEV/tap/marky

# Temporary: the app is not yet Apple-notarized (developer review pending).
# Strip the quarantine attribute so macOS will let it launch.
xattr -cr /Applications/Marky.app
```

**Upgrade:**

```bash
brew update
brew upgrade --cask GRVYDEV/tap/marky
# Re-strip quarantine if Homebrew replaces the bundle and the app is still unsigned
xattr -cr /Applications/Marky.app
```

**Uninstall:**

```bash
brew uninstall --cask GRVYDEV/tap/marky
brew untap GRVYDEV/tap   # optional, only if no other casks from this tap are installed
```

**Set as default app for markdown files (macOS):**

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

### Fedora (from .deb asset)

The AppImage release fails on Wayland sessions (KDE Plasma) with an EGL display error. Install from the `.deb` release asset instead by extracting it manually — no `alien` or rpm conversion needed.

```bash
# Download the latest amd64 .deb
cd /tmp
gh api repos/GRVYDEV/marky/releases/latest \
  --jq '.assets[] | select(.name | test("amd64\\.deb$")) | .browser_download_url' \
  | xargs curl -L -o marky.deb

# Extract the data payload
ar x marky.deb
mkdir -p marky-extract
tar -xzf data.tar.gz -C marky-extract

# Install binary and icons
mkdir -p ~/.local/bin
cp marky-extract/usr/bin/marky ~/.local/bin/marky

mkdir -p ~/.local/share/icons/hicolor/128x128/apps \
         ~/.local/share/icons/hicolor/256x256/apps
cp marky-extract/usr/share/icons/hicolor/128x128/apps/marky.png \
   ~/.local/share/icons/hicolor/128x128/apps/marky.png
cp marky-extract/usr/share/icons/hicolor/256x256@2/apps/marky.png \
   ~/.local/share/icons/hicolor/256x256/apps/marky.png

# Create KDE/desktop menu entry
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/Marky.desktop << 'EOF'
[Desktop Entry]
Categories=Utility;
Comment=A fast markdown viewer with vault support
Exec=/home/kinscoe/.local/bin/marky
StartupWMClass=marky
Icon=marky
Name=Marky
Terminal=false
Type=Application
EOF
update-desktop-database ~/.local/share/applications/

# Clean up
rm -rf marky-extract marky.deb control.tar.gz data.tar.gz debian-binary
```

`~/.local/bin` must be on `$PATH` (it is in the standard dotfiles setup).

**Upgrade (Fedora):**

```bash
cd /tmp && \
gh api repos/GRVYDEV/marky/releases/latest \
  --jq '.assets[] | select(.name | test("amd64\\.deb$")) | .browser_download_url' \
  | xargs curl -L -o marky.deb && \
ar x marky.deb && \
mkdir -p marky-extract && tar -xzf data.tar.gz -C marky-extract && \
cp marky-extract/usr/bin/marky ~/.local/bin/marky && \
rm -rf marky-extract marky.deb control.tar.gz data.tar.gz debian-binary
```

## Configuration

Marky has no user-editable dotfile-style config. State that survives across launches (open folders, last session, theme preference) is managed by the app itself:

| Platform | Storage path |
|----------|-------------|
| macOS | `~/Library/Application Support/` and `~/Library/Preferences/` (Tauri v2 default) |
| Fedora | `~/.config/` (Tauri v2 default on Linux) |

There is nothing to stow.

## Usage

```bash
marky README.md      # open a single file
marky ./docs/        # open a folder as a workspace
marky                # restore the last session
```

On Fedora, launch from the KDE application menu (search "Marky") or via the CLI.

## Troubleshooting

### AppImage fails with EGL error (Fedora)

The AppImage release crashes on Wayland sessions (KDE Plasma) with:

```
Could not create default EGL display: EGL_BAD_PARAMETER. Aborting...
```

This affects `--ozone-platform=x11`, `--ozone-platform=wayland`, and `--disable-gpu` alike. Use the `.deb` install method above instead.
