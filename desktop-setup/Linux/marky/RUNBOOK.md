# Marky — Linux (Fedora)

## Summary

Marky is a fast, native, lightweight markdown viewer built with Tauri v2, React, and markdown-it. See `../../MacOS/marky/RUNBOOK.md` for a full feature description. On Fedora the AppImage release fails with an EGL display error; install from the `.deb` release asset instead by extracting it manually (no `alien` or rpm conversion needed).

## Links

- Source / releases: https://github.com/GRVYDEV/marky/releases

## Install (Fedora, from .deb asset)

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

## Usage

```bash
marky README.md      # open a single file
marky ./docs/        # open a folder as a workspace
marky                # restore last session
```

Or launch from the KDE application menu (search "Marky").

## Upgrade

Same steps as Install — overwrite the existing binary and icons. No config or state files need touching.

```bash
# Quick one-liner to replace just the binary
cd /tmp && \
gh api repos/GRVYDEV/marky/releases/latest \
  --jq '.assets[] | select(.name | test("amd64\\.deb$")) | .browser_download_url' \
  | xargs curl -L -o marky.deb && \
ar x marky.deb && \
mkdir -p marky-extract && tar -xzf data.tar.gz -C marky-extract && \
cp marky-extract/usr/bin/marky ~/.local/bin/marky && \
rm -rf marky-extract marky.deb control.tar.gz data.tar.gz debian-binary
```

## Troubleshooting

### AppImage fails with EGL error

The AppImage release crashes on Wayland sessions (KDE Plasma) with:

```
Could not create default EGL display: EGL_BAD_PARAMETER. Aborting...
```

This affects `--ozone-platform=x11`, `--ozone-platform=wayland`, and `--disable-gpu` alike. Use the `.deb` install method above instead.
