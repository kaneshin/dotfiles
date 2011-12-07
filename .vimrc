" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set foldmethod=marker foldmarker={{{,}}}:
"===========================================================================
" File: .vimrc
" Last Change: 08-Dec-2011.
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
"===========================================================================
"
" ##### for development {{{
set rtp+=D:/home/kaneshin/Dropbox/workspace/project/alerm-vim
" /=for development }}}

" ##### basic setting
scriptencoding utf-8
syntax on
filetype plugin indent on
"
" ##### utilities {{{
" ########## variables {{{
" Windows
let s:is_win = has( 'win32' ) || has( 'win64' )
" UNIX
let s:is_unix = has( 'unix' )
" $MYVIM(my vim dir)
let $MYVIM = s:is_win ? expand( '$HOME/vimfiles' ) : expand( '$HOME/.vim' )
" $MYHOME
if !exists( '$MYHOME' ) && s:is_win
  if ( $USERDOMAIN == 'KANESHIN-ASUS' )
    let $MYHOME = 'D:\home\kaneshin'
  elseif ( $USERDOMAIN == 'KANESHIN-HP')
    let $MYHOME = 'C:\home\kaneshin'
  endif
else
  let $MYHOME = '/home/kaneshin'
endif
" $DROPBOX
if !exists( '$DROPBOX' ) && filewritable( expand( '$MYHOME/Dropbox' ) )
  let $DROPBOX = $MYHOME.'/Dropbox'
endif
" /=variables }}}
"
" ########## autocmds {{{
" change directory when you open that file.
autocmd BufEnter * execute ':lcd ' . expand('%:p:h')
" /=commands }}}
"
" ########## macros {{{
" normal mode
if filereadable( expand( '$DROPBOX/dotfiles/.vimrc' ) )
  command! EditVimrc :tabe $DROPBOX/dotfiles/.vimrc
  command! ReadVimrc :source $DROPBOX/dotfiles/.vimrc
  nnoremap <silent> ,ev :EditVimrc<CR>
  nnoremap <silent> ,rv :ReadVimrc<CR>
endif
if filereadable( expand( '$DROPBOX/dotfiles/.gvimrc' ) )
  command! EditGVimrc :tabe $DROPBOX/dotfiles/.gvimrc
  command! ReadGVimrc :source $DROPBOX/dotfiles/.gvimrc
  nnoremap <silent> ,eg :EditGVimrc<CR>
  nnoremap <silent> ,rg :ReadGVimrc<CR>
endif
if has( 'gui_runnig' )
  nnoremap <silent> <C-F11> :call <SID>my_guioptions()<CR>
  function! s:my_guioptions()
    if &guioptions =~ 'm'
      exec 'set guioptions-=m'
    else
      exec 'set guioptions+=m'
    endif
  endfunction
endif
nnoremap <C-F1> :help<Space>
nnoremap <silent> <C-F4> :tabclose<CR>
nnoremap <silent> <C-F12> :confirm browse saveas<CR>
nnoremap <silent> <C-s> :confirm browse saveas<CR>
nnoremap <silent> <C-Tab> :tabnext<CR>
nnoremap <silent> <C-S-Tab> :tabprevious<CR>
" insert mode
imap <silent> <Leader>date <C-r>=strftime('%Y/%m/%d(%a)')<CR>
imap <silent> <Leader>time <C-r>=strftime('%H:%M')<CR>
imap <silent> <Leader>dl <C-r>=repeat('-', 75)<CR>
inoremap <Leader>email kaneshin0120@gmail.com
inoremap <Leader>ado kaneshin0120@gmail.com
" command mode
cnoremap <Leader>email kaneshin0120@gmail.com
cnoremap <Leader>ado kaneshin0120@gmail.com
cmap <C-x> <C-r>=expand('%:p:h')<CR>/
cmap <C-z> <C-r>=expand('%:p:r')<CR>
" /=macros }}}
"
" ########## key mapping {{{
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-s> <BS>
inoremap <C-d> <ESC><S-d><S-a>
inoremap <C-f> <ESC>
inoremap <C-g> <CR>
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-r><C-r> <C-r>"
inoremap <Leader>reg <ESC>:registers<CR>
inoremap // //<Space>

nnoremap <silent> <C-x>0 :close<CR>
nnoremap <silent> <C-x>1 :only<CR>
nnoremap <silent> <C-x>2 :new<CR>
nnoremap <silent> <C-x>3 :vnew<CR>
nnoremap <silent> <C-x>4 :BufExplorer<CR>
nnoremap <silent> <C-n> :bnext<CR>
nnoremap <silent> <C-p> :bprevious<CR>
nnoremap <silent> d<C-r> :let @"=""<CR>

" emacs key bind in command mode
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>

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
cnoremap %% %%<Left>
" /=key mapping }}}
"
" /=utilities }}}
"
" ##### options {{{
" ########## backup, swap
if finddir('backup', $MYVIM) != ''
  set backup
  set backupext=.bak
  set backupdir=$MYVIM/backup
  set swapfile
  set directory=$MYVIM/backup
