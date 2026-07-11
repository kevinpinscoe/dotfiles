# My cheat sheet system

Kevin uses this to remember command line commands via the [`cheat`](https://github.com/cheat/cheat) CLI.

## Finding a cheat sheet

```sh
cheat <command>        # show the cheat sheet for a command
cheat -l               # list all available cheat sheets
cheat -t flutter       # list sheets matching a tag
cheat -s "pub get"     # search cheat sheet content
```

Cheat reads from two locations:

| Location | Contents |
|---|---|
| `~/cheats/` (this repo, via stow) | Personal sheets maintained by Kevin |
| `~/.config/cheat/cheatsheets/community/` | Community-maintained sheets |

## Creating a new cheat sheet

1. Update `GENERATE-CHEAT.md` with the command details (name, docs URL, summary, template, tags).
2. Create the file using the template in `~/cheats/templates/` as a guide — or ask Claude to generate it.
3. Place the file in the correct subdirectory with **no file extension**:
   - `~/cheats/all/<command>` — cross-platform (Fedora + Raspberry Pi + Mac + Mac-container install sections)
   - `~/cheats/fedora/<command>` — Fedora-only
   - `~/cheats/mac/<command>` — macOS-only
   - `~/cheats/rpi/<command>` — Raspberry Pi / Debian-only
   - `~/cheats/mac-container/<command>` — Mac-container-only (Fedora Linux on ARM/aarch64)

> **Four hosts, four install sections.** A cross-platform (`all`) sheet now carries
> **four** install sections: Fedora, Raspberry Pi, Mac, and Mac-container. The
> Mac-container host (`b38e685e79b8`, a Fedora Docker container on the work Mac) runs
> Fedora Linux on **ARM (aarch64)**, not x86_64. It installs `dnf` packages exactly
> like the Fedora workstation, but any **direct binary download must fetch the
> `aarch64`/`arm64` build**, never the `x86_64`/`amd64` build.
4. Commit directly in `~/.dotfiles` (cheats are stowed — no copy step needed):
   ```sh
   git -C ~/.dotfiles add home/cheats/<dir>/<command>
   git -C ~/.dotfiles commit -m "Add cheat sheet for <command>"
   git -C ~/.dotfiles push
   ```
5. On other workstations: `git -C ~/.dotfiles pull` to get the new sheet.

> **Note:** `copy.sh` in `~/.dotfiles` only syncs VS Code settings — it does not touch cheat sheets.
> Cheats are live via stow symlinks; committing them to git is all that is needed.

## Cheat sheet format

Files use YAML front matter followed by commented shell examples:

```
---
syntax: sh
tags: [ tag1, tag2 ]
---
# Command mycommand

## What does this command do:
Short description.

## Installed from
For Fedora install using: ...

## Command path
For Fedora run: ~/.local/bin/mycommand

## Command documentation
Docs can be found at https://...

## Command options
# Usage examples with inline comments
mycommand --flag value
```

See `~/cheats/templates/` for the canonical `all.md` and `fedora.md` templates, and `~/cheats/all/argocd` or `~/cheats/fedora/linode-cli` for finished examples.

## Configuration

`cheat` is configured at `~/.config/cheat/conf.yml` (managed by stow via `~/.dotfiles/cheat/`).
