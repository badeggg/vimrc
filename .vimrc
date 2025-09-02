let mapleader = " "

set notimeout
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
set re=0

" to view man page in vim
runtime! ftplugin/man.vim

call plug#begin('~/.vim/plugged')

" Add plugins
Plug 'airblade/vim-gitgutter'
Plug 'preservim/tagbar'

call plug#end()

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


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Jump between lines based on indentation
"         <leader>i : jump to next     line with same indentation
" <leader><leader>i : jump to previous line with same indentation
"         <leader>u : jump to next     line with less indentation
" <leader><leader>u : jump to previous line with less indentation
"         <leader>o : jump to next     line with more indentation
" <leader><leader>o : jump to previous line with more indentation
"
" Letter usage explanation:
" 'i' represents indentation.
" 'u' is used since it sit at the left of letter 'i' on keyboard
" 'o' is used since it sit at the right of letter 'i' on keyboard
"
"""""" ↓↓↓

" A unified function for FINDING a jump target based on indentation.
" It returns the line number of the target, or the current line if no target is found.
" direction: 1 for forward (down), -1 for backward (up)
" level: 0 for same, 1 for more, -1 for less
function! FindIndentJump(direction, level)
    " In visual mode, the reference indent is from the start of the selection ('<).
    " In normal mode, it's from the current line (.).
    let ref_line = mode() =~# '[vV\x16]' ? line("'<") : line('.')
    let current_indent = indent(ref_line)

    " Always start the search from the current cursor position.
    let lnum = line('.') + a:direction

    while lnum > 0 && lnum <= line('$')
        " Skip empty or whitespace-only lines
        if getline(lnum) =~ '^\s*$'
            let lnum += a:direction
            continue
        endif

        let target_indent = indent(lnum)

        " Check based on the requested level
        if (a:level == 0 && target_indent == current_indent) ||
           \ (a:level == 1 && target_indent > current_indent) ||
           \ (a:level == -1 && target_indent < current_indent)
            return lnum " Target found, return its line number
        endif

        let lnum += a:direction
    endwhile

    return line('.') " No target found, return current line number to avoid moving
endfunction

" Key mappings in normal mode
" Execute the line number returned by the function.
nnoremap         <leader>i :execute FindIndentJump( 1,  0)<CR>
nnoremap <leader><leader>i :execute FindIndentJump(-1,  0)<CR>
nnoremap         <leader>u :execute FindIndentJump( 1, -1)<CR>
nnoremap <leader><leader>u :execute FindIndentJump(-1, -1)<CR>
nnoremap         <leader>o :execute FindIndentJump( 1,  1)<CR>
nnoremap <leader><leader>o :execute FindIndentJump(-1,  1)<CR>

" Key mappings in visual mode
" Use the returned line number to create a search pattern.
" This acts as a motion and correctly extends the visual selection.
" Side effect is target line is highlighted since searching, I can not fix
" this for now.
vnoremap         <leader>i /<C-R>='\%' . FindIndentJump( 1,  0) . 'l'<CR><CR>
vnoremap <leader><leader>i /<C-R>='\%' . FindIndentJump(-1,  0) . 'l'<CR><CR>
vnoremap         <leader>u /<C-R>='\%' . FindIndentJump( 1, -1) . 'l'<CR><CR>
vnoremap <leader><leader>u /<C-R>='\%' . FindIndentJump(-1, -1) . 'l'<CR><CR>
vnoremap         <leader>o /<C-R>='\%' . FindIndentJump( 1,  1) . 'l'<CR><CR>
vnoremap <leader><leader>o /<C-R>='\%' . FindIndentJump(-1,  1) . 'l'<CR><CR>

"""""" ↑↑↑
" Jump between lines based on indentation 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
