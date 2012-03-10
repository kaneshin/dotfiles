" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set foldmethod=marker foldmarker={{{,}}}:
"===========================================================================
" File: .vimrc
" Last Change: 08-Mar-2012.
" Maintainer: Shintaro Kaneko <kaneshin0120@gmail.com>
" Description:
" ToDo:
"   選択した行を実行
" Note:
"   1.  I'd like to make a plugin(At first, making here) that collect ToDo
"       from current buffer.
"===========================================================================
"
" ##### basic setting
scriptencoding utf-8
syntax on
filetype plugin indent on
"
" ##### utilities {{{
" ########## variables {{{
" Mac (not on terminal)
let s:is_mac = has( 'mac' )
" Windows (not on terminal)
let s:is_win = ( has( 'win32' ) || has( 'win64' ) )
" UNIX
let s:is_unix = has( 'unix' ) && !s:is_mac && !s:is_win
" $MYVIM
let $MYVIM = s:is_win ? expand( '$HOME/vimfiles' ) : expand( '$HOME/.vim' )
" $MYHOME
if !exists( '$MYHOME' )
  if s:is_win
    if ( $USERDOMAIN == 'KANESHIN-ASUS' )
      let $MYHOME = 'C:\Users\kaneshin'
    elseif ( $USERDOMAIN == 'KANESHIN-HP')
      let $MYHOME = 'C:\home\kaneshin'
    endif
  elseif s:is_mac
    let $MYHOME = '/Users/kaneshin0120'
  elseif s:is_unix
    let $MYHOME = '/home/kaneshin'
  else
    echoe "Can't find $MYHOME in .vimrc."
  endif
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
if filereadable( expand( '$DROPBOX/dev/dotfiles/.vimrc' ) )
  command! EditVimrc :tabe $DROPBOX/dev/dotfiles/.vimrc
  command! ReadVimrc :source $DROPBOX/dev/dotfiles/.vimrc
  nnoremap <silent> ,ev :EditVimrc<CR>
  nnoremap <silent> ,rv :ReadVimrc<CR>
endif
if filereadable( expand( '$DROPBOX/dev/dotfiles/.gvimrc' ) )
  command! EditGVimrc :tabe $DROPBOX/dev/dotfiles/.gvimrc
  command! ReadGVimrc :source $DROPBOX/dev/dotfiles/.gvimrc
  nnoremap <silent> ,eg :EditGVimrc<CR>
  nnoremap <silent> ,rg :ReadGVimrc<CR>
endif
nnoremap <silent> <C-s> :confirm browse saveas<CR>
nnoremap <silent> <C-Tab> :tabnext<CR>
nnoremap <silent> <C-S-Tab> :tabprevious<CR>
" insert mode
imap <silent> <Leader>date <C-r>=strftime('%Y/%m/%d(%a)')<CR>
imap <silent> <Leader>time <C-r>=strftime('%H:%M')<CR>
imap <silent> <Leader>line- <C-r>=repeat('-', 75)<CR>
imap <silent> <Leader>line= <C-r>=repeat('=', 75)<CR>
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
" inoremap <C-s> <BS>
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
nnoremap <silent> <C-x>2 :split<CR>
nnoremap <silent> <C-x>3 :vsplit<CR>
nnoremap <silent> <C-x>4 :BufExplorer<CR>
nnoremap <silent> <C-x>n :new<CR>
nnoremap <silent> <C-x>v :vnew<CR>
nnoremap <silent> <C-x>c :close<CR>
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
  echoe "Can't save as a backup file."
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
if s:is_win
  set titlestring=[%l/%L:%c/%{col('$')-1}]\ %t%(\ %M%)\ (%F)%=%<%{g:HahHah()}
