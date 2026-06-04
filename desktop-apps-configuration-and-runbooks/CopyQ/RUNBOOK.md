# CopyQ

## Operation

<!-- Personal usage notes go here -->

## Summary

CopyQ is a clipboard manager with an advanced GUI and scripting support. It monitors the system clipboard and stores clipboard history, allowing retrieval of past entries, custom commands, and tab-based organization.

Used on macOS to restore clipboard history lost when tmux strips it, and to work around copy-on-select behavior between Ghostty, tmux, and the system clipboard.

## Links

- Main site: https://hluk.github.io/CopyQ/
- Source: https://github.com/hluk/CopyQ
- Releases: https://github.com/hluk/CopyQ/releases

## Install

| Platform | Install method | Binary location |
|----------|---------------|-----------------|
| macOS | DMG from GitHub releases — see below | `/Applications/CopyQ.app` |

**Do not install via Homebrew.** The `copyq` Homebrew cask is deprecated (scheduled removal 2026-09-01) and the binary is unsigned. On macOS 26+ it crashes immediately with `SIGKILL (Code Signature Invalid)` before the process can initialize.

### macOS — Install from GitHub DMG

The official GitHub releases are also ad-hoc signed (no Apple Developer certificate), so a local re-sign step is required after installation.

```bash
# 1. Download the ARM DMG (for Apple Silicon)
curl -L -o /tmp/CopyQ-<version>-macos-12-m1.dmg \
  https://github.com/hluk/CopyQ/releases/download/v<version>/CopyQ-<version>-macos-12-m1.dmg

# 2. Mount and install
hdiutil attach /tmp/CopyQ-<version>-macos-12-m1.dmg -nobrowse -quiet
cp -R "/Volumes/copyq-<version>-Darwin/CopyQ.app" /Applications/
hdiutil detach "/Volumes/copyq-<version>-Darwin" -quiet

# 3. Clear quarantine and locally re-sign
xattr -cr /Applications/CopyQ.app
codesign --force --deep --sign - /Applications/CopyQ.app

# 4. Clean up
rm /tmp/CopyQ-<version>-macos-12-m1.dmg
```

Replace `<version>` with the current release tag (e.g. `16.0.0`). Check https://github.com/hluk/CopyQ/releases/latest for the current version.

After install, re-grant Accessibility access — see **Accessibility Permission** below.

### Upgrading

1. Quit CopyQ.
2. Remove existing: `rm -rf /Applications/CopyQ.app`
3. Follow the install steps above with the new version.
4. Re-grant Accessibility access (macOS revokes it when the binary changes).

## CLI

CopyQ ships a `copyq` CLI that talks to the running daemon. It is available at `/Applications/CopyQ.app/Contents/MacOS/copyq` and symlinked to wherever your PATH picks it up after install.

### Quick reference

| Command | What it does |
|---------|-------------|
| `copyq count` | Number of items in history |
| `copyq read 0` | Print the most recent item (index 0 = newest) |
| `copyq read 0 1 2` | Print items at rows 0, 1, 2 |
| `copyq select 3` | Copy item at row 3 to the clipboard |
| `copyq add "text"` | Add text to history without affecting the live clipboard |
| `copyq remove 0` | Delete the most recent item |
| `copyq clipboard` | Print current clipboard contents |
| `copyq copy "text"` | Set clipboard to text |
| `copyq count` \| `copyq read` | Pipe-friendly: read from stdin with `-` |
| `copyq tab` | List all tabs |
| `copyq show` | Raise the CopyQ window |
| `copyq toggle` | Show or hide the main window |
| `copyq disable` / `copyq enable` | Pause / resume clipboard monitoring |
| `copyq exit` | Shut down the CopyQ daemon |
| `copyq config` | List all config options |
| `copyq config OPTION VALUE` | Set a config option |
| `copyq exporttab FILE` | Export a tab's history to a file |
| `copyq importtab FILE` | Import a tab's history from a file |

### Useful one-liners

```bash
# Print the last 10 clipboard entries with index numbers
for i in $(seq 0 9); do echo "[$i] $(copyq read $i | head -c 100)"; done

# Search history for a string (grep on all items)
copyq eval 'for(var i=0;i<size();i++) if(str(read(i)).match(/searchterm/)) print("["+i+"] "+str(read(i)).slice(0,80)+"\n")'

# Pipe clipboard history item 0 into a command
copyq read 0 | pbcopy   # re-copy to pasteboard (useful after a select)

# Set max history size (default 200)
copyq config maxitems 500

# Verify CopyQ is alive and capturing
TEST="verify-$(date +%s)"; printf '%s' "$TEST" | pbcopy; sleep 1; [ "$(copyq read 0)" = "$TEST" ] && echo OK || echo FAIL
```

### Script / eval mode

`copyq eval` runs JavaScript inside the CopyQ scripting engine, giving access to the full API:

```bash
copyq eval 'popup("Test", "CopyQ scripting works")'
copyq eval 'print(size())'   # same as copyq count
```

See the [CopyQ scripting docs](https://hluk.github.io/CopyQ/docs/scripting-api.html) for the full API.

## Configuration

CopyQ stores its configuration in `~/Library/Preferences/io.github.hluk.CopyQ.plist` and its clipboard history in `~/Library/Application Support/CopyQ/`. No GNU Stow management — settings live only on macOS.

## Accessibility Permission

CopyQ requires Accessibility access to monitor clipboard operations globally (including from other applications and tmux).

**Grant / re-grant after upgrade:**

System Settings → Privacy & Security → Accessibility → remove CopyQ if present → add `/Applications/CopyQ.app`

You must re-grant any time the binary changes (new install, upgrade, re-sign). macOS ties the Accessibility grant to the binary's code identity.

## Troubleshooting

**`CopyQ quit unexpectedly` popup on copy operations inside tmux**

Crash reason: `EXC_BAD_ACCESS (SIGKILL (Code Signature Invalid))` / termination namespace `CODESIGNING`, code 2 `Invalid Page`.

macOS kills the process at dyld load time because a code-signature page fails validation. This happens with the Homebrew-managed binary (unsigned, accessed via symlink chain under `/opt/homebrew/`).

Fix:

1. Uninstall Homebrew cask: `brew uninstall --cask copyq`
2. Install from the official GitHub DMG (see **Install** above).
3. Re-sign locally and clear quarantine (steps 3–4 in the install procedure).
4. Re-grant Accessibility access.

The local ad-hoc re-sign rebuilds the CDHash over the actual binary pages on your machine. macOS validates these pages at runtime — a fresh signature prevents the `Invalid Page` kill.

---

**`spctl --assess` rejects CopyQ**

Expected. `spctl` enforces Gatekeeper, which requires a valid Apple Developer certificate. CopyQ is ad-hoc signed only. macOS still runs ad-hoc-signed apps installed to `/Applications` with quarantine cleared — the `spctl` rejection is not the same as a runtime failure.

---

**Clipboard not captured from tmux copy-mode**

tmux has its own copy buffer separate from the macOS pasteboard. CopyQ monitors the macOS pasteboard; it does not see tmux's internal buffer unless the tmux config pipes selections to `pbcopy`.

Ensure `~/.tmux.conf` contains:

```
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
```

This sends tmux copy-mode selections to `pbcopy` (the macOS pasteboard), where CopyQ will pick them up.
