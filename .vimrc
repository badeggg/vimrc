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

"""""""""""
" Helper function to resolve files
function! s:ResolveFile(path)
    if fnamemodify(a:path, ':e') =~? '^\(css\|ts\|tsx\|js\|jsx\)$'
        if filereadable(a:path)
            return a:path
        endif
    endif

    let l:extensions = ['.d.ts', '.js', '.jsx', '.ts', '.tsx']
    for l:ext in l:extensions
        if filereadable(a:path . l:ext)
            return a:path . l:ext
        endif
    endfor

    let l:index_path = a:path . '/index'
    if isdirectory(a:path)
        for l:ext in l:extensions
            if filereadable(a:path . '/index' . l:ext)
                return a:path . '/index' . l:ext
            endif
        endfor
        return a:path . '/'
    endif

    return ''
endfunction

function! s:ResolvePath(module)
    let l:current_file_dir = fnamemodify(expand('%:p'), ':h')

    " Relative module
    if a:module =~ '^\.'
        let l:path = fnamemodify(resolve(l:current_file_dir . '/' . a:module), ':p')
        if l:path =~ '^' . getcwd()
            return s:ResolveFile(fnamemodify(l:path, ':.'))
        else
            return s:ResolveFile(l:path)
        endif
    endif

    " Find and parse tsconfig.json for aliases
    let l:current_dir = l:current_file_dir
    let l:ts_config_path = ''
    while !empty(l:current_dir)
        let l:candidate = l:current_dir . '/tsconfig.json'
        if filereadable(l:candidate)
            let l:ts_config_path = l:candidate
            break
        endif
        let l:parent_dir = fnamemodify(l:current_dir, ':h')
        if l:parent_dir ==# l:current_dir
            break
        endif
        let l:current_dir = l:parent_dir
    endwhile

    if !empty(l:ts_config_path)
        let l:content = join(readfile(l:ts_config_path), '')
        let l:base_url_match = matchlist(l:content, '\v"baseUrl"\s*:\s*"(.{-})"')
        if !empty(l:base_url_match)
            let l:base_url = resolve(fnamemodify(l:ts_config_path, ':h') . '/' . l:base_url_match[1])
            let l:paths_match = matchlist(l:content, '\v"paths"\s*:\s*(\{.{-}\})')
            if !empty(l:paths_match)
                let l:paths_map = json_decode(substitute(l:paths_match[1], '\*', '', 'g'))

                for [l:alias, l:alias_path] in items(l:paths_map)
                    if a:module =~ '^' . l:alias

                        " todo, only checking the first item
                        let l:resolved_alias = substitute(l:alias_path[0], '\*$', '', '')
                        let l:resolved_path = resolve(l:base_url . '/' . l:resolved_alias . substitute(a:module, '^' . l:alias, '', ''))
                        let l:final_path = s:ResolveFile(l:resolved_path)
                        if !empty(l:final_path)
                            if l:final_path =~ '^' . getcwd()
                                return fnamemodify(l:final_path, ':.')
                            else
                                return l:final_path
                            endif
                        endif
                    endif
                endfor
            endif
        endif
    endif

    " node_modules
    let l:current_dir = l:current_file_dir
    while !empty(l:current_dir)
        let l:node_modules_dir = l:current_dir . '/node_modules'
        if isdirectory(l:node_modules_dir)
            let l:resolved_path = l:node_modules_dir . '/' . a:module
            let l:final_path = s:ResolveFile(l:resolved_path)
            if !empty(l:final_path)
                return l:final_path
            endif
        endif
        let l:parent_dir = fnamemodify(l:current_dir, ':h')
        if l:parent_dir ==# l:current_dir
            break
        endif
        let l:current_dir = l:parent_dir
    endwhile

    return ''
endfunction

function! GotoModule()
    let l:found_module = ''

    " todo, not respecting import and 'xxx' are separated in two lines
    " check: import 'xxx'
    let l:match_import = matchlist(getline('.'), '\vimport\s+[''"](.{-})[''"]')
    if !empty(l:match_import)
        let l:found_module = l:match_import[1]
    endif

    " todo, not respecting from and 'xxx' are separated in two lines
    " check: from 'xxx'
    if empty(l:found_module)
        for l:i in range(line('.'), line('$'))
            let l:line_content = getline(l:i)
            let l:match_from = matchlist(l:line_content, '\vfrom\s+[''"](.{-})[''"]')

            if !empty(l:match_from)
                let l:found_module = l:match_from[1]
                break
            endif
        endfor
    endif

    if !empty(l:found_module)
        let l:resolved_path = s:ResolvePath(l:found_module)

        echom 'resolved_path: ' . resolved_path

        if !empty(l:resolved_path)
            " todo, should also search and goto the module name?
            execute 'silent vertical split ' . l:resolved_path
        else
            echom "Error: Could not resolve path for module: " . l:found_module
        endif
    else
        echom "No import or from statement found from the current line onwards."
    endif
endfunction


nmap <leader>m :call GotoModule()<CR>
