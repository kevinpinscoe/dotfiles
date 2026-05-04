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
3. Clear the Gatekeeper quarantine attribute recursively (one-time):
   ```bash
   xattr -dr com.apple.quarantine /Applications/LibreWolf.app
   ```
4. **macOS Tahoe (26+) only:** re-sign the bundle ad-hoc to regenerate the `_CodeSignature` resource manifest. The DMG ships with an embedded adhoc signature on the binary but no bundle resource manifest, and Tahoe's stricter Gatekeeper refuses to launch it (`spctl` reports `code has no resources but signature indicates they must be present`):
   ```bash
   codesign --force --deep --sign - /Applications/LibreWolf.app
   ```
   After this, `codesign -dv` should report `Sealed Resources version=2`. `spctl` will still say `rejected` (adhoc is not notarized), but the app will launch normally.

### Update

LibreWolf has an in-app update notifier. When prompted, download the new `.dmg` from librewolf.net and replace `/Applications/LibreWolf.app`. Re-run **both** the `xattr -dr` and `codesign --force --deep` commands after replacing — in-app updates that overwrite the bundle will reintroduce the same problem.

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
