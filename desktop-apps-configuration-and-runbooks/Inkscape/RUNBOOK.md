# Inkscape

## Operation

<!-- Personal usage notes go here -->

## Summary

Inkscape is a free, open-source vector graphics editor that uses SVG as its native format. It supports unlimited zoom, node editing, XML inspection, layers, and a wide range of export formats. Useful for creating, editing, and inspecting SVG files.

## Links

- [Main website](https://inkscape.org)
- [Download / release page](https://inkscape.org/release/)
- [Installation docs — Linux](https://inkscape.org/release/inkscape-1.x/linux/)
- [Source repo](https://gitlab.com/inkscape/inkscape)
- [Documentation / tutorials](https://inkscape.org/learn/)

## Install

### Fedora

Available in the standard Fedora repositories.

```bash
sudo dnf install inkscape
```

**Update:** `sudo dnf upgrade inkscape`

**Config locations:**

| Path | Purpose |
|------|---------|
| `~/.config/inkscape/` | User preferences, templates, symbols |

### macOS

```bash
brew install --cask inkscape
```

**Update:** `brew upgrade --cask inkscape`

**Config locations:**

| Path | Purpose |
|------|---------|
| `~/.config/inkscape/` | User preferences (Inkscape uses XDG paths even on macOS) |

### Raspberry Pi 5 (Debian Trixie, ARM64)

```bash
sudo apt update
sudo apt install inkscape
```

**Update:** `sudo apt update && sudo apt upgrade inkscape`

**Config locations:**

| Path | Purpose |
|------|---------|
| `~/.config/inkscape/` | User preferences, templates, symbols |

## Post-install Notes

- Open an SVG file directly: `inkscape /path/to/file.svg`
- Use **View → Zoom → Fit Drawing in Window** (`3`) or scroll-wheel zoom to navigate large files.
- The XML editor (**Edit → XML editor**, `Ctrl+Shift+X`) is useful for inspecting SVG structure.
- The **Layers and Objects** panel (`Object → Layers and Objects`) shows the full element tree.

## Troubleshooting

| Symptom | Likely Cause | Resolution |
|---------|-------------|------------|
| | | |
