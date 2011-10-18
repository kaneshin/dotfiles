" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set foldmethod=marker foldmarker={{{,}}} :
"===========================================================================
" File: .vimrc
" Last Change: 19-Oct-2011.
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
"===========================================================================
"
" # basic setting
scriptencoding utf-8
syntax on
filetype plugin indent on
"
" # utilities
" {{{
" ## variables
" {{{
" ### multi OS
" windows machine
let s:is_win = has( 'win16' ) || has( 'win32' ) || has( 'win64' )
" cygwin
let s:is_cyg = has( 'win32unix' )
" unix(NOT Cygwin)
let s:is_unix = has( 'unix' ) && s:is_cyg == 0
"
" ### my vim folder
if s:is_win
  let $MYVIM = expand( '$HOME/vimfiles' )
elseif s:is_cyg || s:is_unix
  let $MYVIM = expand( '$HOME/.vim' )
endif
" }}}
"
" ## commands
" {{{
" ### .vimrc
command! EditVimrc :tabe $DROPBOX/dotfiles/.vimrc
command! ReadVimrc :source $DROPBOX/dotfiles/.vimrc
nnoremap ,ev :EditVimrc<CR>
nnoremap ,rv :ReadVimrc<CR>
"
" ### .vimrc(Local)
command! EditVimrcHome :tabe $HOME/.vimrc
command! ReadVimrcHome :source $HOME/.vimrc
nnoremap <Leader>ev :EditVimrcHome<CR>
nnoremap <Leader>rv :ReadVimrcHome<CR>
" }}}
"
" ## functions
" {{{
" }}}
" }}}
"
" # options
" {{{
" ## backup, swap
if finddir('backup', $MYVIM) != ''
  set backup
  set backupext=.bak
  set backupdir=$MYVIM/backup
  set swapfile
  set directory=$MYVIM/backup
else
  echo 'can NOT save a backup file.'
  set nobackup
  set noswapfile
endif
"
" ## fold
"if finddir('view', $MYVIM) != ''
"  set viewdir=$MYVIM/view
"  autocmd BufWritePost * mkview
"  autocmd BufReadPost * loadview
"endif
"
" ## encoding
set fileencodings=utf-8,euc-jp,cp932,shiftjis,iso-2022-jp,latin1
set fileformats=unix,dos,mac
" set encoding=utf-8
" set fileencoding=utf-8
" set fileformat=unix
"
" ## display#main
set splitbelow
set splitright
set title
set titlelen=80
set number
set scrolloff=5
set linespace=1
set wrap
set nolist
set listchars=eol:$,tab:>\ ,extends:<
"
" ## display#below
set ruler
set showcmd
set laststatus=2
set statusline=%<%t\ %m%r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=[%l/%L,%c/%{col('$')-1}][0x\%02.2B][%{strftime('%b/%d\ %X')}] 
set cmdheight=2
set wildmenu
set wildmode=list:longest
"
" ## cursor
set nocursorbind
set cursorline
set nocursorcolumn
"
" ## search
set ignorecase
set smartcase
set nowrapscan
set incsearch
nnoremap <ESC><ESC> :nohlsearch<CR>
"
" ## edit
set autoindent
set smartindent
set showmatch
set backspace=indent,eol,start
set clipboard=unnamed
set pastetoggle=<F12>
set formatoptions+=mM
"
" ## <Tab>
set tabstop=4
set shiftwidth=4
set softtabstop=0
set expandtab
set smarttab
"
" ## etc
set nocompatible
set shellslash
set nrformats+=alpha
set nrformats+=octal
set nrformats+=hex
set history=50
" }}}
" 
" # key map (:map <F1> <F2> #-> <F1> <- <F2>)
" {{{
" ## move
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
"
" ## window
nnoremap <silent> <C-x>0 <C-w>c
nnoremap <silent> <C-x>1 <C-w>o
nnoremap <silent> <C-x>2 <C-w>s
nnoremap <silent> <C-x>3 <C-w>v
nnoremap <C-S-j> <C-w>k<C-e><C-w><C-w>
"
" ## buffer
nmap <C-n> :bnext<CR>
nmap <C-p> :bprevious<CR>
"
" ## edit
inoremap <C-b> <BS>
inoremap <C-d> <Del>
inoremap <C-f> <CR>
inoremap <Leader>k <ESC>d$i
inoremap <Leader>p <ESC>pi
inoremap {} {}<Left>
inoremap [] []<Left>
inoremap () ()<Left>
inoremap "" ""<Left>
inoremap '' ''<Left>
inoremap <> <><Left>
"
" expand path
cmap <C-x> <C-r>=expand('%:p:h')<CR>/
" expand file
cmap <C-z> <C-r>=expand('%:p:r')<CR>
" }}}

" # macro
" {{{
inoremap <Leader>date <C-r>=strftime('%Y/%m/%d(%a)')<CR>
inoremap <Leader>dl <C-r>=repeat('-', 75)<CR>
" }}}
"
" # file type
" {{{
" ## vim
" {{{
autocmd BufRead *.vim call s:filetype_vim()
autocmd FileType vim call s:filetype_vim()
function! s:filetype_vim()
  set tabstop=2
  set shiftwidth=2
