" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .vimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 04-Jul-2012.
" TODO:

scriptencoding utf-8
syntax on
filetype plugin on
filetype indent on

" Languages
" language en_US
" language ca_ES
" language ja_JP
"
" time to wait after ESC (default value is 1000)
set timeoutlen=350

" variables {{{
" Windows (not on terminal)
let s:is_win = has( 'win32' ) || has( 'win64' )
" Mac (not on terminal)
let s:is_mac = has( 'mac' )
" UNIX like
let s:is_unix = has( 'unix' ) && !s:is_mac && !s:is_win
" $VIMHOME
if !exists( '$VIMHOME' )
  if s:is_win
    if finddir('vimfiles', $HOME) == ''
      cal mkdir(expand('$HOME/vimfiles'), "p")
    endif
    let $VIMHOME = expand('$HOME/vimfiles')
  else
    if finddir('.vim', $HOME) == ''
      cal mkdir(expand('$HOME/.vim'), "p")
    endif
    let $VIMHOME = expand('$HOME/.vim')
  endif
endif
" $MYHOME
if !exists( '$MYHOME' )
  let $MYHOME = $HOME
endif
" $DROPBOX
if !exists( '$DROPBOX' ) && finddir('Dropbox', $MYHOME) != ''
  let $DROPBOX = $MYHOME.'/Dropbox'
endif
" $DOTFILES
if !exists( '$DOTFILES' ) && finddir('dev/dotfiles/dotfiles', $DROPBOX) != ''
  let $DOTFILES = $DROPBOX.'/dev/dotfiles/dotfiles'
endif
" /=variables }}}
"
" options {{{
if !(exists('g:loaded_vimrc') && g:loaded_vimrc)
  let g:loaded_vimrc = 1
  " ##### backup, swap
  if finddir('backup', $VIMHOME) == ''
    cal mkdir(expand('$VIMHOME/backup'), "p")
  endif
  set backup
  set backupext=.bak
  set backupdir=$VIMHOME/backup
  set swapfile
  set directory=$VIMHOME/backup

  " ##### fold
  if finddir('view', $VIMHOME) == ''
    cal mkdir(expand('$VIMHOME/view'), "p")
  endif
  set viewdir=$VIMHOME/view
  " autocmd BufWritePost * mkview
  " autocmd BufReadPost * loadview
  "
  " ##### encoding
  set fileencodings=utf-8,euc-jp,cp932,shiftjis,iso-2022-jp,latin1
  set fileformats=unix,dos,mac
  set encoding=utf-8
  " set fileencoding=utf-8
  if !s:is_win
    set fileformat=unix
  else
    set fileformat=dos
  endif
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
  set shiftround
  "
  " ##### etc
  " NOTE: Vim turn off the compatible mode, if Vim find vimrc or gvimrc.
  " set nocompatible
  set noshellslash
  set nrformats+=alpha
  set nrformats+=octal
  set nrformats+=hex
  set history=300

  set undolevels=2000
  set iminsert=0
  set imsearch=0
  "
  " ##### Mac
  if s:is_mac
    set nomigemo
    set macmeta
  end
endif
" /=options }}}
"
" key mapping {{{
" .vimrc
if filereadable(expand('$DOTFILES/.vimrc'))
  command! EditVimrc :tabe   $DOTFILES/.vimrc
  command! ReadVimrc :source $DOTFILES/.vimrc
  nnoremap <silent> ,ev :EditVimrc<CR>
  nnoremap <silent> ,rv :ReadVimrc<CR>
endif
" .gvimrc
if filereadable(expand('$DOTFILES/.gvimrc'))
  command! EditGVimrc :tabe   $DOTFILES/.gvimrc
  command! ReadGVimrc :source $DOTFILES/.gvimrc
  nnoremap <silent> ,eg :EditGVimrc<CR>
  nnoremap <silent> ,rg :ReadGVimrc<CR>
