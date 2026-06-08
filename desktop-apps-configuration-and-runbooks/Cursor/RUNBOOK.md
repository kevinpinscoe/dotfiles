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

Download the RPM from <https://cursor.com/downloads> and install with `dnf`:

```bash
curl -fL -o /tmp/cursor.rpm "https://api2.cursor.sh/updates/download/golden/linux-x64-rpm/cursor/3.7"
sudo dnf install /tmp/cursor.rpm
rm /tmp/cursor.rpm
```

To update later, re-download and reinstall the same way (`dnf install` handles upgrades).

### Raspberry Pi 5 (Debian Trixie, ARM64)

Download the ARM64 `.deb` from <https://cursor.com/downloads> and install with `apt`:

```bash
curl -fL -o /tmp/cursor.deb "https://api2.cursor.sh/updates/download/golden/linux-arm64-deb/cursor/3.7"
sudo apt install /tmp/cursor.deb
rm /tmp/cursor.deb
```

> Note: Replace `3.7` in the URL with the current version shown at <https://cursor.com/downloads>.

## Configuration

Cursor stores settings in the same locations as VS Code:

| Platform | Settings path |
|----------|--------------|
| macOS | `~/Library/Application Support/Cursor/User/` |
| Fedora | `~/.config/Cursor/User/` |
| Raspberry Pi 5 | `~/.config/Cursor/User/` |

## Cursor SDK

Cursor's SDK is now in public beta. Install it with `npm install @cursor/sdk`. You get the same runtime powering the desktop app: codebase indexing, semantic search, MCP servers, skills from `.cursor/skills/`, hooks, and subagent spawning. Run agents locally, in Cursor's cloud, or self-hosted. The API is built around durable agents and per-prompt runs with SSE streaming.

Teams are already using it to kick off agents from CI/CD (summarize changes, fix failures, update PRs), build internal apps that let non-developers query product data, and embed agent experiences inside customer-facing products.

If you're running Cursor as just an IDE, this changes the surface area. Start with one CI integration and expand from there.

## Troubleshooting

<!-- Record issues and resolutions here -->
