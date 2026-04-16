# Claude Desktop on Fedora KDE — Operational Runbook

## Installation

Claude Desktop does not publish an official Linux package. This setup uses the
community RPM maintained by [aaddrick](https://github.com/aaddrick/claude-desktop-debian).

### Add the repo and install

```bash
# Add the RPM repo
sudo curl -fsSL https://aaddrick.github.io/claude-desktop-debian/rpm/claude-desktop.repo \
  -o /etc/yum.repos.d/claude-desktop.repo

# Install
sudo dnf install claude-desktop
```

### After install: apply the wrapper fix

The RPM does not start the workspace daemon. Apply the wrapper immediately after
install (see [VM Crashing](problems-and-fixes/vm-crashing/README.md) for full
background):

```bash
# 1. Create the wrapper script
sudo tee /usr/local/bin/claude-desktop > /dev/null << 'LAUNCHEREOF'
#!/usr/bin/bash
source "/usr/lib/claude-desktop/launcher-common.sh"

if [[ "${1:-}" == '--doctor' ]]; then
    local_electron_path="/usr/lib/claude-desktop/node_modules/electron/dist/electron"
    run_doctor "$local_electron_path"
    exit $?
fi

setup_logging || exit 1
setup_electron_env
cleanup_orphaned_cowork_daemon
cleanup_stale_lock
cleanup_stale_cowork_socket

log_message '--- Claude Desktop Launcher Start (with daemon) ---'
log_message "Timestamp: $(date)"
log_message "Arguments: $*"

if ! check_display; then
    log_message 'No display detected (TTY session)'
    echo 'Error: Claude Desktop requires a graphical desktop environment.' >&2
    exit 1
fi

detect_display_backend
[[ $is_wayland == true ]] && log_message 'Wayland detected'

DAEMON_SCRIPT="/usr/lib/claude-desktop/node_modules/electron/dist/resources/app.asar.unpacked/cowork-vm-service.js"
SOCK_PATH="${XDG_RUNTIME_DIR:-/tmp}/cowork-vm-service.sock"

log_message "Starting cowork-vm-service daemon..."
node "$DAEMON_SCRIPT" &
_DAEMON_PID=$!
log_message "Daemon PID: $_DAEMON_PID"

for _i in $(seq 1 50); do
    [[ -S "$SOCK_PATH" ]] && break
    sleep 0.1
done

if [[ -S "$SOCK_PATH" ]]; then
    log_message "Daemon socket ready: $SOCK_PATH"
else
    log_message "Warning: daemon socket not ready after 5s, continuing anyway"
fi

electron_exec='electron'
local_electron_path="/usr/lib/claude-desktop/node_modules/electron/dist/electron"
if [[ -f $local_electron_path ]]; then
    electron_exec="$local_electron_path"
    log_message "Using local Electron: $electron_exec"
elif ! command -v electron &>/dev/null; then
    log_message 'Error: Electron executable not found'
    command -v zenity &>/dev/null && zenity --error \
        --text='Claude Desktop cannot start because the Electron framework is missing.'
    command -v kdialog &>/dev/null && kdialog --error \
        'Claude Desktop cannot start because the Electron framework is missing.'
    kill "$_DAEMON_PID" 2>/dev/null
    exit 1
fi

app_path="/usr/lib/claude-desktop/node_modules/electron/dist/resources/app.asar"
build_electron_args 'deb'
electron_args+=("$app_path")

app_dir="/usr/lib/claude-desktop"
log_message "Changing directory to $app_dir"
cd "$app_dir" || { log_message "Failed to cd to $app_dir"; kill "$_DAEMON_PID" 2>/dev/null; exit 1; }

log_message "Executing: $electron_exec ${electron_args[*]} $*"
"$electron_exec" "${electron_args[@]}" "$@" >> "$log_file" 2>&1
exit_code=$?

kill "$_DAEMON_PID" 2>/dev/null || true

log_message "Electron exited with code: $exit_code"
log_message '--- Claude Desktop Launcher End ---'
exit $exit_code
LAUNCHEREOF

sudo chmod +x /usr/local/bin/claude-desktop

# 2. Point the desktop entry at the wrapper
sudo sed -i 's|Exec=/usr/bin/claude-desktop|Exec=/usr/local/bin/claude-desktop|' \
    /usr/share/applications/claude-desktop.desktop

# 3. Fix the KDE taskbar/desktop pinned icon (KDE caches a local copy — must update separately)
sed -i 's|Exec=/usr/bin/claude-desktop|Exec=/usr/local/bin/claude-desktop|' \
    ~/.local/share/plasma_icons/claude-desktop.desktop 2>/dev/null || true

# 4. Verify both
grep Exec= /usr/share/applications/claude-desktop.desktop
grep Exec= ~/.local/share/plasma_icons/claude-desktop.desktop 2>/dev/null
# Both should show: Exec=/usr/local/bin/claude-desktop %u
```

> **KDE gotcha:** When you pin an app to the taskbar or desktop, KDE saves a local copy of
> the `.desktop` file at `~/.local/share/plasma_icons/claude-desktop.desktop`. This copy
> is used instead of the system entry and is **not** updated when the package upgrades.
> Always update both files.

---

## Upgrading

```bash
# Remove old install first (avoids file conflicts)
sudo dnf remove claude-desktop

# Install latest
sudo dnf install claude-desktop

# Re-apply the desktop entry fixes (upgrade resets the system entry)
sudo sed -i 's|Exec=/usr/bin/claude-desktop|Exec=/usr/local/bin/claude-desktop|' \
    /usr/share/applications/claude-desktop.desktop
sed -i 's|Exec=/usr/bin/claude-desktop|Exec=/usr/local/bin/claude-desktop|' \
    ~/.local/share/plasma_icons/claude-desktop.desktop 2>/dev/null || true

# The wrapper at /usr/local/bin/claude-desktop is not touched by the package
# and does not need to be recreated unless the upstream launcher API changes.
# Check the wrapper still works after a major version bump:
/usr/local/bin/claude-desktop --doctor
```

---

## Key File Locations

| File | Purpose |
|------|---------|
| `/usr/local/bin/claude-desktop` | Wrapper script (survives package upgrades) |
| `/usr/bin/claude-desktop` | Upstream launcher (overwritten on upgrade) |
| `/usr/lib/claude-desktop/launcher-common.sh` | Shared launcher functions |
| `/usr/lib/claude-desktop/node_modules/electron/dist/resources/app.asar.unpacked/cowork-vm-service.js` | Workspace daemon |
| `/usr/share/applications/claude-desktop.desktop` | Desktop entry (reset on upgrade) |
| `~/.config/Claude/claude_desktop_config.json` | MCP server configuration |
| `~/.config/Claude/logs/cowork_vm_node.log` | VM/workspace startup log |
| `~/.config/Claude/logs/cowork_vm_daemon.log` | Daemon log (written when debug enabled) |
| `~/.config/Claude/logs/main.log` | Main Electron process log |
| `~/.cache/claude-desktop-debian/launcher.log` | Launcher script log |
| `~/.config/Claude/vm_bundles/claudevm.bundle/` | Downloaded VM bundle (rootfs, kernel) |
| `/etc/yum.repos.d/claude-desktop.repo` | RPM repo definition |

---

## MCP Configuration

MCP servers are configured in `~/.config/Claude/claude_desktop_config.json`.

```json
{
  "mcpServers": {
    "example": {
      "command": "npx",
      "args": ["-y", "@example/mcp-server"]
    }
  }
}
```

---

## Useful Debug Commands

```bash
# Run the built-in diagnostics
claude-desktop --doctor

# Tail the workspace startup log in real time
tail -f ~/.config/Claude/logs/cowork_vm_node.log

# Tail the launcher log
tail -f ~/.cache/claude-desktop-debian/launcher.log

# Enable verbose daemon logging
COWORK_VM_DEBUG=1 claude-desktop

# Check if the daemon socket is alive
ls -la /run/user/1000/cowork-vm-service.sock

# Kill a stuck daemon manually
pkill -f cowork-vm-service

# Force a specific workspace backend
COWORK_VM_BACKEND=host claude-desktop   # no isolation
COWORK_VM_BACKEND=bwrap claude-desktop  # bubblewrap (default)
COWORK_VM_BACKEND=kvm claude-desktop    # full VM (needs qemu)
```

---

## Uninstall

```bash
sudo dnf remove claude-desktop
sudo rm -f /usr/local/bin/claude-desktop
sudo rm -f /etc/yum.repos.d/claude-desktop.repo

# Optional: remove config and logs
rm -rf ~/.config/Claude
rm -rf ~/.cache/claude-desktop-debian
```
