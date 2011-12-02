" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set foldmethod=marker foldmarker={{{,}}}:
"===========================================================================
" File: .vimrc
" Last Change: 03-Dec-2011.
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
" ########## commands {{{
" .vimrc
if filereadable( expand( '$DROPBOX/dotfiles/.vimrc' ) )
  command! EditVimrc :tabe $DROPBOX/dotfiles/.vimrc
  command! ReadVimrc :source $DROPBOX/dotfiles/.vimrc
endif
" .gvimrc
if filereadable( expand( '$DROPBOX/dotfiles/.gvimrc' ) )
  command! EditGVimrc :tabe $DROPBOX/dotfiles/.gvimrc
  command! ReadGVimrc :source $DROPBOX/dotfiles/.gvimrc
endif
" /=commands }}}
"
" ########## functions {{{
if !has('unix') || ($VTE_CJK_WIDTH != '' && &ambiwidth == 'double')
  let s:hahhahstd = [
  \ '(´д｀;)',
  \ '( ´д`;)',
  \ '(  ´д`)',
  \ '(   ´д)',
  \ '(     ´)',
  \ '(       )',
  \ '(       )',
  \ '(;      )',
  \ '( ;     )',
  \ '(` ;    )',
  \ '(д` ;  )']
else
  let s:hahhahstd = [
  \ '(´ д｀; )',
  \ '( ´ д `;)',
  \ '(  ´ д `)',
  \ '(   ´ д )',
  \ '(     ´ )',
  \ '(       )',
  \ '(       )',
  \ '(;      )',
  \ '( ;     )',
  \ '(` ;    )',
  \ '(д `;   )']
endif
let s:hahstr = [
  \ '  ﾊｧ  ',
  \ ' ﾊｧﾊｧ ',
  \ 'ﾊｧﾊｧﾊｧ',
  \ ' ﾊｧﾊｧ ',
\ ]
let s:hahstdpos = 0
let s:leftnum = 0
let s:rightnum = 0
let s:hahflg = 0
function! g:HahHah()
  let s:hahstdpos = (s:hahstdpos + 1) % len(s:hahhahstd)
  if localtime() % 2
    let s:hahflg = 1
  endif
  if !(localtime() % 2) && s:hahflg
    let s:hahflg = 0
    let s:leftnum = (s:leftnum + 1) % len(s:hahstr)
    let s:rightnum = (s:rightnum + 1)  % len(s:hahstr)
  endif
  return s:hahstr[s:leftnum].s:hahhahstd[s:hahstdpos].s:hahstr[s:rightnum]
endfunction
function! s:guiopt()
  if &guioptions =~ 'm'
    exec 'set guioptions-=m'
  else
    exec 'set guioptions+=m'
  endif
endfunction
" /=functions }}}
"
" ########## macros {{{
" normal mode
nnoremap <C-F1> :help<Space>
nnoremap <silent> <C-F4> :tabclose<CR>
" nnoremap <silent> <C-F5> :source %<CR>
nnoremap <silent> <C-F11> :call <SID>guiopt()<CR>
nnoremap <silent> <C-F12> :confirm browse saveas<CR>
nnoremap <silent> <C-s> :confirm browse saveas<CR>
nnoremap <silent> <C-Tab> :tabnext<CR>
nnoremap <silent> <C-S-Tab> :tabprevious<CR>
nnoremap <silent> ,ev :EditVimrc<CR>
nnoremap <silent> ,rv :ReadVimrc<CR>
nnoremap <silent> ,eg :EditGVimrc<CR>
nnoremap <silent> ,rg :ReadGVimrc<CR>
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
" move
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
" window
nnoremap <silent> <C-x>0 <C-w>c
nnoremap <silent> <C-x>1 <C-w>o
nnoremap <silent> <C-x>2 <C-w>s
nnoremap <silent> <C-x>3 <C-w>v
nnoremap <C-S-j> <C-w>k<C-e><C-w><C-w>
" buffer
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>
" edit
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
" inoremap <Space><Space> <Space><Space><Left>
inoremap // //<Space>
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
" ########## display#main
set splitbelow
set splitright
set title
set titlelen=80
set number
set scrolloff=3
set linespace=1
set wrap
set list
set listchars=eol:\ ,tab:>ﾀ,trail:ｽ,extends:<
"
" ########## display#below
set statusline=
      \%<%t\ %m%r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}
      \%=[%l/%L,%c/%{col('$')-1}][0x\%02.2B]%{g:HahHah()}
set ruler
set showcmd
set laststatus=2
set cmdheight=2
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
set nocompatible
set noshellslash
set nrformats+=alpha
set nrformats+=octal
set nrformats+=hex
set history=50
" /=options }}}
"

" ##### file type {{{
" ########## vim {{{
autocmd FileType vim call s:filetype_vim()
autocmd BufReadPost,BufNewFile *.vim call s:filetype_vim()
function! s:filetype_vim()
  set tabstop=2
  set shiftwidth=2
