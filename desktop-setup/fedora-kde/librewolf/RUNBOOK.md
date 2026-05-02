# LibreWolf

## Summary

LibreWolf is a privacy-focused, hardened fork of Firefox. It ships with uBlock Origin pre-installed, strips telemetry, enforces HTTPS-only mode, and applies a strict default security policy — all without requiring post-install configuration. It is not a Flatpak: it installs as a native RPM via the official LibreWolf DNF repository.

## Links

- [Main website](https://librewolf.net/)
- [Installation docs — Fedora](https://librewolf.net/installation/fedora/)
- [Installation docs — macOS](https://librewolf.net/installation/macos/)
- [Installation docs — Debian/Raspberry Pi](https://librewolf.net/installation/debian/)
- [Source / issue tracker](https://gitlab.com/librewolf-community/browser/linux)

## Operation

### Install (Fedora 41+)

```bash
# Add the official LibreWolf DNF repository
sudo dnf config-manager addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo

# Install — accept the OpenPGP key import when prompted
# Key ID: 0x2B12EF16
# Fingerprint: 662E 3CDD 6FE3 2900 2D0C A5BB 4033 9DD8 2B12 EF16
sudo dnf install librewolf
```

### Update

LibreWolf updates alongside the rest of the system:

```bash
sudo dnf upgrade librewolf
```

### Configuration files

| Path | Purpose |
|------|---------|
| `~/.librewolf/<profile>/` | Per-profile settings, extensions, bookmarks |
| `~/.librewolf/profiles.ini` | Profile list and default selection |

LibreWolf stores its profile data separately from Firefox (`~/.mozilla/firefox/`) so both browsers can coexist.

### Post-install notes

- uBlock Origin is bundled and enabled by default.
- The `librewolf.overrides.cfg` file (inside the app bundle) controls hardened defaults; user tweaks go in `about:config` as usual.
- The DNF repo auto-updates LibreWolf on every `dnf upgrade`; no manual repo refresh is needed.

## Troubleshooting

<!-- record issues and resolutions here -->
