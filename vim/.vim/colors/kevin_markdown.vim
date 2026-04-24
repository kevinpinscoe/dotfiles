" Vim color file — markdown-focused, dark background
" Based on kevin_perl (af/desert base) with rich markdown highlights
" Maintainer: Kevin P. Inscoe

set background=dark
if version > 580
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif
let g:colors_name="kevin_markdown"

" ── Base UI (carried over from kevin_perl) ───────────────────────────────────
hi Normal          guifg=#dfdfdf   guibg=#000000
hi Cursor          guibg=khaki     guifg=slategrey
hi Comment         guifg=#c6c6c6                           ctermfg=251
hi Identifier      guifg=#87def0                           ctermfg=117
hi Constant        guifg=#FF99FF                           ctermfg=213
hi String          guifg=lightred                          ctermfg=203
hi Character       guifg=#87cee0                           ctermfg=116
hi Statement       guifg=khaki                             ctermfg=3
hi PreProc         guifg=red                               ctermfg=196
hi Type            guifg=lightgreen          gui=none      ctermfg=120
hi Todo            guifg=orangered  guibg=yellow2          ctermfg=202  ctermbg=226
hi Special         guifg=Orange                            ctermfg=214
hi Visual          guifg=SkyBlue    guibg=grey60  gui=none cterm=reverse
hi IncSearch       guifg=#ffff60    guibg=#0000ff gui=none ctermfg=226  ctermbg=21
hi Search          guifg=khaki      guibg=slategrey gui=none ctermfg=3  ctermbg=242
hi Ignore          guifg=grey40                            ctermfg=242
hi VertSplit       guibg=#c2bfa5    guifg=grey50  gui=none cterm=reverse
hi Folded          guibg=grey30     guifg=gold             ctermfg=darkgrey ctermbg=NONE
hi FoldColumn      guibg=grey30     guifg=tan              ctermfg=darkgrey ctermbg=NONE
hi ModeMsg         guifg=goldenrod                         cterm=NONE ctermfg=brown
hi MoreMsg         guifg=SeaGreen                          ctermfg=darkgreen
hi NonText         guifg=LightBlue  guibg=#000000          cterm=bold ctermfg=darkblue
hi Question        guifg=springgreen                       ctermfg=green
hi SpecialKey      guifg=yellowgreen                       ctermfg=darkgreen
hi StatusLine                                              cterm=bold,reverse
hi StatusLineNC    guibg=#c2bfa5    guifg=grey50  gui=none cterm=reverse
hi Title           guifg=indianred                         ctermfg=5
hi WarningMsg      guifg=salmon                            ctermfg=1
hi Directory                                               ctermfg=darkcyan
hi ErrorMsg        cterm=bold ctermfg=7 ctermbg=1
hi LineNr                                                  ctermfg=3
hi Underlined      cterm=underline ctermfg=5
hi Error           cterm=bold ctermfg=7 ctermbg=1
hi DiffAdd         ctermbg=4
hi DiffChange      ctermbg=5
hi DiffDelete      cterm=bold ctermfg=4 ctermbg=6
hi DiffText        cterm=bold ctermbg=1

hi User1 guibg=darkblue guifg=yellow
hi User2 guibg=darkblue guifg=lightblue
hi User3 guibg=darkblue guifg=red
hi User4 guibg=darkblue guifg=cyan
hi User5 guibg=darkblue guifg=lightgreen
set statusline=%<%1*===\ %5*%f%1*%(\ ===\ %4*%h%1*%)%(\ ===\ %4*%m%1*%)%(\ ===\ %4*%r%1*%)\ ===%====\ %2*%b(0x%B)%1*\ ===\ %3*%l,%c%V%1*\ ===\ %5*%P%1*\ ===%0* laststatus=2

" ── Markdown headings ────────────────────────────────────────────────────────
" H1 — bold yellow (most prominent)
hi markdownH1               guifg=#FFD700  gui=bold      cterm=bold ctermfg=220
" H2 — bold orange
hi markdownH2               guifg=#FFA040  gui=bold      cterm=bold ctermfg=214
" H3 — bold cyan
hi markdownH3               guifg=#00E5FF  gui=bold      cterm=bold ctermfg=51
" H4 — bold light green
hi markdownH4               guifg=#98FF98  gui=bold      cterm=bold ctermfg=120
" H5 — bold magenta/pink
hi markdownH5               guifg=#FF79C6  gui=bold      cterm=bold ctermfg=212
" H6 — bold periwinkle
hi markdownH6               guifg=#BD93F9  gui=bold      cterm=bold ctermfg=183

" Heading delimiter (#) — dimmer version of heading color
hi markdownHeadingDelimiter guifg=#8B8000  gui=bold      cterm=bold ctermfg=136
hi markdownHeadingRule      guifg=#666666                ctermfg=242

" ── Emphasis ─────────────────────────────────────────────────────────────────
hi markdownBold             guifg=#F8F8FF  gui=bold      cterm=bold ctermfg=255
hi markdownItalic           guifg=#DDA0DD  gui=italic    cterm=NONE ctermfg=182
hi markdownBoldItalic       guifg=#FFB6C1  gui=bold,italic cterm=bold ctermfg=218

hi markdownBoldDelimiter    guifg=#888888                ctermfg=245
hi markdownItalicDelimiter  guifg=#888888                ctermfg=245

" ── Code ─────────────────────────────────────────────────────────────────────
" Inline `code` — light green on very dark grey
hi markdownCode             guifg=#50FA7B  guibg=#1a1a1a ctermfg=83  ctermbg=234
hi markdownCodeBlock        guifg=#50FA7B  guibg=#111111 ctermfg=83  ctermbg=233
hi markdownCodeDelimiter    guifg=#44475a                ctermfg=60

" Fenced code block (``` lines)
hi markdownFencedCodeBlock  guifg=#50FA7B  guibg=#111111 ctermfg=83  ctermbg=233

" ── Links ────────────────────────────────────────────────────────────────────
hi markdownLinkText         guifg=#8BE9FD  gui=underline cterm=underline ctermfg=81
hi markdownUrl              guifg=#6272A4                ctermfg=61
hi markdownLinkDelimiter    guifg=#888888                ctermfg=245
hi markdownLinkTextDelimiter guifg=#888888               ctermfg=245
hi markdownAutomaticLink    guifg=#8BE9FD  gui=underline cterm=underline ctermfg=81

" ── Lists ────────────────────────────────────────────────────────────────────
hi markdownListMarker       guifg=#FF9D3B                ctermfg=214
hi markdownOrderedListMarker guifg=#FF9D3B               ctermfg=214

" ── Blockquotes ──────────────────────────────────────────────────────────────
hi markdownBlockquote       guifg=#A8A8A8  gui=italic    ctermfg=248

" ── Rules / HR ───────────────────────────────────────────────────────────────
hi markdownRule             guifg=#555555                ctermfg=240

" ── Escaped characters ───────────────────────────────────────────────────────
hi markdownEscape           guifg=#FF6E6E                ctermfg=203

" ── ID references ────────────────────────────────────────────────────────────
hi markdownId               guifg=#BD93F9                ctermfg=183
hi markdownIdDeclaration    guifg=#BD93F9  gui=underline cterm=underline ctermfg=183

"vim: sw=4
