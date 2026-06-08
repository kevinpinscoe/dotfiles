# Salt Project (SaltStack)

## Operation

<!-- Personal usage notes go here -->

## Summary

Salt (SaltStack) is an open-source configuration management, remote execution, and orchestration platform. It uses a master/minion architecture (or masterless mode) with YAML-based state files and Jinja templating to manage system configuration at scale.

## Links

- [Main website](https://saltproject.io/)
- [Documentation](https://docs.saltproject.io/)
- [Installation guide — Fedora](https://docs.saltproject.io/salt/install-guide/en/latest/topics/install-by-operating-system/linux-fedora.html)
- [Source (GitHub)](https://github.com/saltstack/salt)

## Install (Fedora)

Salt publishes an official DNF repository for Fedora.

```bash
# Add the Salt Project repository (check docs for latest repo URL)
sudo rpm --import https://repo.saltproject.io/salt/py3/redhat/9/x86_64/SALT-PROJECT-GPG-PUBKEY-2023.pub
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.repo \
  | sudo tee /etc/yum.repos.d/salt.repo

# Install salt-minion (agent), salt-master (server), or salt-ssh (agentless)
sudo dnf install salt-minion
```

**Update:** `sudo dnf upgrade salt-minion`

### Masterless (salt-call) mode

For a standalone workstation managed without a salt-master:

```bash
sudo dnf install salt-minion
# No need to start/enable salt-minion service
# Apply states directly:
sudo salt-call --local state.apply
```

## Config locations

| Path | Purpose |
|------|---------|
| `/etc/salt/minion` | Minion configuration |
| `/etc/salt/master` | Master configuration (if running a master) |
| `/srv/salt/` | State files (top.sls, state modules) |
| `/srv/pillar/` | Pillar data (per-host variables) |

## Key commands

```bash
# Apply all states (masterless)
sudo salt-call --local state.apply

# Apply a single state
sudo salt-call --local state.apply <state_name>

# Show highstate (dry-run)
sudo salt-call --local state.apply test=True

# List grains (system facts)
sudo salt-call --local grains.items
```

## Uninstall

```bash
sudo dnf remove salt-minion
sudo rm -rf /etc/salt /srv/salt /srv/pillar
```

## Troubleshooting

<!-- Record issues and resolutions here as they occur -->
