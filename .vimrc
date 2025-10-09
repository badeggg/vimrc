" cursor color: #86bd11
let mapleader = " "

set ttimeoutlen=30 " set a larger value when in a ssh environment
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
Plug 'git@github.com:badeggg/indent-jump.vim.git'
Plug 'git@github.com:badeggg/goto-module-ts.vim.git'

call plug#end()

" related to plugin 'preservim/tagbar'
nnoremap <F8> :TagbarToggle<CR>

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
  let l:cur_pos = getcurpos()
  let l:content = join(getline(1, '$'), "\n") " Get all content
  let l:filetype_supported = (&filetype =~# '\v^(javascript|typescript|javascriptreact|typescriptreact|json|css|scss|less)$')

  if l:filetype_supported
    let l:cmd = 'npx prettier --stdin-filepath ' . shellescape(expand('%'))

    " Use system() to run the command and feed it l:content via stdin.
    let l:output = system(l:cmd, l:content)
    
    " Check the exit code. v:shell_error is set by system()
    if v:shell_error == 0
      " Success: Replace the buffer content.
      call setline(1, split(l:output, "\n"))
      echom "File prettified successfully! ✨"
    else
      " Failure: The buffer is NOT touched. l:output contains the error.
      echohl ErrorMsg
      echom "Prettier failed! Check the error below:"
      echom l:output
      echohl None
    endif
  else
    echohl ErrorMsg | echom "Error: File type unsupported." | echohl None
  endif

  call setpos('.', l:cur_pos)
endfunction
" prettier current file
nmap <leader>f :call PrettifyCurrentFile()<CR>:w<CR>
" paste file name
nmap <leader>p a<C-R>=expand('%:t')<CR><Esc>
" paste file path
nmap <leader><leader>p a<C-R>%<Esc>

function! SearchCurrentFileName()
  let l:filename = expand('%:t')

  " Remove up to three extensions
  for i in range(3)
    let new_filename = fnamemodify(l:filename, ':r')
    if new_filename == l:filename
      break " No more extensions to remove
    endif
    let l:filename = new_filename
  endfor

  if !empty(l:filename)
    " :set hlsearch does not work reliably from within a function
    let @/ = l:filename
    normal! n
    call histadd('search', @/)
  endif
endfunction

nnoremap s<leader>f :call SearchCurrentFileName()\|:set hlsearch<CR>

" convenient commands to close left(h)/down(j)/up(k)/right(l) window
command! Qh execute "normal! \<C-w>h:q\<CR>\<C-w>l"
command! Qj execute "normal! \<C-w>j:q\<CR>\<C-w>l"
command! Qk execute "normal! \<C-w>k:q\<CR>\<C-w>l"
command! Ql execute "normal! \<C-w>l:q\<CR>\<C-w>l"
