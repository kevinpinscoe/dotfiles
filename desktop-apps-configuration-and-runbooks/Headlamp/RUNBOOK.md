# Headlamp

## Operation

<!-- Personal usage notes go here -->

## Summary

Headlamp is an extensible, web-based UI for Kubernetes maintained by the Kubernetes SIG-UI community. The desktop build is an Electron app that lets you browse and operate on multiple clusters from kubeconfig contexts without running an in-cluster deployment.

## Links

- Main site: <https://headlamp.dev/>
- Source repo: <https://github.com/kubernetes-sigs/headlamp>
- Releases: <https://github.com/kubernetes-sigs/headlamp/releases>
- Install docs: <https://headlamp.dev/docs/latest/installation/desktop/>

## Install

### macOS (Apple Silicon)

The macOS desktop build is currently **not signed/notarized** by upstream. Use the DMG manually and clear the quarantine attribute (the workaround documented by the Headlamp project).

```bash
# 1. Pick the latest tag
TAG=$(gh release list --repo kubernetes-sigs/headlamp --limit 20 \
        | awk '$1 !~ /helm/ && $1 ~ /^[0-9]/ {print $1; exit}')
VERSION="$TAG"

# 2. Download the arm64 DMG to ~/Downloads
curl -fL -o ~/Downloads/Headlamp-${VERSION}-mac-arm64.dmg \
  "https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-mac-arm64.dmg"

# 3. Mount, copy to /Applications, unmount
hdiutil attach ~/Downloads/Headlamp-${VERSION}-mac-arm64.dmg -nobrowse -quiet
VOL=$(ls -d /Volumes/Headlamp* | head -n1)
cp -R "$VOL/Headlamp.app" /Applications/
hdiutil detach "$VOL" -quiet

# 4. Clear the Gatekeeper quarantine attribute
xattr -dr com.apple.quarantine /Applications/Headlamp.app

# 5. Launch
open /Applications/Headlamp.app
```

For Intel Macs, swap `mac-arm64` → `mac-x64` in the URL.

**Update:** Re-run the install steps with the new TAG. Re-run `xattr -dr com.apple.quarantine` after every update.

**Uninstall:**

```bash
rm -rf /Applications/Headlamp.app
rm -rf ~/Library/Application\ Support/Headlamp
rm -rf ~/Library/Logs/Headlamp
```

**Config locations:**

| Purpose | Path |
|---------|------|
| Application support | `~/Library/Application Support/Headlamp/` |
| Plugin install | `~/Library/Application Support/Headlamp/plugins/` |
| Logs | `~/Library/Logs/Headlamp/` |

### Fedora (AppImage)

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

# 4. Desktop entry — points to headlamp-launch wrapper, not headlamp directly
cat > ~/.local/share/applications/headlamp.desktop <<'EOF'
[Desktop Entry]
Name=Headlamp
Comment=Kubernetes dashboard UI
Exec=/home/kinscoe/.local/bin/headlamp-launch %U
Icon=/home/kinscoe/.local/share/icons/hicolor/256x256/apps/headlamp.svg
Type=Application
Categories=Development;Network;
StartupWMClass=Headlamp
EOF
update-desktop-database ~/.local/share/applications/
```

Re-register after editing the desktop entry:

```bash
update-desktop-database ~/.local/share/applications/
```

**Upgrade:**

```bash
VERSION="<new-version>"
APPIMAGE_URL="https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-linux-x64.AppImage"
curl -sSfL "$APPIMAGE_URL" -o ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage
chmod +x ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage
ln -sf ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage ~/.local/bin/headlamp
```

Old AppImages in `~/.local/share/headlamp/` can be removed manually.

**Sandbox note:** Fedora 42 enables unprivileged user namespaces by default, so the Electron sandbox works without `--no-sandbox`.

### Raspberry Pi 5 (Debian Trixie — ARM64 AppImage)

```bash
VERSION="0.42.0"
APPIMAGE_URL="https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-linux-arm64.AppImage"

mkdir -p ~/.local/share/headlamp
curl -sSfL "$APPIMAGE_URL" -o ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage
chmod +x ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage
ln -sf ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage ~/.local/bin/headlamp

mkdir -p ~/.local/share/icons/hicolor/256x256/apps
curl -sSfL "https://raw.githubusercontent.com/kubernetes-sigs/headlamp/main/frontend/src/resources/icon-dark.svg" \
  -o ~/.local/share/icons/hicolor/256x256/apps/headlamp.svg

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

> Replace `/home/pi` with the actual home directory path if the user is not `pi`.

**Upgrade:**

```bash
VERSION="<new-version>"
APPIMAGE_URL="https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-linux-arm64.AppImage"
curl -sSfL "$APPIMAGE_URL" -o ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage
chmod +x ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage
ln -sf ~/.local/share/headlamp/Headlamp-${VERSION}-linux-arm64.AppImage ~/.local/bin/headlamp
```

## KDE Plasma Launch Wrapper (`headlamp-launch`)

