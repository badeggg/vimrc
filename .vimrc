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
set encoding=utf-8

" related to plugin 'preservim/tagbar'
nnoremap <F8> :TagbarToggle<CR>

" to jump between matching HTML/XML tags
runtime macros/matchit.vim

filetype plugin on

" no auto comment leader insertion
autocmd FileType * setlocal formatoptions-=r formatoptions-=o

command! Bufnr echo bufnr('%')

vnoremap Y "*y
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" search current word without moving cursor
" <leader>s  : search   sensitive     boundary word
" <leader>S  : search   sensitive non-boundary word
" <leader>cs : search insensitive     boundary word
" <leader>cS : search insensitive non-boundary word
nnoremap <leader>s  :let @/=  '\<<C-R><C-W>\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap <leader>S  :let @/=    '<C-R><C-W>'  <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap <leader>cs :let @/='\c\<<C-R><C-W>\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
nnoremap <leader>cS :let @/=  '\c<C-R><C-W>'  <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>

function! TrimSpaces(s)
    return substitute(a:s, '^\s*\|\s*$', '', 'g')
endfunction

function! TrimNewLines(s)
    " Guess single line searching if only one \n exists, trim \n (Null)
    " Guess multi line searching if multiple \n exist, don't trim \n
    let text = (count(a:s, "\n") == 1) ? substitute(a:s, '^\n\|\n$', '', 'g') : a:s

    " Convert internal 'Nulls' into the literal characters '\' and 'n'
    let text = substitute(l:text, '\n', '\\n', 'g')

    return text
endfunction

function! EscapeForwardSlashes(s)
    return substitute(a:s, '[\/]', '\\&', 'g')
endfunction

" search selected content without moving cursor
"   <leader>s : search   sensitive non-boundary         word
"   <leader>S : search   sensitive     boundary         word
"  <leader>cs : search insensitive non-boundary         word
"  <leader>cS : search insensitive     boundary         word
"  <leader>ts : search   sensitive non-boundary trimmed word

vnoremap   <leader>s "vy:let @/='\V'     .            TrimNewLines(EscapeForwardSlashes(getreg('v')))        <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap   <leader>S "vy:let @/='\V\<'   .            TrimNewLines(EscapeForwardSlashes(getreg('v')))  . '\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap  <leader>cs "vy:let @/='\V\c'   .            TrimNewLines(EscapeForwardSlashes(getreg('v')))        <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap  <leader>cS "vy:let @/='\V\c\<' .            TrimNewLines(EscapeForwardSlashes(getreg('v')))  . '\>'<CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
vnoremap  <leader>ts "vy:let @/='\V'     . TrimSpaces(TrimNewLines(EscapeForwardSlashes(getreg('v'))))       <CR>:set hlsearch<CR>:call histadd('search', @/)<CR>
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
" Plug 'Makaze/AnsiEsc'

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

" This disables the red highlight for underscores inside words in markdown.
" This line must be after colorscheme changing.
hi link markdownError NONE

command! SyntaxSyncFromstart syntax sync fromstart
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" format current file
function! FormatCurrentFile()
    let l:cur_pos = getcurpos()
    let l:content = join(getline(1, '$'), "\n") " Get all content
    let l:filetype = &filetype
    let l:cmd = ''
    let l:success_msg = ''
    let l:formatter_name = ''

    if l:filetype =~# '\v^(javascript|typescript|javascriptreact|typescriptreact|json|css|scss|less)$'
        " Use Prettier for JS/TS/CSS/JSON
        let l:formatter_name = 'Prettier'
        let l:cmd = 'npx prettier --stdin-filepath ' . shellescape(expand('%'))
        let l:success_msg = l:formatter_name . " successfully formatted the file! ✨"
    elseif l:filetype =~# '\v^(c|cpp|h|hpp)$'
        " Use ClangFormat for C/C++
        let l:formatter_name = 'ClangFormat'
        let l:cmd = 'clang-format -style=file -assume-filename=' . shellescape(expand('%'))
        let l:success_msg = l:formatter_name . " successfully formatted the file! 🔧"
    else
        " Unsupported File Type
        echohl ErrorMsg | echom "Error: File type (" . l:filetype . ") is unsupported." | echohl None
        return
    endif

    " --- Execute the Command ---
    " Use system() to run the command and feed it l:content via stdin.
    let l:output = system(l:cmd, l:content)

    " Check the exit code. v:shell_error is set by system()
    if v:shell_error == 0
        " Success: Replace the buffer content.
        let l:output_split = split(l:output, "\n")

        " Handle replacing content, adjusting for line count differences
        let l:origin_longer = line('$') - len(l:output_split)
        if l:origin_longer >= 1
            " Delete excess lines if original content was longer
            silent! execute '$-' . l:origin_longer . ',$d'
        endif
        call setline(1, l:output_split)

        echom l:success_msg
    else
        " Failure: The buffer is NOT touched. l:output contains the error.
        echohl ErrorMsg
        echom l:formatter_name . " failed! Check the error below:"
        " Show the error message (limiting to a few lines)
        echom join(split(l:output, "\n")[0:2], "\n")
        echohl None
    endif

    " Restore original cursor position
    call setpos('.', l:cur_pos)
