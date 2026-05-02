# LibreWolf

## Summary

LibreWolf is a privacy-focused, hardened fork of Firefox. It ships with uBlock Origin pre-installed, strips telemetry, enforces HTTPS-only mode, and applies a strict default security policy — all without requiring post-install configuration.

## Links

- [Main website](https://librewolf.net/)
- [Installation docs — Debian/Raspberry Pi](https://librewolf.net/installation/debian/)
- [Source / issue tracker](https://gitlab.com/librewolf-community/browser/linux)

## Operation

### Install (Debian Trixie, ARM64 — Raspberry Pi 5)

Uses `extrepo` to add the official LibreWolf APT repository, then installs via `apt`.

```bash
sudo apt update
sudo apt install extrepo -y
sudo extrepo enable librewolf
sudo extrepo update librewolf
sudo apt update
sudo apt install librewolf -y
```

### Update

```bash
sudo apt update && sudo apt upgrade librewolf
```

### Configuration files

| Path | Purpose |
|------|---------|
| `~/.librewolf/<profile>/` | Per-profile settings, extensions, bookmarks |
| `~/.librewolf/profiles.ini` | Profile list and default selection |

### Post-install notes

- uBlock Origin is bundled and enabled by default.
- LibreWolf stores its profile data separately from Firefox (`~/.mozilla/firefox/`) so both browsers can coexist.
- The APT repo added by `extrepo` keeps LibreWolf up to date via `apt upgrade`.

## Troubleshooting

<!-- record issues and resolutions here -->
