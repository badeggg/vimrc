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
" [i : jump to previous line with same indentation, 
" ]i : jump to next line with same indentation
" [u : jump to previous line with less indentation, 
" ]o : jump to next line with more indentation
"
" Letter usage explanation:
" 'i' represents indentation.
" 'u' is used since it sit at the left of letter 'i' on keyboard
" 'o' is used since it sit at the right of letter 'i' on keyboard
"
"""""" ↓↓↓

" Custom function to find the nearest previous line with the same indentation
function! FindPrevSameIndent()
    let current_indent = indent(line('.'))
    let lnum = line('.') - 1
    while lnum >= 1
        " Skip empty lines
        if getline(lnum) =~ '^\s*$'
            let lnum -= 1
            continue
        endif

        if indent(lnum) == current_indent
            execute lnum
            return
        endif
        let lnum -= 1
    endwhile
endfunction

" Map [i to the new function in normal mode
nnoremap <buffer> [i :call FindPrevSameIndent()<CR>

"""""" ↑↑↑
" Jump between lines based on indentation 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
