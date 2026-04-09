# Task

## Grounding and background

See CLAUDE.md for grounding

## I need you to generate or replace

<!-- These need changing by a human -->

{{COMMAND_NAME}}="d2"
{{COMMAND_PATH}}="~/.local/bin/d2"
{{DOCUMENTATION_URL}}="https://github.com/terrastruct/d2"
{{SUMMARIZE}}="D2 is a modern diagram scripting language that turns text to diagrams."
<!-- For human consumption: choices are all, mac, fedora or rpi -->
{{TEMPLATE_TO_USE}}="all"
{{TAGGING}}="d2 diagram text-to-diagram"

Create or replace a cheat with updated information for command {{COMMAND_NAME}} with tagging as {{TAGGING}}.

Template to use for cheat file ~/cheats/templates/{{TEMPLATE_TO_USE}}.

tags go into YAML front matter in cheat file replacing `tags: [ {{TAGS}} ]` with comma delinted tags.

Replace {{COMMAND_NAME}} in template with with {{COMMAND_NAME}} from this file.

Replace {{DOCUMENTATION_URL}} in template with {{DOCUMENTATION_URL}} from this file.

Replace {{SUMMARIZE}} in template with {{SUMMARIZE}} from this file.

## Install method

Replace {{INSTALL_METHOD_FEDORA}} with `curl -fsSL https://d2lang.com/install.sh | sh`.
Replace {{INSTALL_METHOD_RPI}} with: `curl -fsSL https://d2lang.com/install.sh | sh`
Replace {{INSTALL_METHOD_MAC}} with `curl -fsSL https://d2lang.com/install.sh | sh`. 

## Command path

Replace {{COMMAND_PATH_FEDORA}} with `{{COMMAND_PATH}}`.
Replace {{COMMAND_PATH_RPI}} with `{{COMMAND_PATH}}`.
Replace {{COMMAND_PATH_MAC}} with `{{COMMAND_PATH}}`.

## Command documentation

Replace {{DOCUMENTATION_URL}} in template with {{DOCUMENTATION_URL}} from this file.

## Command options

Using ai put command options here gleaned from {{DOCUMENTATION_URL}}, command -h, the commands help option whatever that is or the command's usage statement under template file section "Command options".


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

