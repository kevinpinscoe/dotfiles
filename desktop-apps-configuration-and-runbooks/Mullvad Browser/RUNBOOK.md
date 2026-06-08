# Mullvad Browser

## Operation

<!-- Personal usage notes go here -->

## Summary

Mullvad Browser is a privacy-focused web browser developed in partnership with the Tor Project. It is based on Firefox ESR with Mullvad VPN's anti-fingerprinting hardening applied, designed to make all users look the same to tracking systems. It ships without a Mullvad VPN account requirement and works standalone.

## Links

- [Main website](https://mullvad.net/en/browser)
- [Release notes](https://mullvad.net/en/browser/changelog)
- [Source (GitHub)](https://github.com/mullvad/mullvad-browser)
- [Installation docs](https://mullvad.net/en/browser/download)

## Install

### macOS

Download the `.dmg` from <https://mullvad.net/en/browser/download>, open it, and drag `Mullvad Browser.app` into `/Applications`. Clear the Gatekeeper quarantine attribute:

```bash
xattr -dr com.apple.quarantine "/Applications/Mullvad Browser.app"
```

**Update:** Download the new `.dmg`, replace the app in `/Applications`, and re-run the `xattr` command above.

**Config location:**

```
~/Library/Application Support/MullvadBrowser/
```

### Fedora

Mullvad Browser is distributed as a tarball — there is no official RPM or DNF repository.

```bash
# Download and extract to ~/.local/opt
mkdir -p ~/.local/opt
cd /tmp
curl -fLO "https://mullvad.net/download/browser/linux/latest"
# Verify the signature per https://mullvad.net/en/help/verifying-signatures/
tar -xjf mullvad-browser-linux-*.tar.bz2 -C ~/.local/opt/
```

Launch via the included script or create a `.desktop` entry pointing to `~/.local/opt/mullvad-browser/start-mullvad-browser.desktop`.

**Update:** Delete the old extraction directory and re-run the steps above with the new tarball.

**Config location:**

```
~/.local/opt/mullvad-browser/Browser/TorBrowser/Data/Browser/profile.default/
```

### Raspberry Pi 5 (Debian Trixie, ARM64)

Same tarball install as Fedora — download the `linux-arm64` build:

```bash
mkdir -p ~/.local/opt
cd /tmp
curl -fLO "https://mullvad.net/download/browser/linux-arm64/latest"
tar -xjf mullvad-browser-linux-arm64-*.tar.bz2 -C ~/.local/opt/
```

**Update:** Delete the old extraction directory and re-run the steps above.

## Post-install Notes

- Mullvad Browser does not require a Mullvad VPN account to use; the fingerprinting resistance works independently of the VPN.
- Extensions should not be installed beyond what ships by default — additional extensions break the uniform fingerprint.

## Troubleshooting

<!-- Record issues and resolutions here as they occur -->
