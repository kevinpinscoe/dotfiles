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

To keep those refs fresh, a background `git fetch --all` is triggered automatically whenever `.git/FETCH_HEAD` is older than 5 minutes. The fetch is fire-and-forget (`disown`ed) and does not block the prompt.

## gitme — quick git repo navigation

[`gitme`](https://github.com/davorg/gitme) is a shell function that lets you jump to any local git repo by name or remote URL.

### Installation (one-time per host)

```bash
git clone https://github.com/davorg/gitme.git ~/bin/gitme
```

- **bash hosts** (`30_bash_autocomplete`) source the upstream `~/bin/gitme/gitme` directly. If `~/bin/gitme/` doesn't exist the block silently no-ops.
- **zsh hosts** (`30_zsh_autocomplete`, Mac) define a zsh-native reimplementation of `gitme` and `_gitme_build_cache` inline. The upstream script uses `read -ra` and `shopt`, which are bash-only and fail at call time in zsh. Tab completion still sources `~/bin/gitme/gitme-completion.bash` under `bashcompinit`.

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
