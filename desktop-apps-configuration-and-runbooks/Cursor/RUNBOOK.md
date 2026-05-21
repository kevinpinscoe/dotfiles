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

## Cursor SDK

Cursor's SDK is now in public beta. Install it with `npm install @cursor/sdk`. You get the same runtime powering the desktop app: codebase indexing, semantic search, MCP servers, skills from `.cursor/skills/`, hooks, and subagent spawning. Run agents locally, in Cursor's cloud, or self-hosted. The API is built around durable agents and per-prompt runs with SSE streaming.

Teams are already using it to kick off agents from CI/CD (summarize changes, fix failures, update PRs), build internal apps that let non-developers query product data, and embed agent experiences inside customer-facing products.

If you're running Cursor as just an IDE, this changes the surface area. Start with one CI integration and expand from there.

## Troubleshooting

<!-- Record issues and resolutions here -->