endif
" insert mode
inoremap <c-f> <right>
inoremap <c-b> <Left>
inoremap <c-l><c-a> <home>
inoremap <c-l><c-e> <end>
inoremap <c-l><c-l> <end>
inoremap <c-l>( <esc>:call<space>search("(", "w")<cr>a
inoremap <c-l>) <esc>:call<space>search(")", "w")<cr>i
inoremap <c-l><space> <esc>:call<space>search(" ", "w")<cr>i
inoremap <c-l>, <esc>:call<space>search(",", "w")<cr>a
inoremap <C-r><C-r> <C-r>"
" normal node
nnoremap <silent> <c-t> :TabExpand<cr>
nnoremap <c-f> <ESC>
nnoremap <up> 20kzz
nnoremap <c-k> dd<up>
nnoremap <down> 20jzz
nnoremap <c-j> o<esc>
nnoremap <left> 0
nnoremap <c-h> 0
nnoremap <silent> <m-h> :tabprev<cr>
nnoremap <silent> <m-l> :tabnext<cr>
nnoremap <right> $
nnoremap <c-l> $
nnoremap <c-g> g;zz

nnoremap <c-space> i<space><esc><right>
nnoremap ; :
nnoremap <silent> <c-s> :cal setline('.',substitute(getline('.'),@/,@",'g'))<cr>

nnoremap n nzz
nnoremap N Nzz
nnoremap <silent> <C-u> <C-u>zz
nnoremap <silent> <C-f> <C-f>zz

nnoremap <silent> <C-x>0 :close<CR>
nnoremap <silent> <C-x>1 :only<CR>
nnoremap <silent> <C-x>2 :split<CR>
nnoremap <silent> <C-x>3 :vsplit<CR>
nnoremap <silent> <C-x>4 :tabe<CR>:BufExplorer<CR>
nnoremap <silent> <C-x>n :bnext<CR>
nnoremap <silent> <C-x>p :bprevious<CR>
nnoremap <silent> <C-x>k :close<CR>
nnoremap <silent> <ESC><ESC> :nohlsearch<CR>
" visual mode
vnoremap ; :
vnoremap <silent> > >gv
vnoremap <silent> < <gv
vnoremap f <esc>
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
"
" brackets and else
inoremap () ()<Left>
inoremap (); ();<Left><Left>
inoremap (){ ()<space>{<cr>}<esc>kA<left><left><left>
cnoremap () ()<Left>
inoremap {} {}<Left>
cnoremap {} {}<Left>
inoremap [] []<Left>
cnoremap [] []<Left>
inoremap "" ""<Left>
cnoremap "" ""<Left>
inoremap '' ''<Left>
cnoremap '' ''<Left>
inoremap <> <><Left>
cnoremap <> <><Left>
" inoremap %% %%<Left>
" cnoremap %% %%<Left>
" /=key mapping }}}
"
" functions {{{
function! GetShortenRegister(reg)
  return substitute(substitute(a:reg, '\n', '', 'g'), '^ *\(.\{,15\}\).*$', '\1', '')
endfunction
function! s:getTabname()
  let fns = []
  for i in range(1, tabpagenr('$'))
    let fn = substitute(bufname(tabpagebuflist(i)[tabpagewinnr(i) - 1]), ".*\\/", "", "")
    call add(fns, fn)
  endfor
  return fns
endfunction
function! s:getMaxLengthTabname()
  let fns = s:getTabname()
  let maxlfn = 0
  for fn in fns
    if len(fn) > maxlfn
      let maxlfn = len(fn)
    endif
  endfor
  return maxlfn
endfunction
" sticky
" let g:sticky_mode = "eng"
" let s:stickypos = 0
" let s:sticky = {
"         \"eng": [
"             \"I'm gonna be here.",
"             \"Should be ok.",
"             \"Could be ok."
"         \],
"         \"": []
"     \}
" function! g:Sticky()
"   let s:stickypos += 1
"   let s:stickypos = s:stickypos % len(s:sticky[g:sticky_mode])
"   return s:sticky[g:sticky_mode][s:stickypos]
" endfunction
"
" tab to space
" function! s:TabToSpace(...)
"   let lines = getbufline(bufnr(bufname('%')), 1, "$")
"   let result = []
"   for line in lines
"     call add(result, substitute(line, "\t",
"           \repeat(' ', (a:0 > 0 ? a:1 : &shiftwidth)), "g"))
"   endfor
"   call setline(1, result)
" endfunction
" command! -nargs=? TabToSpace call s:TabToSpace(<f-args>)

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
" function! s:RemoveBracketsSpace()
"   let line = getline(".")
"   let line = substitute(line, "( \\+\\(.\\+\\) \\+)", "(\\1)", "")
"   call setline(".", line)
" endfunction
" command! -nargs=0 RemoveBracketsSpace call s:RemoveBracketsSpace()
" }}}
"
" Tab line {{{
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
  let s:tabnr = s:getTabnr()
  let tabrange = range(1, tabpagenr('$'))
  let sep = ' '
  " left side of tab line
  let tableft = ''
  if len(tabrange) > s:tabnr
    let tableft .= sep.'Tab:'.tabpagenr().'/'.tabpagenr('$').sep.MyTabLabel(tabpagenr())
  else
    for i in tabrange
      let tableft .= sep.MyTabLabel(i)
    endfor
  endif
  " right side of tab line
  let tabright = ''
  if s:tabdir
    let fn = fnamemodify(getcwd(), ":~")
    let tabright .= (len(fn) > 20 ? pathshorten(fn) : fn).sep
  endif
  let tabright .= "%{fugitive#statusline()}"
  return tableft."%=".tabright
endfunction
function! s:getTabnr()
  if s:tabtoggle
    let fn = fnamemodify(getcwd(), ":~")
    return ((&columns - len((len(fn) > 20 ? pathshorten(fn) : fn))) / s:getMaxLengthTabname())
  else
    return 20
  endif
endfunction
let s:tabtoggle = 0
function! TabExpand()
  if s:tabtoggle
    let s:tabdir = 0
    let s:tabtoggle = 0
  else
    let s:tabdir = 1
    let s:tabtoggle = 1
  endif
  let &tabline="%!MyTabLine()"
endfunction
cal TabExpand()
command! TabExpand cal TabExpand()
" /=Tab line }}}
"
" status line {{{
function! MyStatusLine()
  return "%t\ %m%r%h%w%y"
        \."%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}"
        \."[0x\%02.2B]"
        \."%=%<"
        \."%{'@\"['.GetShortenRegister(@\").']"
        \."\ @/[/'.GetShortenRegister(@/).']'}"
        \."[%l/%L]"
endfunction
" }}}
"
" autocmds {{{
" change directory if you open a file.
autocmd BufEnter * execute ':lcd '.expand('%:p:h')
" automatically open a quickfix
" autocmd QuickfixCmdPost make,grep,grepadd,vimgrep
"       \if len(getqflist()) != 0 | copen | endif
" autocmd FileType perl :map <C-n> <ESC>:!perl -cw %<CR>
" autocmd FileType perl :map <C-e> <ESC>:!perl %<CR>
" autocmd FileType ruby :map <C-n> <ESC>:!ruby -cW %<CR>
" autocmd FileType ruby :map <C-e> <ESC>:!ruby %<CR>
autocmd FileType javascript
      \ setl shiftwidth=2 |
      \ setl tabstop=2
" /=autocmds }}}
"
" something 1 {{{
let s:progmap_toggle = {
      \  'c': 0
      \, 'ruby': 0
      \}
function! s:progmap_statements(...)
  let ft = &ft
  let ps = a:0 > 0 ? a:1 : 0
  if ft == 'c' || ps == 1
    let &ft = 'c'
    if s:progmap_toggle[&ft] == 0
      let s:progmap_toggle[&ft] = 1
      inoremap printf printf();<left><left>
      inoremap for for<space>()<space>{<cr>}<esc>kA<left><left><left>
    else
      let s:progmap_toggle[&ft] = 0
      iunmap printf
      iunmap for
    endif
  elseif ft == 'ruby' || ps == 2
    let &ft = 'ruby'
    if s:progmap_toggle[&ft] == 0
      let s:progmap_toggle[&ft] = 1
      inoremap each .each<space>{\|x\|<cr>}<esc>kI
    else
      let s:progmap_toggle[&ft] = 0
      iunmap each
    endif
  endif
endfunction
command! -nargs=* Progmapping call s:progmap_statements(<f-args>)
nnoremap <silnet> <c-i>1 :Progmapping 1<cr>
" }}}

" something 2 {{{
let s:comment_str = {
      \  'c': '//'
      \, 'cpp': '//'
      \, 'ruby': '#'
      \, 'vim': '"'
      \}
function! s:to_comment(...)
  let ft = &ft
  let sw = &shiftwidth
  let comm = s:comment_str[ft]
  let line = getline('.')
  if line =~ '^\s*'.comm
    cal setline('.', substitute(line, comm.' ', "", ""))
  else
    cal setline('.', comm.' '.line)
  endif
endfunction
command! -nargs=* Comment call s:to_comment(<f-args>)
nnoremap <silnet> ,co :Comment<cr>
function! s:to_comment_v(...) range
  let ft = &ft
  let sw = &shiftwidth
  let comm = s:comment_str[ft]
  exe (a:firstline + 1).",".a:lastline.'s/^/'.escape(comm, '/').'/g'
endfunction
command! -nargs=* VComment call s:to_comment_v(<f-args>)
vnoremap <silnet> b :'<,'>VComment<cr>
" }}}
"
" makesession {{{
set sessionoptions=
      \"blank,buffers,folds,help,localoptions,resize,tabpages"
let g:session_file = "$VIMHOME/Session.vim"
function! s:session()
  let is_buf = search('[^ \t]', 'wn')
  if is_buf
    exe "mksession! ".g:session_file
  else
    exe "source ".g:session_file
  endif
endfunction
command! Session call s:session()
" }}}
"
" plugin {{{
" ##### gmarik/vundle {{{
filetype off
set rtp+=$VIMHOME/bundle/vundle
call vundle#rc( '$VIMHOME/bundle' )
" github
" Bundle 'kaneshin/vundle'
Bundle 'mattn/sonictemplate-vim'
" set rtp+=$DROPBOX/dev/prj/vim-plugin/sonictemplate-vim
Bundle 'mattn/webapi-vim'
Bundle 'mattn/gist-vim'
Bundle 'mattn/zencoding-vim'
Bundle 'thinca/vim-quickrun'
Bundle 'markabe/bufexplorer'
Bundle 'kien/ctrlp.vim'
Bundle 'mattn/ctrlp-launcher'
Bundle 'mattn/ctrlp-register'
Bundle 'mattn/ctrlp-mark'
Bundle 'kaneshin/ctrlp-tabbed'
Bundle 'kaneshin/ctrlp-sonictemplate'
Bundle 'kaneshin/ctrlp-filetype'
Bundle 'kaneshin/ctrlp-memolist'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-repeat'
Bundle 'tyru/restart.vim'
Bundle 'thinca/vim-ref'
Bundle 'glidenote/memolist.vim'
" www.vim.org
Bundle 'TwitVim'
" playspace
" Bundle 'koron/nyancat-vim'
filetype plugin indent on
" /=gmarik/vundle }}}

" ##### mattn/sonictemplate-vim {{{
let g:sonictemplate_vim_template_dir = [
      \expand('$VIMHOME/template'),
      \expand('$DROPBOX/dev/dotfiles/dotfiles/.vim/template'),
      \]
" let g:sonictemplate_key = <c-y>t
let g:sonic_dict = {
      \  'name': '{{_name_}}'
      \, 'cursor': '{{_cursor_}}'
      \, 'input': '{{_input_:}}'
      \, 'expr': '{{_expr_:}}'
      \, 'if': '{{_if_:;;}}'
      \, 'inline': '{{_inline_}}'
      \}
function! s:sonickeys_complete(lead, cmdline, curpos) abort
  let candidate = []
  for key in keys(g:sonic_dict)
    if key =~ '^'.a:lead
      call add(candidate, key)
    endif
  endfor
  if len(candidate) == 0
    candidate = keys(g:sonic_dict)
  endif
  return candidate
endfunction
function! s:put_sonicvalue(key)
  silent! exec "normal! a\<c-r>=g:sonic_dict[a:key]\<cr>"
endfunction
command! -nargs=1 -complete=customlist,s:sonickeys_complete Sonicvalue call s:put_sonicvalue(<f-args>)
" }}}

" ##### TwitVim {{{
let g:twitvim_count = 50
if s:is_win
  let g:twitvim_browser_cmd
      \ = $HOME.'\AppData\Local\Google\Chrome\Application\chrome.exe'
elseif s:is_mac
  let g:twitvim_browser_cmd
      \ = '/Applications/Safari.app'
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
" ##### glidenote/memolist.vim {{{
let g:memolist_path = $DROPBOX.'/docs/memo'
let g:memolist_memo_suffix = "mkd"
let g:memolist_memo_date = "%Y-%m-%d %H:%M"
let g:memolist_prompt_tags = 1
let g:memolist_prompt_categories = 1
" let g:memolist_qfixgrep = 1
" let g:memolist_vimfiler = 1
" }}}
"
" ##### thinca/ref.vim {{{
let g:ref_source_webdict_sites = {
      \'wikipedia:en': 'http://en.wikipedia.org/wiki/%s',
      \'wikipedia:ja': 'http://ja.wikipedia.org/wiki/%s',
      \'alc': 'http://eow.alc.co.jp/search?q=%s',
      \'Oxford': 'http://oxforddictionaries.com/definition/%s',
      \}
" }}}
"
" ##### kien/ctrlp.vim and Extensions {{{
" Set this to 0 to show the match window at the top of the screen
let g:ctrlp_match_window_bottom = 1
" Change the listing order of the files in the match window
let g:ctrlp_match_window_reversed = 1
" Set the maximum height of the match window
let g:ctrlp_max_height = 20
let g:ctrlp_switch_buffer = 2
let g:ctrlp_working_path_mode = 2
let g:ctrlp_use_caching = 1
let g:ctrlp_max_files = 10000
let g:ctrlp_mruf_max = 250
let g:ctrlp_max_depth = 40
let g:ctrlp_use_migemo = 0
if finddir('.cache/ctrlp', $VIMHOME) == ''
  cal mkdir(expand('$VIMHOME/.cache/ctrlp'), "p")
endif
let g:ctrlp_cache_dir = $VIMHOME.'/.cache/ctrlp'
let g:ctrlp_extensions = [
      \'launcher',
      \'register',
      \'mark',
      \'filetype',
      \'sonictemplate',
      \'tabbed',
      \'memolist',
      \]
nnoremap <c-e>p :<c-u>CtrlPLauncher<cr>
nnoremap <c-e>b :<c-u>CtrlPTabbed<cr>
nnoremap <c-e>t :<c-u>CtrlPSonictemplate<cr>
nnoremap <c-e>f :<c-u>CtrlPFiletype<cr>
nnoremap <c-e>m :<c-u>CtrlPMemolist<cr>
" }}}
"
" /=plugin }}}

" storage {{{
" --- " How to use 's:' or '<SID>'
" --- "--------------------
" --- " s:
" --- " :autocmd, :command, :function/:endfunction
" --- command! -nargs=1 Foo :call s:foo(<f-args>)
" --- function! s:foo(bar)
" ---   let l:baz = 0
" ---   " ...
" ---   return s:foo(l:baz)
" --- endfunction
" --- "--------------------
" --- " <SID>
" --- " :map, :menu
" --- cnoremap foo call <SID>foo("qux")<CR>
" --- "--------------------

" let s:en_enc = 'cp932'
" let s:crlf = "\r\n"
" let s:temporary_filename = 'vimever.tmp'
"
" " command line
" function! s:cmdline_evernote(init_str)
"   " call inputsave()
"   let l:msg = input('Post Evernote: ', a:init_str)
"   " call inputrestore()
"   let s:temp = s:post_evernote(l:msg, l:msg)
" endfunction
"
" " current line
" function! s:curline_evernote(init_str)
"   let l:msg = a:init_str
"   let s:temp = s:post_evernote(l:msg, l:msg)
" endfunction
"
" " buffer
" function! s:buffer_evernote()
"   let l:title = fnamemodify(expand('%:p'), ':t')
"   let l:body = join(getline(1, '$'), s:crlf)
"   let s:temp = s:post_evernote(l:title, l:body)
" endfunction
"
" " arguments
" function! s:args_evernote(...)
"   let s:temp = s:post_evernote(a:1, a:2)
" endfunction
"
" " full path of ENScript.exe
" function! s:get_enscript_path()
"   if exists('g:enscript_path') && g:enscript_path != ''
"       return g:enscript_path
"   else
"       echo 'Please add a full path of ENScript.exe to .vimrc'
"       echo 'e.g.) "let enscript_path = ''C:\Program Files\Evernote\Evernote3.5\ENScript.exe''"'
"       return ''
"   endif
" endfunction
"
" " post to evernote
" function! s:post_evernote(title, body)
"   let l:en_title = iconv(a:title, &encoding, s:en_enc)
"   let l:en_body = iconv(a:body, &encoding, s:en_enc)
"   let l:enscript = s:get_enscript_path()
"   if l:enscript == ''
"       return
"   endif
"   if expand('%:h') != ''
"       let l:target_path = expand('%:h') . '\' . s:temporary_filename . '.txt'
"   else
"       let l:target_path = $VIM . '\' . s:temporary_filename . '.txt'
"   endif
"   call writefile(split(l:en_body, s:crlf), l:target_path, 'b')
"   let l:cmd = '"' . shellescape(l:enscript) . ' createNote /s ' . shellescape(l:target_path) . ' /i ' . shellescape(l:en_title) . '"'
"   echo l:cmd
"   call system(l:cmd)
"   call delete(l:target_path)
" endfunction
"
" " define command
" if !exists(":PosttoEvernote")
"   command! PosttoEvernote :call <SID>cmdline_evernote('')
" endif
"
" if !exists(":CPosttoEvernote")
"   command! CPosttoEvernote :call <SID>curline_evernote(getline('.'))
" endif
"
" if !exists(":BPosttoEvernote")
"   command! BPosttoEvernote :call <SID>buffer_evernote()
" endif
"
" if !exists(":APosttoEvernote")
"   command! -nargs=+ APosttoEvernote :call <SID>args_evernote(<f-args>)
" endif
" /=storage }}}

" Mathematics, Algorithm {{{
" Factorial
function! Factorial(n)
  return a:n == 1 ? 1 : a:n * s:Factorial(a:n - 1)
endfunction
command! -nargs=1 Factorial :echo Factorial(<f-args>)
" FizzBuzz
function! FizzBuzz(n)
  let fb = []
  let i = 1
  while i <= a:n
    if i % 3 == 0
      cal add(fb, 'Fizz')
    elseif i % 5 == 0
      cal add(fb, 'Buzz')
    elseif i % 15 == 0
      cal add(fb, 'FizzBuzz')
    else
      cal add(fb, ''.i)
    endif
    let i = i + 1
  endwhile
  return fb
endfunction
command! -nargs=1 FizzBuzz :echo FizzBuzz(<f-args>)
" Greatest Common Divisor
function! GreatestCommonDivisor(a, b)
  let r = a:a % a:b
  return r == 0 ? a:b : GreatestCommonDivisor(a:b, r)
endfunction
command! -nargs=+ GreatestCommonDivisor :echo GreatestCommonDivisor(<f-args>)
" Fibonacci
function! Fibonacci(n)
  return a:n < 2 || a:n < 0 || a:n > 27 ? 1 : Fibonacci(a:n - 1) + Fibonacci(a:n - 2)
endfunction
command! -nargs=1 Fibonacci :echo Fibonacci(<f-args>)
" /=Mathematics, Algorithm }}}

