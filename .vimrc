" disable vi compat
set nocompatible
" show line numbers
set number
" improve smoothness
set ttyfast

" Set utf8 as standard encoding
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Sets how many lines of history VIM has to remember
set history=10000

" Set to auto read when a file is changed from the outside
" Might decrease VIM responsiveness
" set autoread

" Activate persistent undo
set undofile
set undodir=~/.vim/undodir

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in git anyway...
set nobackup
set nowb
set noswapfile


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

set ai "Auto indent
set si "Smart indent

set shiftwidth=4 " The # of spaces for indenting
set tabstop=4 " 1 tab == 4 spaces
set softtabstop=4
set smarttab " At start of line, <Tab> inserts shiftwidth spaces, <Bs> deletes shiftwidth spaces

set ignorecase " Ignore case when searching
set smartcase " Ignore 'ignorecase' if search patter contains uppercase characters


""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Format the status line
"set statusline=%t\ %{fugitive#statusline()}


set listchars=tab:>·,trail:.,extends:>,precedes:<,space:.
set list

" Enable mouse click/scroll in insert mode
" Keep mouse select and copy in normal mode
set mouse=i

" Highlight search results
set hlsearch

" show the matching part of the pair for [] {} and ()
set showmatch

" enable all Python syntax highlighting features
" let python_highlight_all = 1

"Always show current position
set ruler

set title " Show the filename in the window titlebar

" Open new splits to right and bottom
set splitbelow
set splitright

" Use the clipboard as the default register
set clipboard^=unnamed,unnamedplus

" Habitual backspace behavior
set backspace=indent,eol,start

" Quick quit Shift + Q
map Q :q<CR>

" Disable search highlighting
nnoremap <silent> <Esc><Esc> :nohlsearch<CR><Esc>

" easier splits switch shortcuts
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

let mapleader = ','
let g:mapleader = ','

" Fast saving
nmap <leader>w :w!<cr>

" bind k to grep word under cursor
nmap <leader>k :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" toggle line numbers (to copy text without line numbers)
map <leader>l :set invnumber<cr>

" Turn on the Wild menu
set wildmenu
set wildignore+=.DS_Store
set wildignore+=*/node_modules/*
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
set wildignore+=*/.sass-cache/*,*/log/*,*/tmp/*,*/doc/*,*/source_maps/*,*/dist/*,*/build/*

" Set the working directory to wherever the open file lives
" set autochdir

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Enable syntax highlighting
syntax enable
set background=dark
"let g:solarized_termcolors=256
"colorscheme molokai
"colorscheme grb256
colorscheme gruvbox

"highlight ColorColumn ctermbg=DarkGrey
set colorcolumn=120

augroup vimrc_autocmds
    " Clear all autocmds in the group
    autocmd!

    " highlight characters past column 120
    autocmd FileType python highlight Excess ctermbg=lightred guibg=Black
    autocmd FileType python match Excess /\%120v.*/
    autocmd FileType python set nowrap

    " Jump to last cursor position unless it's invalid or in an event handler
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif

augroup END

augroup python
    " Highlight python self keyword
    " https://vi.stackexchange.com/a/8773
    autocmd!
    autocmd FileType python
                \   syn keyword pythonSelf self
                \ | highlight def link pythonSelf Special
augroup end

" Dim inactive windows using 'colorcolumn' setting
" This tends to slow down redrawing, but is very useful.
" Based on https://groups.google.com/d/msg/vim_use/IJU-Vk-QLJE/xz4hjPjCRBUJ
" XXX: this will only work with lines containing text (i.e. not '~')
function! s:DimInactiveWindows()
  " Credits: https://stackoverflow.com/a/12519572
  for i in range(1, tabpagewinnr(tabpagenr(), '$'))
    let l:range = ""
    if i != winnr()
      if &wrap
        " HACK: when wrapping lines is enabled, we use the maximum number
        " of columns getting highlighted. This might get calculated by
        " looking for the longest visible line and using a multiple of
        " winwidth().
        let l:width=256 " max
      else
        let l:width=winwidth(i)
      endif
      let l:range = join(range(1, l:width), ',')
    endif
    call setwinvar(i, '&colorcolumn', l:range)
  endfor
endfunction
augroup DimInactiveWindows
  au!
  au WinEnter * call s:DimInactiveWindows()
  au WinEnter * set cursorline
  au WinLeave * set nocursorline
augroup END


" Strip trailing whitespace on save
function! StripWhitespace()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    :%s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunction

