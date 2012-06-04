" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .vimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 03-Jun-2012.

scriptencoding utf-8
syntax on
filetype plugin on
filetype indent on

" utilities {{{
" ##### variables {{{
" Windows (not on terminal)
let s:is_win = has( 'win32' ) || has( 'win64' )
" Mac (not on terminal)
let s:is_mac = has( 'mac' )
" UNIX or on terminal
let s:is_unix = has( 'unix' ) && !s:is_mac && !s:is_win
" $MYVIM
"     Windows  -> vimfiles/
"   Mac, Linux -> .vim/
if !exists( '$MYVIM' )
  let $MYVIM = s:is_win ? expand( '$HOME/vimfiles' ) : expand( '$HOME/.vim' )
endif
" $MYHOME
if !exists( '$MYHOME' )
  if s:is_win
    if ( $USERDOMAIN == 'KANESHIN-ASUS' )
      let $MYHOME = $HOME
    elseif ( $USERDOMAIN == 'KANESHIN-HP' )
      let $MYHOME = 'C:\home\kaneshin'
    endif
  else
    let $MYHOME = $HOME
  endif
endif
" $DROPBOX
if !exists( '$DROPBOX' ) && filewritable( expand( '$MYHOME/Dropbox' ) )
  let $DROPBOX = $MYHOME.'/Dropbox'
endif
" /=variables }}}

" ##### functions {{{
" status line
function! GetShortenRegister(reg)
  return substitute(substitute(a:reg, '\n', '', 'g'), '^ *\(.\{,15\}\).*$', '\1', '')
endfunction
function! MyStatusLine()
  return "%t\ %m%r%h%w%y"
        \."%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}"
        \."[0x\%02.2B]"
        \."%=%<"
        \."%{'@\"['.GetShortenRegister(@\").']"
        \."\ @/[/'.GetShortenRegister(@/).']'}"
        \."[%l/%L]"
endfunction

" tab label
function! DirInfo(...)
  let dirinfo = fnamemodify(getcwd(), ":~")
  return strlen(dirinfo) > (a:0 > 0 ? a:1 : &titlelen - 20) ? pathshorten(dirinfo) : dirinfo