else
  echo "can't save a backup file."
  set nobackup
  set noswapfile
endif
"
" ########## fold
if finddir('view', $MYVIM) != ''
  set viewdir=$MYVIM/view
"  autocmd BufWritePost * mkview
"  autocmd BufReadPost * loadview
endif
"
" ########## encoding
set fileencodings=utf-8,euc-jp,cp932,shiftjis,iso-2022-jp,latin1
set fileformats=unix,dos,mac
" set encoding=utf-8
" set fileencoding=utf-8
" set fileformat=unix
"
" ########## display#title
set title
set titlelen=90
set titlestring=%t%(\ %M%)\ (%F)\ L=%l/%L\ :\ C=%c/%{col('$')-1}%=%<%{g:HahHah()}
"
" ########## display#tabline
set showtabline=2
set tabline=%!MyTabLine()
function! MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let mod = len(filter(copy(buflist), 'getbufvar(v:val, "&modified")')) ? '+ ' : ''
  let fname = bufname(buflist[winnr - 1])
  let tablb = mod . pathshorten(fname != '' ? fname : '名前が無いよ')
  let hi = (a:n == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#' )
  return '%'.a:n.'T' . hi . ' ' . tablb . ' ' . '%T%#TabLineFill#'
endfunction
function! MyTabLine()
  let tabrange = range(1, tabpagenr('$'))
  let sep = ' '
  let tabln = ' '
  for i in tabrange
    let tabln .= MyTabLabel(i)
    let tabln .= sep
  endfor
  let tabln .= '%=%<@*['.@*.'] '
  return tabln
endfunction
"
" ########## display#main
set splitbelow
set splitright
set number
set scrolloff=3
set linespace=1
set wrap
set list
set listchars=eol:\ ,tab:>\ ,trail:ｽ,extends:<
"
" ########## display#below
set laststatus=2
set cmdheight=2
set statusline=%!MyStatusLine()
function! MyStatusLine()
  let stsln = "%t\ %m%r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}[0x\%02.2B]"
      \ ."%=%<%{'@\"['.@\".']\ @/[/'.@/.']'}"
  return stsln
endfunction
set ruler
set showcmd
set wildmenu
set wildmode=list:longest
"
" ########## cursor
set cursorline
set nocursorcolumn
"
" ########## search
set ignorecase
set smartcase
set nowrapscan
set incsearch
nnoremap <ESC><ESC> :nohlsearch<CR>
"
" ########## edit
set autoindent
set smartindent
set showmatch
set backspace=indent,eol,start
set clipboard=unnamed
set pastetoggle=<F12>
set formatoptions+=mM
"
" ########## <Tab>
set tabstop=4
set shiftwidth=4
set softtabstop=0
set expandtab
set smarttab
"
" ########## etc
" NOTE: compatible is switched off if Vim figure out vimrc or gvimrc when Vim run.
" set nocompatible
set noshellslash
set nrformats+=alpha
set nrformats+=octal
set nrformats+=hex
set history=100
" /=options }}}
"
" ##### file type {{{
" ########## common setting {{{
function! s:my_common()
endfunction
" }}}
" ########## vim {{{
autocmd FileType vim call s:filetype_vim()
function! s:filetype_vim()
  setlocal tabstop=2
  setlocal shiftwidth=2
endfunction
" /=vim }}}
"
" ########## perl {{{
autocmd FileType perl call s:filetype_pl()
function! s:filetype_pl()
  setlocal tabstop=4
  setlocal shiftwidth=4
endfunction
" /=perl }}}
"
" ########## javascript {{{
autocmd FileType javascript call s:filetype_js()
function! s:filetype_js()
  setlocal tabstop=4
  setlocal shiftwidth=4
endfunction
" /=javascript }}}
"
" ########## c {{{
autocmd FileType c call s:filetype_c()
function! s:filetype_c()
  setlocal tabstop=4
  setlocal shiftwidth=4
endfunction
" /=c }}}
"
" ########## html {{{
autocmd FileType html call s:filetype_html()
function! s:filetype_html()
  setlocal tabstop=4
  setlocal shiftwidth=4
endfunction
" /=html }}}
"
" ########## css {{{
autocmd FileType css call s:filetype_css()
function! s:filetype_css()
  setlocal tabstop=4
  setlocal shiftwidth=4
endfunction
" /=css }}}
"
" ########## vbs {{{
autocmd FileType vb call s:filetype_vb()
function! s:filetype_vb()
  setlocal tabstop=4
  setlocal shiftwidth=4
endfunction
" /=vbs }}}
"
" ########## markdown {{{
autocmd FileType markdown call s:filetype_mkd()
function! s:filetype_mkd()
  setlocal tabstop=4
  setlocal shiftwidth=4
endfunction
" /=vbs }}}
" /=file type }}}
"
" ##### plugin {{{
" ########## gmarik/vundle {{{
filetype off
set rtp+=$MYVIM/bundle/vundle
call vundle#rc( '$MYVIM/bundle' )
" github
Bundle 'gmarik/vundle'
Bundle 'mattn/webapi-vim'
Bundle 'mattn/gist-vim'
Bundle 'mattn/vimplenote-vim'
Bundle 'mattn/sonictemplate-vim'
Bundle 'mattn/zencoding-vim'
Bundle 'mattn/calendar-vim'
Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-ref'
Bundle 'thinca/vim-prettyprint'
Bundle 'tyru/restart.vim'
Bundle 'tyru/caw.vim'
Bundle 'kaneshin/hahhah-vim'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'tpope/vim-repeat'
Bundle 'markabe/bufexplorer'
Bundle 't9md/vim-quickhl'
Bundle 'dannyob/quickfixstatus'
Bundle 'vim-scripts/Highlight-UnMatched-Brackets'
Bundle 'hotchpotch/perldoc-vim'
Bundle 'c9s/perlomni.vim'
Bundle 'kana/vim-smartchr'
" www.vim.org
Bundle 'TwitVim'
Bundle 'surround.vim'
Bundle 'Align'
" colorscheme
Bundle 'mrtazz/molokai.vim'
filetype plugin indent on
" /=gmarik/vundle }}}

" ########## TwitVim {{{
let g:twitvim_count = 50
if s:is_win
  let g:twitvim_browser_cmd
      \ = $HOME.'\AppData\Local\Google\Chrome\Application\chrome.exe'
elseif s:is_unix
  let g:twitvim_browser_cmd
      \ = ''
endif
nnoremap <silent> ,tp :<C-u>PosttoTwitter<CR>
nnoremap <silent> ,tl :tabnew<CR>:<C-u>ListTwitter refav<CR>:close<CR>
nnoremap <silent> ,tf :tabnew<CR>:<C-u>FriendsTwitter<CR>:close<CR>
nnoremap <silent> ,tu :tabnew<CR>:<C-u>UserTwitter<CR>:close<CR>
nnoremap <silent> ,tr :tabnew<CR>:<C-u>RepliesTwitter<CR>:close<CR>
autocmd FileType twitvim :call s:my_twitvim()
function! s:my_twitvim()
  setlocal nowrap
  nnoremap <buffer> <silent> ,tl :<C-u>ListTwitter refav<CR>
  nnoremap <buffer> <silent> ,tf :<C-u>FriendsTwitter<CR>
  nnoremap <buffer> <silent> ,tu :<C-u>UserTwitter<CR>
  nnoremap <buffer> <silent> ,tr :<C-u>RepliesTwitter<CR>
  nnoremap <buffer> <silent> ,tn :<C-u>NextTwitter<CR>
  nnoremap <buffer> <silent> ,tb :<C-u>BackTwitter<CR>
  nnoremap <buffer> <C-n> :<C-u>NextTwitter<CR>
  nnoremap <buffer> <C-p> :<C-u>BackTwitter<CR>
endfunction
" /=TwitVim }}}
"
" ########## mattn/vimplenote-vim {{{
nmap ,vl :<C-u>VimpleNote -l<CR>\ado
nnoremap ,vd :<C-u>VimpleNote -d<CR>
nnoremap ,vD :<C-u>VimpleNote -D<CR>
nnoremap ,vt :<C-u>VimpleNote -t<CR>
nnoremap ,vn :<C-u>VimpleNote -n<CR>
nnoremap ,vu :<C-u>VimpleNote -u<CR>
nnoremap ,vs :<C-u>VimpleNote -s<CR>
" /=mattn/vimplenote-vim }}}
"
" ########## mattn/gist-vim {{{
" --- gist setting ---
" let g:github_user = 'kaneshin'
" let g:github_token = ''
" let g:gist_privates = 1
" --- key map ---
nnoremap ,gs :<C-u>Gist<CR>
nnoremap ,ge :<C-u>Gist -e<CR>
nnoremap ,gp :<C-u>Gist -p<CR>
nnoremap ,gl :<C-u>Gist -l<CR>
nnoremap ,gla :<C-u>Gist -la<CR>
nnoremap ,gd :<C-u>Gist -d<CR>
nnoremap ,gf :<C-u>Gist -f<CR>
" /=mattn/gist-vim }}}
"
" ########## tyru/restart.vim {{{
let g:restart_sessionoptions
    \ = 'blank,buffers,curdir,folds,help,localoptions,tabpages'
" /=tyru/restart.vim }}}
"
" ########## Lokaltog/vim-easymotion {{{
let g:EasyMotion_leader_key = '<Leader>'
" }}}
"
" ########## thinca/vim-quickrun {{{
" }}}
"
" ########## tyru/caw.vim {{{
" }}}
"
" /=plugin }}}
"
" EOF
