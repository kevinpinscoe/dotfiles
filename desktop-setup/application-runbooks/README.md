# Desktop Application Runbooks

Runbooks for GUI/desktop applications. Unlike containers, scripts, and CLI tools — which can carry colocated documentation — desktop apps have no natural place to store operational notes, so they live here instead.

## Structure

Each application has its own directory containing a `RUNBOOK.md` and any supporting reference files.

```
application-runbooks/
├── README.md
└── <AppName>/
    ├── RUNBOOK.md          ← procedures, tips, and troubleshooting
    └── <supporting files>
```

Runbooks are not platform-gated. An app directory is created regardless of whether the app runs on one platform or many — the runbook itself documents any platform-specific caveats.

## Current Runbooks

| Application | Runbook | Notes |
|-------------|---------|-------|
| git (gitsign) | [git/RUNBOOK.md](git/RUNBOOK.md) | Keyless commit/tag signing via Sigstore, hook setup, verification |
| Ghostty | [Ghostty/RUNBOOK.md](Ghostty/RUNBOOK.md) | Install (macOS/Fedora/Debian Pi), build from source, config |
| Mark Text | [MarkText/RUNBOOK.md](MarkText/RUNBOOK.md) | Install (Fedora/macOS), custom CSS theming |
| Obsidian | [Obsidian/RUNBOOK.md](Obsidian/RUNBOOK.md) | Spell-check dictionary management |
| tmux | [tmux/RUNBOOK.md](tmux/RUNBOOK.md) | tmux config, status bar, keybindings |
| Typora | [Typora/RUNBOOK.md](Typora/RUNBOOK.md) | Install (macOS/Fedora/Windows), licensing, themes (paid app) |
