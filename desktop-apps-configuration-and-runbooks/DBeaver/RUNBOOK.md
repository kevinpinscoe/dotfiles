# DBeaver Community Edition

## Metadata

| Field | Value |
|---|---|
| **Owner** | kinscoe |
| **Last Updated** | 2026-05-25 |
| **Last Tested** | 2026-05-25 |
| **Expected Duration** | N/A (desktop application) |
| **Risk Level** | Low |
| **Repo** | `~/.dotfiles` |

---

## Summary

DBeaver Community Edition is a free, open-source universal database management tool. Supports PostgreSQL, MySQL, SQLite, MariaDB, and many other databases. Used as a desktop GUI database client.

---

## Links

- [DBeaver website](https://dbeaver.io/)
- [Flathub page](https://flathub.org/apps/io.dbeaver.DBeaverCommunity)
- [DBeaver Community source](https://github.com/dbeaver/dbeaver)
- [DBeaver documentation](https://dbeaver.com/docs/dbeaver/)

---

## Operation

### Personal usage notes

- Launch from app menu or: `flatpak run io.dbeaver.DBeaverCommunity`
- User data (connections, scripts, settings): `~/.var/app/io.dbeaver.DBeaverCommunity/`

---

## Fedora 42 KDE Plasma 6 (x86_64)

### Install

DBeaver Community is installed from Flathub as a system-wide Flatpak:

```bash
sudo flatpak install -y flathub io.dbeaver.DBeaverCommunity
```

Installed version: `26.0.5` (stable channel, system-wide).

### Update

```bash
sudo flatpak update io.dbeaver.DBeaverCommunity
```

Or update all Flatpaks:

```bash
sudo flatpak update
```

### Uninstall

```bash
sudo flatpak uninstall io.dbeaver.DBeaverCommunity
```

### Application ID

`io.dbeaver.DBeaverCommunity`

### Flatpak permissions

The Flatpak has access to:
- Home directory (file access)
- Network
- D-Bus: `org.freedesktop.FileManager1`, `org.freedesktop.Notifications`, `org.freedesktop.secrets`
- Wayland, X11, DRI, PulseAudio, SSH auth

---

## Troubleshooting

| Symptom | Likely Cause | Resolution |
|---|---|---|
| App won't launch | Flatpak runtime missing | `sudo flatpak update` to refresh runtimes |
| Can't connect to a database | Firewall or SELinux blocking | Check Flatpak network permission; try `flatpak override --user --talk-name=... io.dbeaver.DBeaverCommunity` |
| Settings not persisting | User data under `~/.var/app/` not writable | Check permissions on `~/.var/app/io.dbeaver.DBeaverCommunity/` |
