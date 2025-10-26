"-------------------------------------------------------------------------
"miscellanea

" macOS terminal cursor color: #86bd11

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
set nowrap
set updatetime=300
set splitright
set splitbelow
set ruler
set listchars+=space:␣
set backspace=indent,eol,start
set tags=tags;/
set re=0
set laststatus=2
set statusline=%<%{expand('%:.')}\ %h%w%m%r%=%-14.(%l,%c%V%)\ %P

" related to plugin 'preservim/tagbar'
nnoremap <F8> :TagbarToggle<CR>

" to jump between matching HTML/XML tags
runtime macros/matchit.vim

filetype plugin on

" no auto comment leader insertion
autocmd FileType * setlocal formatoptions-=r formatoptions-=o

" This disables the red highlight for underscores inside words.
hi link markdownError NONE
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" search current word without moving cursor
"         <leader>s : search   sensitive     boundary word
"        g<leader>s : search   sensitive non-boundary word
"        c<leader>s : search insensitive     boundary word
"       cg<leader>s : search insensitive non-boundary word
"       gc<leader>s : search insensitive non-boundary word
nnoremap   <leader>s :let @/=  '\<<C-R><C-W>\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap  g<leader>s :let @/=    '<C-R><C-W>'  <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap  c<leader>s :let @/='\c\<<C-R><C-W>\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap cg<leader>s :let @/=  '\c<C-R><C-W>'  <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap gc<leader>s :let @/=  '\c<C-R><C-W>'  <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>

" search selected content without moving cursor
"         <leader>s : search   sensitive non-boundary word
"        g<leader>s : search   sensitive     boundary word
"        c<leader>s : search insensitive     boundary word
"       cg<leader>s : search insensitive non-boundary word
"       gc<leader>s : search insensitive non-boundary word
vnoremap   <leader>s "vy:let @/='\V'     . substitute(substitute(getreg('v'), '[\/]', '\\&', 'g'), '[\n\0]', '', 'g')       <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap  g<leader>s "vy:let @/='\V\<'   . substitute(substitute(getreg('v'), '[\/]', '\\&', 'g'), '[\n\0]', '', 'g') . '\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap  c<leader>s "vy:let @/='\V\c'   . substitute(substitute(getreg('v'), '[\/]', '\\&', 'g'), '[\n\0]', '', 'g')       <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap cg<leader>s "vy:let @/='\V\c\<' . substitute(substitute(getreg('v'), '[\/]', '\\&', 'g'), '[\n\0]', '', 'g') . '\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap gc<leader>s "vy:let @/='\V\c\<' . substitute(substitute(getreg('v'), '[\/]', '\\&', 'g'), '[\n\0]', '', 'g') . '\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" use Vim-Plug manage vim plugins
call plug#begin('~/.vim/plugged')

" Add plugins
Plug 'airblade/vim-gitgutter'
Plug 'preservim/tagbar'
Plug 'badeggg/indent-jump.vim'
Plug 'badeggg/goto-module-ts.vim'
Plug 'badeggg/git-link.vim'

call plug#end()
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" color scheme related
colorscheme desert
autocmd VimEnter * redraw!
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" prettier current file
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
      let l:output_split = split(l:output, "\n")
      let l:origin_longer = line('$') - len(l:output_split)
      if l:origin_longer >= 1
          " delete longer text in original content
          silent! execute '$-' . l:origin_longer . ',$d'
      endif
      call setline(1, l:output_split)
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

nmap <leader>f :call PrettifyCurrentFile()<CR>:w<CR>
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" file name related operations
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

command! SearchCurrentFileName execute 'call SearchCurrentFileName()' | set hlsearch

command! PasteFileName         execute "normal! a\<C-R>=expand('%:t')\<CR>\<Esc>"
command! PasteFilePath         execute "normal! a\<C-R>%\<Esc>"
command! PasteFilePathRelative execute "normal! a\<C-R>%\<Esc>"
command! PasteFilePathAbsolute execute "normal! a\<C-R>=expand('%:p')\<CR>\<Esc>"

command! CopyFileName         execute "let @* = expand('%:t')"
command! CopyFilePath         execute "let @* = expand('%')"
command! CopyFilePathRelative execute "let @* = expand('%')"
command! CopyFilePathAbsolute execute "let @* = expand('%:p')"
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" convenient commands to close left(h)/down(j)/up(k)/right(l) window
command! Qh execute "normal! \<C-w>h:q\<CR>\<C-w>l"
command! Qj execute "normal! \<C-w>j:q\<CR>\<C-w>k"
command! Qk execute "normal! \<C-w>k:q\<CR>"
command! Ql execute "normal! \<C-w>l:q\<CR>"
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" to delete those lines

" highlight SignColumn guibg=#ffffff
" set background=dark

" highlight GitGutterAdd    guifg=#009900 ctermfg=2 
" highlight GitGutterChange guifg=#bbbb00 ctermfg=3 
" highlight GitGutterDelete guifg=#ff2222 ctermfg=1 

" to view man page in vim
" runtime! ftplugin/man.vim


"-------------------------------------------------------------------------
