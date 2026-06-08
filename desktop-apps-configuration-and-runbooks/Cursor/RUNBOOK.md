# Cursor

> **This runbook covers two components of the Cursor ecosystem:**
>
> | Component | What it is | Runbook section |
> |-----------|-----------|-----------------|
> | **Desktop application** | AI-first code editor (GUI), built on VS Code | [Desktop Application](#desktop-application) |
> | **CLI (`agent`)** | Terminal agent for interactive use, scripting, and CI | [CLI — `agent`](#cli--agent) |
>
> Both are installed and used independently. The `agent` binary is installed separately from the desktop app — having one does not require the other.

---

## Operation

<!-- Personal usage notes go here -->

---

## Desktop Application

### Summary

Cursor is an AI-first code editor built on VS Code. It integrates AI assistance (chat, autocomplete, multi-file edits) directly into the editor workflow.

### Links

- [Main website](https://cursor.com)
- [Documentation](https://docs.cursor.com)
- [Downloads](https://cursor.com/downloads)
- [Changelog](https://cursor.com/changelog)

### Install

#### macOS

```bash
brew install --cask cursor
```

Or download the `.dmg` from <https://cursor.com/downloads> and drag `Cursor.app` to `/Applications`.

#### Fedora

```bash
curl -fL -o /tmp/cursor.rpm "https://api2.cursor.sh/updates/download/golden/linux-x64-rpm/cursor/3.7"
sudo dnf install /tmp/cursor.rpm
rm /tmp/cursor.rpm
```

To update later, re-download and reinstall the same way (`dnf install` handles upgrades).

> Note: Replace `3.7` in the URL with the current version shown at <https://cursor.com/downloads>.

#### Raspberry Pi 5 (Debian Trixie, ARM64)

```bash
curl -fL -o /tmp/cursor.deb "https://api2.cursor.sh/updates/download/golden/linux-arm64-deb/cursor/3.7"
sudo apt install /tmp/cursor.deb
rm /tmp/cursor.deb
```

> Note: Replace `3.7` in the URL with the current version shown at <https://cursor.com/downloads>.

### Configuration

Cursor stores settings in the same locations as VS Code:

| Platform | Settings path |
|----------|--------------|
| macOS | `~/Library/Application Support/Cursor/User/` |
| Fedora | `~/.config/Cursor/User/` |
| Raspberry Pi 5 | `~/.config/Cursor/User/` |

### Cursor SDK

Cursor's SDK is in public beta. Install it with `npm install @cursor/sdk`. It exposes the same runtime powering the desktop app: codebase indexing, semantic search, MCP servers, skills from `.cursor/skills/`, hooks, and subagent spawning. Agents can run locally, in Cursor's cloud, or self-hosted.

---

## CLI — `agent`

### Summary

Cursor CLI lets you interact with AI agents directly from your terminal to write, review, and modify code. Supports interactive terminal use and headless/print mode for scripts and CI pipelines.

### Links

- [CLI Documentation](https://cursor.com/docs/cli/installation)

### Install

All platforms use the same installer:

```bash
curl https://cursor.com/install -fsS | bash
```

**Expected output:**
```
✓ Detected linux/x64
✓ Directory created
✓ Package downloaded and extracted
✓ Package installed successfully
✓ Symlink created
✨ Installation Complete!
```

The installer places a symlink at `~/.local/bin/agent` pointing to the versioned binary under `~/.local/share/cursor-agent/versions/`.

Ensure `~/.local/bin` is on your `PATH`. Add to `~/.bashrc` / `~/.zshrc` if needed:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Verification

```bash
which agent
agent --version
```

**Expected output:**
```
~/.local/bin/agent
2026.06.04-5fd875e   # (version will vary)
```

### Update

```bash
agent update
```

The CLI manages its own versioning — this command fetches and switches to the latest release.

### Authentication

```bash
agent login     # opens browser for Cursor account auth
agent logout
agent status    # show current auth / whoami
agent about     # version, system, and account info
```

### Common usage

```bash
# Interactive session in current directory
agent

# Start with an initial prompt
agent "refactor this file to use async/await"

# Headless / CI mode — print response and exit
agent --print "explain this function"
agent -p "what does main.go do?"

# Plan mode (read-only, no edits)
agent --plan "design a new auth module"

# Continue or resume a session
agent --continue
agent --resume
```

---

## Troubleshooting

| Symptom | Likely Cause | Resolution |
|---------|-------------|------------|
| `agent: command not found` | `~/.local/bin` not on PATH | Add `export PATH="$HOME/.local/bin:$PATH"` to shell rc |
| Auth errors / 401 | Stale login token | `agent logout && agent login` |
| Desktop app won't launch on Fedora | SELinux or missing dependency | Check `journalctl -xe` and `ausearch -m avc -ts today` |
| CLI and desktop app show different versions | Installed independently | Update each separately: `agent update` for CLI, re-download RPM/deb for desktop |
