# Calibre

## Summary

Calibre is a free, open-source e-book management application. It handles library organization, format conversion (EPUB, MOBI, PDF, etc.), e-reader device syncing, and has a built-in e-book viewer and editor.

## Links

- [Main website](https://calibre-ebook.com/)
- [Linux install docs](https://calibre-ebook.com/download_linux)
- [Source repo](https://github.com/kovidgoyal/calibre)
- [User forum](https://www.mobileread.com/forums/forumdisplay.php?f=166)

## Operation

### Install (Fedora / Linux — official binary installer)

The official installer places Calibre under `/opt/calibre/` and creates `.desktop` entries for KDE/GNOME launchers.

```bash
sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
```

Running the same command again upgrades an existing install in-place.

**Config and library locations:**
- Library default: `~/Calibre Library/`
- Config dir: `~/.config/calibre/`
- Plugins dir: `~/.config/calibre/plugins/`

### Uninstall

```bash
sudo calibre-uninstall
```

### macOS

```bash
brew install --cask calibre
```

Or download the `.dmg` from <https://calibre-ebook.com/download_osx>.

### Raspberry Pi 5 (Debian Trixie, ARM64)

Use `apt` — the official installer fails on Debian Trixie with a `FileNotFoundError: tzdata/zoneinfo/EST5EDT not found` error. Modern `tzdata` dropped POSIX-style timezone names like `EST5EDT`, and Calibre's bundled Python can't find them.

```bash
sudo apt install calibre
```

The Trixie package is recent enough for normal use (8.5.0 as of 2026-05-11).

## Troubleshooting

### Official installer fails with `tzdata/zoneinfo/EST5EDT not found` (Debian Trixie)

Calibre's bundled Python tries to look up the POSIX timezone name `EST5EDT`, which modern `tzdata` no longer ships. The file `/usr/share/zoneinfo/EST5EDT` is absent on Trixie even when `tzdata` is installed and the system timezone is correctly set to `America/New_York`.

**Fix:** use `sudo apt install calibre` instead of the official installer.