endfunction
" }}}
"
" ## perl
" {{{
autocmd BufRead *.pl call s:filetype_pl()
autocmd FileType perl call s:filetype_pl()
function! s:filetype_pl()
  set tabstop=4
  set shiftwidth=4
endfunction
" }}}
"
" ## javascript
" {{{
autocmd BufRead *.js call s:filetype_js()
autocmd FileType javascript call s:filetype_js()
function! s:filetype_js()
  set tabstop=4
  set shiftwidth=4
endfunction
" }}}
"
" ## vba
" {{{
autocmd BufRead *.bas call s:filetype_bas()
autocmd FileType vb call s:filetype_bas()
function! s:filetype_bas()
  set tabstop=4
  set shiftwidth=4
endfunction
" }}}
" }}}
"
" # plugin
" {{{
" ## gmarik/vundle
" {{{
filetype off
set rtp+=$MYVIM/bundle/vundle
call vundle#rc( '$MYVIM/bundle' )
" self-managing
Bundle 'gmarik/vundle'
" github
Bundle 'thinca/vim-quickrun'
Bundle 'mattn/zencoding-vim'
Bundle 'mattn/gist-vim'
Bundle 'mattn/calendar-vim'
Bundle 'Shougo/neocomplcache'
Bundle 'Shougo/unite.vim'
Bundle 'kaneshin/vimever-vim'
Bundle 'tpope/vim-repeat'
" www.vim.org
Bundle 'TwitVim'
Bundle 'surround.vim'
Bundle 'shomarks.vim'
" Bundle
filetype plugin indent on
" using BundleInstall for installing vim plugin 
command! MyBundleInstall :call s:my_bundle()
function! s:my_bundle()
  set noshellslash
  :BundleInstall!
  set shellslash
endfunction
nnoremap ,bi :<C-u>BundleMyInstall<CR>
" }}}
" ## TwitVim
" {{{
let g:twitvim_count = 30
nnoremap ,tp :<C-u>PosttoTwitter<CR>
nnoremap ,tf :<C-u>FriendsTwitter<CR><C-w>j
nnoremap ,tu :<C-u>UserTwitter<CR><C-w>j
nnoremap ,tr :<C-u>RepliesTwitter<CR><C-w>j
nnoremap ,tn :<C-u>NextTwitter<CR>
nnoremap ,tb :<C-u>BackTwitter<CR>
autocmd FileType twitvim call s:twitvim_my_settings()
function! s:twitvim_my_settings()
  set nowrap
endfunction
" }}}
" ## mattn/gist-vim
" {{{
" --- gist setting ---
" let g:github_user = 'kaneshin'
" let g:github_token = '<api token>'
" let g:gist_privates = 1
" --- key map ---
" post to gist
nnoremap ,gs :<C-u>Gist<CR>
" update gist
nnoremap ,ge :<C-u>Gist -e<CR>
" private post
nnoremap ,gp :<C-u>Gist -p<CR>
" my list
nnoremap ,gl :<C-u>Gist -l<CR>
" all list
nnoremap ,gla :<C-u>Gist -la<CR>
" delete gist
nnoremap ,gd :<C-u>Gist -d<CR>
" fork gist
nnoremap ,gf :<C-u>Gist -f<CR>
" }}}
" ## surround.vim
" {{{
" }}}
" ## tpope/vim-repeat
" {{{
" }}}
" ## vimever.vim
" {{{
" }}}
" ## thinca/vim-quickrun
" {{{
" }}}
" ## mattn/zencoding-vim
" {{{
" }}}
" ## Shougo/unite.vim
" {{{
if exists( 'g:my_unite_flag' ) && g:my_unite_flag != 0
endif
" }}}
" ## Shougo/neocomplcache
" {{{
if exists( 'g:my_neocomplcache_flag' ) && g:my_neocomplcache_flag != 0
  " Disable AutoComplPop.
  let g:acp_enableAtStartup = 0
  " Use neocomplcache.
  let g:neocomplcache_enable_at_startup = 1
  " Use smartcase.
  let g:neocomplcache_enable_smart_case = 1
  " Use camel case completion.
  let g:neocomplcache_enable_camel_case_completion = 1
  " Use underbar completion.
  let g:neocomplcache_enable_underbar_completion = 1
  " Set minimum syntax keyword length.
  let g:neocomplcache_min_syntax_length = 3
  let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
  
  " Define keyword.
  if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
  endif
  let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
  
  " Plugin key-mappings.
  imap <C-f>     <Plug>(neocomplcache_snippets_expand)
  smap <C-f>     <Plug>(neocomplcache_snippets_expand)
  " inoremap <expr><C-g>     neocomplcache#undo_completion()
  " inoremap <expr><C-l>     neocomplcache#complete_common_string()
  
  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  " inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
  " inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
  " inoremap <expr><C-y>  neocomplcache#close_popup()
  " inoremap <expr><C-e>  neocomplcache#cancel_popup()
  
  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  
  " Enable heavy omni completion.
  if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
  endif
  let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
  "autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
  let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
  let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
  let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'
endif
" }}}
" }}}
"
