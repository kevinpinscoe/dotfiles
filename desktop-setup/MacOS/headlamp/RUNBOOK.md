# Headlamp

## Summary

Headlamp is an extensible, web-based UI for Kubernetes maintained by the Kubernetes SIG-UI community. The desktop build is an Electron app that lets you browse and operate on multiple clusters from kubeconfig contexts without running an in-cluster deployment.

## Links

- Project / source: https://github.com/kubernetes-sigs/headlamp
- Releases (download source for macOS DMG): https://github.com/kubernetes-sigs/headlamp/releases/latest
- Upstream installation docs: https://headlamp.dev/docs/latest/installation/desktop/
- Plugins catalog: https://headlamp.dev/docs/latest/development/plugins/

## Operation

The macOS desktop build is currently **not signed/notarized** by upstream. Homebrew is therefore not used on this host — Homebrew casks get auto-disabled when their cask signature expires under Gatekeeper. We install the DMG manually and clear the quarantine attribute, which is the workaround documented by the Headlamp project.

### Install (Apple Silicon)

```bash
# 1. Pick the latest tag
TAG=$(gh release list --repo kubernetes-sigs/headlamp --limit 20 \
        | awk '$1 !~ /helm/ && $1 ~ /^[0-9]/ {print $1; exit}')
VERSION="$TAG"

# 2. Download the arm64 DMG to ~/Downloads
curl -fL -o ~/Downloads/Headlamp-${VERSION}-mac-arm64.dmg \
  "https://github.com/kubernetes-sigs/headlamp/releases/download/v${VERSION}/Headlamp-${VERSION}-mac-arm64.dmg"

# 3. Mount, copy to /Applications, unmount
#    The mounted volume is named "Headlamp <version>-arm64" (e.g. "Headlamp 0.42.0-arm64").
hdiutil attach ~/Downloads/Headlamp-${VERSION}-mac-arm64.dmg -nobrowse -quiet
VOL=$(ls -d /Volumes/Headlamp* | head -n1)
cp -R "$VOL/Headlamp.app" /Applications/
hdiutil detach "$VOL" -quiet

# 4. Clear the Gatekeeper quarantine attribute so macOS will run it
xattr -dr com.apple.quarantine /Applications/Headlamp.app

# 5. Launch
open /Applications/Headlamp.app
```

For Intel Macs, swap `mac-arm64` → `mac-x64` in the URL.

### Config locations

- Application support dir: `~/Library/Application Support/Headlamp/`
- Plugin install dir: `~/Library/Application Support/Headlamp/plugins/`
- Logs: `~/Library/Logs/Headlamp/`
- Kubeconfig: Headlamp reads `~/.kube/config` by default; additional kubeconfig paths can be added inside the UI under Settings → Cluster.

### Update

Re-run the install steps above with the new `TAG`. Copying the new `Headlamp.app` over the existing one in `/Applications` keeps the user data under `~/Library/Application Support/Headlamp/` intact. Re-run `xattr -dr com.apple.quarantine /Applications/Headlamp.app` after every update — the quarantine flag is re-applied on freshly downloaded binaries.

### Uninstall

```bash
rm -rf /Applications/Headlamp.app
rm -rf ~/Library/Application\ Support/Headlamp
rm -rf ~/Library/Logs/Headlamp
```

## Troubleshooting
