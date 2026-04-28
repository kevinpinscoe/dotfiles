# Runbook for Terragrunt

[Terragrunt](https://terragrunt.gruntwork.io) is a flexible orchestration tool for Infrastructure as Code written in OpenTofu/Terraform. It adds dependency management, remote state configuration, DRY includes, and multi-module `run-all` execution on top of OpenTofu/Terraform.

---

## Platform Install Methods

| Platform | Install method | Binary location |
|----------|---------------|-----------------|
| Fedora | `curl` — download raw binary to `~/.local/bin/` | `~/.local/bin/terragrunt` |
| macOS (Apple Silicon) | `brew install terragrunt` | `/opt/homebrew/bin/terragrunt` |
| Raspberry Pi 5 (Debian Trixie, aarch64) | `curl` — download raw binary to `~/.local/bin/` | `~/.local/bin/terragrunt` |

---

## Upgrading

Terragrunt ships single-file binaries on GitHub Releases. Upgrading is a direct binary replacement.

### Step 1 — Find the latest version

```bash
curl -sSf https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest \
  | grep '"tag_name"'
```

### Step 2 — Download and replace

**Fedora (linux_amd64):**

```bash
VERSION=vX.X.X   # replace with version from step 1
curl -sSfL "https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_amd64" \
  -o ~/.local/bin/terragrunt && chmod +x ~/.local/bin/terragrunt
```

**Raspberry Pi 5 (linux_arm64):**

```bash
VERSION=vX.X.X   # replace with version from step 1
curl -sSfL "https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_arm64" \
  -o ~/.local/bin/terragrunt && chmod +x ~/.local/bin/terragrunt
```

**macOS (Apple Silicon):**

```bash
brew upgrade terragrunt
```

### Step 3 — Verify

```bash
terragrunt --version
```

---

## Version History

| Date | Version | Platform | Notes |
|------|---------|----------|-------|
| 2026-04-28 | v1.0.3 | Fedora | Upgraded from v1.0.0 via curl |
| (unknown) | v1.0.0 | Fedora | Initial install |

---

## Shell Configuration (`~/.bash.d/41_bashrc_tofu_and_terragrunt`)

This bash fragment runs at shell startup and sets `TG_TF_PATH` to the OpenTofu binary if it is found on `PATH`:

```bash
if tofu_path="$(command -v tofu 2>/dev/null)"; then
  export TG_TF_PATH="$tofu_path"
fi
```

Terragrunt defaults to `terraform` if `TG_TF_PATH` is unset. Setting it to `tofu` ensures OpenTofu is used when both are installed. If `tofu` is not found, the variable is left unset and Terragrunt will look for `terraform` on `PATH`.

---

## Key Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `TG_TF_PATH` | (auto-detect `terraform`) | Path to the OpenTofu/Terraform binary |
| `TG_LOG_LEVEL` | `info` | Log verbosity: `error`, `warn`, `info`, `debug`, `trace` |
| `TG_NON_INTERACTIVE` | `false` | Skip all confirmation prompts (useful in CI) |
| `TG_NO_COLOR` | `false` | Disable ANSI color output |
| `TG_WORKING_DIR` | current dir | Override the working directory |
| `TG_STRICT_MODE` | `false` | Treat deprecated features as errors |
| `TG_EXPERIMENT_MODE` | `false` | Enable all experiments |

---

## Common Commands

```bash
# Initialise a module (wraps tofu init)
terragrunt init

# Plan changes
terragrunt plan

# Apply changes
terragrunt apply

# Run a command across all modules in a stack
terragrunt run-all plan
terragrunt run-all apply

# Show the resolved config with all includes and functions evaluated
terragrunt render

# List configurations Terragrunt can find from the current directory
terragrunt list

# Find relevant configurations
terragrunt find

# Show the dependency graph (DAG)
terragrunt dag

# Execute an arbitrary command via Terragrunt's wrapper
terragrunt exec -- <command> [args]
```

---

## Troubleshooting

**`Error: No valid credential sources found`**
Terragrunt inherits AWS credentials from the environment. Ensure `AWS_PROFILE` or the standard credential chain is configured before running. Check with `aws sts get-caller-identity`.

**`Error finding AWS credentials` during remote state init**
The S3 backend config is usually in a root `terragrunt.hcl`. Confirm the bucket and region values are correct and that the IAM principal has `s3:GetObject`, `s3:PutObject`, and `dynamodb:*` on the lock table.

**`tofu: command not found` but OpenTofu is installed**
The `41_bashrc_tofu_and_terragrunt` fragment sets `TG_TF_PATH` at login. If you installed OpenTofu after opening your shell, reload: `source ~/.bashrc`. Alternatively set `TG_TF_PATH` manually: `export TG_TF_PATH=$(which tofu)`.

**`chmod +x` denied after upgrade on Fedora**
If `~/.local/bin` is on an `noexec` mount, you will see permission errors. This has not been observed on this system; `~/.local/bin` is on the home NVMe.
