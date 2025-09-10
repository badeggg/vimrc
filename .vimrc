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

" Find the jump target based on indentation.
" It returns a keystroke sequence string which can move the cursor to the target
" line, e.g. '3j' to move cursor 3 lines downwards, or an empty stirng if no
" target is found.
"
" direction: 1 for forward (down), -1 for backward (up)
"     level: 0 for same, 1 for more, -1 for less
function! IndentJump(direction, level)
    let ref_line = line('.')
    let current_indent = indent(ref_line)

    " Search from ref_line.
    let lnum = ref_line + a:direction

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
            " Target found
            let shift = abs(lnum - ref_line)
            return a:direction > 0 ? shift . 'j' : shift . 'k'
        endif

        let lnum += a:direction
    endwhile

    return '' " No target found
endfunction

" Key mappings in normal mode
nnoremap <expr>         <leader>i IndentJump( 1,  0)
nnoremap <expr> <leader><leader>i IndentJump(-1,  0)
nnoremap <expr>         <leader>u IndentJump( 1, -1)
nnoremap <expr> <leader><leader>u IndentJump(-1, -1)
nnoremap <expr>         <leader>o IndentJump( 1,  1)
nnoremap <expr> <leader><leader>o IndentJump(-1,  1)


" Key mappings in visual mode
vnoremap <expr>         <leader>i IndentJump( 1,  0)
vnoremap <expr> <leader><leader>i IndentJump(-1,  0)
vnoremap <expr>         <leader>u IndentJump( 1, -1)
vnoremap <expr> <leader><leader>u IndentJump(-1, -1)
vnoremap <expr>         <leader>o IndentJump( 1,  1)
vnoremap <expr> <leader><leader>o IndentJump(-1,  1)

"""""" ↑↑↑
" Jump between lines based on indentation 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