endfunction
function! MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let mod = filter(copy(buflist), 'getbufvar(v:val, "&modified")')
  let fname = substitute(bufname(buflist[winnr-1]), ".*\\/", "", "")
  let tablb = (len(mod) ? '+ ' : '').(fname != '' ? fname : 'New File')
  let hi = (a:n == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#' )
  return '%'.a:n.'T'.hi.' '.tablb.' '.'%T%#TabLineFill#'
endfunction
function! MyTabLine()
  let tabrange = range(1, tabpagenr('$'))
  let tabstr = ''
  let sep = ' '
  let len = &titlelen - 20
  if (len(tabrange) > 2)
    let tabstr .= sep.'Tab:'.tabpagenr().'/'.tabpagenr('$').sep.MyTabLabel(tabpagenr())
  else
    for i in tabrange
      let tabstr .= sep.MyTabLabel(i)
    endfor
  endif
  return tabstr."%=".DirInfo(len).sep."%{fugitive#statusline()}"
endfunction
" /=functions }}}
"
" ##### semi-plugin {{{
" sticky
" let g:sticky_mode = "ours"
" let s:stickypos = 0
" let s:sticky = {
"         \"eng": [
"             \"I'm gonna go to Japan.",
"             \"I'm gonna be here.",
"             \"Should be ok.",
"             \"Could be ok."
"         \],
"         \"ours": [
" \"Elevator buttons and morning air",
" \"Stranger's silence makes me wanna take the stairs",
" \"If you were here, we'd laugh about their vacant stares",
" \"But right now, my time is theirs",
" \"Seems like there's always someone who disapproves",
" \"They'll judge it like they know about me and you",
" \"And the verdict comes from those with nothing else to do",
" \"The jury's out, but my choice is you",
" \"So don't you worry your pretty little mind",
" \"People throw rocks at things that shine",
" \"And life makes love look hard",
" \"The stakes are high, the water's rough, but this love is ours",
" \"You never know what people have up their sleeves",
" \"Ghosts from your past gonna jump out at me",
" \"Lurking in the shadows with their lip gloss smiles",
" \"But I don't care 'cause right now you're mine",
" \"And you'll say don't you worry your pretty little mind",
" \"People throw rocks at things that shine",
" \"And life makes love look hard",
" \"The stakes are high, the water's rough, but this love is ours",
" \"And it's not theirs to speculate if it's wrong and",
" \"Your hands are tough but they are where mine belong in",
" \"I'll fight their doubt and give you faith with this song for you",
" \"'Cause I love the gap between your teeth",
" \"And I love the riddles that you speak",
" \"And any snide remarks from my father about your tattoos will be ignored",
" \"'Cause my heart is yours",
" \"So don't you worry your pretty little mind",
" \"People throw rocks at things that shine",
" \"And life makes love look hard",
" \"And don't you worry your pretty little mind",
" \"People throw rocks at things that shine",
" \"But they can't take what's ours, they can't take what's ours",
" \"The stakes are high, the water's rough, but this love is ours",
" \]
"     \}
" function! g:Sticky()
"   let s:stickypos += 1
"   let s:stickypos = s:stickypos % len(s:sticky[g:sticky_mode])
"   return s:sticky[g:sticky_mode][s:stickypos]
" endfunction
"
" tab to space
function! s:TabToSpace(...)
  let lines = getbufline(bufnr(bufname('%')), 1, "$")
  let result = []
  for line in lines
    call add(result, substitute(line, "\t",
          \repeat(' ', (a:0 > 0 ? a:1 : &shiftwidth)), "g"))
  endfor
  call setline(1, result)
endfunction
command! -nargs=? TabToSpace call s:TabToSpace(<f-args>)
"
" remove spaces
function! s:RemoveSpace()
  let lines = getbufline(bufnr(bufname('%')), 1, "$")
  let result = []
  for line in lines
    call add(result, substitute(line, " \\+$", "", ""))
  endfor
  call setline(1, result)
endfunction
command! -nargs=0 RemoveSpace call s:RemoveSpace()
" remove spaces of brackets
function! s:RemoveBracketsSpace()
  let line = getline(".")
  let line = substitute(line, "( \\+\\(.\\+\\) \\+)", "(\\1)", "")
  call setline(".", line)
endfunction
command! -nargs=0 RemoveBracketsSpace call s:RemoveBracketsSpace()
" }}}
"
" ##### key mapping {{{
" .vimrc
if filereadable(expand('$DROPBOX/dev/dotfiles/dotfiles/.vimrc'))
  command! EditVimrc :tabe $DROPBOX/dev/dotfiles/dotfiles/.vimrc
  command! ReadVimrc :source $DROPBOX/dev/dotfiles/dotfiles/.vimrc
  nnoremap <silent> ,ev :EditVimrc<CR>
  nnoremap <silent> ,rv :ReadVimrc<CR>
endif
" .gvimrc
if filereadable(expand('$DROPBOX/dev/dotfiles/dotfiles/.gvimrc'))
  command! EditGVimrc :tabe $DROPBOX/dev/dotfiles/dotfiles/.gvimrc
  command! ReadGVimrc :source $DROPBOX/dev/dotfiles/dotfiles/.gvimrc
  nnoremap <silent> ,eg :EditGVimrc<CR>
  nnoremap <silent> ,rg :ReadGVimrc<CR>
endif
" insertion mode
inoremap <C-f> <ESC>
inoremap <c-l><c-h> <Left>
inoremap <c-l><c-j> <esc>O
inoremap <c-l><c-k> <up><end>
inoremap <c-l><c-l> <right>
inoremap <c-l><c-a> <home>
inoremap <c-l><c-e> <end>
inoremap <C-r><C-r> <C-r>"
" normal node
nnoremap <silent> <C-x>0 :close<CR>
nnoremap <silent> <C-x>1 :only<CR>
nnoremap <silent> <C-x>2 :split<CR>
nnoremap <silent> <C-x>3 :vsplit<CR>
nnoremap <silent> <C-x>4 :tabe<CR>:BufExplorer<CR>
nnoremap <silent> <C-x>n :bnext<CR>
nnoremap <silent> <C-x>p :bprevious<CR>
nnoremap <silent> <C-x>k :close<CR>
nnoremap <silent> <ESC><ESC> :nohlsearch<CR>
nnoremap <silent> <C-s> :confirm browse saveas<CR>
nnoremap <silent> <C-u> <C-u>zz
nnoremap <silent> <C-f> <C-f>zz
nnoremap ; :
" command mode
cmap <C-x> <C-r>=expand('%:p:h')<CR>/
cmap <C-z> <C-r>=expand('%:p:r')<CR>
" emacs key bind in command mode
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
cnoremap <C-h> <BS>
" brackets and else
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
" ##### autocmds {{{
" change directory if you open a file.
autocmd BufEnter * execute ':lcd '.expand('%:p:h')
" automatically open a quickfix
autocmd QuickfixCmdPost make,grep,grepadd,vimgrep
      \if len(getqflist()) != 0 | copen | endif
" /=autocmds }}}
"
" /=utilities }}}
"
" options {{{
" ##### backup, swap
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

" ##### fold
if finddir('view', $MYVIM) != ''
  set viewdir=$MYVIM/view
"  autocmd BufWritePost * mkview
"  autocmd BufReadPost * loadview
else
  echoe "Can't save as a fold file."
endif
"
" ##### encoding
set fileencodings=utf-8,euc-jp,cp932,shiftjis,iso-2022-jp,latin1
set fileformats=unix,dos,mac
" set encoding=utf-8
" set fileencoding=utf-8
" set fileformat=unix
"
" ##### display#title
set title
set titlelen=90
if 0 && s:is_win
  set titlestring=[%l/%L:%c/%{col('$')-1}]\ %t%(\ %M%)\ (%F)%=%<(kaneshin)
endif
"
" ##### display#tabline
set showtabline=2
set tabline=%!MyTabLine()
"
" ##### display#main
set splitbelow
set splitright
set nonumber
set scrolloff=3
set wrap
set list
set listchars=eol:\ ,tab:>\ ,trail:S,extends:<
" ##### display#below
set laststatus=2
set cmdheight=2
set statusline=%!MyStatusLine()
set ruler
set showcmd
set wildmenu
set wildmode=list:longest
"
" ##### cursor
set cursorline
set nocursorcolumn
"
" ##### search
set ignorecase
set smartcase
set nowrapscan
set incsearch
"
" ##### edit
set autoindent
set smartindent
set showmatch
set backspace=indent,eol,start
set clipboard=unnamed
set pastetoggle=<F12>
set formatoptions+=mM
"
" ##### <Tab>
set tabstop=4
set shiftwidth=4
set softtabstop=0
set expandtab
set smarttab
"
" ##### etc
" NOTE: Vim turn off the compatible mode, if Vim find vimrc or gvimrc.
" set nocompatible
set noshellslash
set nrformats+=alpha
set nrformats+=octal
set nrformats+=hex
set history=300
"
" ##### Mac
if s:is_mac
  set nomigemo
end
" /=options }}}
"
" plugin {{{
set rtp+=$DROPBOX/dev/prj/sonictemplate-vim
set rtp+=$DROPBOX/dev/prj/ctrlp-tabbed
set rtp+=$DROPBOX/dev/prj/ctrlp-sonictemplate
" ##### gmarik/vundle {{{
filetype off
set rtp+=$MYVIM/bundle/vundle
call vundle#rc( '$MYVIM/bundle' )
" github
Bundle 'gmarik/vundle'
Bundle 'mattn/webapi-vim'
Bundle 'mattn/gist-vim'
Bundle 'mattn/zencoding-vim'
" Bundle 'kaneshin/sonictemplate-vim'
Bundle 'thinca/vim-quickrun'
Bundle 'thinca/vim-ref'
Bundle 'kien/ctrlp.vim'
Bundle 'mattn/ctrlp-launcher'
Bundle 'mattn/ctrlp-register'
Bundle 'mattn/ctrlp-mark'
Bundle 'tyru/restart.vim'
Bundle 'markabe/bufexplorer'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-surround'
" www.vim.org
Bundle 'TwitVim'
" playspace
" Bundle 'koron/nyancat-vim'
filetype plugin indent on
" /=gmarik/vundle }}}

" ##### TwitVim {{{
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
" ##### mattn/vimplenote-vim {{{
nmap ,vl :<C-u>VimpleNote -l<CR>\ado<CR>
nnoremap ,vd :<C-u>VimpleNote -d<CR>
nnoremap ,vD :<C-u>VimpleNote -D<CR>
nnoremap ,vt :<C-u>VimpleNote -t<CR>
nnoremap ,vn :<C-u>VimpleNote -n<CR>
nnoremap ,vu :<C-u>VimpleNote -u<CR>
nnoremap ,vs :<C-u>VimpleNote -s<CR>
" /=mattn/vimplenote-vim }}}
"
" ##### mattn/gist-vim {{{
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
" ##### thinca/vim-quickrun {{{
" let g:loaded_quicklaunch = 1
" 1. b:quickrun_config
" 2. 'filetype'
" 3. g:quickrun_config._type_
" 4. g:quickrun#default_conig._type_
" 5. g:quickrunconfig.
" 6. g:quickrun#defaultonig.
let b:quickrun_config = {}
let g:quickrun_config = {
\ '_': {
\   'outputter' : 'buffer',
\   'outputter/buffer/split': 'rightbelow 10sp',
\   'runner': 'system',
\ },
\ 'c': {
\   'command': 'gcc',
\   'exec': ['%c %o %s -o %s:p:r', '%s:p:r %a', 'rm -f %s:p:r'],
\   'cmdopt': '-Wall',
\   'tempfile': '%{tempname()}.c',
\ },
\ 'cpp': {
\   'command': 'g++',
\   'exec': ['%c %o %s -o %s:p:r', '%s:p:r %a', 'rm -f %s:p:r'],
\   'cmdopt': '-Wall',
\   'tempfile': '%{tempname()}.cpp',
\ },
\ 'ruby': {
\   'command': 'ruby',
\   'exec': ['%c %o %s %a'],
\   'cmdopt': '',
\   'tempfile': '%{tempname()}.rb',
\ },
\}

" /=thinca/vim-quickrun }}}
"
" ##### tyru/restart.vim {{{
let g:restart_sessionoptions
    \ = 'blank,buffers,curdir,folds,help,localoptions,tabpages'
" /=tyru/restart.vim }}}
"
" ##### Lokaltog/vim-easymotion {{{
let g:EasyMotion_leader_key = '<Leader>'
" }}}
"
" ##### mattn/sonictemplate-vim {{{
" for editing
inoremap {{in {{_input_:}}<Left><Left>
inoremap {{cur {{_cursor_}}
" }}}
"
" ##### kien/ctrlp.vim {{{
let g:ctrlp_extensions = [
      \'tabbed',
      \'sonictemplate',
      \'register',
      \'launcher',
      \]
" }}}
"
" ##### mattn/ctrlp-launcher {{{
" nnoremap <c-e> :<c-u>CtrlPLauncher<cr>
" }}}
"
" ##### kaneshin/ctrlp-tabbed {{{
nnoremap <c-b> :<c-u>CtrlPTabbed<cr>
" }}}
"
" ##### kaneshin/ctrlp-sonictemplate {{{
nnoremap <c-e> :<c-u>CtrlPSonictemplate<cr>
" }}}
"
" ##### mattn/sonictemplate-vim {{{
" let g:sonictemplate_key = <c-y>s
" }}}
" /=plugin }}}

