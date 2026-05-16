# Headlamp

## Summary

Kubernetes dashboard UI — a web-based, extensible interface for browsing, managing, and monitoring Kubernetes clusters. Supports multiple clusters, plugin architecture, and OIDC authentication.

## Links

- Main site: <https://headlamp.dev/>
- Source repo: <https://github.com/kubernetes-sigs/headlamp>
- Releases: <https://github.com/kubernetes-sigs/headlamp/releases>
- Install docs (Linux): <https://headlamp.dev/docs/latest/installation/desktop/linux-installation>

## Operation

### Install (Fedora — AppImage)

```bash
VERSION="0.42.0"
APPIMAGE_URL="https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-linux-x64.AppImage"

# 1. Download AppImage
mkdir -p ~/.local/share/headlamp
curl -sSfL "$APPIMAGE_URL" -o ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage
chmod +x ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage

# 2. Stable symlink for scripts / CLI
ln -sf ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage ~/.local/bin/headlamp

# 3. Icon (from GitHub source tree)
mkdir -p ~/.local/share/icons/hicolor/256x256/apps
curl -sSfL "https://raw.githubusercontent.com/kubernetes-sigs/headlamp/main/frontend/src/resources/icon-dark.svg" \
  -o ~/.local/share/icons/hicolor/256x256/apps/headlamp.svg

# 4. Desktop entry
cat > ~/.local/share/applications/headlamp.desktop <<'EOF'
[Desktop Entry]
Name=Headlamp
Comment=Kubernetes dashboard UI
Exec=/home/kinscoe/.local/bin/headlamp %U
Icon=/home/kinscoe/.local/share/icons/hicolor/256x256/apps/headlamp.svg
Type=Application
Categories=Development;Network;
StartupWMClass=Headlamp
EOF
update-desktop-database ~/.local/share/applications/
```

### Upgrade

```bash
VERSION="<new-version>"
APPIMAGE_URL="https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-linux-x64.AppImage"
curl -sSfL "$APPIMAGE_URL" -o ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage
chmod +x ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage
ln -sf ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage ~/.local/bin/headlamp
```

Old AppImages can be removed from `~/.local/share/headlamp/` manually.

### File locations

| Purpose | Path |
|---------|------|
| AppImage | `~/.local/share/headlamp/Headlamp-<version>-linux-x64.AppImage` |
| CLI symlink | `~/.local/bin/headlamp` |
| Desktop entry | `~/.local/share/applications/headlamp.desktop` |
| Icon | `~/.local/share/icons/hicolor/256x256/apps/headlamp.svg` |
| Kubeconfig | `~/.kube/config` (standard; Headlamp reads it automatically) |

### KDE Plasma launch wrapper (`headlamp-launch`)

The `.desktop` entry calls `~/.local/bin/headlamp-launch` rather than `headlamp` directly.
The wrapper kills any stale `headlamp-server` or FUSE mount processes before launching, to
avoid port 4466 conflicts when the previous instance exited uncleanly.

Full details and the wrapper script verbatim:
→ [`~/.dotfiles/desktop-apps/headlamp.md`](../../../../desktop-apps/headlamp.md)

Install the wrapper:

```bash
cat > ~/.local/bin/headlamp-launch << 'EOF'
#!/usr/bin/env bash
pkill -f 'headlamp-server' 2>/dev/null
pkill -f '\.local/bin/headlamp$' 2>/dev/null
sleep 0.5
exec /home/kinscoe/.local/bin/headlamp "$@"
EOF
chmod +x ~/.local/bin/headlamp-launch
```

The `.desktop` entry must point to `headlamp-launch`:

```ini
Exec=/home/kinscoe/.local/bin/headlamp-launch %U
```

### Sandbox note

Fedora 42 enables unprivileged user namespaces by default, so the Electron sandbox works without `--no-sandbox`.

### Install (Raspberry Pi 5 Debian Trixie — AppImage ARM64)

```bash
VERSION="0.42.0"
APPIMAGE_URL="https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-linux-arm64.AppImage"

# 1. Download AppImage
mkdir -p ~/.local/share/headlamp
curl -sSfL "$APPIMAGE_URL" -o ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage
chmod +x ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage

# 2. Stable symlink
ln -sf ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage ~/.local/bin/headlamp

# 3. Icon
mkdir -p ~/.local/share/icons/hicolor/256x256/apps
curl -sSfL "https://raw.githubusercontent.com/kubernetes-sigs/headlamp/main/frontend/src/resources/icon-dark.svg" \
  -o ~/.local/share/icons/hicolor/256x256/apps/headlamp.svg

# 4. Desktop entry
cat > ~/.local/share/applications/headlamp.desktop <<'EOF'
[Desktop Entry]
Name=Headlamp
Comment=Kubernetes dashboard UI
Exec=/home/pi/.local/bin/headlamp %U
Icon=/home/pi/.local/share/icons/hicolor/256x256/apps/headlamp.svg
Type=Application
Categories=Development;Network;
StartupWMClass=Headlamp
EOF
update-desktop-database ~/.local/share/applications/
```

> **Note:** Replace `/home/pi` with the actual home directory path if the RPi5 user is not `pi`.

### Upgrade (Raspberry Pi 5)

```bash
VERSION="<new-version>"
APPIMAGE_URL="https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-linux-arm64.AppImage"
curl -sSfL "$APPIMAGE_URL" -o ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage
chmod +x ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage
ln -sf ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage ~/.local/bin/headlamp
```

### Install (macOS — GitHub Releases DMG)

Homebrew install is deprecated due to macOS Tahoe Gatekeeper issues. Use the DMG from GitHub Releases instead.

```bash
VERSION="0.42.0"
# Choose arm64 for Apple Silicon or x64 for Intel
DMG_URL="https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-mac-arm64.dmg"
# Intel: https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-mac-x64.dmg

# 1. Download and open DMG
curl -sSfL "$DMG_URL" -o ~/Downloads/Headlamp-${VERSION}-mac-arm64.dmg
open ~/Downloads/Headlamp-${VERSION}-mac-arm64.dmg
```

2. In the Finder window that opens, drag **Headlamp** into `/Applications`.
3. Eject the disk image when done.
4. Launch Headlamp from `/Applications` — macOS may show a Gatekeeper warning on first open; right-click → Open to bypass it.

### Upgrade (macOS)

Download the new `.dmg` from the [releases page](https://github.com/kubernetes-sigs/headlamp/releases), drag to `/Applications` (overwrite), and eject.

## Troubleshooting

### KDE icon click does nothing (port 4466 conflict)

A stale `headlamp-server` subprocess or FUSE mount helper is blocking the port. Kill
everything and relaunch:

```bash
pkill -f 'headlamp-server'; pkill -f '\.local/bin/headlamp$'; sleep 1
headlamp-launch &
```

See the KDE launch doc for full diagnostics:
→ [`~/.dotfiles/desktop-apps/headlamp.md`](../../../../desktop-apps/headlamp.md)
