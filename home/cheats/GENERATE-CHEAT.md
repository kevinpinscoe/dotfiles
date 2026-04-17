# Task

## Grounding and background

See CLAUDE.md for grounding

## I need you to generate or replace

<!-- These need changing by a human -->

{{COMMAND_NAME}}="valkey-cli"
<!-- How would I run this command without it being on my PATH? -->
{{COMMAND_PATH}}="valkey-cli"
{{DOCUMENTATION_URL}}="https://valkey.io/topics/installation/"
{{SUMMARIZE}}="Command line interface for Valkey key-value databases, optimized for caching and other realtime workloads. Compatible with Redis protocol."
<!-- For human consumption: choices are all, mac, fedora or rpi -->
{{TEMPLATE_TO_USE}}="all"
{{TAGGING}}="valkey redis"

Create or replace a cheat with updated information for command {{COMMAND_NAME}} with tagging as {{TAGGING}}.

Template to use for cheat file ~/cheats/templates/{{TEMPLATE_TO_USE}}.

tags go into YAML front matter in cheat file replacing `tags: [ {{TAGS}} ]` with comma delinted tags. Ensure `syntax: sh` is present in the front matter.

Replace {{COMMAND_NAME}} in template with with {{COMMAND_NAME}} from this file.

Replace {{DOCUMENTATION_URL}} in template with {{DOCUMENTATION_URL}} from this file.

Replace {{SUMMARIZE}} in template with {{SUMMARIZE}} from this file.

## Install method

Replace {{INSTALL_METHOD_FEDORA}} with `sudo dnf install valkey`.
Replace {{INSTALL_METHOD_RPI}} with `sudo apt install valkey`
Replace {{INSTALL_METHOD_MAC}} with `brew install valkey`.

## Command path

Replace {{COMMAND_PATH_FEDORA}} with `{{COMMAND_PATH}}`.
Replace {{COMMAND_PATH_RPI}} with `{{COMMAND_PATH}}`.
Replace {{COMMAND_PATH_MAC}} with `{{COMMAND_PATH}}`.

## Command documentation

Replace {{DOCUMENTATION_URL}} in template with {{DOCUMENTATION_URL}} from this file.

## Command options

Using ai put command options here gleaned from {{DOCUMENTATION_URL}}, command -h, the commands help option whatever that is or the command's usage statement under template file section "Command options".

Key commands to include:
- `valkey-cli` — start interactive REPL (connects to 127.0.0.1:6379 by default)
- `valkey-cli -h <host> -p <port>` — connect to a specific host and port
- `valkey-cli -a <password>` — authenticate with password (prefer REDISCLI_AUTH env var)
- `valkey-cli -u valkey://user:pass@host:port/db` — connect via URI
- `valkey-cli -n <db>` — select database number
- `valkey-cli ping` — test connectivity (returns PONG)
- `valkey-cli set <key> <value>` — set a key
- `valkey-cli get <key>` — get a key's value
- `valkey-cli del <key>` — delete a key
- `valkey-cli keys <pattern>` — list keys matching pattern (use SCAN in production)
- `valkey-cli --scan --pattern '<pattern>'` — safely iterate keys without blocking
- `valkey-cli info` — server info and stats
- `valkey-cli --stat` — rolling real-time server stats (mem, clients, etc.)
- `valkey-cli --latency` — continuously sample server latency
- `valkey-cli --bigkeys` — find keys with the most elements
- `valkey-cli --memkeys` — find keys consuming the most memory
- `valkey-cli --hotkeys` — find frequently accessed keys (requires LFU maxmemory-policy)
- `valkey-cli --rdb <file>` — dump remote RDB snapshot to local file
- `valkey-cli --pipe` — send raw RESP protocol from stdin (bulk import)
- `valkey-cli -r <n> <cmd>` — repeat a command N times
- `valkey-cli -r <n> -i <sec> <cmd>` — repeat with interval between executions
- `valkey-cli --csv` — output results in CSV format
- `valkey-cli --json` — output results in JSON format (RESP3)
- `valkey-cli -c` — enable cluster mode (follow MOVED/ASK redirections)
- `valkey-cli --cluster help` — list all cluster management subcommands
- `valkey-cli --tls --cert <file> --key <file>` — connect with TLS client cert
- `valkey-cli --eval <file> key1 , arg1` — run a Lua script via EVAL
- Connection flags: `-h` (host), `-p` (port), `-s` (unix socket), `-n` (db), `-a` (password), `-u` (URI)
- Output flags: `--raw`, `--no-raw`, `--csv`, `--json`, `--quoted-json`


## Assumptions

Assigning the "all" tag implies:
    - install into  ~/cheats/all/  

Assigning the "fedora" tag implies:
    - install into ~/cheats/fedora/ 
    - Ignore replacing {{INSTALL_METHOD_RPI}}
    - Ignore replacing {{INSTALL_METHOD_MAC}}
    - Ignore replacing {{COMMAND_PATH_RPI}}
    - Ignore replacing {{COMMAND_PATH_MAC}}

Assigning the "mac" tag implies:
    - install into ~/cheats/mac/  
    - Ignore replacing {{INSTALL_METHOD_FEDORA}}
    - Ignore replacing {{INSTALL_METHOD_RPI}}
    - Ignore replacing {{COMMAND_PATH_RPI}}
    - Ignore replacing {{COMMAND_PATH_FEDORA}}

Assigning the "rpi" tag implies:
    - install into ~/cheats/rpi/ 
    - Ignore replacing {{INSTALL_METHOD_FEDORA}}
    - Ignore replacing {{INSTALL_METHOD_MAC}}
    - Ignore replacing {{COMMAND_PATH_FEDORA}}
    - Ignore replacing {{COMMAND_PATH_MAC}}

