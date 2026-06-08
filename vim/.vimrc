set noautoindent
"set fo=cql
set fo=o
"set fo=vt
"set formatoptions=vt
"set formatoptions=cql
set noai
set paste
set background=dark
syntax on
colorscheme kevin
so $HOME/.vim/myfiletypes.vim
"set mouse=a
set spell spelllang=en_us
set spellfile=~/.vim/spell/en.utf-8.add
hi clear SpellBad
hi SpellBad cterm=underline ctermfg=red
set tabstop=3 softtabstop=0 noexpandtab shiftwidth=3
" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

