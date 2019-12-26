" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .vimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 26-Dec-2019.

syntax on
filetype plugin on
filetype indent on

let g:go_version_warning = 0

function! UtilIsDarwin()
  return has('mac')
endfunction

function! UtilIsUnix()
  return has('unix') && !UtilIsDarwin() && !UtilIsWindows()
endfunction

function! UtilIsWindows()
  return has('win32') || has('win64')
endfunction

function! UtilSourceFile(filepath)
  if filereadable(expand(a:filepath))
    execute "silent! source " . a:filepath
  endif
endfunction

" set $VIMHOME
if !exists('$VIMHOME')
  let s:filepath = $HOME . '/.vim'
  if UtilIsWindows()
    let s:filepath = $HOME . '/vimfiles'
  endif
  let $VIMHOME = expand(s:filepath)
endif

" make $VIMHOME as directory
if finddir($VIMHOME) == ''
  cal mkdir($VIMHOME, "p")
endif

" backup, swap
let s:dirpath = $VIMHOME . '/backup'
if finddir(s:dirpath) == ''
  cal mkdir(s:dirpath, "p")
endif
set backup
set backupext=.bak
set backupdir=$VIMHOME/backup
set backupskip=/tmp/*,/private/tmp/*
set swapfile
set directory=$VIMHOME/backup
augroup BackupOptions
  autocmd!
augroup END

" fold
let s:dirpath = $VIMHOME . '/view'
if finddir(s:dirpath) == ''
  cal mkdir(s:dirpath, "p")
endif
set viewdir=$VIMHOME/view
augroup FoldOptions
  autocmd!
  autocmd BufWritePost * mkview
  autocmd BufReadPost * loadview
augroup END

" undo
if version >= 703
  let s:dirpath = $VIMHOME . '/undo'
  if finddir(s:dirpath) == ''
    cal mkdir(s:dirpath, "p")
  endif
  set undofile
  set undodir=$VIMHOME/undo
  augroup UndoOptions
    autocmd!
  augroup END
endif

" encoding and format
set ambiwidth=double
set fileencodings=utf-8,euc-jp,cp932,shiftjis,iso-2022-jp,latin1
set encoding=utf-8
set fileformats=unix,dos,mac
set fileformat=unix
"
" display: title
set title
set titlelen=90

" display: tabline
set showtabline=2

" display: main
set splitbelow
set splitright
set nonumber
set scrolloff=3
set wrap
set list
set listchars=eol:\ ,tab:>-,trail:~,extends:\ ,precedes:\ 

" display: statusline
set laststatus=2
set cmdheight=2
set ruler
set showcmd
set wildmenu
set wildmode=list:longest

" cursor
set nocursorline
set nocursorcolumn

" search
set ignorecase
set smartcase
set nowrapscan
set incsearch

" edit: basic
set autoindent
set smartindent
set showmatch
set backspace=indent,eol,start
set clipboard+=unnamed
set pastetoggle=<F12>
set formatoptions+=mM
" time to wait after ESC
set timeoutlen=350

" edit: <Tab>
set tabstop=4
set shiftwidth=4
set softtabstop=0
set expandtab
set smarttab
set shiftround

" edit: etc
set tags=$VIMHOME/tags,./tags,tags
set noshellslash
set nrformats+=alpha
set nrformats+=octal
set nrformats+=hex
set history=300
set undolevels=2000
set iminsert=0
set imsearch=0

" edit and read .vimrc.init
if filereadable(expand('$HOME/.vimrc'))
  command! EditVimrcInit :tabe   $HOME/.vimrc
  command! ReadVimrcInit :source $HOME/.vimrc
  nnoremap <silent> ,ev :EditVimrcInit<cr>
  nnoremap <silent> ,rv :ReadVimrcInit<cr>
endif

nnoremap ; :
vnoremap ; :

" use emacs key bind during command mode and a movement of insert mode
" start of line
cnoremap <c-a> <Home>
inoremap <c-a> <Home>
" back one character
cnoremap <c-b> <Left>
inoremap <c-b> <Left>
" delete character under cursor
cnoremap <c-d> <Del>
inoremap <c-d> <Del>
" end of line
cnoremap <c-e> <End>
inoremap <c-e> <End>
" forward one character
" cnoremap <c-f> <Right>
inoremap <c-f> <Right>
" recall newer command-line
cnoremap <c-n> <Down>
" recall previous (older) command-line
cnoremap <c-p> <Up>
" delete character backward
cnoremap <c-h> <BS>

" insert mode
inoremap <c-c> <esc>

" kill line
inoremap <c-k> <right><esc>Da

" normal mode
" searching
nnoremap n nzz
nnoremap N Nzz
nnoremap <silent> <ESC><ESC> :nohlsearch<CR>
" spliting window
nnoremap <silent> <C-x>0 :close<CR>
nnoremap <silent> <C-x>1 :only<CR>
nnoremap <silent> <C-x>2 :split<CR>
nnoremap <silent> <C-x>3 :vsplit<CR>
nnoremap <silent> <C-x>n :bnext<CR>
nnoremap <silent> <C-x>p :bprevious<CR>
nnoremap <silent> <C-x>k :close<CR>
nnoremap g[ <c-w>h
nnoremap g] <c-w>l

nnoremap <silent> gb :bnext<cr>
nnoremap <silent> gB :bprevious<cr>

" visual mode
vnoremap <c-c> <esc>
vnoremap f <esc>

vnoremap <silent> > >gv
vnoremap <silent> < <gv

" brackets and else
" inoremap () ()<Left>
" cnoremap () ()<Left>
" inoremap {} {}<Left>
" cnoremap {} {}<Left>
" inoremap [] []<Left>
" cnoremap [] []<Left>
" inoremap "" ""<Left>
" cnoremap "" ""<Left>
" inoremap '' ''<Left>
" cnoremap '' ''<Left>
" inoremap <> <><Left>
" cnoremap <> <><Left>

" inoremap {<cr> {<cr><cr>}<up>

" modify typo
inoremap {] {}<Left>
cnoremap {] {}<Left>

" quickfix
nnoremap <silent> <leader>n :cnext<cr>
nnoremap <silent> <leader>p :cprevious<cr>
nnoremap <silent> <leader>q :cclose<cr>
nnoremap <silent> <c-n> :cnext<cr>
nnoremap <silent> <c-m> :cprevious<cr>
nnoremap <leader>a :cclose<cr>

command! -nargs=1 -complete=filetype Tmp edit $VIMHOME/backup/tmp.<args>
command! -nargs=1 -complete=filetype Temp edit $VIMHOME/backup/tmp.<args>

" Leader
" autocmd BufEnter * execute ':lcd '.expand('%:p:h')
" nnoremap <silent> <leader>t :execute 'lcd '.expand('%:p:h')<cr>:!go test<cr>

augroup MyVimOptions
  autocmd!
  " change directory if you open a file.
  " autocmd BufEnter * execute ':lcd '.expand('%:p:h')

  autocmd QuickfixCmdPost vimgrep cw

  " In the quickfix window, <CR> is used to jump to the error under the
  " cursor, so undefine the mapping there.
  autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
augroup END

augroup MyGolang
  autocmd!
  autocmd FileType go :highlight goErr cterm=bold ctermfg=214
  autocmd FileType go :match goErr /\<err\>/
augroup END

source $VIMRUNTIME/macros/matchit.vim

" vundle {{{
filetype off
set rtp+=$VIMHOME/bundle/Vundle.vim
call vundle#begin('$VIMHOME/bundle')

" vundle is managed by itself
Plugin 'VundleVim/Vundle.vim'

" ctrlp {{{
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'mattn/ctrlp-gist'
Plugin 'mattn/ctrlp-mark'
Plugin 'mattn/ctrlp-launcher'
Plugin 'mattn/ctrlp-register'
Plugin 'kaneshin/ctrlp-sonictemplate'
Plugin 'kaneshin/ctrlp-filetype'
Plugin 'kaneshin/ctrlp-sudden-death'
" /=ctrlp }}}

" essentials
Plugin 'vim-scripts/autodate.vim'
Plugin 'mattn/webapi-vim'

" statusline
Plugin 'Lokaltog/vim-powerline'
Plugin 'tpope/vim-fugitive'

" go
Plugin 'prabirshrestha/async.vim'
Plugin 'prabirshrestha/vim-lsp'
Plugin 'mattn/vim-lsp-settings'
Plugin 'mattn/vim-goimports'

" syntax
Plugin 'vim-ruby/vim-ruby'
Plugin 'JavaScript-syntax'
Plugin 'tpope/vim-markdown'
Plugin 'b4winckler/vim-objc'
Plugin 'cakebaker/scss-syntax.vim'
Plugin 'Keithbsmiley/swift.vim'
Plugin 'leafgarland/typescript-vim'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'hashivim/vim-terraform'
Plugin 'posva/vim-vue'
Plugin 'smartword'
Plugin 'thinca/vim-ref'
Plugin 'tpope/vim-abolish'
Plugin 'chase/vim-ansible-yaml'

" misc
Plugin 'mattn/gist-vim'
Plugin 'mattn/sonictemplate-vim'
Plugin 'thinca/vim-quickrun'
Plugin 'airblade/vim-gitgutter'
Plugin 'altercation/solarized'
Plugin 'kristijanhusak/vim-carbon-now-sh'

" ...
call vundle#end()
filetype plugin indent on
" /=vundle }}}

" vim-lsp {{{
let g:lsp_diagnostics_enabled = 0
let g:lsp_signs_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
" }}}

" ctrlp {{{
" Set this to 0 to show the match window at the top of the screen
let g:ctrlp_match_window_bottom = 1
" Change the listing order of the files in the match window
let g:ctrlp_match_window_reversed = 1
" Set the maximum height of the match window
let g:ctrlp_max_height = 20
let g:ctrlp_switch_buffer = 2
let g:ctrlp_working_path_mode = 2
let g:ctrlp_use_caching = 1
let g:ctrlp_max_files = 30000
let g:ctrlp_mruf_max = 250
let g:ctrlp_max_depth = 40
let g:ctrlp_use_migemo = 0
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](node_modules|target|dist)|(\.(swp|ico|git|svn))$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': '',
  \ }
if finddir('.cache/ctrlp', $VIMHOME) == ''
  cal mkdir(expand('$VIMHOME/.cache/ctrlp'), "p")
endif
let g:ctrlp_cache_dir = $VIMHOME.'/.cache/ctrlp'
let g:ctrlp_extensions = [
      \]
let g:ctrlp_filetype = {
      \'user': [
      \   'go',
      \   'c',
      \   'objc',
      \   'javascript',
      \   'ruby',
      \   'perl',
      \   'html',
      \   'css',
      \   'sh',
      \   'vim',
      \   'cpp',
      \   'java',
      \],
      \}
nnoremap <c-e>g :<c-u>CtrlPGoDoc<cr>
nnoremap <c-e>l :<c-u>CtrlPLauncher<cr>
nnoremap <c-e>t :<c-u>CtrlPSonictemplate<cr>
inoremap <c-e>t <esc>:<c-u>CtrlPSonictemplate<cr>
nnoremap <c-e>f :<c-u>CtrlPFiletype<cr>
" /=ctrlp }}}

" gist-vim {{{
let g:gist_show_privates = 1
if UtilIsDarwin()
  let g:gist_clip_command = 'pbcopy'
elseif UtilIsUnix()
  let g:gist_clip_command = 'xclip -selection clipboard'
endif
" /=gist-vim }}}

" sonictemplate {{{
let g:sonictemplate_vim_template_dir = [
      \expand('$VIMHOME/template'),
      \expand('$HOME/.vim/template'),
      \]
" /=sonictemplate }}}

" quickrun {{{
" let g:loaded_quicklaunch = 1
" 1. b:quickrun_config
" 2. 'filetype'
" 3. g:quickrun_config._type_
" 4. g:quickrun#default_conig._type_
" 5. g:quickrunconfig.
" 6. g:quickrun#defaultonig.
"   'outputter/buffer/split': 'rightbelow 10sp',
let b:quickrun_config = {}
let g:quickrun_config = {
\ '_': {
\   'outputter' : 'buffer',
\   'runner': 'system',
\ },
\ 'ruby': {
\   'command': 'ruby',
\   'exec': ['%c %o %s %a'],
\   'cmdopt': '',
\   'tempfile': '%{tempname()}.rb',
\ },
\}
" /=quickrun }}}

" powerline {{{
if has('gui_running')
  let g:Powerline_symbols = 'fancy'
else
  let g:Powerline_symbols = 'compatible'
endif
" /=powerline }}}

" set colorscheme
silent! colorscheme concise

" CarbonNowSh {{{
let g:carbon_now_sh_options = {
  \ 'ln': 'false',
  \ 'fm': 'Source Code Pro'
\}
vnoremap <silent> <c-i> :CarbonNowSh<CR>
" /=CarbonNowSh }}}

" load local configuration
call UtilSourceFile($HOME . "/.vimrc.local")

""" ============
""" Experimental
""" ============

" open buffer
function s:OpenBuf(target, name, body)
  execute a:target.' '.a:name
  setlocal noswapfile buflisted buftype=nofile bufhidden=hide
  setlocal nonumber nobinary nolist
  cal append(line('^'), split(a:body, '\n'))
  silent! $d
  execute 'normal! 1G'
endfunction

" Plugin for godoc
function s:GoDoc(target, args)
  let arg = join(split(a:args), '.')
  silent! let res = system('go doc -cmd -all '.arg.' 2>/dev/null')
  if v:shell_error != 0
    let err = systemlist('go doc '.arg.' 1>/dev/null')
    redraw | echohl ErrorMsg | echoerr err
    return
  endif
  call s:OpenBuf(a:target, arg, res)
  setlocal ft=godoc
  setlocal nomodifiable nomodified
  nnoremap <buffer> <silent> q :q<cr>
endfunction
command -bar -bang -nargs=1 GoDoc cal s:GoDoc('<bang>' == '' ? 'split!' : 'tabnew', <f-args>)

" CtrlPGoDoc
" depending the s:GoDoc above
command! CtrlPGoDoc cal ctrlp#init(ctrlp#godoc#id())