endfunction
" /=vim }}}
"
" ########## perl {{{
autocmd FileType perl call s:filetype_pl()
autocmd BufReadPost,BufNewFile *.pl,*.pm,*.t call s:filetype_pl()
function! s:filetype_pl()
  set tabstop=4
  set shiftwidth=4
endfunction
" /=perl }}}
"
" ########## javascript {{{
autocmd FileType javascript call s:filetype_js()
autocmd BufReadPost,BufNewFile *.js call s:filetype_js()
function! s:filetype_js()
  set tabstop=4
  set shiftwidth=4
endfunction
" /=javascript }}}
"
" ########## c {{{
autocmd FileType c call s:filetype_c()
autocmd BufReadPost,BufNewFile *.c call s:filetype_c()
function! s:filetype_c()
  set tabstop=4
  set shiftwidth=4
  set noexpandtab
endfunction
" /=c }}}
"
" ########## html {{{
autocmd FileType html call s:filetype_html()
autocmd BufReadPost,BufNewFile *.html,*.htm call s:filetype_html()
function! s:filetype_html()
  set tabstop=4
  set shiftwidth=4
endfunction
" /=html }}}
"
" ########## css {{{
autocmd FileType css call s:filetype_css()
autocmd BufReadPost,BufNewFile *.css call s:filetype_css()
function! s:filetype_css()
  set tabstop=4
  set shiftwidth=4
endfunction
" /=css }}}
"
" ########## vbs {{{
autocmd FileType vb call s:filetype_vb()
autocmd BufReadPost,BufNewFile *.bas call s:filetype_vb()
function! s:filetype_vb()
  set tabstop=4
  set shiftwidth=4
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
Bundle 'mattn/zencoding-vim'
Bundle 'mattn/vimplenote-vim'
Bundle 'mattn/sonictemplate-vim'
Bundle 'mattn/gist-vim'
Bundle 'mattn/calendar-vim'
Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-ref'
Bundle 'tpope/vim-repeat'
Bundle 'markabe/bufexplorer'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'thinca/vim-prettyprint'
Bundle 'tyru/restart.vim'
Bundle 't9md/vim-quickhl'
Bundle 'dannyob/quickfixstatus'
Bundle 'tyru/caw.vim'
Bundle 'vim-scripts/Highlight-UnMatched-Brackets'
Bundle 'hotchpotch/perldoc-vim'
Bundle 'c9s/perlomni.vim'
" www.vim.org
Bundle 'TwitVim'
Bundle 'surround.vim'
filetype plugin indent on
" /=gmarik/vundle }}}
"
" ########## TwitVim {{{
let g:twitvim_count = 50
if s:is_win
  let g:twitvim_browser_cmd
      \ = $HOME.'\AppData\Local\Google\Chrome\Application\chrome.exe'
elseif s:is_unix
  let g:twitvim_browser_cmd
      \ = ''
endif
nnoremap ,twp :<C-u>PosttoTwitter<CR>
nnoremap ,twl :tabe<CR>:<C-u>ListTwitter refav<CR><C-w>c
nnoremap ,twf :tabe<CR>:<C-u>FriendsTwitter<CR><C-w>c
nnoremap ,twu :<C-u>UserTwitter<CR><C-w>j
nnoremap ,twr :<C-u>RepliesTwitter<CR><C-w>j
nnoremap ,twn :<C-u>NextTwitter<CR>
nnoremap ,twb :<C-u>BackTwitter<CR>
autocmd FileType twitvim call s:twitvim_my_settings()
function! s:twitvim_my_settings()
  set nowrap
endfunction
nnoremap ,twh :call <SID>twitvim_my_help()<CR>
function! s:twitvim_my_help()
  echo ',twp :<C-u>PosttoTwitter<CR>'
  echo ',twl :tabe<CR>:<C-u>ListTwitter refav<CR><C-w>c'
  echo ',twf :tabe<CR>:<C-u>FriendsTwitter<CR><C-w>c'
  echo ',twu :<C-u>UserTwitter<CR><C-w>j'
  echo ',twr :<C-u>RepliesTwitter<CR><C-w>j'
  echo ',twn :<C-u>NextTwitter<CR>'
  echo ',twb :<C-u>BackTwitter<CR>'
  echo '<Leader><Leader> :RefreshTwitter'
  echo '<Leader>r Not official retweet'
  echo '<Leader>R Official retweet'
  echo '<Leader>g Open URL on your browser('.g:twitvim_browser_cmd.')'
endfunction
" /=TwitVim }}}
"
" ## mattn/gist-vim {{{
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
" /=mattn/gist-vim }}}
"
" ########## mattn/vimplenote-vim {{{
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
" /=mattn/vimplenote-vim }}}
"
" tyru/restart.vim {{{
let g:restart_sessionoptions
    \ = 'blank,buffers,curdir,folds,help,localoptions,tabpages'
" /=tyru/restart.vim }}}
" /=plugin }}}
"
" EOF
