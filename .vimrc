" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set foldmethod=marker foldmarker={{{,}}}:
"===========================================================================
" File: .vimrc
" Last Change: 30-Nov-2011.
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
let s:is_win = has( 'win32' ) || has( 'win64' )
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
if finddir('view', $MYVIM) != ''
  set viewdir=$MYVIM/view
"  autocmd BufWritePost * mkview
"  autocmd BufReadPost * loadview
endif
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
set scrolloff=3
set linespace=1
set wrap
set list
set listchars=eol:\ ,tab:>\ ,trail:ｽ,extends:<
"
" ## display#below
let s:hahhahpos = 0
if !has('unix') || $VTE_CJK_WIDTH != ''
  let s:hahhahstr = [
        \"( ´д`)",
        \"(  ´д)",
        \"(    ´)",
        \"(      )",
        \"(      )",
        \"( ;    )",
        \"(` ;   )",
        \"(д` ; )",
        \"(´д`;)",
        \]
else
  let s:hahhahstr = [
        \"(  ´ д `)",
        \"(   ´ д )",
        \"(   ´ )",
        \"(     )",
        \"(    )",
        \"( ;   )",
        \"(` ;  )",
        \"(д `;  )",
        \"(´ д `; )",
        \"( ´ д `;)",
        \]
endif
function! g:HahHah()
  let s:hahhahpos = (s:hahhahpos + 1) % len(s:hahhahstr)
  return s:hahhahstr[s:hahhahpos] . ' ﾊｧﾊｧ'
endfunction
" let &statusline = '%t %m%h%r%q%=%l-%c%V %p %=%{g:HahHah()}'
set statusline=%<%t\ %m%r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}%=[%l/%L,%c/%{col('$')-1}][0x\%02.2B]%{g:HahHah()}
set ruler
set showcmd
set laststatus=2
set cmdheight=2
set wildmenu
set wildmode=list:longest
"
" ## cursor
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
set noshellslash
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
" cnoremap <C-a> <Home>
" cnoremap <C-e> <End>
" cnoremap <C-b> <Left>
" cnoremap <C-f> <Right>
" cnoremap <C-n> <Down>
" cnoremap <C-p> <Up>
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
inoremap <Leader>p <ESC>pi
inoremap {} {}<Left>
inoremap [] []<Left>
inoremap () ()<Left>
inoremap "" ""<Left>
inoremap '' ''<Left>
inoremap <> <><Left>
inoremap %% %%<Left>
cnoremap {} {}<Left>
cnoremap [] []<Left>
cnoremap () ()<Left>
cnoremap "" ""<Left>
cnoremap '' ''<Left>
cnoremap <> <><Left>
"
" expand path
cmap <C-x> <C-r>=expand('%:p:h')<CR>/
" expand file
cmap <C-z> <C-r>=expand('%:p:r')<CR>

" my email address
cmap <C-e> kaneshin0120@gmail.com

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
autocmd FileType vim call s:filetype_vim()
autocmd BufReadPost,BufNewFile *.vim call s:filetype_vim()
function! s:filetype_vim()
  set tabstop=2
  set shiftwidth=2
endfunction
" }}}
"
" ## perl
" {{{
autocmd FileType perl call s:filetype_pl()
autocmd BufReadPost,BufNewFile *.pl,*.pm,*.t call s:filetype_pl()
function! s:filetype_pl()
  set tabstop=4
  set shiftwidth=4
endfunction
" }}}
"
" ## javascript
" {{{
autocmd FileType javascript call s:filetype_js()
autocmd BufReadPost,BufNewFile *.js call s:filetype_js()
function! s:filetype_js()
  set tabstop=4
  set shiftwidth=4
endfunction
" }}}
"
" ## vba
" {{{
autocmd FileType vb call s:filetype_vb()
autocmd BufReadPost,BufNewFile *.bas call s:filetype_vb()
function! s:filetype_vb()
  set tabstop=4
  set shiftwidth=4
endfunction
" }}}
" }}}
"
" # plugin
" {{{
"
" ## gmarik/vundle
" {{{
filetype off
set rtp+=$MYVIM/bundle/vundle
call vundle#rc( '$MYVIM/bundle' )
" github
Bundle 'gmarik/vundle'
Bundle 'mattn/webapi-vim'
Bundle 'mattn/zencoding-vim'
Bundle 'mattn/vimplenote-vim'
Bundle 'mattn/sonictemplate-vim'
" Bundle 'mattn/gist-vim'
Bundle 'mattn/calendar-vim'
Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-ref'
Bundle 'tpope/vim-repeat'
Bundle 'markabe/bufexplorer'
" www.vim.org
Bundle 'TwitVim'
Bundle 'surround.vim'
" Bundle
filetype plugin indent on
" }}}
"
" ## mattn/vimplenote-vim
" {{{
"
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
" let g:github_token = ''
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
" ## mattn/vimplenote-vim
" {{{
" list all notes
nnoremap ,vl :<C-u>VimpleNote -l<CR>
" move note to trash
nnoremap ,vd :<C-u>VimpleNote -d<CR>
" delete note in current buffer
nnoremap ,vD :<C-u>VimpleNote -D<CR>
" tag note in current buffer
nnoremap ,vt :<C-u>VimpleNote -t<CR>
" create new note from buffer
nnoremap ,vn :<C-u>VimpleNote -n<CR>
" update a note from buffer
nnoremap ,vu :<C-u>VimpleNote -u<CR>
" search notes with tags
nnoremap ,vs :<C-u>VimpleNote -s<CR>
" }}}
" }}}
"
" EOF
