# ~/.bash.d Runbook

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

### Why `which cd` and `command -v cd` give different results

- `which cd` → `/usr/bin/cd` — `which` only searches `$PATH` executables, not shell functions
- `command -v cd` → `cd` — confirms the name resolves but doesn't distinguish function from builtin
- `type cd` → `cd is a function` — the correct way to see that a shell function is shadowing the builtin
