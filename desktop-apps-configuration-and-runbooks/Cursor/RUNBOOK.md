# Cursor

## Operation

<!-- Personal usage notes go here -->

## Summary

Cursor is an AI-first code editor built on VS Code. It integrates AI assistance (chat, autocomplete, multi-file edits) directly into the editor workflow.

## Links

- [Main website](https://cursor.com)
- [Documentation](https://docs.cursor.com)
- [Changelog](https://cursor.com/changelog)

## Install

### macOS

Download the `.dmg` from <https://cursor.com/downloads> and drag `Cursor.app` to `/Applications`.

Or via Homebrew:

```bash
brew install --cask cursor
```

### Fedora

Download the `.AppImage` or `.deb` from <https://cursor.com/downloads>.

For the AppImage:

```bash
mkdir -p ~/.local/share/cursor
curl -fL -o ~/.local/share/cursor/cursor.AppImage "$(curl -s https://api.cursor.sh/updates/latest | jq -r '.linux.x64.url')"
chmod +x ~/.local/share/cursor/cursor.AppImage
ln -sf ~/.local/share/cursor/cursor.AppImage ~/.local/bin/cursor
```

## Configuration

Cursor stores settings in the same locations as VS Code:

| Platform | Settings path |
|----------|--------------|
| macOS | `~/Library/Application Support/Cursor/User/` |
| Fedora | `~/.config/Cursor/User/` |

## Troubleshooting

<!-- Record issues and resolutions here -->
