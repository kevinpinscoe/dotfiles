# Anytype

## Operation

<!-- Personal usage notes go here -->

## Summary

Local-first, encrypted personal knowledge and workspace app. Closer to "private Notion with graph/object modeling" than to a plain Markdown vault. Supports notes, tasks, databases, kanban, calendars, custom object types, graph views, local storage, and peer-to-peer sync. Designed as a visual ideation and object-graph tool alongside Obsidian (which remains the canonical Markdown/Git store).

See also: `~/Projects/private/ideation/tools/anytype/` for usage guidance and self-hosting notes.

## Links

- Main site: <https://anytype.io/>
- FAQ: <https://anytype.io/faq/>
- Download: <https://download.anytype.io/>
- GitHub (desktop app): <https://github.com/anyproto/anytype-ts>
- GitHub (self-hosted sync): <https://github.com/anyproto/any-sync-dockercompose>
- Docs (self-hosting): <https://doc.anytype.io/anytype-docs/advanced/data-and-security/self-hosting>

## Install (Fedora — RPM)

Anytype ships an RPM via <https://download.anytype.io/> (or GitHub releases). No dnf repo is provided; install from the downloaded RPM each time.

```bash
# Download the latest RPM (check https://github.com/anyproto/anytype-ts/releases/latest for current version)
cd ~/Downloads
curl -sSfL "https://github.com/anyproto/anytype-ts/releases/download/v0.55.7-alpha/anytype-0.55.7-alpha.x86_64.rpm" \
  -o anytype-0.55.7-alpha.x86_64.rpm

# Install
sudo dnf install ./anytype-0.55.7-alpha.x86_64.rpm
```

**Installed version:** 0.55.7-alpha (2026-05-23)

### Post-install

- Launch from the KDE application menu (search "Anytype") or run `anytype` from a terminal.
- On first launch, save the Anytype recovery key somewhere safe (never commit it to Git).
- If Linux repeatedly prompts for the recovery key, install a desktop keychain (e.g., KWallet, which is already active on KDE Plasma).

## Upgrade

Download the new RPM from <https://github.com/anyproto/anytype-ts/releases/latest> and re-run:

```bash
sudo dnf install ./anytype-<version>.x86_64.rpm
```

`dnf` will detect the installed version and upgrade in place. App data under `~/.config/anytype` is unaffected.

## File Locations

| Purpose | Path |
|---------|------|
| App binary | `/usr/bin/anytype` (or similar — set by RPM) |
| App data / config | `~/.config/anytype/` |
| Recovery key | Store in a password manager — never in Git |

## Network Modes

| Mode | Notes |
|------|-------|
| Default Anytype Network | Local app + Anytype-provided sync/backup (1 GB file limit; Zurich/GCP) |
| Local-only | Single device, no sync |
| Self-hosted | Run `any-sync-dockercompose`, import `client.yml` into app — see GitHub link above |

Start with the Default Anytype Network for initial testing. Consider self-hosting later only if sync control is needed.

## Troubleshooting

<!-- Document issues and resolutions here as they arise -->
