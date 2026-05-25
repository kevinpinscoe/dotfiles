# Signal Desktop

## Operation

<!-- Personal usage notes go here -->

## Summary

Signal Desktop is an end-to-end encrypted messaging app. On Fedora it runs as
a Flatpak (`org.signal.Signal`) from the Flathub stable channel.

## Links

- [signal.org](https://signal.org)
- [Flathub — org.signal.Signal](https://flathub.org/apps/org.signal.Signal)
- [Signal Desktop releases](https://github.com/signalapp/Signal-Desktop/releases)

## Install (Fedora — Flatpak)

```bash
flatpak install flathub org.signal.Signal
```

## Upgrade

Flatpak updates are applied automatically when the system-wide Flatpak update
runs, or manually:

```bash
flatpak update org.signal.Signal
```

## Uninstall

```bash
flatpak uninstall org.signal.Signal
# Remove leftover app data (optional):
rm -rf ~/.var/app/org.signal.Signal
```

## Launch

Launch from the KDE application menu or:

```bash
flatpak run org.signal.Signal
```

## Config / data location

```
~/.var/app/org.signal.Signal/     ← all app data (messages, attachments, prefs)
```

## Permissions

Signal's Flatpak manifest grants `filesystems=home`, giving it read/write
access to the entire home directory. Additional sandbox permissions:

```bash
flatpak info --show-permissions org.signal.Signal
```

---

## Troubleshooting

### File/image attachment locks up the app (Fedora — KDE Plasma 6)

**Symptom:** Clicking the attachment paperclip opens the KDE file picker, but
after selecting a file Signal freezes and the file is never attached. No crash
dialog appears.

**Root cause:** A race condition between Flatpak sandbox teardown and
`xdg-document-portal` cleanup causes the portal to exit with ENODEV (exit
code 21), leaving a stale FUSE mount at `/run/user/1000/doc`. Subsequent file
registrations time out waiting for the dead FUSE filesystem.

First observed 2026-05-15, triggered by Signal 8.10.0 replacing a running
Signal instance while it was actively in use.

**Confirm the diagnosis:**

```bash
journalctl --user -u xdg-desktop-portal.service -n 20 --no-pager | grep -i timeout
# Expected when broken:
#   Failed to register file:///home/kinscoe/Downloads/...: Timeout was reached

findmnt /run/user/1000/doc
# Stale mount shows: user_id=0,group_id=0
# Healthy mount shows: user_id=1000,group_id=1000
```

**Fix — restart portals and clear stale mount:**

```bash
systemctl --user stop xdg-document-portal.service xdg-desktop-portal.service
sudo umount /run/user/1000/doc
# Services socket-activate back up within a few seconds automatically
systemctl --user is-active xdg-document-portal.service xdg-desktop-portal.service
findmnt /run/user/1000/doc   # must show user_id=1000,group_id=1000
```

**Permanent prevention:** A systemd user drop-in automatically lazy-unmounts
any stale FUSE mount before the portal starts on every restart:

```
~/.config/systemd/user/xdg-document-portal.service.d/fix-stale-fuse.conf
```

```ini
[Service]
ExecStartPre=-/usr/bin/umount -l /run/user/%U/doc
```

Install the drop-in:

```bash
mkdir -p ~/.config/systemd/user/xdg-document-portal.service.d
# Write the file as shown above, then:
systemctl --user daemon-reload
# Verify:
systemctl --user show xdg-document-portal.service --property=ExecStartPre
# Must show: ignore_errors=yes
```

Full runbook: `~/admin/portal-fuse-fix/RUNBOOK.md`
