# Fastfetch

## Operation

<!-- Personal usage notes go here -->

## Summary

Fastfetch is a system information tool similar to neofetch. The scripts in this directory generate a PNG screenshot of `fastfetch` output for embedding in README files.

## Platform Scripts

| Platform | Script |
|----------|--------|
| macOS | [mac/fastfetch.sh](mac/fastfetch.sh) |
| Fedora | [fedora/fastfetch.sh](fedora/fastfetch.sh) |
| Raspberry Pi 5 | [rpi5/fastfetch.sh](rpi5/fastfetch.sh) |

Generated logos: `<platform>/logo.png`

## Install

### macOS

```bash
brew install fastfetch aha imagemagick
# Google Chrome is also required (for headless screenshot rendering)
brew install --cask google-chrome
```

After installing, update the repo's Brewfile:

```bash
brew bundle dump --file=~/.dotfiles/Brewfile/Brewfile --force
```

### Fedora

```bash
sudo dnf install fastfetch
```

### Raspberry Pi 5

```bash
sudo apt install fastfetch
```

## Generating the Logo Image

```bash
# macOS
bash ~/.dotfiles/desktop-apps-configuration-and-runbooks/Fastfetch/mac/fastfetch.sh

# Fedora
bash ~/.dotfiles/desktop-apps-configuration-and-runbooks/Fastfetch/fedora/fastfetch.sh

# RPi5
bash ~/.dotfiles/desktop-apps-configuration-and-runbooks/Fastfetch/rpi5/fastfetch.sh
```

Each script writes `logo.png` into its own directory.

## How It Works (macOS)

1. `fastfetch --pipe false` → full color ANSI output.
2. `aha --black` → converts ANSI to an HTML document with a dark background.
3. `sed` injects a `<style>` block (font, padding, background) into the HTML `<head>`.
4. Headless Chrome renders the HTML and screenshots it to PNG.
5. ImageMagick trims whitespace and adds a 20px dark border for consistent framing.

## Customizing Fastfetch Output

```bash
mkdir -p ~/.config/fastfetch
fastfetch --gen-config
```

Edit `~/.config/fastfetch/config.jsonc` to pick the logo (ASCII art, image, or preset), choose modules, and set colors. Re-run the script to regenerate `logo.png`.
