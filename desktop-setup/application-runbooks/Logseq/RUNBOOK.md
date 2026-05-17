# Logseq

## Summary

Privacy-first, open-source outliner / knowledge base built on plain Markdown and Org-mode files. Supports bidirectional linking, daily journals, tasks, and a local graph database. Data stays on disk — no cloud sync required.

## Links

- Main site / source repo: <https://github.com/logseq/logseq>
- Releases (nightly + stable): <https://github.com/logseq/logseq/releases>

## Operation

### Install (Fedora — manual zip, nightly build)

Logseq ships as a self-contained Electron zip for Linux. No package manager integration.

```bash
# 1. Download the nightly zip
LOGSEQ_URL="https://github.com/logseq/logseq/releases/download/nightly/Logseq-linux-x86_64-<version>.zip"
curl -sSfL "$LOGSEQ_URL" -o /tmp/logseq-nightly.zip

# 2. Extract to install location
mkdir -p ~/.local/share/logseq
unzip -o /tmp/logseq-nightly.zip -d ~/.local/share/logseq/
chmod +x ~/.local/share/logseq/logseq

# 3. CLI wrapper
cat > ~/.local/bin/logseq <<'EOF'
#!/usr/bin/env bash
exec ~/.local/share/logseq/logseq "$@"
EOF
chmod +x ~/.local/bin/logseq

# 4. Icon
mkdir -p ~/.local/share/icons/hicolor/512x512/apps
curl -sSfL "https://raw.githubusercontent.com/logseq/logseq/master/resources/icons/logseq_big_sur.png" \
  -o ~/.local/share/icons/hicolor/512x512/apps/logseq.png

# 5. Desktop entry
cat > ~/.local/share/applications/logseq.desktop <<'EOF'
[Desktop Entry]
Name=Logseq
Comment=Privacy-first, open-source knowledge base
Exec=/home/kinscoe/.local/share/logseq/logseq %U
Icon=logseq
Type=Application
Categories=Office;TextEditor;
MimeType=x-scheme-handler/logseq;
StartupWMClass=Logseq
EOF
update-desktop-database ~/.local/share/applications/
xdg-mime default logseq.desktop x-scheme-handler/logseq
```

### Upgrade

Re-run steps 1–2 above with the new zip URL. The `~/.local/share/logseq/` directory is overwritten in place; settings and graph data are unaffected (stored separately under `~/.logseq/` and the user-chosen graph folder).

### File locations

| Purpose | Path |
|---------|------|
| App binary | `~/.local/share/logseq/logseq` |
| App data / config | `~/.logseq/` |
| Graph storage | User-chosen folder (set on first run) |
| CLI wrapper | `~/.local/bin/logseq` |
| Desktop entry | `~/.local/share/applications/logseq.desktop` |
| Icon | `~/.local/share/icons/hicolor/512x512/apps/logseq.png` |

### Sandbox note

Fedora 42 enables unprivileged user namespaces by default, so Electron's sandbox works without `--no-sandbox` or setuid on `chrome-sandbox`.

## Troubleshooting

<!-- Document issues and resolutions here as they arise -->