if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call StripWhitespace()
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SHORTCUT TO REFERENCE CURRENT FILE'S PATH IN COMMAND LINE MODE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
cnoremap <expr> %% expand('%:h').'/'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RENAME CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <leader>n :call RenameFile()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Dotted path for Django/Python
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! PythonGetLabel()
    if foldlevel('.') != 0
        norm! zo
    endif
    let originalline = getpos('.')
    let lnlist = [] 
    let lastlineindent = indent(line('.'))
    let objregexp = "^\\s*\\(class\\|def\\)\\s\\+[^:]\\+\\s*:"
    if match(getline('.'),objregexp) != -1
        let lastlineindent = indent(line('.'))
        norm! ^wye
        call insert(lnlist, @0, 0)
    endif
    while line('.') > 1
        if indent('.') < lastlineindent
            if match(getline('.'),objregexp) != -1
                let lastlineindent = indent(line('.'))
                norm! ^wye
                call insert(lnlist, @0, 0)
            endif
        endif
        norm! k
    endwhile
    let pathlist =  split(expand('%:r'), '/')
    echo 'Python label: ' join(pathlist + lnlist, '.')
    let @0 = join(pathlist + lnlist, '.')
    let @+ = @0
    call setpos('.', originalline)
endfunction

nnoremap <leader>p :call PythonGetLabel()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
"map <space> /
"map <c-space> ?

" Fix weird behavior inside tmux session
" @see https://stackoverflow.com/a/6988748
map OA <up>
map OB <down>
map OC <right>
map OD <left>

silent! nmap <C-t> :NERDTreeToggle<CR>
" ignore .pyc files in the tree
let NERDTreeIgnore = ['\.pyc$']

let g:netrw_list_hide= '.*\.pyc'

" ignore files in ctrlp search
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(bz2|pyc)$',
  \ }


"autocmd FileType python map <buffer> <F3> :call Flake8()<CR>

" Jedi-vim
let g:jedi#popup_on_dot=0
let g:jedi#show_call_signatures=0
"let g:jedi#auto_vim_configuration=0
autocmd FileType python setlocal completeopt-=preview " disable the docstring window during completion

" Plugins (with vim.plug) -------------------------------------------------------------

" Load plugins
call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'pangloss/vim-javascript'
Plug 'davidhalter/jedi-vim'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/mru.vim'
Plug 'terryma/vim-expand-region'

Plug 'altercation/vim-colors-solarized'
Plug 'morhetz/gruvbox'
Plug 'tomasr/molokai'
" Plug 'tpope/vim-fugitive'

call plug#end()


" Plugin Configuration  -------------------------------------------------------------

" gitgutter faster refresh
set updatetime=250

" Ctrl+N to toggle NERDTree
map <C-n> :NERDTreeToggle %<CR>
" reveal current file in tree
nmap <leader>r :NERDTreeFind "@%"<CR>

" CtrlP.vim {{{
augroup ctrlp_config
  autocmd!
  let g:ctrlp_clear_cache_on_exit = 0 " Do not clear filenames cache, to improve CtrlP startup
  "let g:ctrlp_lazy_update = 350 " Set delay to prevent extra search
  let g:ctrlp_match_window_bottom = 0 " Show at top of window
  let g:ctrlp_max_files = 0 " Set no file limit, we are building a big project
  let g:ctrlp_switch_buffer = 'Et' " Jump to tab AND buffer if already open
  let g:ctrlp_open_new_file = 'r' " Open newly created files in the current window
  let g:ctrlp_open_multiple_files = 'ij' " Open multiple files in hidden buffers, and jump to the first one
augroup END
" }}}


" MRU {{{
augroup mru_config
  autocmd!
  "let MRU_File = ~/.vim/plugged/mru.vim/.vim_mru_files
  let MRU_Max_Entries = 50
  "let MRU_Include_Files = '\.py$\|\.html$\|\.js$\|\.coffee$'
  nmap <leader>e :MRU<CR>
augroup END

" }}}

" fzf
nnoremap <silent> <leader>f :Files<CR>

nnoremap <Leader>o :Agc<CR>
command! -bang -nargs=* Agc call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

" Silver Searcher {{{
augroup ag_config
  autocmd!

  if executable("ag")
    " Note we extract the column as well as the file and line number
    set grepprg=ag\ --nogroup\ --nocolor\ --column
    set grepformat=%f:%l:%c%m

    " Have the silver searcher ignore all the same things as wilgignore
    let b:ag_command = 'ag %s -i --nocolor --nogroup'

    for i in split(&wildignore, ",")
      let i = substitute(i, '\*/\(.*\)/\*', '\1', 'g')
      let b:ag_command = b:ag_command . ' --ignore "' . substitute(i, '\*/\(.*\)/\*', '\1', 'g') . '"'
    endfor

    let b:ag_command = b:ag_command . ' --hidden -g ""'
    let g:ctrlp_user_command = b:ag_command
    let g:ctrlp_use_caching = 0
    let $FZF_DEFAULT_COMMAND = 'ag -i -l'
  endif
augroup END
" }}}
