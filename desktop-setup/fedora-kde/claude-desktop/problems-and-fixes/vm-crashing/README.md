# VM Service Crashing on Startup

## Problem Statement

Claude Desktop launches, shows briefly, then enters a crash/reload loop with the error:

```
Failed to start Claude's workspace
VM service not running. The service failed to start.
Restarting Claude or your computer sometimes resolves this. If it persists, you can reinstall the workspace.
```

The app auto-reinstalls its workspace bundle and crashes again immediately. This happens on every launch.

## What Was Broken

Claude Desktop's workspace feature ("Cowork") relies on a local daemon process
(`cowork-vm-service.js`) running on a Unix domain socket at
`$XDG_RUNTIME_DIR/cowork-vm-service.sock` (e.g. `/run/user/1000/cowork-vm-service.sock`).

The app assumes this daemon is **already listening** when it tries to start the workspace.
The startup sequence is:

1. Download/prepare VM bundle
2. Copy `smol-bin.x64.vhdx` to bundle directory
3. Connect to socket → call `startVM` on the daemon
4. If socket not found after 5 retries (~5 s) → throw "VM service not running"

**The RPM package does not spawn this daemon anywhere.** The upstream launcher
(`/usr/bin/claude-desktop`) only cleans up orphaned daemons; it never starts one.
The Electron app itself also never spawns the daemon — it only connects to it.
The result: the socket never exists, every launch fails.

### Key log file

```
~/.config/Claude/logs/cowork_vm_node.log
```

The decisive entries look like:

```
[VM:start] Copying smol-bin.x64.vhdx to bundle (Linux)
[VM:start] smol-bin.x64.vhdx copied successfully
[VM:start] VM boot failed: VM service not running. The service failed to start.
```

And in `~/.cache/claude-desktop-debian/launcher.log`:

```
[vm-client] Event subscription error: connect ENOENT /run/user/1000/cowork-vm-service.sock
```

`ENOENT` confirms the socket was never created.

### Why a pre-started daemon also fails

Starting the daemon manually before launching Claude Desktop also fails because
`/usr/bin/claude-desktop` calls `cleanup_orphaned_cowork_daemon()` during startup,
which kills any `cowork-vm-service.js` process when no Claude Desktop UI is running yet.
The socket is then removed by `cleanup_stale_cowork_socket()` before Electron starts.

## Fix Applied

A wrapper script at `/usr/local/bin/claude-desktop` replaces the desktop entry's
`Exec=` target. It:

1. Sources the upstream launcher library (`launcher-common.sh`) and runs the same
   cleanup functions the real launcher runs.
2. **Starts the daemon** (`node cowork-vm-service.js &`) immediately after cleanup,
   so no prior daemon is running to be "orphaned".
3. Waits up to 5 seconds for the socket to appear.
4. Launches Electron (identical to what `/usr/bin/claude-desktop` does).
5. Kills the daemon when Electron exits (safety net; the app's own shutdown hook
   also sends SIGTERM).

Two desktop entry files must be updated to point to the wrapper:

```bash
# System entry (reset by package upgrades)
sudo sed -i 's|Exec=/usr/bin/claude-desktop|Exec=/usr/local/bin/claude-desktop|' \
    /usr/share/applications/claude-desktop.desktop

# KDE local copy (created when app is pinned to taskbar/desktop — NOT updated by upgrades)
sed -i 's|Exec=/usr/bin/claude-desktop|Exec=/usr/local/bin/claude-desktop|' \
    ~/.local/share/plasma_icons/claude-desktop.desktop 2>/dev/null || true
```

> **KDE gotcha:** When you pin the app to the taskbar or desktop, KDE snapshots the
> `.desktop` file into `~/.local/share/plasma_icons/claude-desktop.desktop`. That local
> copy is what actually gets executed when you click the icon, and it is never updated by
> package upgrades. Forgetting to update it is the most likely reason the fix stops working.

### Daemon details

| Property | Value |
|----------|-------|
| Script | `/usr/lib/claude-desktop/node_modules/electron/dist/resources/app.asar.unpacked/cowork-vm-service.js` |
| Socket | `$XDG_RUNTIME_DIR/cowork-vm-service.sock` |
| Backend (auto-detected) | `bwrap` (bubblewrap namespace sandbox) |
| Log | `~/.config/Claude/logs/cowork_vm_daemon.log` |

## Troubleshooting if It Returns

### 1. Confirm the wrapper is being used

```bash
which claude-desktop          # should be /usr/local/bin/claude-desktop

# Check BOTH desktop entry files — the KDE pinned icon uses the local copy
grep Exec= /usr/share/applications/claude-desktop.desktop
grep Exec= ~/.local/share/plasma_icons/claude-desktop.desktop 2>/dev/null
# Both should show: Exec=/usr/local/bin/claude-desktop %u
```

If either shows `/usr/bin/claude-desktop`, fix it:

```bash
sudo sed -i 's|Exec=/usr/bin/claude-desktop|Exec=/usr/local/bin/claude-desktop|' \
    /usr/share/applications/claude-desktop.desktop
sed -i 's|Exec=/usr/bin/claude-desktop|Exec=/usr/local/bin/claude-desktop|' \
    ~/.local/share/plasma_icons/claude-desktop.desktop 2>/dev/null || true
```

To confirm the wrapper is actually being invoked, check for its startup marker in the launcher log:

```bash
grep "with daemon" ~/.cache/claude-desktop-debian/launcher.log | tail -3
# If empty, the wrapper is not being called — check both Exec= paths above
```

### 2. Check the launcher log

```bash
tail -40 ~/.cache/claude-desktop-debian/launcher.log
```

Look for `Starting cowork-vm-service daemon...` and `Daemon socket ready`. If absent,
the wrapper script is not being called.

### 3. Check the daemon log

```bash
cat ~/.config/Claude/logs/cowork_vm_daemon.log
```

If empty, the daemon process is dying before it writes anything. Run it manually to
see the error:

```bash
node /usr/lib/claude-desktop/node_modules/electron/dist/resources/app.asar.unpacked/cowork-vm-service.js
```

### 4. Test the socket directly

```bash
# Is the socket present while Claude Desktop is running?
ls -la /run/user/1000/cowork-vm-service.sock

# Can you connect to it?
socat - UNIX-CONNECT:/run/user/1000/cowork-vm-service.sock
```

### 5. Run the built-in doctor

```bash
claude-desktop --doctor
```

All checks should pass. Pay attention to the `Cowork Mode` section — it lists
bubblewrap, KVM, and vsock status.

### 6. Check bubblewrap works

```bash
bwrap --ro-bind / / true; echo "exit: $?"
# Should print: exit: 0
```

If bubblewrap fails, SELinux may be blocking it:

```bash
sudo ausearch -c bwrap --raw | tail -20
sudo ausearch -c bwrap --raw | audit2allow -M claude-bwrap
sudo semodule -i claude-bwrap.pp
```

### 7. Force a specific backend

If bubblewrap is broken, force the host-direct backend (no isolation) as a diagnostic:

```bash
COWORK_VM_BACKEND=host claude-desktop
```

Or force KVM (requires `qemu-system-x86_64` and `/dev/vhost-vsock`):

```bash
COWORK_VM_BACKEND=kvm claude-desktop
```