The `.desktop` entry on Fedora calls `~/.local/bin/headlamp-launch` rather than `headlamp` directly. The wrapper kills any stale `headlamp-server` or FUSE mount processes before launching, to avoid port 4466 conflicts when the previous instance exited uncleanly.

### How the launch works

```
KDE app launcher
  └─ headlamp.desktop  (Exec=headlamp-launch)
       └─ headlamp-launch  (wrapper: pkill stale, then exec headlamp)
            └─ headlamp  (symlink → AppImage)
                 ├─ AppImage FUSE mount → /tmp/.mount_headla<random>/
                 ├─ Electron main process  (big memory, runs from FUSE mount)
                 └─ headlamp-server  (embedded Go binary, port 4466)
```

When the AppImage runs, two processes appear:

| What you see in `ps` | What it is |
|----------------------|-----------|
| `/home/kinscoe/.local/bin/headlamp` | AppImage FUSE mount helper (low memory) |
| `/tmp/.mount_headla<rand>/headlamp` | Actual Electron process (high memory) |

Killing the FUSE helper tears down the mount and the Electron process with it.

### Install the wrapper

```bash
cat > ~/.local/bin/headlamp-launch << 'EOF'
#!/usr/bin/env bash
# Kill any stale headlamp processes before launching.
# Three patterns needed:
#   headlamp-server       — embedded Go backend subprocess
#   \.local/bin/headlamp$ — AppImage FUSE mount helper ($ avoids matching headlamp-launch)
#   \.mount_headla        — Electron processes running from the AppImage FUSE mount in /tmp
pkill -f 'headlamp-server' 2>/dev/null
pkill -f '\.local/bin/headlamp$' 2>/dev/null
pkill -f '\.mount_headla' 2>/dev/null
sleep 1
# Remove stale Electron single-instance files. If headlamp was killed externally,
# Electron doesn't finish cleanup, leaving SingletonSocket behind. The next instance
# then waits ~20s on the dead socket before timing out, often ending in a crash.
rm -f "${HOME}/.config/Headlamp/SingletonLock" \
      "${HOME}/.config/Headlamp/SingletonSocket" \
      "${HOME}/.config/Headlamp/SingletonCookie"
exec /home/kinscoe/.local/bin/headlamp "$@"
EOF
chmod +x ~/.local/bin/headlamp-launch
```

### Why three kill patterns

| Pattern | What it kills |
|---------|--------------|
| `headlamp-server` | Embedded Go backend subprocess |
| `\.local/bin/headlamp$` | AppImage FUSE mount helper (`$` stops it matching `headlamp-launch`) |
| `\.mount_headla` | Electron main process + zygotes inside `/tmp/.mount_headla*/` |

Killing only the FUSE helper leaves the Electron process alive. Headlamp's single-instance logic sees the zombie Electron shell, forwards the new launch to it, and exits — nothing appears on screen. All three must be killed.

### Why delete the Singleton files

When headlamp is killed externally, Electron's cleanup handler never runs. Three files are left behind in `~/.config/Headlamp/`:

| File | Purpose |
|------|---------|
| `SingletonLock` | Marks the user-data dir as claimed |
| `SingletonSocket` | Unix socket for cross-instance IPC |
| `SingletonCookie` | Authentication token for that socket |

The next launch connects to `SingletonSocket`, gets no answer, waits ~20 seconds for its timeout, then tries to claim the lock itself — but the lock state is inconsistent and the launch usually crashes. Deleting all three before `exec` gives the new instance a clean slate every time.

## File Locations

| Purpose | Path |
|---------|------|
| AppImage (Fedora) | `~/.local/share/headlamp/Headlamp-<version>-linux-x64.AppImage` |
| AppImage (RPi5) | `~/.local/share/headlamp/Headlamp-<version>-linux-arm64.AppImage` |
| CLI symlink | `~/.local/bin/headlamp` |
| Launch wrapper (Fedora) | `~/.local/bin/headlamp-launch` |
| Desktop entry | `~/.local/share/applications/headlamp.desktop` |
| Icon | `~/.local/share/icons/hicolor/256x256/apps/headlamp.svg` |
| Kubeconfig | `~/.kube/config` (standard; read automatically) |
| App support (macOS) | `~/Library/Application Support/Headlamp/` |

## Troubleshooting

### KDE icon click does nothing / Headlamp doesn't open (port 4466 conflict)

A stale `headlamp-server` subprocess or FUSE mount helper is blocking the port. Kill everything and relaunch:

```bash
pkill -f 'headlamp-server'; pkill -f '\.local/bin/headlamp$'; pkill -f '\.mount_headla'; sleep 1
headlamp-launch &
```

Check what is holding the port:

```bash
ss -tlnp | grep 4466
```

### Verify running processes

```bash
ps -eo pid,ppid,args | grep headlamp | grep -v grep
```

Expected: one FUSE helper (low RSS), one Electron main process (high RSS), and several zygote/renderer children.

### drkonqi crash report

Crash dumps land in:

```
~/.cache/drkonqi/crashes/headlamp.<hash>.<pid>.<timestamp>.ini
```
