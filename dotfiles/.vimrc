" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .vimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 22-Dec-2013.

scriptencoding utf-8

syntax on
filetype plugin on
filetype indent on

" lazy mapping
nnoremap ; :
vnoremap ; :

" windows
let s:is_win = has('win32') || has('win64')
" mac
let s:is_mac = has('mac')
" unix
let s:is_unix = has('unix') && !s:is_win && !s:is_mac

" $VIMHOME
if !exists('$VIMHOME')
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

" $DEVHOME
if finddir('Develop', $HOME) == ''
  echoerr "Can't find a `~/Develop` directory in your system."
endif
if !exists('$DEVHOME') && finddir('Develop', $HOME) != ''
  let $DEVHOME = $HOME.'/Develop'
endif

" $DOTFILES
if !exists('$DOTFILES') && finddir('dotfiles/dotfiles', $DEVHOME) != ''
  let $DOTFILES = $DEVHOME.'/dotfiles/dotfiles'
endif

" backup, swap
if finddir('backup', $VIMHOME) == ''
  cal mkdir(expand('$VIMHOME/backup'), "p")
endif
set backup
set backupext=.bak
set backupdir=$VIMHOME/backup
set backupskip=/tmp/*,/private/tmp/*
set swapfile
set directory=$VIMHOME/backup

" fold
if finddir('view', $VIMHOME) == ''
  cal mkdir(expand('$VIMHOME/view'), "p")
endif
set viewdir=$VIMHOME/view
augroup FoldOptions
  autocmd!
  autocmd BufWritePost * mkview
  autocmd BufReadPost * loadview
augroup END

" undo
if version >= 703
  if finddir('undo', $VIMHOME) == ''
    cal mkdir(expand('$VIMHOME/undo'), "p")
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

source $VIMRUNTIME/macros/matchit.vim

" key mapping {{{
" edit and read .vimrc.init
if filereadable(expand('$DOTFILES/.vimrc'))
  command! EditVimrcInit :tabe   $DOTFILES/.vimrc
  command! ReadVimrcInit :source $DOTFILES/.vimrc
  nnoremap <silent> ,ev :EditVimrcInit<cr>
  nnoremap <silent> ,rv :ReadVimrcInit<cr>
endif

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
nnoremap <silent> ft :bnext<cr>
nnoremap <silent> fT :bprevious<cr>

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
" inoremap {] {}<Left>
" cnoremap {] {}<Left>

" quickfix
nnoremap <silent> <leader>n :cn<cr>
nnoremap <silent> <leader>p :cp<cr>
nnoremap <silent> <leader>q :ccl<cr>
" /=key mapping }}}

" autocmds {{{
augroup MyVimOptions
  autocmd!
  " change directory if you open a file.
  " autocmd BufEnter * execute ':lcd '.expand('%:p:h')
  autocmd QuickfixCmdPost vimgrep cw
augroup END
" /=autocmds }}}

" colorscheme toggle
if !has('gui_running')
  let g:color_nr = 1
  function! ColorschemeToggle()
    if g:color_nr == 0
      colorscheme default
      let g:color_nr = 1
    elseif g:color_nr == 1
      colorscheme concise
      let g:color_nr = 0
    endif
  endfunction
  cal ColorschemeToggle()
  command! ColorschemeToggle call ColorschemeToggle()
endif

" plugin {{{
" vundle {{{
filetype off
set rtp+=$VIMHOME/bundle/vundle
call vundle#rc('$VIMHOME/bundle')
" vundle is managed by itself
Bundle 'gmarik/vundle'

" useful
Bundle "autodate.vim"
Bundle 'mattn/webapi-vim'

" ctrlp
Bundle 'kien/ctrlp.vim'
Bundle 'mattn/ctrlp-gist'
Bundle 'mattn/ctrlp-mark'
Bundle 'mattn/ctrlp-launcher'
Bundle 'mattn/ctrlp-register'
Bundle 'kaneshin/ctrlp-memolist'
Bundle 'kaneshin/ctrlp-sonictemplate'
Bundle 'kaneshin/ctrlp-filetype'
Bundle 'kaneshin/ctrlp-git'
Bundle 'kaneshin/ctrlp-sudden-death'
Bundle 'kaneshin/ctrlp-project'

" vim-surround
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-repeat'

" statusline
Bundle 'Lokaltog/vim-powerline'
Bundle 'tpope/vim-fugitive'

Bundle 'mattn/gist-vim'
Bundle 'mattn/emmet-vim'
Bundle 'glidenote/memolist.vim'
Bundle 'mattn/sonictemplate-vim'
Bundle 'thinca/vim-quickrun'
Bundle 'Lokaltog/vim-easymotion'

" misc
Bundle 'tyru/open-browser.vim'
Bundle 'scrooloose/nerdcommenter'

" source
Bundle 'wesleyche/SrcExpl'
Bundle 'vim-scripts/taglist.vim'
Bundle 'scrooloose/nerdtree'

" syntax
Bundle 'vim-ruby/vim-ruby'
Bundle 'JavaScript-syntax'
Bundle 'jQuery'
Bundle 'tpope/vim-markdown'
Bundle 'b4winckler/vim-objc'
Bundle 'cakebaker/scss-syntax.vim'

" ===== recently installed =====
Bundle 'smartword'
Bundle 'thinca/vim-ref'
Bundle 'tpope/vim-abolish'

filetype plugin indent on
" /=vundle }}}

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
let g:ctrlp_max_files = 5000
let g:ctrlp_mruf_max = 250
let g:ctrlp_max_depth = 40
let g:ctrlp_use_migemo = 0
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': '',
  \ }
if finddir('.cache/ctrlp', $VIMHOME) == ''
  cal mkdir(expand('$VIMHOME/.cache/ctrlp'), "p")
endif
let g:ctrlp_cache_dir = $VIMHOME.'/.cache/ctrlp'
let g:ctrlp_extensions = [
      \'git_log',
      \'project',
      \]
let g:ctrlp_filetype = {
      \'user': [
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
nnoremap <c-e>m :<c-u>CtrlPMemolist<cr>
nnoremap <c-e>f :<c-u>CtrlPFiletype<cr>
nnoremap <c-e>p :<c-u>CtrlPProject<cr>
" /=ctrlp }}}

" gist-vim {{{
let g:gist_show_privates = 1
if s:is_mac
  let g:gist_clip_command = 'pbcopy'
elseif s:is_unix
  let g:gist_clip_command = 'xclip -selection clipboard'
endif
" /=gist-vim }}}

" sonictemplate {{{
let g:sonictemplate_vim_template_dir = [
      \expand('$VIMHOME/template'),
      \expand('$DOTFILES/.vim/template'),
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
let b:quickrun_config = {}
let g:quickrun_config = {
\ '_': {
\   'outputter' : 'buffer',
\   'outputter/buffer/split': 'rightbelow 10sp',
\   'runner': 'system',
\ },
\ 'c': {
\   'command': 'clang',
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
" /=quickrun }}}

" TwitVim {{{
let g:twitvim_count = 50
nnoremap <silent> ,tt :tabnew<cr>:<c-u>FriendsTwitter<cr>:close<cr>
nnoremap <silent> ,tp :<c-u>PosttoTwitter<cr>
function! s:twitvim_options()
  setlocal nowrap
  nnoremap <buffer> <silent> s :<c-u>PosttoTwitter<cr>
  nnoremap <buffer> <silent> <c-n> :<c-u>NextTwitter<cr>
  nnoremap <buffer> <silent> <c-p> :<c-u>BackTwitter<cr>
  nnoremap <buffer> <silent> ,tu :<C-u>UserTwitter<CR>
  nnoremap <buffer> <silent> ,tr :<C-u>RepliesTwitter<CR>
endfunction
augroup TwitVimOptions
  autocmd!
  autocmd FileType twitvim :call s:twitvim_options()
augroup END
" /=TwitVim }}}

" TweetVim {{{
nnoremap <silent> ,t1 :<c-u>TweetVimSwitchAccount _kaneshin<cr>
nnoremap <silent> ,t2 :<c-u>TweetVimSwitchAccount kaneshinth<cr>
nnoremap <silent> ,ts :<C-u>TweetVimSay<CR>
nnoremap <silent> ,th :tabnew<cr>:<c-u>TweetVimHomeTimeline<cr>
let g:tweetvim_tweet_per_page = 50
let g:tweetvim_display_separator = 0
let g:tweetvim_footer = ''
function! s:tweetvim_options()
  setlocal nowrap
  nnoremap <buffer> <silent> 1 :<c-u>TweetVimSwitchAccount _kaneshin<cr>
  nnoremap <buffer> <silent> 2 :<c-u>TweetVimSwitchAccount kaneshinth<cr>
  nnoremap <buffer> <silent> s :<C-u>TweetVimSay<CR>
endfunction
augroup TweetVimOptions
  autocmd!
  autocmd FileType tweetvim :call s:tweetvim_options()
augroup END
" /=TweetVim }}}

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

" memolist {{{
let g:memolist_path = $HOME.'/Documents/Notes'
let g:memolist_memo_suffix = "mkd"
let g:memolist_memo_date = "%Y-%m-%d %H:%M"
let g:memolist_prompt_tags = 0
let g:memolist_prompt_categories = 0
" let g:memolist_qfixgrep = 1
" let g:memolist_vimfiler = 1
" /=memolist }}}

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

" /=plugin }}}

