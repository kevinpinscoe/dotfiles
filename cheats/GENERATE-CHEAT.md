# Task

## Grounding and background

See CLAUDE.md for grounding

## I need you to generate or replace

<!-- These need changing by a human -->

{{COMMAND_NAME}}="terragrunt"
{{COMMAND_PATH}}="terragrunt"
{{DOCUMENTATION_URL}}="https://docs.terragrunt.com/reference/cli/"
{{SUMMARIZE}}="terragrunt - a thin wrapper for OpenTofu/Terraform that provides extra tools for working with multiple modules, remote state, and DRY configurations"
<!-- For human consumption: choices are all, mac, fedora or rpi -->
{{TEMPLATE_TO_USE}}="all"
{{TAGGING}}="iac terragrunt opentofu terraform"

Create or replace a cheat with updated information for command {{COMMAND_NAME}} with tagging as {{TAGGING}}.

Template to use for cheat file ~/cheats/templates/{{TEMPLATE_TO_USE}}.

tags go into YAML front matter in cheat file replacing `tags: [ {{TAGS}} ]` with comma delinted tags. Ensure `syntax: sh` is present in the front matter.

Replace {{COMMAND_NAME}} in template with with {{COMMAND_NAME}} from this file.

Replace {{DOCUMENTATION_URL}} in template with {{DOCUMENTATION_URL}} from this file.

Replace {{SUMMARIZE}} in template with {{SUMMARIZE}} from this file.

## Install method

Replace {{INSTALL_METHOD_FEDORA}} with `curl -sL https://docs.terragrunt.com/install | bash`.
Replace {{INSTALL_METHOD_RPI}} with `curl -sL https://docs.terragrunt.com/install | bash`
Replace {{INSTALL_METHOD_MAC}} with `brew install terragrunt`.

## Command path

Replace {{COMMAND_PATH_FEDORA}} with `{{COMMAND_PATH}}`.
Replace {{COMMAND_PATH_RPI}} with `{{COMMAND_PATH}}`.
Replace {{COMMAND_PATH_MAC}} with `{{COMMAND_PATH}}`.

## Command documentation

Replace {{DOCUMENTATION_URL}} in template with {{DOCUMENTATION_URL}} from this file.

## Command options

Using ai put command options here gleaned from {{DOCUMENTATION_URL}}, command -h, the commands help option whatever that is or the command's usage statement under template file section "Command options".

Key commands to include:
- `terragrunt run-all plan` — plan across all modules
- `terragrunt run-all apply` — apply across all modules
- `terragrunt run-all destroy` — destroy across all modules
- `terragrunt plan` / `terragrunt apply` — single module (mirrors tofu/terraform)
- `terragrunt init` — initialize with remote state config from terragrunt.hcl
- `terragrunt output` — show outputs
- `terragrunt validate` — validate config
- `terragrunt graph-dependencies` — show dependency graph across modules
- Global flags: `--terragrunt-working-dir`, `--terragrunt-source`, `--terragrunt-include-dir`, `--terragrunt-log-level`


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

