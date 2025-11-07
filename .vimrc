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
" <leader>s   : search   sensitive     boundary word
" <leader>gs  : search   sensitive non-boundary word
" <leader>cs  : search insensitive     boundary word
" <leader>cgs : search insensitive non-boundary word
" <leader>gcs : search insensitive non-boundary word
nnoremap <leader>s   :let @/=  '\<<C-R><C-W>\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap <leader>gs  :let @/=    '<C-R><C-W>'  <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap <leader>cs  :let @/='\c\<<C-R><C-W>\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap <leader>cgs :let @/=  '\c<C-R><C-W>'  <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap <leader>gcs :let @/=  '\c<C-R><C-W>'  <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>

function! TrimSpaces(s)
  return substitute(a:s, '^\s*\|\s*$', '', 'g')
endfunction

function! TrimNewLines(s)
  return substitute(a:s, '^[\n\r]*\|[\n\r]*$', '', 'g')
endfunction

function! EscapeForwardSlashes(s)
  return substitute(a:s, '[\/]', '\\&', 'g')
endfunction

" search selected content without moving cursor
"   <leader>s : search   sensitive non-boundary         word
"  <leader>ts : search   sensitive non-boundary trimmed word
"  <leader>gs : search   sensitive     boundary         word
"  <leader>cs : search insensitive non-boundary         word
" <leader>cgs : search insensitive     boundary         word
" <leader>gcs : search insensitive non-boundary         word

vnoremap   <leader>s "vy:let @/='\V'     .            TrimNewLines(EscapeForwardSlashes(getreg('v')))        <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap  <leader>ts "vy:let @/='\V'     . TrimSpaces(TrimNewLines(EscapeForwardSlashes(getreg('v'))))       <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap  <leader>gs "vy:let @/='\V\<'   .            TrimNewLines(EscapeForwardSlashes(getreg('v')))  . '\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap  <leader>cs "vy:let @/='\V\c'   .            TrimNewLines(EscapeForwardSlashes(getreg('v')))        <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap <leader>cgs "vy:let @/='\V\c\<' .            TrimNewLines(EscapeForwardSlashes(getreg('v')))  . '\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap <leader>gcs "vy:let @/='\V\c\<' .            TrimNewLines(EscapeForwardSlashes(getreg('v')))  . '\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" use Vim-Plug manage vim plugins
call plug#begin('~/.vim/plugged')

" Add plugins
Plug 'airblade/vim-gitgutter'
Plug 'preservim/tagbar'
Plug 'tpope/vim-fugitive'
Plug 'badeggg/indent-jump.vim'
Plug 'badeggg/goto-module-ts.vim'
Plug 'badeggg/git-link.vim'

call plug#end()
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" color scheme related

colorscheme desert

autocmd VimEnter * redraw!

highlight StatusLine ctermfg=232 ctermbg=172

highlight DiffDelete ctermfg=168
highlight DiffRemoved ctermfg=168
highlight DiffAdded ctermfg=35

highlight GitGutterAdd    guifg=#009900 ctermfg=2 
highlight GitGutterChange guifg=#bbbb00 ctermfg=3 
highlight GitGutterDelete guifg=#ff2222 ctermfg=1 
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
function! SearchFileName()
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

command! SearchFileName execute 'call SearchFileName()' | set hlsearch

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
command! Qh let target_win = winnr('h') | execute target_win . 'wincmd q'
command! Qj let target_win = winnr('j') | execute target_win . 'wincmd q'
command! Qk let target_win = winnr('k') | execute target_win . 'wincmd q'
command! Ql let target_win = winnr('l') | execute target_win . 'wincmd q'

command! QH let target_win = winnr('h') | execute target_win . 'q!'
command! QJ let target_win = winnr('j') | execute target_win . 'q!'
command! QK let target_win = winnr('k') | execute target_win . 'q!'
command! QL let target_win = winnr('l') | execute target_win . 'q!'
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" in-vim terminal

function! TerminalWrapper(cmd, horizontal, unlimited_width)
    if a:unlimited_width
        set termwinsize=0x9999
    else
        set termwinsize=0x0
    endif

    if empty(a:cmd)
        let l:cmd = a:horizontal ? 'botright terminal' : 'vertical terminal'
        execute l:cmd
    else
        let l:cmd = (a:horizontal ? 'botright terminal' : 'vertical terminal') . ' bash -ic "' . a:cmd . '"'
        execute l:cmd
    endif

    if a:unlimited_width
        call feedkeys("\<C-W>=", 't')
    endif
endfunction

