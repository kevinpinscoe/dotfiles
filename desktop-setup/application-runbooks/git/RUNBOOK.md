# Runbook for git (gitsign / Sigstore commit signing)

Commits and `vX.Y.Z` tags are signed with **gitsign** (keyless Sigstore signing via Google OIDC). Each signature is logged to Rekor (Sigstore's public transparency log) — no GPG key management required.

---

## Configuration

Signing settings are tracked in the `git` stow package and applied to all three platforms on `bash install.sh`.

| Setting | Value | File |
|---------|-------|------|
| `gpg.format` | `x509` | `git/.gitconfig` |
| `gpg.x509.program` | `gitsign` | `git/.gitconfig` |
| `commit.gpgsign` | `true` | `git/.gitconfig` |
| `tag.gpgsign` | `true` | `git/.gitconfig` |
| `gitsign.connectorID` | `https://accounts.google.com` | `git/.gitconfig` |
| `core.hooksPath` | `~/.config/git/hooks` | `git/.gitconfig` |

Global hooks (`pre-push`, `post-commit`) are tracked in `git/.config/git/hooks/` and symlinked by stow.

---

## Installing gitsign

gitsign is not in the stow package — install the binary separately on each host.

### Fedora / Raspberry Pi Debian

```bash
# Replace X.Y.Z with the latest release from https://github.com/sigstore/gitsign/releases
curl -sSfL https://github.com/sigstore/gitsign/releases/download/vX.Y.Z/gitsign_X.Y.Z_linux_amd64 \
  -o ~/.local/bin/gitsign && chmod +x ~/.local/bin/gitsign

# Raspberry Pi (ARM64):
curl -sSfL https://github.com/sigstore/gitsign/releases/download/vX.Y.Z/gitsign_X.Y.Z_linux_arm64 \
  -o ~/.local/bin/gitsign && chmod +x ~/.local/bin/gitsign
```

### macOS

```bash
brew install sigstore/tap/gitsign
```

### Verify install

```bash
gitsign version
```

---

## Signing workflow

### Commits

Signing is automatic — `commit.gpgsign = true` means every `git commit` triggers gitsign. On the first commit in a session, a browser window opens for Google OIDC auth.

```
[gitsign] commit signed OK    ← printed by the post-commit hook on success
```

### Tags

Tags are also signed automatically (`tag.gpgsign = true`):

```bash
git tag -a v1.2.3 -m "release message"
# Browser opens for OIDC auth if the certificate has expired (short-lived, ~10 min TTL)
```

---

## Verifying signatures

### Verify a commit

```bash
# Quick check — G?=U is expected (git doesn't hold Sigstore certs in its keyring)
git log -1 --format="%H %G? %GS"

# Full verification against Rekor
gitsign verify \
  --certificate-identity=kevin.inscoe@gmail.com \
  --certificate-oidc-issuer=https://accounts.google.com \
  HEAD
```

`%G? = U` ("unknown") is normal — git grades signatures against a local GPG keyring which has no entry for Sigstore certs. Use `gitsign verify` for authoritative verification.

### Verify a tag

```bash
gitsign verify \
  --certificate-identity=kevin.inscoe@gmail.com \
  --certificate-oidc-issuer=https://accounts.google.com \
  refs/tags/v1.2.3
```

Expected output:
```
Validated Git signature: true
Validated Rekor entry: true
Validated Certificate claims: true
```

---

## Global git hooks

| Hook | Trigger | Behaviour |
|------|---------|-----------|
| `post-commit` | After every commit | Prints `[gitsign] commit signed OK` if the commit is signed |
| `pre-push` | Before pushing | Blocks push of any unsigned `vX.Y.Z` tag |

### pre-push: sign a tag before pushing

If the pre-push hook blocks you:

```bash
# Re-sign (replace) the tag
git tag -s -f v1.2.3 -m "release message"
git push origin v1.2.3
```

---

## Smoke test (new host setup)

Run this after `bash install.sh` and installing gitsign on any new host.

```bash
mkdir /tmp/gitsign-test && cd /tmp/gitsign-test
git init && echo "test" > test.txt && git add .
git commit -m "gitsign smoke test"
# Expected: browser opens for Google OIDC auth
# Expected: "[gitsign] commit signed OK" printed by post-commit hook

# Check the commit signature
git log -1 --format="%H %G? %GS"
# Expected: <hash> U <empty> — U ("unknown") is normal, see note below

# Create and verify a signed tag
git tag -a v0.0.0-test -m "gitsign smoke test"
gitsign verify \
  --certificate-identity=kevin.inscoe@gmail.com \
  --certificate-oidc-issuer=https://accounts.google.com \
  refs/tags/v0.0.0-test
# Expected:
#   Validated Git signature: true
#   Validated Rekor entry: true
#   Validated Certificate claims: true

# Clean up
git tag -d v0.0.0-test
cd / && rm -rf /tmp/gitsign-test
```

> **Note on `%G? = U`:** git grades signatures against a local GPG keyring. Sigstore certs are never in that keyring, so git always returns `U` ("unknown"). This is expected — use `gitsign verify` for authoritative verification.

### Headless host (RPi without a browser)

If no browser is available, gitsign will print a URL instead of opening one. Open that URL on any other device, auth with `kevin.inscoe@gmail.com`, and the callback completes on the headless host. To force URL-only mode:

```bash
BROWSER=echo git commit -m "gitsign smoke test"
```

---

## Troubleshooting

### Browser does not open / OIDC flow hangs

gitsign spawns a local HTTP server to receive the OAuth callback. If the browser doesn't open automatically:

1. Check that `DISPLAY` or `WAYLAND_DISPLAY` is set (required on Fedora/Linux).
2. Run a test commit with verbose output:
   ```bash
   GITSIGN_LOG=/tmp/gitsign.log git commit --allow-empty -m "debug"
   cat /tmp/gitsign.log
   ```

### `gitsign: executable not found` on commit

gitsign must be on `PATH`. Check:

```bash
which gitsign
gitsign version
```

On Fedora/Raspberry Pi confirm `~/.local/bin` is in PATH (set in `bash/.bash.d/02_core_path_env` or `02_fedora_path_env`).

### Hooks not firing

```bash
git config --global core.hooksPath   # should return ~/.config/git/hooks
ls -la ~/.config/git/hooks/           # both files should be executable (x bit)
```

If hooks are missing after a fresh `git pull`:

```bash
cd ~/.dotfiles && bash install.sh
```

### Certificate expired mid-session

Sigstore certificates are short-lived (~10 minutes). If you get a certificate error mid-commit, just retry — gitsign will open the browser again for a fresh auth.
