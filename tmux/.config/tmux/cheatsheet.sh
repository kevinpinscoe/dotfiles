#!/usr/bin/env bash
# ~/.config/tmux/cheatsheet.sh
# Key binding reference — launched via prefix + h

b=$'\033[1m'        # bold
d=$'\033[2m'        # dim
h=$'\033[1;35m'     # bold magenta  (section headers)
k=$'\033[1m'        # bold          (key names)
n=$'\033[0m'        # reset

cat <<EOF
${b}╭──────────────────────────────────────────────────────────╮
│          tmux key bindings — prefix = Ctrl-b             │
╰──────────────────────────────────────────────────────────╯${n}

${h}  Sessions${n}
    ${k}S${n}           fzf picker — preview + last-connected time
    ${k}D${n}           dashboard — live box grid,  q to exit
    ${k}N${n}           new named session  (prompts for name)
    ${k}s${n}           choose-tree  (built-in session browser)
    ${k}\$${n}           rename current session
    ${k}d${n}           detach from session
    ${k}o  …${n}        opensessions sidebar  (sub-key menu)

${h}  Windows${n}
    ${k}c${n}           new window
    ${k}n / p${n}       next / prev window
    ${k},${n}           rename window
    ${k}&${n}           kill window
    ${k}0–9${n}         jump to window by index

${h}  Panes${n}
    ${k}%${n}           split right  (vertical divider)
    ${k}"${n}           split down  (horizontal divider)
    ${k}z${n}           zoom / unzoom active pane
    ${k}x${n}           kill pane
    ${k}q${n}           show pane numbers — click or type to jump
    ${k}← ↑ ↓ →${n}    move between panes  (arrow keys)

${h}  Copy mode  (vi)${n}
    ${k}v${n}           enter copy mode
    ${k}v${n}           begin selection  (inside copy mode)
    ${k}y${n}           yank selection and exit
    ${k}C-u / C-d${n}  half-page up / down
                mouse — drag to select, release to copy

${h}  Misc${n}
    ${k}?${n}           full key list  (built-in, scrollable)
    ${k}C-A${n}         clear Claude attention indicator
    ${k}h${n}           this cheatsheet

${d}  any key to close${n}
EOF

IFS= read -r -s -n 1
