let mapleader = " "

" set notimeout
set timeoutlen=3000
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


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" search current word without moving cursor
"         <leader>s : search   sensitive     boundary word
"        g<leader>s : search   sensitive non-boundary word
"        c<leader>s : search insensitive     boundary word
"       cg<leader>s : search insensitive non-boundary word
"       gc<leader>s : search insensitive non-boundary word
"""""" ↓↓↓

nnoremap   <leader>s :let @/='\<<C-R><C-W>\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap  g<leader>s :let @/='<C-R><C-W>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap  c<leader>s :let @/='\c\<<C-R><C-W>\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap cg<leader>s :let @/='\c<C-R><C-W>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap gc<leader>s :let @/='\c<C-R><C-W>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>

"""""" ↑↑↑
" search current word without moving cursor
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


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
" prettier current file
nmap <leader>f :call PrettifyCurrentFile()<CR>:w<CR>
" paste file name
nmap <leader>p a<C-R>=expand('%:t')<CR><Esc>
" paste file path
nmap <leader><leader>p a<C-R>%<Esc>

function! TruncateFileName()
  let filename = expand('%:t')

  " Remove up to three extensions
  for i in range(3)
    let new_filename = fnamemodify(filename, ':r')
    if new_filename == filename
      break " No more extensions to remove
    endif
    let filename = new_filename
  endfor

  return filename
endfunction
" search current file name
nnoremap <expr> s<leader>f "/" . TruncateFileName() . "<CR>"
