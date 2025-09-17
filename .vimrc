let mapleader = " "

" set notimeout
set autoindent
set nu
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
set smarttab
set hlsearch
set nowrapscan
" setlocal foldmethod=indent
syntax on
set nowrap
set updatetime=300
set splitright

" todo this does not effect search hisroty
" search exact word without moving cursor
nnoremap         <leader>s :let @/='\<<C-R><C-W>\>'<CR>:set hlsearch<CR>
" search word without moving cursor
nnoremap <leader><leader>s :let @/='<C-R><C-W>'<CR>:set hlsearch<CR>

highlight GitGutterAdd    guifg=#009900 ctermfg=2 
highlight GitGutterChange guifg=#bbbb00 ctermfg=3 
highlight GitGutterDelete guifg=#ff2222 ctermfg=1 
highlight SignColumn guibg=#ffffff

" colorscheme gruvbox
" set background=dark
set ruler

set listchars+=space:␣
set backspace=indent,eol,start

set tags=tags;/
set re=0

" to view man page in vim
runtime! ftplugin/man.vim

call plug#begin('~/.vim/plugged')

" Add plugins
Plug 'airblade/vim-gitgutter'
Plug 'preservim/tagbar'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'badeggg/indent-jump.vim'
Plug 'badeggg/goto-module-ts.vim'

call plug#end()

nnoremap <F8> :TagbarToggle<CR>
nnoremap <silent> gd :LspDefinition<CR>
nnoremap <silent> ge :LspNextError<CR>
nnoremap <silent> gE :LspPreviousError<CR>
nnoremap <silent> gw :LspNextWarning<CR>
nnoremap <silent> gW :LspPreviousWarning<CR>

" to jump between matching HTML/XML tags
runtime macros/matchit.vim
filetype plugin on

" no auto comment leader insertion
autocmd FileType * setlocal formatoptions-=r formatoptions-=o

colorscheme desert
autocmd VimEnter * redraw!

" This disables the red highlight for underscores inside words.
hi link markdownError NONE

set laststatus=2
set statusline=%<%{expand('%:.')}\ %h%w%m%r%=%-14.(%l,%c%V%)\ %P

function! PrettifyCurrentFile()
  let cur_pos = getcurpos()
  if &filetype == 'javascript' || &filetype == 'typescript' || &filetype == 'javascriptreact' || &filetype == 'typescriptreact'
      silent :%!npx prettier --stdin-filepath %
  else
      echom "Error: This file type is not supported by this function."
  endif
  call setpos('.', cur_pos)
endfunction

nmap <leader>f :call PrettifyCurrentFile()<CR>:w<CR>
" paste file name
nmap <leader>p a<C-R>=expand('%:t')<CR><Esc>
" paste file path
nmap <leader><leader>p a<C-R>%<Esc>
