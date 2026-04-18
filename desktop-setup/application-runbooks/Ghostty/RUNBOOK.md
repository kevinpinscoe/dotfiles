# Runbook for Ghostty

[Ghostty](https://ghostty.org) is a GPU-accelerated terminal emulator. It is the standard terminal on all three platforms (macOS, Fedora, Raspberry Pi).

---

## Platform Install Methods

| Platform | Install method | Binary location |
|----------|---------------|-----------------|
| macOS | `brew install --cask ghostty` | `/Applications/Ghostty.app` |
| Fedora | `sudo dnf copr enable pgdev/ghostty && sudo dnf install ghostty` | `/usr/bin/ghostty` |
| Raspberry Pi 5 (Debian Trixie, aarch64) | Built from source — see below | `~/.local/bin/ghostty` |

---

## Raspberry Pi 5 — Build from Source

No official arm64 `.deb` exists. Ghostty must be built from source using Zig.

### Source

| Item | Value |
|------|-------|
| Ghostty version | 1.3.0 |
| Source tarball | `https://release.files.ghostty.org/1.3.0/ghostty-1.3.0.tar.gz` |
| Zig version required | 0.15.2 (Ghostty 1.3.x is pinned to a specific Zig version) |
| Zig package | `zig-0` from the [griffo.io community repo](https://debian.griffo.io) |
| Zig binary path | `/usr/lib/zig/0.15.2/zig` |
| Build date | 2026-04-18 |

### Build dependencies

Install all of these via `apt` before building:

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

`mesa-vulkan-drivers` is not a build dependency — it's a runtime requirement. Ghostty requires OpenGL 4.3, but the Pi 5's V3D GPU only exposes OpenGL 3.1 via Mesa's standard driver. The Vulkan driver enables Mesa's Zink backend (GL-over-Vulkan), which provides OpenGL 4.x. Without it, Ghostty fails at launch with "Unable to acquire an OpenGL context for rendering".

Install Zig 0.15.2 via the griffo.io repo:

```bash
curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc \
  | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
echo "deb https://debian.griffo.io/apt $(lsb_release -sc) main" \
  | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list
sudo apt update && sudo apt install -y zig-0
```

The `zig-stable` package in that repo is currently 0.16.0, which is too new for Ghostty 1.3.x. `zig-0` is the 0.15.2 package.

### Build steps

```bash
curl -L -o /tmp/ghostty-1.3.0.tar.gz \
  https://release.files.ghostty.org/1.3.0/ghostty-1.3.0.tar.gz
tar xzf /tmp/ghostty-1.3.0.tar.gz -C /tmp
cd /tmp/ghostty-1.3.0
/usr/lib/zig/0.15.2/zig build -Doptimize=ReleaseFast -p ~/.local
```

Binary is installed to `~/.local/bin/ghostty`. Ensure `~/.local/bin` is on your `$PATH` (it is via `~/.bash.d/02_core_path_env`).

Build takes approximately 5 minutes on a Raspberry Pi 5.

### Upgrading

To upgrade to a new Ghostty release:

1. Check the required Zig version at `https://ghostty.org/docs/install/build` — it may change between releases.
2. Download the new source tarball from `https://release.files.ghostty.org/<VERSION>/ghostty-<VERSION>.tar.gz`.
3. Re-run the build steps above. The `-p ~/.local` flag overwrites the existing binary in place.
4. **Re-apply the OpenGL fix to the desktop entry** — the build overwrites `~/.local/share/applications/com.mitchellh.ghostty.desktop`, losing the `MESA_LOADER_DRIVER_OVERRIDE=zink MESA_EGL_NO_X11=1` vars. Edit both `Exec` lines to prepend `env MESA_LOADER_DRIVER_OVERRIDE=zink MESA_EGL_NO_X11=1` after each rebuild. See the Troubleshooting section for why this is needed.

---

## Configuration

Ghostty config is managed via GNU Stow. The dotfiles package per platform:

| Platform | Stow package | Live path |
|----------|-------------|-----------|
| macOS | `ghostty-mac` | `~/.config/ghostty/config` |
| Fedora | `ghostty-fedora` | `~/.config/ghostty/config` |
| Debian/Pi | `ghostty-debian` | `~/.config/ghostty/config` |

`install.sh` selects the correct package automatically based on `/etc/os-release`.

The configs are identical in content today — they differ only in the `command` path if tmux locations ever diverge between platforms. Currently all three use `/usr/bin/tmux`.

Key config settings:

```
font-family = JetBrainsMono Nerd Font Mono
font-size = 13
copy-on-select = true
command = /usr/bin/tmux new-session -A -s main
```

`command` means every Ghostty window auto-attaches to (or creates) a persistent tmux session named `main`.

---

## LXDE Application Menu (Raspberry Pi)

The Ghostty build (`zig build -p ~/.local`) installs everything needed for LXDE automatically:

| File | Location | Purpose |
|------|----------|---------|
| Desktop entry | `~/.local/share/applications/com.mitchellh.ghostty.desktop` | Menu entry, categories, exec path |
| Icons | `~/.local/share/icons/hicolor/<size>/apps/com.mitchellh.ghostty.png` | Multiple sizes (16×16 through 1024×1024) |

The desktop entry uses `Categories=System;TerminalEmulator;` which places Ghostty under **System Tools** in the LXDE menu.

After a fresh build, refresh the menu so LXDE picks up the new entry:

```bash
update-desktop-database ~/.local/share/applications/
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor/
```

Then right-click the LXDE desktop → **Refresh Menu** (or log out and back in).

**Note:** These files are not managed by GNU Stow — they are generated by the Ghostty build process and live outside the dotfiles repo. They will be recreated automatically each time you rebuild Ghostty.

---

## Troubleshooting

**`Unable to acquire an OpenGL context for rendering` on Pi**
Ghostty requires OpenGL 4.3. The Pi 5's V3D GPU only exposes OpenGL 3.1 via Mesa's standard driver. The fix is to route OpenGL through Mesa's Zink driver (GL-over-Vulkan), which exposes GL 4.x on top of the Pi's Vulkan stack.

Install the Vulkan driver if not already present:
```bash
sudo apt install mesa-vulkan-drivers
```

Then launch with:
```bash
MESA_LOADER_DRIVER_OVERRIDE=zink MESA_EGL_NO_X11=1 ghostty
```

The desktop entry (`~/.local/share/applications/com.mitchellh.ghostty.desktop`) already has these vars set in its `Exec` line — this only matters if launching from a shell directly. Add both vars to `~/.bashrc` or a shell wrapper if needed.

---

**`ghostty: command not found` on Pi**
`~/.local/bin` is not on `$PATH`. Check that `~/.bash.d/02_core_path_env` is being sourced, or add `export PATH="$HOME/.local/bin:$PATH"` to `~/.bashrc`.

**Build fails: `unable to find dynamic system library 'gtk4-layer-shell-0'`**
Install the missing dev package: `sudo apt install libgtk4-layer-shell-dev`

**Wrong Zig version**
Running `zig build` with the wrong Zig will produce a cryptic compile error. Confirm version with `/usr/lib/zig/0.15.2/zig version` before building. Do not use the `zig` or `zig-stable` packages — only `zig-0`.
