---
title: ~/.bash.d Runbook
tags: [runbook, operations]
vault_link: runbooks/home-kinscoe-.dotfiles-bash-.bash.d.md
source_path: /home/kinscoe/.dotfiles/bash/.bash.d/RUNBOOK.md
---

> 📓 Indexed in the PKM knowledge vault at `runbooks/home-kinscoe-.dotfiles-bash-.bash.d.md` (symlink → this file).
# ~/.bash.d Runbook

## AI sync workflow (dotfiles)

When any file in `~/.bash.d/` is created, edited, or deleted, it must be synced into `~/.dotfiles/bash/.bash.d/` so the change is tracked in git.

After making changes in `~/.bash.d/`:

1. Run `~/.dotfiles/copy.sh` (it will prompt for `yes` confirmation, or pass `-y`) to sync the live files into the repo.
2. `cd ~/.dotfiles && git status && git diff` to review what changed.
3. Ask the user to confirm before committing. Only after explicit confirmation:
   - `git commit` with a message describing the change.
   - `git push origin` to publish.

Do not commit or push without an explicit user confirmation.

See `~/.dotfiles/CLAUDE.md` for the full dotfiles repo layout.


## Fedora-only aliases (`22_bashrc_fedora_aliases`)

| Alias | Command | Purpose |
|-------|---------|---------|
| `journal` | `~/AppImages/Obsidian.AppImage …` | Open Obsidian Personal Journal vault |
| `dlogin` | `docker login git.kevininscoe.com …` | Log in to self-hosted Gitea container registry |
| `km` | `cd $HOME/KnowledgeVault` | Jump to KnowledgeVault directory |
| `work` | `ssh acst@127.0.0.1` | SSH into the acst account on this machine |

---

## Reloading shell config (`reload`)

The `reload` function is defined in `~/.bash.d/20_bashrc_aliases`. Run it after editing any file in `~/.bash.d/` to load those changes into your current shell without opening a new terminal.

```
reload
```

### How it works

`reload` sources `~/.bash_profile`, which in turn sources `~/.bashrc`. The sourcing loop in `~/.bashrc` then re-reads every file in `~/.bash.d/`:

```
~/.bash_profile  →  ~/.bashrc  →  for file in ~/.bash.d/*
```

### File filtering rules (in `~/.bashrc`)

| Pattern | Behaviour |
|---------|-----------|
| `*_zsh_*` | Always skipped (zsh-only files) |
| `*.md` | Always skipped (documentation files) |
| `*mac*` | Only sourced when `$IS_MACOS == true` |
| everything else | Always sourced |



## mise activation (`03_mise`)

