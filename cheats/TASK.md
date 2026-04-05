# Task

## Grounding and background

See CLAUDE.md for grounding

## I need you to generate or replace

<!-- These need changing by a human -->

{{COMMAND_NAME}}="glow"
{{DOCUMENTATION_URL}}="https://github.com/charmbracelet/glow"
{{SUMMARIZE}}="Render Markdown in the terminal"
<!-- For human consumption: choices are all, mac, fedora or rpi -->
{{TEMPLATE_TO_USE}}="all"
{{TAGGING}}="markdown, viewer"

Create or replace a cheat with updated information for command {{COMMAND_NAME}} with tagging as {{TAGGING}}.

Template to use for cheat file ~/cheats/templates/{{TEMPLATE_TO_USE}}.

tags go into YAML front matter in cheat file replacing `tags: [ {{TAGS}} ]` with comma delinted tags.

Replace {{COMMAND_NAME}} in template with with {{COMMAND_NAME}} from this file.

Replace {{DOCUMENTATION_URL}} in template with {{DOCUMENTATION_URL}} from this file.

Replace {{SUMMARIZE}} in template with {{SUMMARIZE}} from this file.

## Install method

Replace {{INSTALL_METHOD_FEDORA}} with `sudo dnf install glow`.
Replace {{INSTALL_METHOD_RPI}} with:
```
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update
sudo apt install glow
```.
Replace {{INSTALL_METHOD_MAC}} with `homebrew install glow`. 

## Command path

Replace {{COMMAND_PATH_FEDORA}} with `{{COMMAND_NAME}}`.
Replace {{COMMAND_PATH_RPI}} with `{{COMMAND_NAME}}`.
Replace {{COMMAND_PATH_MAC}} with `{{COMMAND_NAME}}`.

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