endif
"
" ########## display#tabline
set showtabline=2
set tabline=%!MyTabLine()
function! MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let mod = len(filter(copy(buflist), 'getbufvar(v:val, "&modified")')) ? '+ ' : ''
  let fname = bufname(buflist[winnr - 1])
  let tablb = mod . pathshorten(fname != '' ? fname : 'New File')
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
set listchars=eol:\ ,tab:>\ ,trail:S,extends:<
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
" NOTE: Vim turn off the compatible mode, if Vim find vimrc or gvimrc.
" set nocompatible
set noshellslash
set nrformats+=alpha
set nrformats+=octal
set nrformats+=hex
set history=300
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
Bundle 'mattn/vimplenote-vim'
Bundle 'mattn/gist-vim'
Bundle 'mattn/zencoding-vim'
Bundle 'mattn/sonictemplate-vim'
Bundle 'mattn/calendar-vim'
Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-ref'
Bundle 'thinca/vim-prettyprint'
Bundle 'tyru/restart.vim'
Bundle 'tyru/caw.vim'
Bundle 'markabe/bufexplorer'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'kaneshin/hahhah-vim'
" testing
Bundle 'tpope/vim-repeat'
Bundle 't9md/vim-quickhl'
Bundle 'dannyob/quickfixstatus'
Bundle 'vim-scripts/Highlight-UnMatched-Brackets'
Bundle 'c9s/perlomni.vim'
Bundle 'kana/vim-smartchr'
Bundle 'motemen/git-vim'
" www.vim.org
Bundle 'TwitVim'
Bundle 'surround.vim'
" colorscheme
Bundle 'mrtazz/molokai.vim'
Bundle 'Wombat'
" playspace
" Bundle 'koron/nyancat-vim'
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
nmap ,vl :<C-u>VimpleNote -l<CR>\ado<CR>
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
" ########## kana/vim-smartchr {{{
" inoremap <buffer> <expr> = smartchr#one_of('=', ' = ', ' == ')
" }}}
"
" ########## thinca/vim-quickrun {{{
" }}}
"
" ########## Shougo/neocomplcache {{{
function! MyNeoComplMap()
  imap <C-s> <Plug>(neocomplcache_snippets_expand)
  smap <C-s> <Plug>(neocomplcache_snippets_expand)
  inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
  " inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
  " inoremap <expr><C-y>  neocomplcache#close_popup()
  " inoremap <expr><C-e>  neocomplcache#cancel_popup()
endfunction
function! NeoComplCacheToggle()
  if s:neocom_is_enable
    let s:neocom_is_enable = 0
    call neocomplcache#disable()
    echo 'NeoComplCache is disabled'
    inoremap <C-s> <BS>
    inoremap <CR>  <CR>
    inoremap <TAB> <TAB>
  else
    let s:neocom_is_enable = 1
    call neocomplcache#enable()
    call MyNeoComplMap()
    echo 'NeoComplCache is enabled'
  endif
endfunction
let g:neocomplcache_enable_at_startup = 0
let s:neocom_is_enable = g:neocomplcache_enable_at_startup
if s:neocom_is_enable
  call MyNeoComplMap()
endif
" nnoremap <expr> <C-Space> NeoComplCacheToggle()
" let g:neocomplcache_enable_smart_case = 1
" let g:neocomplcache_enable_camel_case_completion = 1
" let g:neocomplcache_enable_underbar_completion = 1
" let g:neocomplcache_min_syntax_length = 3
" let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
" let g:neocomplcache_dictionary_filetype_lists = {
"     \ 'default' : ''
"     \ }
" " Define keyword.
" if !exists('g:neocomplcache_keyword_patterns')
"   let g:neocomplcache_keyword_patterns = {}
" endif
" let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
" " Enable omni completion.
" autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
" autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
" autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
" autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
" autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
" " Enable heavy omni completion.
" if !exists('g:neocomplcache_omni_patterns')
"   let g:neocomplcache_omni_patterns = {}
" endif
" let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
" "autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
" let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
" let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
" let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'
" }}}
"
" /=plugin }}}
"
" EOF
