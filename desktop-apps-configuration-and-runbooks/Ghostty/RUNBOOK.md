# Ghostty

## Operation

<!-- Personal usage notes go here -->

## Summary

Ghostty is a fast, feature-rich, GPU-accelerated terminal emulator that aims to be platform-native while supporting a single cross-platform config file. It is the standard terminal across all three machines.

Every Ghostty window immediately attaches to (or creates) a persistent tmux session named `main`. Closing a Ghostty window does not kill the shell session — tmux keeps it alive. The tmux status bar at the bottom shows git branch, AWS account, k8s cluster, working-on context, and time — always visible.

## Links

- Main site: https://ghostty.org
- Source: https://github.com/ghostty-org/ghostty
- Documentation: https://ghostty.org/docs
- Config reference: https://ghostty.org/docs/config

## Install

| Platform | Install method | Binary location |
|----------|---------------|-----------------|
| macOS | `brew install --cask ghostty` | `/Applications/Ghostty.app` |
| Fedora | `sudo dnf copr enable pgdev/ghostty && sudo dnf install ghostty` | `/usr/bin/ghostty` |
| Raspberry Pi 5 (Debian Trixie, aarch64) | Built from source — see below | `~/.local/bin/ghostty` |

### Raspberry Pi 5 — Build from Source

No official arm64 `.deb` exists. Ghostty must be built from source using Zig.

