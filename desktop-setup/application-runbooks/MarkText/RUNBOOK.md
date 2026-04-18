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

### Export themes

Mark Text also supports themes specifically for **exported** documents (PDF, HTML), separate from the editor UI theme. Three are built-in: Academic, GitHub, and Liber.

#### Install an export theme

Copy a `.css` file into the `themes/export/` directory inside the app data directory, then restart Mark Text:

| Platform | Export themes path |
|----------|--------------------|
| Fedora (native) | `~/.config/marktext/themes/export/` |
| Fedora (Flatpak) | `~/.var/app/com.github.marktext.marktext/config/marktext/themes/export/` |
| macOS | `~/Library/Application Support/marktext/themes/export/` |

#### Create an export theme

Export themes use the GitHub markdown style as a base (via [`github-markdown-css`](https://github.com/sindresorhus/github-markdown-css/blob/gh-pages/github-markdown.css)). A custom theme must override those styles to change things like font family or heading decoration.

The theme name is defined by a CSS comment on the first line:

```css
/** My Theme **/

.markdown-body {
  font-family: "IBM Plex Mono", monospace;
  background-color: #1e1e1e;
  color: #d4d4d4;
}
```

Reference examples from the Mark Text source:
- [academic.theme.css](https://github.com/marktext/marktext/blob/develop/src/renderer/assets/themes/export/academic.theme.css)
- [liber.theme.css](https://github.com/marktext/marktext/blob/develop/src/renderer/assets/themes/export/liber.theme.css)

#### Gruvbox Dark export theme

A ready-made Gruvbox Dark export theme is available at [kevinpinscoe/marktext-theme-gruvbox](https://github.com/kevinpinscoe/marktext-theme-gruvbox). Install it:

```bash
# Fedora (Flatpak) — curl from GitHub
curl -o ~/.var/app/com.github.marktext.marktext/config/marktext/themes/export/gruvbox.theme.css \
  https://raw.githubusercontent.com/kevinpinscoe/marktext-theme-gruvbox/main/gruvbox.theme.css
```

Or scp from a machine that has the repo cloned (e.g. from the Pi over Tailscale):

```bash
# scp from remote host
scp -i ~/.ssh/id_ed25519 \
  kinscoe@100.72.95.90:~/Projects/public/marktext-theme-gruvbox/gruvbox.theme.css \
  ~/.var/app/com.github.marktext.marktext/config/marktext/themes/export/

# scp to remote host
scp -i ~/.ssh/id_ed25519 \
  ~/.var/app/com.github.marktext.marktext/config/marktext/themes/export/gruvbox.theme.css \
  kinscoe@100.72.95.90:~/.var/app/com.github.marktext.marktext/config/marktext/themes/export/
```

Then restart Mark Text. The theme appears as **Gruvbox Dark** in the export dialog under **File → Export → Theme**.

### Theme limitations

Mark Text's custom theme support is minimal — there is no hot-reload, no theme packager, and no marketplace. If rich theming is a priority, consider **Typora** (paid, $15 one-time), which has a large community theme library at `theme.typora.io`.
