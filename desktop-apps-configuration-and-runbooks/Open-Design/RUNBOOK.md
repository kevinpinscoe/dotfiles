# Open Design

## Operation

<!-- Personal usage notes go here -->

## Summary

Open Design is a local-first, open-source alternative to Anthropic's Claude Design. It pairs a Next.js web UI with a local Express daemon that spawns CLI coding agents (Claude Code, Codex, Gemini CLI, etc.) as the design engine. Give it a prompt and it generates web prototypes, mobile screens, slide decks, dashboards, and editorial pages — rendered live in a sandboxed iframe with HTML/PDF/PPTX/ZIP export. Ships with 129 design systems and 31 composable skills. Persists projects in a local SQLite database.

## Links

- [Source repo / main website](https://github.com/nexu-io/open-design)
- [Installation docs (QUICKSTART.md)](https://github.com/nexu-io/open-design/blob/main/QUICKSTART.md)

## Procedures

### Prerequisites

Open Design requires **Node.js 24** and **pnpm 10.33.x** (pinned via Corepack). Fedora 42 ships Node 22, so `fnm` is used to manage Node 24 alongside the system version.

**fnm is installed at `~/.local/bin/fnm` and initialized via `~/.bash.d/23_bashrc_fedora_fnm`** — this runs `eval "$(fnm env --use-on-cd)"` on shell startup so fnm-managed Node versions activate automatically when you enter a directory containing a `.node-version` file.

### Install steps

```bash
# 1. Install fnm (already done; documented for fresh machines)
gh release download --repo Schniz/fnm --pattern "fnm-linux.zip" --dir /tmp/fnm-dl
unzip /tmp/fnm-dl/fnm-linux.zip -d /tmp/fnm-dl
cp /tmp/fnm-dl/fnm ~/.local/bin/fnm && chmod +x ~/.local/bin/fnm

# 2. Install Node 24
fnm install 24

# 3. Clone the repo (3rd-party repo convention)
git clone https://github.com/nexu-io/open-design.git ~/Projects/3rd-party-repos/open-design

# 4. Enable Corepack and install dependencies
cd ~/Projects/3rd-party-repos/open-design
# fnm auto-switches to Node 24 via .node-version file in repo root
corepack enable
pnpm install

# 5. Build the daemon CLI (required for media generation and the `od` binary)
pnpm --filter @open-design/daemon build
```

### Starting the app

A wrapper script at `~/bin/open-design` handles Node 24 activation and cd automatically:

```bash
open-design              # start daemon + web in the foreground (default)
open-design start web    # start in the background
open-design status       # show running processes
open-design logs         # show daemon/web logs
open-design stop         # stop all processes
open-design restart      # restart all processes
open-design check        # status + logs + diagnostics
```

Any arguments are forwarded directly to `pnpm tools-dev`; no arguments defaults to `run web`.

Open the URL printed on startup (typically `http://localhost:3000`).

On first launch the app auto-detects Claude Code (or whichever agent CLI is on `PATH`). If no CLI is installed, configure a BYOK API key in **Settings → API Mode**.

### Manual startup (without the wrapper)

```bash
cd ~/Projects/3rd-party-repos/open-design
eval "$(~/.local/bin/fnm env)" && fnm use 24
pnpm tools-dev run web
```

### Configuration

| Location | Purpose |
|----------|---------|
| `.od/app.sqlite` (repo root) | SQLite database — projects, conversations, messages, tabs |
| `.od/artifacts/` (repo root) | Generated output files (HTML, PDF, ZIP) |
| Settings UI (in-app) | Agent selection, BYOK API keys, design system defaults |

No dotfile or `~/.config/` path; all runtime state stays inside the cloned repo directory.

### Updating

```bash
cd ~/Projects/3rd-party-repos/open-design
git pull
pnpm install
pnpm --filter @open-design/daemon build   # rebuild daemon after updates
```

## Troubleshooting

### Media generation fails: `OD_BIN: parameter not set` or daemon not reachable

The daemon CLI needs to be built and the managed runtime restarted:

```bash
cd ~/Projects/3rd-party-repos/open-design
pnpm --filter @open-design/daemon build
pnpm tools-dev restart --daemon-port 7457 --web-port 5175
ls -la apps/daemon/dist/cli.js
curl -s http://127.0.0.1:7457/api/health
```

Then reopen the project from the Open Design UI (do not resume an old terminal agent session).

### Node version not activating

Confirm `23_bashrc_fedora_fnm` is sourced and the `.node-version` file exists:

```bash
cat ~/Projects/3rd-party-repos/open-design/.node-version   # should print 24
fnm list                                                    # should show v24.x installed
node --version                                              # should print v24.x when inside repo dir
```

If `node --version` still shows v22, open a new shell (so `.bashrc` re-sources the fnm fragment) and `cd` back into the repo.