| Item | Value |
|------|-------|
| Ghostty version | 1.3.0 |
| Source tarball | `https://release.files.ghostty.org/1.3.0/ghostty-1.3.0.tar.gz` |
| Zig version required | 0.15.2 (pinned to a specific Zig version) |
| Zig package | `zig-0` from the [griffo.io community repo](https://debian.griffo.io) |
| Zig binary path | `/usr/lib/zig/0.15.2/zig` |
| Build date | 2026-04-18 |

**Build dependencies:**

```bash
sudo apt install -y \
  pkg-config \
  gettext \
  libxml2-utils \
  libgtk-4-dev \
  libadwaita-1-dev \
  libgtk4-layer-shell-dev \
  mesa-vulkan-drivers
```

`mesa-vulkan-drivers` is a runtime requirement, not a build dep. Ghostty requires OpenGL 4.3; the Pi 5's V3D GPU only exposes OpenGL 3.1 via Mesa's standard driver. The Vulkan driver enables Mesa's Zink backend (GL-over-Vulkan) which provides OpenGL 4.x.

**Install Zig 0.15.2:**

```bash
curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc \
  | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
echo "deb https://debian.griffo.io/apt $(lsb_release -sc) main" \
  | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list
sudo apt update && sudo apt install -y zig-0
```

The `zig-stable` package in that repo is 0.16.0, which is too new for Ghostty 1.3.x. `zig-0` is the 0.15.2 package.

**Build:**

```bash
curl -L -o /tmp/ghostty-1.3.0.tar.gz \
  https://release.files.ghostty.org/1.3.0/ghostty-1.3.0.tar.gz
tar xzf /tmp/ghostty-1.3.0.tar.gz -C /tmp
cd /tmp/ghostty-1.3.0
/usr/lib/zig/0.15.2/zig build -Doptimize=ReleaseFast -p ~/.local
```

Binary installs to `~/.local/bin/ghostty`. Build takes approximately 5 minutes on a Pi 5.

**Upgrading (RPi):**

1. Check the required Zig version at `https://ghostty.org/docs/install/build` — it may change between releases.
2. Download the new source tarball.
3. Re-run the build steps above. The `-p ~/.local` flag overwrites the existing binary.
4. **Re-apply the OpenGL fix to the desktop entry** — the build overwrites `~/.local/share/applications/com.mitchellh.ghostty.desktop`, losing the `MESA_LOADER_DRIVER_OVERRIDE=zink MESA_EGL_NO_X11=1` vars. Edit both `Exec` lines after each rebuild.

## Configuration

Ghostty config is managed via GNU Stow. Three platform-specific packages:

| Platform | Stow package | Live path |
|----------|-------------|-----------|
| macOS | `ghostty-mac` | `~/.config/ghostty/config` |
| Fedora | `ghostty-fedora` | `~/.config/ghostty/config` |
| Debian/Pi | `ghostty-debian` | `~/.config/ghostty/config` |

`install.sh` selects the correct package automatically based on `/etc/os-release`.

Key config settings:

```
font-family = JetBrainsMono Nerd Font Mono
font-size = 13
copy-on-select = true
command = /usr/bin/tmux new-session -A -s main
```

| Setting | Purpose |
|---------|---------|
| `font-family` | Nerd Font variant required for tmux status bar icons |
| `copy-on-select` | Selected text copied to clipboard immediately |
| `command` | Replaces default shell with tmux on every new window. `-A` attaches if session exists, `-s main` names it |

The `command` path differs per platform:

| Platform | tmux path |
|----------|-----------|
| macOS | `/opt/homebrew/bin/tmux` |
| Fedora | `/usr/bin/tmux` |
| Raspberry Pi (Debian) | `/usr/bin/tmux` |

Ghostty reloads config on `Ctrl+Shift+,` — no restart needed for most settings. The `command` setting requires a restart.

## LXDE Application Menu (Raspberry Pi)

The Ghostty build installs everything needed for LXDE automatically:

| File | Location | Purpose |
|------|----------|---------|
| Desktop entry | `~/.local/share/applications/com.mitchellh.ghostty.desktop` | Menu entry, categories, exec path |
| Icons | `~/.local/share/icons/hicolor/<size>/apps/com.mitchellh.ghostty.png` | Multiple sizes |

After a fresh build, refresh the menu:

```bash
update-desktop-database ~/.local/share/applications/
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor/
```

Then right-click the LXDE desktop → **Refresh Menu** (or log out and back in).

These files are generated by the Ghostty build process, not managed by GNU Stow — they will be recreated automatically each time you rebuild Ghostty.

## Clickable URLs

### Method 1 — Ghostty native (modifier + click)

| Platform | Gesture |
|----------|---------|
| macOS | `Cmd` + click |
| Linux (Fedora, Raspberry Pi) | `Ctrl` + click |

The modifier bypasses tmux's mouse capture. No config required.

### Method 2 — tmux-open (keyboard, copy mode)

The `tmux-plugins/tmux-open` plugin adds URL-opening keybindings inside tmux copy mode. Configured in `~/.tmux.conf`:

```
set -g @plugin 'tmux-plugins/tmux-open'
```

1. Enter copy mode: `prefix + v`
2. Move cursor over URL
3. Press `o` — opens in default browser
4. Press `Ctrl-o` — opens in `$EDITOR`
5. Press `S` — searches for selection on Google

After adding the plugin, install inside tmux: `prefix + I`.

## Troubleshooting

**`Unable to acquire an OpenGL context for rendering` on Pi**

Install the Vulkan driver if not already present:

```bash
sudo apt install mesa-vulkan-drivers
```

Then launch with:

```bash
MESA_LOADER_DRIVER_OVERRIDE=zink MESA_EGL_NO_X11=1 ghostty
```

The desktop entry already has these vars set — this only matters when launching from a shell directly.

---

**`ghostty: command not found` on Pi**

`~/.local/bin` is not on `$PATH`. Check that `~/.bash.d/02_core_path_env` is being sourced.

**Build fails: `unable to find dynamic system library 'gtk4-layer-shell-0'`**

```bash
sudo apt install libgtk4-layer-shell-dev
```

**Wrong Zig version**

Confirm version: `/usr/lib/zig/0.15.2/zig version`. Do not use `zig` or `zig-stable` packages — only `zig-0`.

---

**Clipboard not working when SSH'd to the Pi from Ghostty on Fedora**

See the **Clipboard (RPi5 over SSH)** section in the [tmux runbook](../tmux/RUNBOOK.md) for architecture details and troubleshooting.
