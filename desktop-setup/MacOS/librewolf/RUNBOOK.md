# LibreWolf

## Summary

LibreWolf is a privacy-focused, hardened fork of Firefox. It ships with uBlock Origin pre-installed, strips telemetry, enforces HTTPS-only mode, and applies a strict default security policy — all without requiring post-install configuration.

## Links

- [Main website](https://librewolf.net/)
- [Installation docs — macOS](https://librewolf.net/installation/macos/)
- [Source / issue tracker](https://gitlab.com/librewolf-community/browser/linux)

## Operation

### Install (macOS, Homebrew Cask)

```bash
brew install --cask librewolf
```

### Update

```bash
brew upgrade --cask librewolf
```

### Configuration files

| Path | Purpose |
|------|---------|
| `~/Library/Application Support/LibreWolf/<profile>/` | Per-profile settings, extensions, bookmarks |
| `~/Library/Application Support/LibreWolf/profiles.ini` | Profile list and default selection |

### Post-install notes

- uBlock Origin is bundled and enabled by default.
- LibreWolf stores its profile data separately from Firefox so both browsers can coexist.
- Homebrew Cask updates LibreWolf on `brew upgrade`; no manual steps needed.

## Troubleshooting

<!-- record issues and resolutions here -->
