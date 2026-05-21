# LibreWolf

## Operation

<!-- Personal usage notes go here -->

## Summary

LibreWolf is a privacy-focused, hardened fork of Firefox. It ships with uBlock Origin pre-installed, strips telemetry, enforces HTTPS-only mode, and applies a strict default security policy — all without requiring post-install configuration.

## Links

- [Main website](https://librewolf.net/)
- [Installation docs — macOS](https://librewolf.net/installation/macos/)
- [Installation docs — Fedora](https://librewolf.net/installation/fedora/)
- [Installation docs — Debian/Raspberry Pi](https://librewolf.net/installation/debian/)
- [Source / issue tracker](https://gitlab.com/librewolf-community/browser/linux)

## Install

### macOS

The Homebrew cask `librewolf` was deprecated and **disabled on 2026-09-01** because LibreWolf does not notarize their macOS builds (they decline to pay Apple's Developer ID fee). Use the direct `.dmg` from librewolf.net instead.

1. Download the arm64 `.dmg` from <https://librewolf.net/installation/macos/>
2. Open the DMG and drag `LibreWolf.app` into `/Applications`
3. Clear the Gatekeeper quarantine attribute recursively (one-time):
   ```bash
   xattr -dr com.apple.quarantine /Applications/LibreWolf.app
   ```
4. **macOS Tahoe (26+) only:** re-sign the bundle ad-hoc to regenerate the `_CodeSignature` resource manifest:
   ```bash
   codesign --force --deep --sign - /Applications/LibreWolf.app
   ```
   After this, `codesign -dv` should report `Sealed Resources version=2`. `spctl` will still say `rejected` (adhoc is not notarized), but the app will launch normally.

**Update:** Download the new `.dmg` from librewolf.net and replace `/Applications/LibreWolf.app`. Re-run **both** the `xattr -dr` and `codesign --force --deep` commands after replacing.

**Config locations:**

| Path | Purpose |
|------|---------|
| `~/Library/Application Support/LibreWolf/<profile>/` | Per-profile settings, extensions, bookmarks |
| `~/Library/Application Support/LibreWolf/profiles.ini` | Profile list and default selection |

### Fedora

```bash
# Add the official LibreWolf DNF repository
sudo dnf config-manager addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo

# Install — accept the OpenPGP key import when prompted
# Key ID: 0x2B12EF16
# Fingerprint: 662E 3CDD 6FE3 2900 2D0C A5BB 4033 9DD8 2B12 EF16
sudo dnf install librewolf
```

Updates alongside the rest of the system: `sudo dnf upgrade librewolf`

The DNF repo auto-updates LibreWolf on every `dnf upgrade` — no manual refresh needed.

**Config locations:**

| Path | Purpose |
|------|---------|
| `~/.librewolf/<profile>/` | Per-profile settings, extensions, bookmarks |
| `~/.librewolf/profiles.ini` | Profile list and default selection |

### Raspberry Pi 5 (Debian Trixie, ARM64)

Uses `extrepo` to add the official LibreWolf APT repository, then installs via `apt`.

```bash
sudo apt update
sudo apt install extrepo -y
sudo extrepo enable librewolf
sudo extrepo update librewolf
sudo apt update
sudo apt install librewolf -y
```

**Update:** `sudo apt update && sudo apt upgrade librewolf`

The APT repo added by `extrepo` keeps LibreWolf up to date via `apt upgrade`.

**Config locations:**

| Path | Purpose |
|------|---------|
| `~/.librewolf/<profile>/` | Per-profile settings, extensions, bookmarks |
| `~/.librewolf/profiles.ini` | Profile list and default selection |

## Post-install Notes

- uBlock Origin is bundled and enabled by default on all platforms.
- LibreWolf stores its profile data separately from Firefox, so both browsers can coexist.

## Alternatives Considered (macOS)

- **`akdev1l/homebrew-apps` tap** — third-party tap that auto-clears quarantine via a launchd agent. Rejected: trades Homebrew's vetting for trust in a single maintainer.
- **`brew install --cask librewolf --no-quarantine`** — only worked while the cask existed in main Homebrew (pre-2026-09-01).

## Troubleshooting

### App refuses to launch on macOS Tahoe (26.x)

**Symptom:** Double-clicking `LibreWolf.app` does nothing, or Finder shows a Gatekeeper damaged/cannot-be-opened dialog. `spctl -a -vv /Applications/LibreWolf.app` reports:

```
code has no resources but signature indicates they must be present
```

and `ls /Applications/LibreWolf.app/Contents/_CodeSignature` returns no such file.

**Cause:** LibreWolf's macOS DMG ships the main Mach-O with an embedded adhoc signature but omits the bundle's `_CodeSignature/` resource manifest. Pre-Tahoe Gatekeeper tolerated this; Tahoe (macOS 26+) refuses to launch the bundle until the manifest exists.

**Fix:**

```bash
xattr -dr com.apple.quarantine /Applications/LibreWolf.app
codesign --force --deep --sign - /Applications/LibreWolf.app
open /Applications/LibreWolf.app
```

Verified working on macOS 26.4.1 (arm64) on 2026-05-04.