The file `~/.bash.d/03_mise` activates [mise](https://mise.jdx.dev/) in the current shell session. It runs after the `02_*` PATH fragments so that `mise` is already on `$PATH`, and `mise activate` prepends its shims directory to `$PATH` so mise-managed tool versions take precedence.

### What it does

Calls `mise activate bash` or `mise activate zsh` depending on the current shell. This makes mise shims the first thing searched on `$PATH`, ensuring repos with a `mise.toml` or `.tool-versions` file get the right tool versions automatically when you `cd` into them.

### Platform coverage

Sourced on all three platforms (Fedora, macOS, Raspberry Pi) in both bash and zsh — the filename has no platform marker. On macOS, `brew install mise` places the binary at `/opt/homebrew/bin/mise`; on Linux, it lands at `~/.local/bin/mise` via the curl installer. The fragment guards with `command -v mise` so hosts without mise installed silently no-op.

### Installation reminder

After cloning dotfiles on a new host, install mise separately — it is not bundled here:

```bash
# Linux (Fedora, Raspberry Pi)
curl https://mise.run | sh

# macOS
brew install mise
```


## cd override (`10_cd`)

The file `~/.bash.d/10_cd` defines a `cd()` shell function that wraps `builtin cd`.

### What it does

Every time you `cd` into a directory that is inside a git repo, it prints a single-line summary showing the current branch and your sync status relative to the remote:

```
git: main  |  PULL NEEDED — 1 commit(s) behind
```

Possible sync states:

- `up to date` — local matches remote tracking refs
- `PULL NEEDED — N commit(s) behind` — remote has commits you don't have locally
- `PUSH NEEDED — N commit(s) ahead` — you have commits not yet pushed
- `DIVERGED — N ahead, N behind (needs rebase or merge)` — both sides have diverged
- `(no upstream tracked)` — branch has no remote upstream configured

It also prints `.readme.txt` if one exists in the directory.

### How sync detection works

Ahead/behind counts are read from git's locally cached remote-tracking refs (e.g. `origin/main` in `.git/refs/remotes/`). This requires no network call and is instant.

To keep those refs fresh, a background `git fetch --all --no-write-fetch-head` is triggered automatically whenever the refs are older than 2 minutes. The fetch is fire-and-forget (`disown`ed) and does not block the prompt.

**Why `--no-write-fetch-head`, and why staleness is measured from a sentinel.** `git pull` is internally `git fetch` followed by `git merge FETCH_HEAD`. A backgrounded fetch that writes `FETCH_HEAD` at the same moment corrupts it mid-pull — the merge then aborts with `fatal: Cannot fast-forward to multiple branches` or `fatal: not something we can merge in .git/FETCH_HEAD`. This is not hypothetical: `cd <repo> && git pull --ff-only` failed **60/60** times in testing whenever the repo's refs were stale enough to trigger the auto-fetch. Dropping `--all` does **not** help — a plain backgrounded `git fetch` fails at the same rate. Only suppressing the `FETCH_HEAD` write fixes it (0/60 failures after).

Because nothing writes `FETCH_HEAD` in the background any more, its mtime is no longer a usable clock. Staleness is measured instead from a sentinel file, `<git-dir>/.cd-last-fetch`, touched **only after a successful fetch** — so an offline or failed refresh keeps reporting stale refs and the next `cd` retries rather than pretending they are fresh. On first use in a repo that predates the sentinel, the function falls back to `FETCH_HEAD`'s mtime so the repo is not misreported as "never fetched".

The git directory is resolved with `git rev-parse --git-common-dir`, not by assuming `<repo-root>/.git`: `.git` is a *file* in submodules and linked worktrees, and can live elsewhere entirely with a separate git directory. Using the *common* dir means every linked worktree shares one sentinel, matching the remote-tracking refs they already share.

On git older than 2.29 (no `--no-write-fetch-head`), the background fetch is **skipped entirely** rather than run unsafely. The banner still reports ahead/behind from cached refs; run `check-remote` to refresh on demand.

## gitme — quick git repo navigation

[`gitme`](https://github.com/davorg/gitme) is a shell function that lets you jump to any local git repo by name or remote URL.

### Installation (one-time per host)

```bash
git clone git@github.com:kevinpinscoe/gitme.git ~/Projects/public/gitme
```

- **bash hosts** (`30_bash_autocomplete`) source the upstream `~/Projects/public/gitme/gitme` directly. If `~/Projects/public/gitme/` doesn't exist the block silently no-ops.
- **zsh hosts** (`30_zsh_autocomplete`, Mac) define a zsh-native reimplementation of `gitme` and `_gitme_build_cache` inline. The upstream script uses `read -ra` and `shopt`, which are bash-only and fail at call time in zsh. Tab completion still sources `~/Projects/public/gitme/gitme-completion.bash` under `bashcompinit`.

### Configuration

`GITME_DIRS` is set per-platform:

- **Mac** — `01_bashrc_mac_env`: `export GITME_DIRS="$HOME"`
- **Fedora** — `01_bashrc_fedora_env` (gated on `/etc/fedora-release`): `export GITME_DIRS="$HOME:/opt/containers"`

`$HOME` covers repos scattered across many top-level directories (`tools`, `KnowledgeVault`, `.environment`, `ai`, `.dotfiles`, `skills`, `admin`, `Journal/Personal Journal`, `bookmarks/browser_bookmarks`, etc.). On Fedora, `/opt/containers` is added for the containers repo outside `$HOME`. gitme's `find` recurses from each base, so all roots are searched. The cache keeps searches fast; run `gitme --rebuild-cache` after cloning new repos.

### Usage

```bash
gitme my-project       # cd to the matching repo
gitme github.com/foo   # match by remote URL
gitme utils            # interactive picker if multiple matches
```

Matching is tiered by specificity: an exact repo-name match wins, then a
repo-name substring match, and only if neither matches does gitme fall back to
remote-URL substring matches. This keeps a term that appears in every repo's
remote (e.g. the `kevininscoe.com` Gitea host) from returning every repo —
`gitme kevininscoe.com` jumps straight to the repo named `kevininscoe.com`.

Tab completion lists repo names and remote URLs from the cache.

### Rebuilding the cache

The cache lives at `~/.gitme/cache` and is built automatically on first use. Rebuild it any time you clone new repos or move existing ones:

```bash
gitme --rebuild-cache
```

When to run it:
- After cloning a new repo anywhere under `$HOME`
- After moving or deleting a repo
- If tab completion stops showing a repo you expect

**Permission errors during rebuild** (`find: '...': Permission denied`) from `/opt/containers` are expected — gitme recurses into Gitea and OpenBAO data directories it can't read. These are benign; the cache still builds correctly and all accessible repos are indexed.

---

### Why `which cd` and `command -v cd` give different results

- `which cd` → `/usr/bin/cd` — `which` only searches `$PATH` executables, not shell functions
- `command -v cd` → `cd` — confirms the name resolves but doesn't distinguish function from builtin
- `type cd` → `cd is a function` — the correct way to see that a shell function is shadowing the builtin
