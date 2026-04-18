# Typora Runbook

Typora is a minimalist Markdown editor with live rendering (no split preview — Markdown is rendered inline as you type). It is a **paid** application: $14.99 USD one-time purchase, covering up to 3 devices per license. A 15-day free trial is available on first launch.

## Installation

### macOS

Install via Homebrew (recommended):

```bash
brew install --cask typora
```

Or download the `.dmg` directly from [typora.io](https://typora.io/#download).

### Fedora

Typora provides an official RPM repository:

```bash
# Add the repository
sudo rpm --import https://typoraio.cn/linux/public-key.asc
sudo sh -c 'echo -e "[typora]\nname=Typora\nbaseurl=https://typoraio.cn/linux/dnf-repo/\nenabled=1\ngpgcheck=1" > /etc/yum.repos.d/typora.repo'

# Install
sudo dnf install typora
```

Alternatively, install via Flatpak (community-maintained, not official):

```bash
flatpak install flathub io.typora.Typora
```

### Windows

Download the installer from [typora.io](https://typora.io/#download), or install via winget:

```powershell
winget install --id Typora.Typora
```

## Licensing

1. Launch Typora — it starts a 15-day free trial automatically.
2. Purchase a license at [store.typora.io](https://store.typora.io/).
3. Enter the license via **Help → My License** (macOS: **Typora → My License**).
4. One license activates up to 3 devices. Deactivate a device from the same **My License** dialog before reaching the limit on a new machine.

## Config and theme paths

| Platform | Config directory | Themes directory |
|----------|------------------|------------------|
| macOS | `~/Library/Application Support/abnerworks.Typora/` | `~/Library/Application Support/abnerworks.Typora/themes/` |
| Fedora (native) | `~/.config/Typora/` | `~/.config/Typora/themes/` |
| Fedora (Flatpak) | `~/.var/app/io.typora.Typora/config/Typora/` | `~/.var/app/io.typora.Typora/config/Typora/themes/` |
| Windows | `%APPDATA%\Typora\` | `%APPDATA%\Typora\themes\` |

Open the themes directory quickly from the app: **File → Preferences → Appearance → Open Theme Folder**.

## Themes

Typora has a large community theme library at [theme.typora.io](https://theme.typora.io/).

### Installing a theme

1. Download the theme's `.css` file (and any sibling assets) from its page.
2. Place the files in the themes directory (see path table above).
3. Restart Typora, then choose the theme via **Themes** menu (or **File → Preferences → Appearance → Theme**).

### Writing a custom theme

Typora renders Markdown as HTML via an embedded Chromium engine. A theme is a single `.css` file — the filename becomes the theme's display name in the menu. Target `#write` and standard HTML elements:

```css
/* my-theme.css */
#write {
  max-width: 900px;
  font-family: "IBM Plex Mono", monospace;
  color: #d4d4d4;
  background-color: #1e1e1e;
}

h1, h2, h3 { color: #569cd6; }
code { background-color: #2d2d2d; color: #ce9178; }
blockquote { border-left: 4px solid #569cd6; }
```

See the [theme gallery source repos](https://github.com/typora) for reference implementations.

### Live CSS iteration

Enable developer tools via **Help → Toggle DevTools** (macOS: hold Option and click the Help menu) to inspect elements and tweak CSS live.

## Export

Typora exports to PDF, HTML, Word, LaTeX, EPUB, and more via **File → Export**. PDF export uses the current editor theme by default; pick a different theme first if you want the PDF styled differently.

For pandoc-based formats (Word, LaTeX, EPUB, etc.), install pandoc separately:

```bash
# macOS
brew install pandoc

# Fedora
sudo dnf install pandoc
```
