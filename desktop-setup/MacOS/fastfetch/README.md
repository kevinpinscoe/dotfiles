# fastfetch (macOS)

Generates a PNG screenshot of `fastfetch` output for embedding in the main repo README, mirroring `desktop-setup/fedora-kde/fastfetch/`.

## Install dependencies

```bash
brew install fastfetch aha imagemagick
```

Google Chrome is also required (for headless screenshot rendering). If not installed:

```bash
brew install --cask google-chrome
```

The script expects Chrome at `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` (the default cask install location).

After installing, add `fastfetch`, `aha`, `imagemagick` entries to the repo's `Brewfile/Brewfile` by running:

```bash
brew bundle dump --file=~/.dotfiles/Brewfile/Brewfile --force
```

## Generate the logo image

```bash
bash ~/.dotfiles/desktop-setup/MacOS/fastfetch/fastfetch.sh
```

Writes `logo.png` into this directory. The main `README.md` can then reference it with:

```markdown
![Fastfetch logo](desktop-setup/MacOS/fastfetch/logo.png)
```

## How it works

1. `fastfetch --pipe false` → full color ANSI output.
2. `aha --black` → converts ANSI to an HTML document with a dark background.
3. `sed` injects a `<style>` block (font, padding, background) into the HTML `<head>`.
4. Headless Chrome renders the HTML and screenshots it to PNG.
5. ImageMagick trims whitespace and adds a 20px dark border for consistent framing.

## Customizing fastfetch output

fastfetch uses `~/.config/fastfetch/config.jsonc`. Generate a starter:

```bash
mkdir -p ~/.config/fastfetch
fastfetch --gen-config
```

Edit that file to pick the logo (ASCII art, image, or preset like `macos`), choose modules, and set colors. Re-run the script to regenerate `logo.png`.
