# Mark Text Runbook

Mark Text is an open-source markdown editor with live preview and distraction-free modes.

## Installation

### Fedora

Install via Flatpak (recommended):

```bash
flatpak install flathub com.github.marktext.marktext
```

Run:

```bash
flatpak run com.github.marktext.marktext
```

### macOS

Install via Homebrew:

```bash
brew install --cask mark-text
```

Or download the `.dmg` directly from the [Mark Text releases page](https://github.com/marktext/marktext/releases).

## Custom Themes

Mark Text ships with a small set of built-in themes and has no official theme library. Theming is done via custom CSS.

### Theme config location

| Platform | Path |
|----------|------|
| Fedora (native) | `~/.config/marktext/` |
| Fedora (Flatpak) | `~/.var/app/com.github.marktext.marktext/config/marktext/` |
| macOS | `~/Library/Application Support/marktext/` |

### Applying custom CSS

1. Open **Preferences → Theme**.
2. Select a built-in theme as your base (e.g. Dark).
3. Paste or link custom CSS in the **Custom CSS** field, or place a `.css` file in the themes directory above.

### Finding community themes

- Search GitHub for [`marktext theme`](https://github.com/search?q=marktext+theme) — individuals share themes as repos or gists.
- Search GitHub for [`marktext css`](https://github.com/search?q=marktext+css) for snippet-style overrides.

### Writing your own theme

Mark Text renders markdown as HTML inside an Electron shell. Target standard HTML elements in your CSS:

```css
/* Example dark theme overrides */
body {
  background-color: #1e1e1e;
  color: #d4d4d4;
  font-family: "IBM Plex Mono", monospace;
}

h1, h2, h3 { color: #569cd6; }
code { background-color: #2d2d2d; color: #ce9178; }
blockquote { border-left: 4px solid #569cd6; color: #9cdcfe; }
a { color: #4ec9b0; }
```

Use browser DevTools (Ctrl+Shift+I on Fedora, Cmd+Option+I on macOS) to inspect elements and iterate on styles live.

### Theme limitations

Mark Text's custom theme support is minimal — there is no hot-reload, no theme packager, and no marketplace. If rich theming is a priority, consider **Typora** (paid, $15 one-time), which has a large community theme library at `theme.typora.io`.
