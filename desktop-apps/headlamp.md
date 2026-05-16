# Headlamp — KDE Plasma Launch Setup (Fedora)

Headlamp is an Electron-based Kubernetes dashboard that ships as an AppImage.
The AppImage bundles both the Electron UI and an embedded `headlamp-server` Go binary
that serves the backend API (default port **4466**).

When a second launch is attempted while a previous instance is still running the server
process holds port 4466 and the new launch fails silently. The `headlamp-launch` wrapper
exists to kill any stale processes before starting a fresh instance.

---

## File locations

| File | Purpose |
|------|---------|
| `~/.local/share/headlamp/Headlamp-<ver>-linux-x64.AppImage` | AppImage binary |
| `~/.local/bin/headlamp` | Stable symlink → AppImage (used by scripts and the wrapper) |
| `~/.local/bin/headlamp-launch` | Pre-kill wrapper called by the KDE desktop entry |
| `~/.local/share/applications/headlamp.desktop` | KDE `.desktop` entry (the icon in the app launcher) |
| `~/.local/share/icons/hicolor/256x256/apps/headlamp.svg` | App icon |
| `~/.config/Headlamp/headlamp-config.json` | Headlamp user config (zoom factor etc.) |

---

## How the launch works

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

Killing the FUSE helper (the symlink path) tears down the mount and the Electron process
with it.

---

## KDE `.desktop` entry

Path: `~/.local/share/applications/headlamp.desktop`

```ini
[Desktop Entry]
Name=Headlamp
Comment=Kubernetes dashboard UI
Exec=/home/kinscoe/.local/bin/headlamp-launch %U
Icon=/home/kinscoe/.local/share/icons/hicolor/256x256/apps/headlamp.svg
Type=Application
Categories=Development;Network;
StartupWMClass=Headlamp
```

Re-register after editing:

```bash
update-desktop-database ~/.local/share/applications/
```

---

## `headlamp-launch` wrapper

Path: `~/.local/bin/headlamp-launch`

```bash
#!/usr/bin/env bash
# Kill any stale headlamp processes before launching to avoid port 4466 conflicts.
# Pattern anchored with $ so it matches .local/bin/headlamp but NOT .local/bin/headlamp-launch.
pkill -f 'headlamp-server' 2>/dev/null
pkill -f '\.local/bin/headlamp$' 2>/dev/null
sleep 0.5
exec /home/kinscoe/.local/bin/headlamp "$@"
```

**Why `\.local/bin/headlamp$` and not `Headlamp.*AppImage`?**

The AppImage process never shows the AppImage filename in `ps` output. Running processes
appear as the symlink path (`/home/kinscoe/.local/bin/headlamp`) or the FUSE mount path
(`/tmp/.mount_headla*/headlamp`). The `Headlamp.*AppImage` pattern therefore matched
nothing, leaving stale processes alive.

Install / reinstall the wrapper:

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

---

## Upgrading the AppImage

```bash
VERSION="<new-version>"
APPIMAGE_URL="https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-linux-x64.AppImage"
curl -sSfL "$APPIMAGE_URL" -o ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage
chmod +x ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage
ln -sf ~/.local/share/headlamp/Headlamp-${VERSION}-linux-x64.AppImage ~/.local/bin/headlamp
```

Old AppImages in `~/.local/share/headlamp/` can be removed manually.

---

## Troubleshooting

### Icon click does nothing / Headlamp doesn't open

Port 4466 is held by a stale `headlamp-server` process, or the FUSE mount helper is still
running. Kill everything and retry:

```bash
pkill -f 'headlamp-server'; pkill -f '\.local/bin/headlamp$'; sleep 1
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

Expected output when running normally: one FUSE helper (low RSS), one Electron main
process (high RSS), and several zygote/renderer children.

### drkonqi crash report

Crash dumps land in:

```
~/.cache/drkonqi/crashes/headlamp.<hash>.<pid>.<timestamp>.ini
```

The `COREDUMP_CMDLINE` field shows the real binary path inside the FUSE mount; `ARGV0`
shows the symlink path used to invoke it.

---

## See also

- Full install / upgrade runbook: [`~/.dotfiles/desktop-setup/application-runbooks/Headlamp/RUNBOOK.md`](../desktop-setup/application-runbooks/Headlamp/RUNBOOK.md)
