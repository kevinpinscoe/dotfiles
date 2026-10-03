# git package

Global git configuration and hooks, stowed to `~/.config/git/` and `~/.gitconfig`.

`~/.gitconfig` sets `core.hooksPath = ~/.config/git/hooks` so every repo on this machine runs these hooks automatically — no per-repo setup needed.

## Hooks

### commit-msg — cspell spell check

**File:** `.config/git/hooks/commit-msg`

Runs `cspell` against the commit message before the commit is recorded. The commit is blocked if any misspellings are found.

```
git commit  →  commit-msg runs cspell on the message text  →  pass/fail
```

**How it works:**

1. Git passes the path to a temporary file containing the commit message as `$1`.
2. The hook runs `cspell --no-must-find-files --quiet "$1"`.
   - `--no-must-find-files` prevents an error if the file is empty or unrecognised.
   - `--quiet` suppresses progress output; only misspellings are printed.
3. A non-zero exit from cspell aborts the commit.

**Dependency: cspell**

See [`~/cheats/all/cspell`](../home/cheats/all/cspell) for full installation and usage reference.

| Platform | Install |
|----------|---------|
| Fedora | `npm install -g cspell` → lands at `~/.local/bin/cspell` |
| Raspberry Pi | install nvm → `nvm install 22` → `npm install -g cspell` |
| macOS | `brew install cspell` |

To bypass the hook for a single commit (use sparingly):

```bash
git commit --no-verify -m "message"
```

---

### post-commit — gitsign verification

**File:** `.config/git/hooks/post-commit`

After each commit, confirms the commit was signed by gitsign. Prints `[gitsign] commit signed OK` when the signature is present. Silent if `commit.gpgsign` is not enabled.

**Dependency: gitsign** — configured in `.gitconfig` (`gpg.format = x509`, `gpg.x509.program = gitsign`, `gitsign.connectorID` = Google OAuth).

---

### post-checkout — repo-local delegation

**File:** `.config/git/hooks/post-checkout`

Runs a repository's own `.githooks/post-checkout`, if it has an executable one — the same
delegation shape as `pre-commit` and `pre-push`. Git runs `post-checkout` after a branch
checkout, a clone, and `git worktree add` (inside the new worktree). In a repository without
`.githooks/post-checkout` it does nothing and prints nothing. It always exits 0: a
`post-checkout` status cannot undo a checkout, so a failing repo hook is reported on stderr and
not propagated.

**Why it exists:** the km-vault-lint vaults (`~/PCM`, `~/KnowledgeVault`) ship a
`.githooks/post-checkout` that installs a new worktree's local linter link
(<https://youtrack.kevininscoe.com/issue/KOA-22>). Without this delegator `core.hooksPath` makes
every repo hook unreachable, so that hook would never run.

**Existing behaviour preserved.** Before this file, no `post-checkout` ran on any host:
`core.hooksPath` bypasses `.git/hooks/`, and this directory had none. An inventory on the FLDW
(2026-10-03) found no `.githooks/post-checkout` and no `.git/hooks/post-checkout` under
`~/Projects` (excluding `3rd-party-repos/`), `~/web`, `~/sheets`, `~/KnowledgeVault`, `~/PCM`,
`~/ai`, `~/admin`, `~/tools`, `~/private-tools`, `~/.dotfiles`, `~/.claude/skills` or `~/Journal`.
Re-run it before activating on any host — a dormant repo hook would start running:

```bash
find ~/Projects ~/web ~/KnowledgeVault ~/PCM ~/ai ~/admin -maxdepth 5 \
  \( -path '*/3rd-party-repos' -o -path '*/ai-wt' -o -path '*/node_modules' \) -prune -o \
  -path '*/.githooks/post-checkout' -print
```

git-lfs's own `post-checkout` is deliberately **not** called (none ran before), so LFS
behaviour is unchanged.

**Activation** (per host, after the change is merged): `bash ~/.dotfiles/install.sh`, or just
`stow -d ~/.dotfiles -t ~ git`. Check with `ls -l ~/.config/git/hooks/post-checkout`.

**Rollback:** `rm ~/.config/git/hooks/post-checkout` takes effect at once on that host; revert
the commit here and re-stow to remove it everywhere.

---

### pre-push — signed tag enforcement

**File:** `.config/git/hooks/pre-push`

Blocks pushes of `v*` tags that are not signed. Unsigned version tags are rejected with a message showing the sign command to run.
