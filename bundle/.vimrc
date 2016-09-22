" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .vimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 20-Sep-2016.

syntax on
filetype plugin on
filetype indent on

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
set listchars=eol:-,tab:>~,trail:~,extends:>,precedes:<

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
cnoremap <c-f> <Right>
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
augroup END

" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#cmd#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

augroup MyGolang
  autocmd!
  autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
  autocmd FileType go nmap <leader>r  <Plug>(go-run)
  autocmd FileType go nmap <leader>t  <Plug>(go-test)
  autocmd FileType go nmap <silent><leader>l  :GoLint<CR>
  autocmd FileType go nmap <silent><leader>f  :GoImports<CR>
  autocmd FileType go nmap <c-e>e :<c-u>GoDecls<cr>
  autocmd FileType go nmap <c-e>d :<c-u>GoDeclsDir<cr>
  autocmd FileType go :highlight goErr cterm=bold ctermfg=214
  autocmd FileType go :match goErr /\<err\>/
augroup END

source $VIMRUNTIME/macros/matchit.vim

" vundle {{{
filetype off
set rtp+=$VIMHOME/bundle/Vundle.vim
call vundle#begin('$VIMHOME/bundle')

" vundle is managed by itself
Plugin 'gmarik/Vundle.vim'

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

Plugin 'scrooloose/nerdtree'

" essentials
Plugin 'vim-scripts/autodate.vim'
Plugin 'mattn/webapi-vim'

" vim-surround
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'

" statusline
Plugin 'Lokaltog/vim-powerline'
Plugin 'tpope/vim-fugitive'

" misc
Plugin 'mattn/gist-vim'
Plugin 'mattn/emmet-vim'
Plugin 'mattn/sonictemplate-vim'
Plugin 'thinca/vim-quickrun'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'scrooloose/nerdcommenter'
Plugin 'airblade/vim-gitgutter'

" source
Plugin 'wesleyche/SrcExpl'
Plugin 'vim-scripts/taglist.vim'

" syntax
Plugin 'vim-ruby/vim-ruby'
Plugin 'JavaScript-syntax'
Plugin 'tpope/vim-markdown'
Plugin 'b4winckler/vim-objc'
Plugin 'cakebaker/scss-syntax.vim'
Plugin 'Keithbsmiley/swift.vim'
Plugin 'leafgarland/typescript-vim'
Plugin 'editorconfig/editorconfig-vim'

Plugin 'smartword'
Plugin 'thinca/vim-ref'
Plugin 'tpope/vim-abolish'

Plugin 'chase/vim-ansible-yaml'

" Golang
Plugin 'fatih/vim-go'
Plugin 'AndrewRadev/splitjoin.vim'

Plugin 'tyru/open-browser.vim'
Plugin 'altercation/solarized'

Plugin 'Shougo/vimproc.vim'
Plugin 'Shougo/vimshell.vim'

call vundle#end()
filetype plugin indent on
" /=vundle }}}

" vim-go {{{
let g:go_list_type = "quickfix"
" let g:go_fmt_command = "goimports"
let g:go_snippet_case_type = "camelcase"
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 0
let g:go_highlight_interfaces = 0
let g:go_highlight_operators = 0
let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
if finddir('shims', $GOENV_ROOT) != ''
  let g:go_bin_path = expand('$GOENV_ROOT/shims')
endif
" }}}

" https://github.com/Valloric/YouCompleteMe.
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<c-b>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" " If you want :UltiSnipsEdit to split your window.
" let g:UltiSnipsEditSplit="vertical"

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
let g:ctrlp_max_files = 10000
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
nnoremap <c-e>g :<c-u>CtrlPGist<cr>
nnoremap <c-e>l :<c-u>CtrlPLauncher<cr>
nnoremap <c-e>t :<c-u>CtrlPSonictemplate<cr>
inoremap <c-e>t <esc>:<c-u>CtrlPSonictemplate<cr>
nnoremap <c-e>f :<c-u>CtrlPFiletype<cr>
" /=ctrlp }}}

" nerdtree {{{
nnoremap <silent><C-e> :NERDTreeToggle<CR>
" /=nerdtree }}}


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

" vim-go {{{
let g:go_fmt_autosave = 1
" /=vim-go }}}

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

" easymotion {{{
let g:EasyMotion_leader_key = '<Leader>'
" /=easymotion }}}

" powerline {{{
if has('gui_running')
  let g:Powerline_symbols = 'fancy'
else
  let g:Powerline_symbols = 'compatible'
endif
" /=powerline }}}

" nerdcommenter {{{
let g:NERDCreateDefaultMappings = 1
let NERDSpaceDelims = 1
" /=nerdcommenter }}}

" taglist {{{
let Tlist_Show_One_File = 0
let Tlist_Use_Right_Window = 1
let Tlist_Exit_OnlyWindow = 1
" /=taglist }}}

" SrcExpl {{{
" // The switch of the Source Explorer
nmap <F8> :SrcExplToggle<CR>
" " // Set the height of Source Explorer window
let g:SrcExpl_winHeight = 8
" // Set 100 ms for refreshing the Source Explorer
let g:SrcExpl_refreshTime = 100
" // Set "Enter" key to jump into the exact definition context
let g:SrcExpl_jumpKey = "<ENTER>"
" // Set "Space" key for back from the definition context
let g:SrcExpl_gobackKey = "<SPACE>"
" // In order to Avoid conflicts, the Source Explorer should know what plugins
" // are using buffers. And you need add their bufname into the list below
" // according to the command ":buffers!"
let g:SrcExpl_pluginList = [
  \"__Tag_List__",
  \"_NERD_tree_",
  \"Source_Explorer"
\]
" // Enable/Disable the local definition searching, and note that this is not
" // guaranteed to work, the Source Explorer doesn't check the syntax for now.
" // It only searches for a match with the keyword according to command 'gd'
let g:SrcExpl_searchLocalDef = 1
" // Do not let the Source Explorer update the tags file when opening
let g:SrcExpl_isUpdateTags = 0
" // Use 'Exuberant Ctags' with '--sort=foldcase -R .' or '-L cscope.files' to
" //  create/update a tags file
let g:SrcExpl_updateTagsCmd = "ctags --sort=foldcase -R ."
" // Set "<F12>" key for updating the tags file artificially
let g:SrcExpl_updateTagsKey = "<F12>"
" /=SrcExpl }}}

" set colorscheme
silent! colorscheme concise

" load local configuration
call UtilSourceFile($HOME . "/.vimrc.local")

