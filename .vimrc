set autoindent
set nu
set tabstop=8
set softtabstop=0
set expandtab
set shiftwidth=4
set smarttab
set hlsearch
set nowrapscan
" setlocal foldmethod=indent
syntax on
set nowrap
set updatetime=300

highlight GitGutterAdd    guifg=#009900 ctermfg=2 
highlight GitGutterChange guifg=#bbbb00 ctermfg=3 
highlight GitGutterDelete guifg=#ff2222 ctermfg=1 
highlight SignColumn guibg=#ffffff

" colorscheme gruvbox
" set background=dark
set ruler
set laststatus=2

set listchars+=space:␣
set backspace=indent,eol,start

set tags=tags;/

set clipboard=unnamed
