# Task

## Grounding and background

See CLAUDE.md for grounding

## I need you to generate or replace

<!-- These need changing by a human -->

{{COMMAND_NAME}}="husky"
<!-- How would I run this command without it being on my PATH? -->
{{COMMAND_PATH}}="husky"
{{DOCUMENTATION_URL}}="https://github.com/typicode/husky"
{{SUMMARIZE}}="Library of githooks for teams"
<!-- For human consumption: choices are all, mac, fedora, rpi or mac-container -->
{{TEMPLATE_TO_USE}}="all"
{{TAGGING}}="git git-hooks"

Create or replace a cheat with updated information for command {{COMMAND_NAME}} with tagging as {{TAGGING}}.

Template to use for cheat file ~/cheats/templates/{{TEMPLATE_TO_USE}}.

tags go into YAML front matter in cheat file replacing `tags: [ {{TAGS}} ]` with comma delinted tags. Ensure `syntax: sh` is present in the front matter.

Replace {{COMMAND_NAME}} in template with with {{COMMAND_NAME}} from this file.

Replace {{DOCUMENTATION_URL}} in template with {{DOCUMENTATION_URL}} from this file.

Replace {{SUMMARIZE}} in template with {{SUMMARIZE}} from this file.

## Install method

Replace {{INSTALL_METHOD_FEDORA}} with `npm install -g husky`
Replace {{INSTALL_METHOD_MAC}} with `brew install husky`.
Replace {{INSTALL_METHOD_RPI}} with: 
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22
npm install -g husky
```
Replace {{INSTALL_METHOD_MAC_CONTAINER}} with `npm install -g husky`

> The Mac container is Fedora Linux on ARM (aarch64), so `dnf`/`npm`-style installs
> match Fedora. Only the install method differs when the tool ships prebuilt
> binaries: fetch the `aarch64`/`arm64` asset, not the `x86_64`/`amd64` one used on
> the Fedora workstation.

## Command path

Replace {{COMMAND_PATH_FEDORA}} with `~/.local/bin/husky`.
Replace {{COMMAND_PATH_RPI}} with `~/.nvm/versions/node/v22.22.2/bin/husky`.
Replace {{COMMAND_PATH_MAC}} with `{{COMMAND_PATH}}`.
Replace {{COMMAND_PATH_MAC_CONTAINER}} with `~/.local/bin/husky`.

## Command documentation

Replace {{DOCUMENTATION_URL}} in template with {{DOCUMENTATION_URL}} from this file.

## Command options

Using ai put command options here gleaned from {{DOCUMENTATION_URL}}, command -h, the commands help option whatever that is or the command's usage statement under template file section "Command options".

## Assumptions

Assigning the "all" tag implies:
    - install into  ~/cheats/all/
    - replace all four install methods and command paths, including
      {{INSTALL_METHOD_MAC_CONTAINER}} and {{COMMAND_PATH_MAC_CONTAINER}}

Assigning the "fedora" tag implies:
    - install into ~/cheats/fedora/ 
    - Ignore replacing {{INSTALL_METHOD_RPI}}
    - Ignore replacing {{INSTALL_METHOD_MAC}}
    - Ignore replacing {{INSTALL_METHOD_MAC_CONTAINER}}
    - Ignore replacing {{COMMAND_PATH_RPI}}
    - Ignore replacing {{COMMAND_PATH_MAC}}
    - Ignore replacing {{COMMAND_PATH_MAC_CONTAINER}}

Assigning the "mac" tag implies:
    - install into ~/cheats/mac/  
    - Ignore replacing {{INSTALL_METHOD_FEDORA}}
    - Ignore replacing {{INSTALL_METHOD_RPI}}
    - Ignore replacing {{INSTALL_METHOD_MAC_CONTAINER}}
    - Ignore replacing {{COMMAND_PATH_RPI}}
    - Ignore replacing {{COMMAND_PATH_FEDORA}}
    - Ignore replacing {{COMMAND_PATH_MAC_CONTAINER}}

Assigning the "rpi" tag implies:
    - install into ~/cheats/rpi/ 
    - Ignore replacing {{INSTALL_METHOD_FEDORA}}
    - Ignore replacing {{INSTALL_METHOD_MAC}}
    - Ignore replacing {{INSTALL_METHOD_MAC_CONTAINER}}
    - Ignore replacing {{COMMAND_PATH_FEDORA}}
    - Ignore replacing {{COMMAND_PATH_MAC}}
    - Ignore replacing {{COMMAND_PATH_MAC_CONTAINER}}

Assigning the "mac-container" tag implies:
    - install into ~/cheats/mac-container/
    - the host is Fedora Linux on ARM (aarch64); use the aarch64/arm64 binary when
      the tool is not installed via dnf
    - Ignore replacing {{INSTALL_METHOD_FEDORA}}
    - Ignore replacing {{INSTALL_METHOD_MAC}}
    - Ignore replacing {{INSTALL_METHOD_RPI}}
    - Ignore replacing {{COMMAND_PATH_FEDORA}}
    - Ignore replacing {{COMMAND_PATH_MAC}}
    - Ignore replacing {{COMMAND_PATH_RPI}}

