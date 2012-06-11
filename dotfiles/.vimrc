" vim:set ts=2 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .vimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 09-Jun-2012.

scriptencoding utf-8
syntax on
filetype plugin on
filetype indent on

" Languages
" language en_US
" language ca_ES
" language ja_JP

" variables {{{
" Windows (not on terminal)
let s:is_win = has( 'win32' ) || has( 'win64' )
" Mac (not on terminal)
let s:is_mac = has( 'mac' )
" UNIX or on terminal
let s:is_unix = has( 'unix' ) && !s:is_mac && !s:is_win
" $VIMHOME
"   Windows    -> vimfiles/
"   Mac, Linux -> .vim/
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
if !exists( '$DROPBOX' )
  let $DROPBOX = $MYHOME.'/Dropbox'
endif
" $DOTFILES
if !exists( '$DOTFILES' )
  let $DOTFILES = $DROPBOX.'/dev/dotfiles/dotfiles'
endif
" /=variables }}}

" functions {{{
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
let g:tabnum = 2
let g:tabdir = 1
let s:tabtoggle = 1
function! TabExpand()
  if s:tabtoggle == 1
    let g:tabnum = 5
    let g:tabdir = 0
    let s:tabtoggle = 0
  else
    let g:tabnum = 2
    let g:tabdir = 1
    let s:tabtoggle = 1
  endif
  let &tabline="%!MyTabLine()"
endfunction
command! TabExpand cal TabExpand()
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
  if (len(tabrange) > g:tabnum)
    let tabstr .= sep.'Tab:'.tabpagenr().'/'.tabpagenr('$').sep.MyTabLabel(tabpagenr())
  else
    for i in tabrange
      let tabstr .= sep.MyTabLabel(i)
    endfor
  endif
  return tabstr."%=".(g:tabdir == 1 ? DirInfo(len).sep : "")."%{fugitive#statusline()}"
