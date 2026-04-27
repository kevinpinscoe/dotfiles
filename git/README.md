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

### pre-push — signed tag enforcement

**File:** `.config/git/hooks/pre-push`

Blocks pushes of `v*` tags that are not signed. Unsigned version tags are rejected with a message showing the sign command to run.
