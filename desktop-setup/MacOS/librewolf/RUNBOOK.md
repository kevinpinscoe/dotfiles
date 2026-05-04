# LibreWolf

## Summary

LibreWolf is a privacy-focused, hardened fork of Firefox. It ships with uBlock Origin pre-installed, strips telemetry, enforces HTTPS-only mode, and applies a strict default security policy — all without requiring post-install configuration.

## Links

- [Main website](https://librewolf.net/)
- [Installation docs — macOS](https://librewolf.net/installation/macos/)
- [Source / issue tracker](https://gitlab.com/librewolf-community/browser/linux)

## Install method on macOS

The Homebrew cask `librewolf` was deprecated and **disabled on 2026-09-01** because LibreWolf does not notarize their macOS builds (they decline to pay Apple's Developer ID fee), and Homebrew now drops casks that fail Gatekeeper. Use the direct `.dmg` from librewolf.net instead.

### Install (direct DMG)

1. Download the arm64 `.dmg` from <https://librewolf.net/installation/macos/>
2. Open the DMG and drag `LibreWolf.app` into `/Applications`
3. Clear the Gatekeeper quarantine attribute (one-time):
   ```bash
   xattr -d com.apple.quarantine /Applications/LibreWolf.app
   ```
   Or right-click the app → **Open** the first time and approve the warning.

### Update

LibreWolf has an in-app update notifier. When prompted, download the new `.dmg` from librewolf.net and replace `/Applications/LibreWolf.app`. Re-run the `xattr` command after replacing.

### Configuration files

| Path | Purpose |
|------|---------|
| `~/Library/Application Support/LibreWolf/<profile>/` | Per-profile settings, extensions, bookmarks |
| `~/Library/Application Support/LibreWolf/profiles.ini` | Profile list and default selection |

### Post-install notes

- uBlock Origin is bundled and enabled by default.
- LibreWolf stores its profile data separately from Firefox so both browsers can coexist.

## Alternatives considered

- **`akdev1l/homebrew-apps` tap** — third-party tap that keeps a `brew`-style workflow and reportedly auto-clears quarantine via a launchd agent. Rejected as primary path: trades Homebrew's vetting for trust in a single maintainer.
- **`brew install --cask librewolf --no-quarantine`** — only worked while the cask existed in main Homebrew (pre-2026-09-01). Homebrew has also flagged `--no-quarantine` itself as removable.

## Troubleshooting

<!-- record issues and resolutions here -->