endfunction
" /=functions }}}
"
" semi-function {{{
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
"
" ===== Mathematics, Algorithm
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
" }}}
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
inoremap <C-f> <ESC>
inoremap <c-l><c-h> <Left>
inoremap <c-l><c-j> <esc>O
inoremap <c-l><c-k> <up><end>
inoremap <c-l><c-l> <right>
inoremap <c-l><c-a> <home>
inoremap <c-l><c-e> <end>
inoremap <C-r><C-r> <C-r>"
" normal node
nnoremap <silent> <c-t> :TabExpand<cr>
nnoremap <c-f> <ESC>
nnoremap <up> 30k
nnoremap <c-k> dd<up>
nnoremap <down> 30j
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
" ##### autocmds {{{
" change directory if you open a file.
autocmd BufEnter * execute ':lcd '.expand('%:p:h')
" automatically open a quickfix
" autocmd QuickfixCmdPost make,grep,grepadd,vimgrep
"       \if len(getqflist()) != 0 | copen | endif
" autocmd FileType perl :map <C-n> <ESC>:!perl -cw %<CR>
" autocmd FileType perl :map <C-e> <ESC>:!perl %<CR>
" autocmd FileType ruby :map <C-n> <ESC>:!ruby -cW %<CR>
" autocmd FileType ruby :map <C-e> <ESC>:!ruby %<CR>
" /=autocmds }}}
"
" options {{{
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
" /=options }}}
"
" plugin {{{
set rtp+=$DROPBOX/dev/prj/sonictemplate-vim
set rtp+=$DROPBOX/dev/prj/ctrlp-tabbed
set rtp+=$DROPBOX/dev/prj/ctrlp-sonictemplate
set rtp+=$DROPBOX/dev/prj/ctrlp-filetype
" ##### gmarik/vundle {{{
filetype off
" set rtp+=$VIMHOME/bundle/vundle
set rtp+=$DROPBOX/dev/prj/vundle
call vundle#rc( '$VIMHOME/bundle' )
" github
" if 0
"   Bundle 'zolrath/vundle'
" else
"   Bundle 'gmarik/vundle'
" endif
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
\   'command': 'clang++',
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
" let g:sonictemplate_key = <c-y>s
" for editing
inoremap {{in {{_input_:}}<Left><Left>
inoremap {{cur {{_cursor_}}
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
  cal mkdir(expand('$HOME/.cache/ctrlp'), "p")
endif
let g:ctrlp_cache_dir = $VIMHOME.'/.cache/ctrlp'
let g:ctrlp_extensions = [
      \'tabbed',
      \'sonictemplate',
      \'filetype',
      \'register',
      \'launcher',
      \'mark',
      \]
"
nnoremap <c-e>p :<c-u>CtrlPLauncher<cr>
nnoremap <c-e>b :<c-u>CtrlPTabbed<cr>
nnoremap <c-e>t :<c-u>CtrlPSonictemplate<cr>
nnoremap <c-e>f :<c-u>CtrlPFiletype<cr>
" }}}
"
" /=plugin }}}

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
" 	" call inputsave()
" 	let l:msg = input('Post Evernote: ', a:init_str)
" 	" call inputrestore()
" 	let s:temp = s:post_evernote(l:msg, l:msg)
" endfunction
" 
" " current line
" function! s:curline_evernote(init_str)
" 	let l:msg = a:init_str
" 	let s:temp = s:post_evernote(l:msg, l:msg)
" endfunction
" 
" " buffer
" function! s:buffer_evernote()
" 	let l:title = fnamemodify(expand('%:p'), ':t')
" 	let l:body = join(getline(1, '$'), s:crlf)
" 	let s:temp = s:post_evernote(l:title, l:body)
" endfunction
" 
" " arguments
" function! s:args_evernote(...)
" 	let s:temp = s:post_evernote(a:1, a:2)
" endfunction
" 
" " full path of ENScript.exe
" function! s:get_enscript_path()
" 	if exists('g:enscript_path') && g:enscript_path != ''
" 		return g:enscript_path
" 	else
" 		echo 'Please add a full path of ENScript.exe to .vimrc'
" 		echo 'e.g.) "let enscript_path = ''C:\Program Files\Evernote\Evernote3.5\ENScript.exe''"'
" 		return ''
" 	endif
" endfunction
" 
" " post to evernote
" function! s:post_evernote(title, body)
" 	let l:en_title = iconv(a:title, &encoding, s:en_enc)
" 	let l:en_body = iconv(a:body, &encoding, s:en_enc)
" 	let l:enscript = s:get_enscript_path()
" 	if l:enscript == ''
" 		return
" 	endif
" 	if expand('%:h') != ''
" 		let l:target_path = expand('%:h') . '\' . s:temporary_filename . '.txt'
" 	else
" 		let l:target_path = $VIM . '\' . s:temporary_filename . '.txt'
" 	endif
" 	call writefile(split(l:en_body, s:crlf), l:target_path, 'b')
" 	let l:cmd = '"' . shellescape(l:enscript) . ' createNote /s ' . shellescape(l:target_path) . ' /i ' . shellescape(l:en_title) . '"'
" 	echo l:cmd
" 	call system(l:cmd)
" 	call delete(l:target_path)
" endfunction
" 
" " define command
" if !exists(":PosttoEvernote")
" 	command! PosttoEvernote :call <SID>cmdline_evernote('')
" endif
" 
" if !exists(":CPosttoEvernote")
" 	command! CPosttoEvernote :call <SID>curline_evernote(getline('.'))
" endif
" 
" if !exists(":BPosttoEvernote")
" 	command! BPosttoEvernote :call <SID>buffer_evernote()
" endif
" 
" if !exists(":APosttoEvernote")
" 	command! -nargs=+ APosttoEvernote :call <SID>args_evernote(<f-args>)
" endif