command! -nargs=* T  call TerminalWrapper(<q-args>, 0, 0)
command! -nargs=* Th call TerminalWrapper(<q-args>, 1, 0)
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" git
" todo to delete
" autocmd VimEnter * command! Diff         vnew | setlocal ft=git buftype=nofile | execute '0read! git -P diff #'
" autocmd VimEnter * command! Filehist     vnew | setlocal ft=git buftype=nofile | execute '0read! git -P log -p #'
" autocmd VimEnter * command! -nargs=* Git vnew | setlocal ft=git buftype=nofile | execute '0read! git ' . <q-args>

autocmd VimEnter * command!          Diff     call TerminalWrapper('git diff %',    0, 1)
autocmd VimEnter * command!          Filehist call TerminalWrapper('git log -p %',  0, 1)
autocmd VimEnter * command! -nargs=* Git      call TerminalWrapper('git '.<q-args>, 0, 1)

command! Add call system('git add ' . shellescape(expand('%'))) | e

" search a hunk
nnoremap <leader>hs :let @/= "^@@.*$"   <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
" search a file diff
nnoremap <leader>ds :let @/= "^diff.*$" <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>

" disable confilict key mappings from git-gutter
nmap <plug>(disable-hp) <Plug>(GitGutterPreviewHunk)
nmap <plug>(disable-hu) <Plug>(GitGutterUndoHunk)
nmap <plug>(disable-hs) <Plug>(GitGutterStageHunk)
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" open a file whose path is the last item of current line or selected content
"         <leader><CR> : open in current window(open in new window then close current window actually)
" <leader><leader><CR> : open in new window

nnoremap         <leader><CR>    :call OpenLastWord({'use_reg_v_content': 0, 'open_in_new_window': 0})<CR>
nnoremap <leader><leader><CR>    :call OpenLastWord({'use_reg_v_content': 0, 'open_in_new_window': 1})<CR>
vnoremap         <leader><CR> "vy:call OpenLastWord({'use_reg_v_content': 1, 'open_in_new_window': 0})<CR>
vnoremap <leader><leader><CR> "vy:call OpenLastWord({'use_reg_v_content': 1, 'open_in_new_window': 1})<CR>

function! OpenLastWord(args)
    let l:use_reg_v_content = get(a:args, 'use_reg_v_content', 0)
    let l:open_in_new_window = get(a:args, 'open_in_new_window', 0)

    if !l:use_reg_v_content
        let l:content = getline('.')
    else
        let l:content = getreg('v')
        echom 'reg v: ' . l:content
    endif

    let l:content = substitute(l:content, '[\n\0]', '', 'g')

    let l:match = matchlist(l:content, '\(\S\+\)\s*$')

    if !empty(l:match)
        let l:current_win = winnr()
        execute 'vsp' fnameescape(l:match[1])
        if !l:open_in_new_window
            execute l:current_win . 'wincmd q'
        endif
    else
        echo "No path found on the current line."
    endif
endfunction
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" search last search pattern in buffers

function! BufNrCompareForward(a, b)
  return a:a.bufnr - a:b.bufnr
endfunction

function! BufNrCompareReverse(a, b)
  return a:b.bufnr - a:a.bufnr
endfunction

function! SearchBuffers(backwards)
    " Get the last search pattern directly from the search register (@/)
    let l:pattern = @/

    if empty(l:pattern)
        echo "No previous search pattern found."
        return
    endif

    let l:current_bufnr = bufnr('%')
    let l:found_bufnr = 0

    let l:all_buffers = getbufinfo({'buflisted':1})

    if empty(a:backwards)
        let l:all_buffers = sort(l:all_buffers, 'BufNrCompareForward')
    else
        let l:all_buffers = sort(l:all_buffers, 'BufNrCompareReverse')
    endif

    for l:buf_info in l:all_buffers
        let l:next_bufnr = l:buf_info.bufnr
        if (!empty(a:backwards) && l:next_bufnr < l:current_bufnr) || (empty(a:backwards) && l:next_bufnr > l:current_bufnr)
            let l:next_bufname = buf_info.name
            execute 'silent! buffer ' . l:next_bufnr
            if search(l:pattern, 'wc') > 0
                let l:found_bufnr = l:next_bufnr
                break
            endif
        endif
    endfor

    if !l:found_bufnr
        execute 'b' . l:current_bufnr
        echohl ErrorMsg
        echom 'Error: Search hit ' . (empty(a:backwards) ? 'last' : 'first') . ' buffer without match for ' . l:pattern
        echohl None
    endif
endfunction

command! -nargs=? SearchBuffers call SearchBuffers(<q-args>) | set hlsearch
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
function! OpenInVSCode()
    " Execute 'code %' but redirect all output to /dev/null
    " The trailing '&' is important to run it in the background.
    call system('code ' . shellescape(expand('%')) . ' > /dev/null 2>&1 &')
endfunction
command! Code call OpenInVSCode()
"-------------------------------------------------------------------------
