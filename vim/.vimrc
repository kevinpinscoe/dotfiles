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
setlocal spell spelllang=en
hi clear SpellBad
hi SpellBad cterm=underline
set tabstop=3 softtabstop=0 noexpandtab shiftwidth=3
set nospell
" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

