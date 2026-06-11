# Cursor IDE Configuration

This document describes how Cursor is integrated with this dotfiles repository via GNU Stow.

## Overview

[Cursor](https://cursor.com/) is an AI-first code editor based on VS Code. This dotfiles setup manages Cursor's configuration across machines using GNU Stow, ensuring consistent settings and keybindings everywhere.

## Configuration Files Location

Cursor stores its configuration in:

**macOS:**
```
~/Library/Application Support/Cursor/User/
├── settings.json        # Editor settings, auto-save config, themes
├── keybindings.json     # Keyboard shortcuts
└── snippets/            # Code snippets (managed manually)
```

**Linux (if using):**
```
~/.config/Cursor/User/
├── settings.json
├── keybindings.json
└── snippets/
```

## Dotfiles Structure

Configuration is version-controlled in the dotfiles repo:

```
~/.dotfiles/cursor-professional/
└── Library/
    └── Application Support/
        └── Cursor/
            └── User/
                ├── settings.json
                └── keybindings.json
```

(Named `cursor-professional` to support future `cursor-personal` configs if needed, similar to how `vscode/` has `professional` and `personal` subdirectories.)

## Setup & Installation

### First Time Setup

1. Run the standard install script (which now includes Cursor):
   ```bash
   cd ~/.dotfiles
   ./install.sh
   ```

   This will:
   - Create `~/Library/Application Support/Cursor/User/` as a real directory
   - Symlink `settings.json` and `keybindings.json` from the dotfiles

2. Restart Cursor for settings to take effect

### After Each Update

When you update cursor config in dotfiles, re-run stow:
```bash
cd ~/.dotfiles
stow -d . -t $HOME --restow cursor-professional
```

Or simply re-run `install.sh`, which restows all packages including cursor-professional.

## Key Settings

### Auto-Save (Enabled)
```json
"files.autoSave": "afterDelay",
"files.autoSaveDelay": 100
```

Files auto-save 100ms after you stop typing. This was NOT enabled by default — it was added during dotfiles integration.

### Session Restoration
```json
"window.restoreWindows": "preserve",
"files.hotExit": "onExitAndWindowClose",
"workbench.editor.restoreViewState": true,
"workbench.startupEditor": "none"
```

Cursor remembers your open tabs and window layout when you close and reopen it.

### Word Wrap & Rulers

- Default: 70-character word wrap (matches markdown/commit message conventions)
- Applied to `plaintext`, `markdown`, and all other editor modes
- Ruler at column 70

### Other Customizations

- Theme: **Dank Neon**
- Editor font size: **16pt**
- Disable workspace trust prompts
- Disable extension update nagging
- Manual updates only

## Capturing Changes

If you modify settings in Cursor's UI, those changes are live in `~/Library/Application Support/Cursor/User/settings.json`. To persist them to dotfiles:

```bash
# Copy the live settings to the dotfiles version
cp ~/Library/Application\ Support/Cursor/User/settings.json \
   ~/.dotfiles/cursor/professional/Library/Application\ Support/Cursor/User/settings.json

# Verify changes
cd ~/.dotfiles
git diff

# Commit
git add cursor/
git commit -m "Update Cursor settings"
```

## Troubleshooting

### Settings Not Taking Effect

Cursor caches settings. If changes don't apply:
1. Fully quit Cursor (`Cmd+Q`)
2. Wait a few seconds
3. Reopen Cursor

### Symlinks Not Working

Verify stow correctly symlinked the files:
```bash
ls -la ~/Library/Application\ Support/Cursor/User/settings.json
```

Should show something like:
```
settings.json -> /Users/yourname/.dotfiles/cursor-professional/Library/Application Support/Cursor/User/settings.json
```

If it's a real file instead of a symlink, manually delete it and re-run stow:
```bash
rm ~/Library/Application\ Support/Cursor/User/settings.json
cd ~/.dotfiles && stow -d . -t $HOME --restow cursor-professional
```

### Cursor Won't Start

If `~/Library/Application Support/Cursor/User/` is entirely a symlink (not a real directory), Cursor may refuse to start. Fix this:
```bash
# Check if it's a symlink
ls -ld ~/Library/Application\ Support/Cursor/User/

# If it shows "-> ...", it's a symlink — delete it
[[ -L "$HOME/Library/Application Support/Cursor/User" ]] && \
  rm "$HOME/Library/Application Support/Cursor/User"

# Create as real directory and restow
mkdir -p "$HOME/Library/Application Support/Cursor/User"
cd ~/.dotfiles && stow -d . -t $HOME --restow cursor-professional
```

## Extensions

Cursor extensions are installed manually via the UI (`Cmd+Shift+X`). They are NOT version-controlled in dotfiles (extensions list changes frequently and has platform-specific dependencies).

To restore extensions on a new machine:
1. Install Cursor
2. Run `./install.sh` to restore settings
3. Manually install extensions you commonly use

## Differences from VS Code

While Cursor is based on VS Code, it's a separate application:

- **Config location**: `Cursor/` instead of `Code/`
- **Extensions**: Downloaded separately; not compatible between Cursor and VS Code
- **Keybindings**: Cursor adds AI-specific commands (e.g., `composerMode.agent`)
- **Settings**: Cursor adds AI features (inlay hints, composer mode)

If you use both editors, maintain separate config in dotfiles (VSCode via `restore.sh`, Cursor via stow).

## Further Reading

- [Cursor Docs](https://docs.cursor.com/)
- [VS Code Settings Reference](https://code.visualstudio.com/docs/getstarted/settings) (most settings work the same)
- [GNU Stow Documentation](https://www.gnu.org/software/stow/)
