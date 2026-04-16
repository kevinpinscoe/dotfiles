# Desktop Setup

Public documentation for my **desktop and GUI environment** across:

- **Fedora Linux 42 KDE Plasma 6**
- **macOS Tahoe**
- **Debian Trixie on Raspberry Pi with LXDE**

This repo is separate from my CLI-oriented dotfiles.  
The focus here is on:

- desktop layout
- GUI applications
- desktop themes and appearance
- window behavior and shortcuts
- app configuration
- workstation rebuild notes
- screenshots and visual documentation

## Purpose

I wanted a public repo that documents how my desktop systems are actually put together beyond shell config.

Typical dotfiles repos usually cover:

- bash/zsh
- vim/neovim
- git
- tmux
- terminal tools

This repo is for the rest of the workstation:

- KDE Plasma settings
- LXDE settings
- macOS desktop and app setup
- VS Code
- Obsidian
- browser setup
- desktop utilities
- launchers, panels, widgets, and appearance
- fonts, themes, icons, wallpapers
- rebuild notes after reinstall or replacement hardware

## Systems Covered

### Fedora Linux

Primary Linux desktop:

- Fedora Linux 42
- KDE Plasma 6
- Wayland
- preferred editor: VS Code
- quick edits: Vim
- container preference: Docker over Podman

See: [`fedora-kde/`](./fedora-kde/)

### macOS

Work machine setup:

- macOS Tahoe
- GUI app setup and workstation notes
- editor: VS Code
- desktop productivity and app configuration

See: [`macos/`](./macos/)

### Raspberry Pi

Small-system desktop and utility setup:

- Raspberry Pi 5
- Debian Trixie
- LXDE desktop environment
- lightweight GUI and utility applications
- desktop and input-sharing related configuration
- practical notes for low-resource or appliance-style usage

See: [`raspberry-pi-lxde/`](./raspberry-pi-lxde/)

## Repo Layout

```text
desktop/
├── README.md
├── docs/
│   ├── screenshots/
│   ├── apps.md
│   ├── conventions.md
│   └── rebuild-checklist.md
├── fedora-kde/
│   ├── README.md
│   ├── packages/
│   ├── plasma/
│   ├── kwin/
│   ├── konsole/
│   ├── autostart/
│   ├── themes/
│   ├── fonts/
│   └── scripts/
├── macos/
│   ├── README.md
│   ├── brew/
│   ├── settings/
│   ├── apps/
│   └── scripts/
├── raspberry-pi-lxde/
│   ├── README.md
│   ├── packages/
│   ├── lxde/
│   ├── autostart/
│   ├── themes/
│   ├── wallpapers/
│   └── scripts/
└── shared/
    ├── vscode/
    ├── obsidian/
    ├── wallpapers/
    └── fonts/
