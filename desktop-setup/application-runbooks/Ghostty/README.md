# Ghostty

[Ghostty](https://ghostty.org) is a fast, feature-rich, GPU-accelerated terminal emulator that aims to be platform-native while supporting a single cross-platform config file. It is the standard terminal across all three machines in this setup.

- **Project:** https://ghostty.org
- **Source:** https://github.com/ghostty-org/ghostty
- **Documentation:** https://ghostty.org/docs
- **Config reference:** https://ghostty.org/docs/config

---

## How it fits into this setup

Ghostty is the entry point for all terminal work. Every Ghostty window immediately attaches to (or creates) a persistent [tmux](https://github.com/tmux/tmux) session named `main`. This means:

- Closing a Ghostty window does not kill your shell session — tmux keeps it alive.
- Reopening Ghostty drops you straight back into exactly where you left off.
- The tmux status bar at the bottom of every window shows git branch, AWS account, k8s cluster, working-on context, current directory, and time — always visible, never scrolling away.

The shell prompt (`PS1`) is intentionally minimal (`user@host $`) since all environment context lives in the tmux status bar instead.

---

## Config files in dotfiles

Ghostty's config is platform-specific because the tmux binary path differs between macOS (Homebrew) and Linux. There are three stow packages, one per platform:

```
~/.dotfiles/
├── ghostty-mac/
│   └── .config/ghostty/config       ← macOS (tmux via Homebrew)
├── ghostty-fedora/
│   └── .config/ghostty/config       ← Fedora Linux
└── ghostty-debian/
    └── .config/ghostty/config       ← Raspberry Pi (Debian Trixie, aarch64)
```

All three are stowed to the same live path: `~/.config/ghostty/config`

`install.sh` selects the correct package automatically by reading `/etc/os-release` on Linux or `uname -s` on macOS. You never need to pick the package manually.

---

## Config explained

```
font-family = JetBrainsMono Nerd Font Mono
font-size = 13

copy-on-select = true

command = /usr/bin/tmux new-session -A -s main
```

| Setting | Purpose |
|---------|---------|
| `font-family` | Nerd Font variant of JetBrains Mono — required for the tmux status bar icons |
| `font-size` | 13pt across all platforms |
| `copy-on-select` | Selected text is copied to clipboard immediately, no Cmd/Ctrl+C needed |
| `command` | Replaces the default shell with tmux on every new window. `-A` attaches to an existing session if one exists, `-s main` names the session `main` |

The `command` path differs per platform:

| Platform | tmux path |
|----------|-----------|
| macOS | `/opt/homebrew/bin/tmux` |
| Fedora | `/usr/bin/tmux` |
| Raspberry Pi (Debian) | `/usr/bin/tmux` |

---

## Editing the config

Because configs are managed via GNU Stow, the live file at `~/.config/ghostty/config` is a symlink into `~/.dotfiles`. Edit either path — they are the same file.

```bash
# Edit directly via the symlink (simplest)
$EDITOR ~/.config/ghostty/config

# Or edit in the repo
$EDITOR ~/.dotfiles/ghostty-debian/.config/ghostty/config  # adjust platform as needed
```

Ghostty reloads its config on `Ctrl+Shift+,` (or via the menu) — no restart needed for most settings. The `command` setting requires a restart to take effect.

---

## tmux integration

The tmux config lives separately at `~/.dotfiles/tmux/.tmux.conf` (stowed to `~/.tmux.conf`), and the status bar scripts at `~/.dotfiles/tmux/.config/tmux/status/`.

See the [tmux RUNBOOK](../../fedora-kde/RUNBOOK.md) for status bar details, or read the scripts directly in `~/.config/tmux/status/`.
