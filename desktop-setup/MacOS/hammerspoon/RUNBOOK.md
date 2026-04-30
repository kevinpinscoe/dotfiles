# Hammerspoon

## Summary

Hammerspoon is a powerful macOS automation tool. It exposes the operating system to a Lua scripting engine, letting you bind keys, manipulate windows, react to system events (Wi-Fi changes, screen reconfiguration, USB attach, etc.), and script almost any desktop workflow from `~/.hammerspoon/init.lua`.

## Links

- Main website: https://www.hammerspoon.org/
- Installation docs: https://www.hammerspoon.org/ (the front page is the install doc)
- Releases (download artifact): https://github.com/Hammerspoon/hammerspoon/releases/latest
- Source repo: https://github.com/Hammerspoon/hammerspoon
- Getting Started guide: https://www.hammerspoon.org/go/
- API reference: https://www.hammerspoon.org/docs/

## Operation

### Install

Vendor download from GitHub releases — the only method shown by the project.

1. Open https://github.com/Hammerspoon/hammerspoon/releases/latest in a browser.
2. Download `Hammerspoon-<version>.zip`.
3. Unzip the archive (Finder usually does this automatically on download).
4. Drag `Hammerspoon.app` into `/Applications/`.
5. Launch `Hammerspoon.app` from `/Applications/`.

Equivalent from a terminal (replace `<version>` with the current release tag, e.g. `1.0.0`):

```bash
cd ~/Downloads
curl -L -o Hammerspoon.zip https://github.com/Hammerspoon/hammerspoon/releases/latest/download/Hammerspoon-<version>.zip
unzip Hammerspoon.zip
mv Hammerspoon.app /Applications/
open /Applications/Hammerspoon.app
```

### Configuration

- Config directory: `~/.hammerspoon/`
- Main entry point: `~/.hammerspoon/init.lua` (Lua; you create this — Hammerspoon does not generate one).
- Spoons (reusable plugins) live in `~/.hammerspoon/Spoons/<Name>.spoon/`.
- Hammerspoon watches `init.lua` and offers to auto-reload on save (configurable via the menu-bar icon).

`init.lua` is managed by this dotfiles repo via the `hammerspoon` stow package
(macOS only). The real file is `~/.dotfiles/hammerspoon/.hammerspoon/init.lua`;
`~/.hammerspoon/init.lua` is a symlink to it after `bash install.sh`. Edit
either path — both point at the same file. `~/.hammerspoon/Spoons/` is left as
a real directory so Hammerspoon's Spoon installer can write to it; Spoons are
not tracked in the repo.

Minimal `init.lua` to verify the install works:

```lua
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
  hs.alert.show("Hello from Hammerspoon")
end)
```

Reload from the menu-bar icon → `Reload Config`, then press `⌘⌥⌃H`.

### Post-install setup

1. **Accessibility permissions.** On first launch macOS prompts for Accessibility access. Approve via *System Settings → Privacy & Security → Accessibility* and toggle Hammerspoon on. Without this, hotkeys, window manipulation, and most APIs will silently fail.
2. **Optional permissions** prompted on demand the first time a script uses them: Automation (per-target app), Screen Recording (for `hs.screen` / `hs.window.snapshot`), Input Monitoring (for `hs.eventtap`), Microphone, Camera, Notifications, Full Disk Access. Approve in the same Privacy & Security pane.
3. **Launch at login** (optional): menu-bar icon → `Preferences…` → check *Launch Hammerspoon at login*.
4. **Auto-reload config** (optional): same Preferences pane → check *Automatically reload config when files change*.

### Updating

Hammerspoon has a built-in updater (Sparkle). It checks on launch and via menu-bar icon → `Check for Updates…`. To do it manually, repeat the install steps with the newer release.

### Uninstall

```bash
rm -rf /Applications/Hammerspoon.app
rm -rf ~/.hammerspoon
defaults delete org.hammerspoon.Hammerspoon 2>/dev/null || true
```

Then remove Hammerspoon from *System Settings → Privacy & Security → Accessibility* (and any other Privacy panes where it was granted).

## Troubleshooting