endfunction

nmap <leader>f :call FormatCurrentFile()<CR>:w<CR>
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

command! SFileName execute 'call SearchFileName()' | set hlsearch

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
        let l:term_command = a:horizontal ? 'botright terminal' : 'vertical terminal'
        execute l:term_command
    else
        let l:escaped_cmd = escape(a:cmd, '`"$\!\')
        let l:term_command = (a:horizontal ? 'botright terminal' : 'vertical terminal') . ' bash -ic "' . l:escaped_cmd . '"'
        execute l:term_command
    endif

    if a:unlimited_width
        call feedkeys("\<C-W>=", 't')
    endif
endfunction

command! -nargs=* T  call TerminalWrapper(<q-args>, 0, 0)
command! -nargs=* Tu call TerminalWrapper(<q-args>, 0, 1)
command! -nargs=* Th call TerminalWrapper(<q-args>, 1, 0)
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" git

autocmd VimEnter * command! -nargs=* Diff     call TerminalWrapper('git -P diff --color=always '.<q-args>.'    % | diff-highlight', 0, 1)
autocmd VimEnter * command!          Filehist call TerminalWrapper('git -P log  --color=always  -p             % | diff-highlight', 0, 1)
autocmd VimEnter * command! -nargs=* Show     call TerminalWrapper('git -P show --color=always '.<q-args>.'      | diff-highlight', 0, 1)
autocmd VimEnter * command! -nargs=* Git      call TerminalWrapper('git '                       .<q-args>,                          0, 1)

" Alternative version, the main version may have gibberish
autocmd VimEnter * command! -nargs=* Adiff     vnew | setlocal ft=git buftype=nofile | execute 'read! git -P diff '.<q-args>.' #' | 1d
autocmd VimEnter * command!          Afilehist vnew | setlocal ft=git buftype=nofile | execute 'read! git -P log   -p          #' | 1d | syn sync minlines=500
autocmd VimEnter * command! -nargs=* Ashow     vnew | setlocal ft=git buftype=nofile | execute 'read! git    show '.<q-args>      | 1d
autocmd VimEnter * command! -nargs=* Agit      vnew | setlocal ft=git buftype=nofile | execute 'read! git '        .<q-args>      | 1d

autocmd VimEnter * command! -nargs=* LastVersion
  \ let s:ft = &filetype |
  \ vnew |
  \ setlocal buftype=nofile |
  \ execute 'setlocal ft=' . s:ft |
  \ execute 'read! git cat-file -p '.(empty(<q-args>) ? 'HEAD' : <q-args>).':./#' |
  \ 1d


command! Add   call system('git add      ' . shellescape(expand('%'))) | e
command! Drop  call system('git checkout ' . shellescape(expand('%'))) | e
command! Reset call system('git reset    ' . shellescape(expand('%'))) | e

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
" open a file whose path is the last/first item of current line or selected content.
"
"         <leader><CR> : open last item(file) in current window
" <leader><leader><CR> : open last item(file) in new window
"
"            <leader>' : open first item(file) in current window
"    <leader><leader>' : open first item(file) in new window
"
"    We can't use <shift><CR> as key map. Single quote(') is used since it
"    sit at the left of 'enter' key on keyboard.
"
" Those chars are regarded as separators:
"   - space   ( )
"   - tab     (\t)
"   - newline (\n)
"   - colon   (:)

function! OpenWord(args)
    let use_reg_v_content = get(a:args, 'use_reg_v_content', 0)
    let open_in_new_window = get(a:args, 'open_in_new_window', 0)
    let position = get(a:args, 'position', 'end') " 'start' | 'end'

    if !use_reg_v_content
        let content = getline('.')
    else
        let content = getreg('v')
    endif

    " Split on space, tab, newline, or colon
    let word_list = split(content, '[ \t\n:]\+')
    call filter(word_list, 'v:val != ""')

    let file = ''
    let line = ''
    let column = ''

    if position == 'start'
        for word in word_list
            if empty(file)
                let file = word
                continue
            elseif empty(line)
                if word =~ '^\d\+$'
                    let line = word
                    continue
                else
                    break
                endif
            elseif empty(column)
                if word =~ '^\d\+$'
                    let column = word
                    break
                else
                    break
                endif
            endif
            break
        endfor
    elseif position == 'end'
        echom 'word_list: ' . string(word_list)

        let word_count = len(word_list)
        let last_word      = get(word_list, -1, "")
        let second_to_last = get(word_list, -2, "")
        let third_to_last  = get(word_list, -3, "")

        if word_count == 1
            let file = last_word
        elseif word_count == 2
            if last_word =~ '^\d\+$'
                let file = second_to_last
                let line = last_word
            else
                let file = last_word
            endif
        elseif word_count >= 3
            if last_word =~ '^\d\+$' && second_to_last =~ '^\d\+$'
                let file = third_to_last
                let line = second_to_last
                let column = last_word
            elseif last_word =~ '^\d\+$'
                let file = second_to_last
                let line = last_word
            else
                let file = last_word
            endif
        endif
    endif

    if !empty(file)
        if open_in_new_window
            execute 'vs' fnameescape(file)
        else
            execute 'edit' fnameescape(file)
        endif

        if !empty(line)
            call cursor(str2nr(line), !empty(column) ? str2nr(column) : 1)
        endif
    else
        echo "No path found."
    endif
endfunction

nnoremap         <leader><CR>    :call OpenWord({'use_reg_v_content': 0, 'open_in_new_window': 0, 'position': 'end'})<CR>
nnoremap <leader><leader><CR>    :call OpenWord({'use_reg_v_content': 0, 'open_in_new_window': 1, 'position': 'end'})<CR>
vnoremap         <leader><CR> "vy:call OpenWord({'use_reg_v_content': 1, 'open_in_new_window': 0, 'position': 'end'})<CR>
vnoremap <leader><leader><CR> "vy:call OpenWord({'use_reg_v_content': 1, 'open_in_new_window': 1, 'position': 'end'})<CR>

nnoremap            <leader>'    :call OpenWord({'use_reg_v_content': 0, 'open_in_new_window': 0, 'position': 'start'})<CR>
nnoremap    <leader><leader>'    :call OpenWord({'use_reg_v_content': 0, 'open_in_new_window': 1, 'position': 'start'})<CR>
vnoremap            <leader>' "vy:call OpenWord({'use_reg_v_content': 1, 'open_in_new_window': 0, 'position': 'start'})<CR>
vnoremap    <leader><leader>' "vy:call OpenWord({'use_reg_v_content': 1, 'open_in_new_window': 1, 'position': 'start'})<CR>
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" search last search pattern in buffers

function! BufNrCompareForward(a, b)
    let a_bufnr = a:a.bufnr
    let b_bufnr = a:b.bufnr

    let max_bufnr = bufnr('$')

    if a_bufnr < s:current_bufnr
        let a_bufnr = a_bufnr + max_bufnr
    endif

    if b_bufnr < s:current_bufnr
        let b_bufnr = b_bufnr + max_bufnr
    endif

    return a_bufnr - b_bufnr
endfunction

function! BufNrCompareReverse(a, b)
    let a_bufnr = a:a.bufnr
    let b_bufnr = a:b.bufnr

    let max_bufnr = bufnr('$')

    if a_bufnr > s:current_bufnr
        let a_bufnr = a_bufnr - max_bufnr
    endif

    if b_bufnr > s:current_bufnr
        let b_bufnr = b_bufnr - max_bufnr
    endif

    return b_bufnr - a_bufnr
endfunction

function! SearchBuffers(search_pattern, backwards, wrap)
    let pattern = a:search_pattern
    if empty(pattern)
        " Get the last search pattern if not specified
        let pattern = @/
    else
        let @/ = pattern
        call histadd('search', pattern)
    endif

    if empty(pattern)
        echo "No search pattern found."
        return
    endif

    let s:current_bufnr = bufnr('%')
    let max_bufnr = bufnr('$')
    let found_bufnr = 0

    let all_buffers = getbufinfo({'buflisted':1})

    " make all_buffers a list from current buffer
    if !a:backwards
        let all_buffers = sort(all_buffers, 'BufNrCompareForward')
    else
        let all_buffers = sort(all_buffers, 'BufNrCompareReverse')
    endif

    for buf_info in all_buffers
        let next_bufnr = buf_info.bufnr

        if next_bufnr == s:current_bufnr
            continue
        endif

        if !a:wrap && (
            \    (!a:backwards && next_bufnr < s:current_bufnr)
            \ || (a:backwards && next_bufnr > s:current_bufnr)
            \ )
            continue
        endif

        let next_bufname = buf_info.name
        execute 'silent! buffer ' . next_bufnr
        if search(pattern, 'wc') > 0
            let found_bufnr = next_bufnr
            break
        endif
    endfor

    if !found_bufnr
        execute 'b' . s:current_bufnr
        echohl ErrorMsg
        echom 'Error: Can not find match for ' . pattern
        echohl None
    endif
endfunction

command! -nargs=? SBuffers                call SearchBuffers(<q-args>, 0, 1) | set hlsearch
command! -nargs=? SBuffersBackwards       call SearchBuffers(<q-args>, 1, 1) | set hlsearch
command! -nargs=? SBuffersNoWrap          call SearchBuffers(<q-args>, 0, 0) | set hlsearch
command! -nargs=? SBuffersBackwardsNoWrap call SearchBuffers(<q-args>, 1, 0) | set hlsearch
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
function! OpenInVSCode()
    " Execute 'code %' but redirect all output to /dev/null
    " The trailing '&' is important to run it in the background.
    call system('code ' . shellescape(expand('%')) . ' > /dev/null 2>&1 &')
endfunction
command! Code call OpenInVSCode()
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" Jump to window with wrap
function! s:JumpWithWrap(direction, opposite)
    " Try to move in the desired direction (e.g., 'h' for left)
    " We use v:count1 to respect any count the user may have given (e.g. 2<C-w>h)
    let l:prevWinNr = winnr()
    execute v:count1 . ' wincmd ' . a:direction

    " If the window number hasn't changed, it means the move failed (hit the edge)
    if winnr() == l:prevWinNr
        execute 99 . ' wincmd ' . a:opposite
    endif
endfunction

" --- Remap C-w h and C-w l to use the wrapping function ---
nnoremap <silent> <C-w>h :<C-u>call <SID>JumpWithWrap('h', 'l')<CR>
nnoremap <silent> <C-w>l :<C-u>call <SID>JumpWithWrap('l', 'h')<CR>
nnoremap <silent> <C-w>j :<C-u>call <SID>JumpWithWrap('j', 'k')<CR>
nnoremap <silent> <C-w>k :<C-u>call <SID>JumpWithWrap('k', 'j')<CR>
"-------------------------------------------------------------------------


"-------------------------------------------------------------------------
" Adjust window size

function! GetAmountStr(amount, opposite)
    let l:arg_str = empty(a:amount) ? "10" : a:amount

    try
        let l:amount = str2nr(l:arg_str)
    catch
        echoerr "Invalid numeric argument : " . l:arg_str
    endtry

    if !a:opposite
        if l:amount < 0
            return '-' . abs(l:amount)
        else
            return '+' . l:amount
        endif
    else
        if l:amount < 0
            return '+' . abs(l:amount)
        else
            return '-' . l:amount
        endif
    endif
endfunction


command! -nargs=? Wider    execute 'vertical resize ' . GetAmountStr(<q-args>, 0)
command! -nargs=? Narrower execute 'vertical resize ' . GetAmountStr(<q-args>, 1)
command! -nargs=? Higher   execute '         resize ' . GetAmountStr(<q-args>, 0)
command! -nargs=? Shorter  execute '         resize ' . GetAmountStr(<q-args>, 1)
"-------------------------------------------------------------------------
