" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .vimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 16-Mar-2021.

syntax on
filetype plugin on
filetype indent on

" set $VIMHOME
if !exists('$VIMHOME')
  let s:filepath = $HOME . '/.vim'
  if has('win32') || has('win64')
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
  command! EditVimrc :tabe   $HOME/.vimrc
  command! ReadVimrc :source $HOME/.vimrc
  nnoremap <silent> ,ev :EditVimrc<cr>
  nnoremap <silent> ,rv :ReadVimrc<cr>
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

augroup QuickFixOptions
  autocmd!
  autocmd QuickfixCmdPost vimgrep cw
  autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
augroup END

source $VIMRUNTIME/macros/matchit.vim

" vim-plug {{{
call plug#begin('~/.vim/plugged')

Plug 'vim-scripts/autodate.vim'
Plug 'mattn/webapi-vim'
Plug 'kana/vim-smartword'

" tools
Plug 'vim-airline/vim-airline'
Plug 'mattn/gist-vim'
Plug 'kristijanhusak/vim-carbon-now-sh'

" devel
Plug 'mattn/sonictemplate-vim'
Plug 'thinca/vim-quickrun'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'mattn/emmet-vim'
Plug 'ryanolsonx/vim-lsp-typescript'

"" go
Plug 'mattn/vim-goimports'

"" prettier
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

"" syntax
Plug 'stephpy/vim-yaml'
Plug 'tpope/vim-markdown'
Plug 'hashivim/vim-terraform'
Plug 'chase/vim-ansible-yaml'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'cakebaker/scss-syntax.vim'
Plug 'posva/vim-vue'
Plug 'digitaltoad/vim-pug'
Plug 'mxw/vim-jsx'
Plug 'rust-lang/rust.vim'

" finder
Plug 'ctrlpvim/ctrlp.vim'

"" ctrlp plugins
Plug 'mattn/ctrlp-register'
Plug 'kaneshin/ctrlp-sonictemplate'
Plug 'kaneshin/ctrlp-filetype'

call plug#end()
" }}}

""" Plug 'mattn/gist-vim'
let g:gist_token_file = expand('$HOME/.config/github/.gist-vim')
let g:gist_detect_filetype = 1
let g:gist_show_privates = 1
let g:gist_post_private = 1
if has('mac')
  let g:gist_clip_command = 'pbcopy'
elseif has('unix')
  let g:gist_clip_command = 'xclip -selection clipboard'
endif

""" Plug 'kristijanhusak/vim-carbon-now-sh'
let g:carbon_now_sh_options = {
  \ 'ln': 'false',
  \ 'fm': 'Source Code Pro'
\}
vnoremap <silent> <c-i> :CarbonNowSh<CR>

""" Plug 'mattn/sonictemplate-vim'
let g:sonictemplate_vim_template_dir = [
      \expand('$VIMHOME/template'),
      \expand('$HOME/.vim/template'),
      \]

""" Plug 'thinca/vim-quickrun'
let g:quickrun_config = {
      \ '_': {
      \   'outputter' : 'buffer',
      \   'outputter/buffer/split': '6'
      \ },
      \}

""" Plug 'prabirshrestha/vim-lsp'
let g:lsp_diagnostics_enabled = 1
let g:lsp_signs_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:lsp_text_edit_enabled = 0

if executable('gopls')
  augroup LspGo
    au!
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'go-lang',
          \ 'cmd': {server_info->['gopls']},
          \ 'whitelist': ['go'],
          \ 'workspace_config': {'gopls': {
          \     'staticcheck': v:true,
          \     'completeUnimported': v:true,
          \     'caseSensitiveCompletion': v:true,
          \     'usePlaceholders': v:true,
          \     'completionDocumentation': v:true,
          \     'watchFileChanges': v:true,
          \     'hoverKind': 'SingleLine',
          \   }},
          \ })
    autocmd FileType go setlocal omnifunc=lsp#complete
    autocmd FileType go nmap <buffer> gd <plug>(lsp-definition)
    autocmd FileType go nmap <buffer> ,n <plug>(lsp-next-error)
    autocmd FileType go nmap <buffer> ,p <plug>(lsp-previous-error)
  augroup END
endif

if executable('typescript-language-server')
  augroup LspTS
    au!
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'typescript-language-server',
          \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
          \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
          \ 'whitelist': ['typescript', 'typescript.tsx'],
          \ })
  augroup END
endif

if executable('rls')
  augroup LspRust
    au!
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'rls',
          \ 'cmd': {server_info->['rustup', 'run', 'stable', 'rls']},
          \ 'workspace_config': {'rust': {
          \     'clippy_preference': 'on'
          \ }},
          \ 'whitelist': ['rust'],
          \ })
  augroup END
endif

""" Plug 'prettier/vim-prettier'
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0

""" Plug 'ctrlpvim/ctrlp.vim'
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
  \ 'dir':  '\v[\/](node_modules|target|dist)|(\.(swp|ico|git|hg|svn|github))$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': '',
  \ }
if finddir('.cache/ctrlp', $VIMHOME) == ''
  cal mkdir(expand('$VIMHOME/.cache/ctrlp'), "p")
endif
let g:ctrlp_cache_dir = $VIMHOME.'/.cache/ctrlp'
let g:ctrlp_extensions = [
      \'tag',
      \'quickfix',
      \'dir',
      \'undo',
      \'line',
      \'changes',
      \'mixed'
      \]
nnoremap <c-e>t :<c-u>CtrlPSonictemplate<cr>
inoremap <c-e>t <esc>:<c-u>CtrlPSonictemplate<cr>
nnoremap <c-e>f :<c-u>CtrlPFiletype<cr>

""" Plug 'rust-lang/rust.vim'
let g:rustfmt_autosave = 1

" set colorscheme
silent! colorscheme concise

" load local configuration
let g:vimrc_local = $HOME."/.vimrc.local"
if filereadable(expand(g:vimrc_local))
  execute "silent! source ".g:vimrc_local
endif


""" ============
""" Experimental
""" ============

" open buffer
function s:OpenReadOnly(target, name, body)
  execute a:target.' '.a:name
  setlocal buflisted modifiable modified noreadonly
  cal append(line('^'), split(a:body, '\n'))
  silent! $d
  setlocal noswapfile nobuflisted buftype=nofile bufhidden=unload
  setlocal nomodifiable nomodified readonly
  setlocal nonumber nobinary nolist
  execute 'normal! 1G'
endfunction

function s:OpenReadOnlyTab(type, name, body)
  cal s:OpenReadOnly('tabnew!', a:name, a:body)
endfunction

function s:OpenReadOnlyBuffer(type, name, body)
  cal s:OpenReadOnly(a:type =~# '^\(v\|vert\)' ? 'vsplit!' : 'split!', a:name, a:body)
endfunction

" Plugin for go-lang
function s:GoInstallBinaries()
  echo 'go get golang.org/x/tools/gopls'
  silent! let res = system('go get golang.org/x/tools/gopls')
  if v:shell_error != 0
    echohl ErrorMsg | echomsg res | echohl None
  endif

  echo 'go get golang.org/x/tools/cmd/goimports'
  silent! let res = system('go get golang.org/x/tools/cmd/goimports')
  if v:shell_error != 0
    echohl ErrorMsg | echomsg res | echohl None
  endif
endfunction
command GoInstallBinaries cal s:GoInstallBinaries()

function s:GoList()
  return systemlist('{ cd $(go env GOROOT)/src && find . -type d } | sed -e "s#^\./##" | grep -v "^\(\.\|vendor\)"')
endfunction
command GoList cal s:GoList()

function s:GoDoc(bang, args)
  let arg = join(split(a:args), '.')
  silent! let res = system('go doc -cmd -all '.arg.' 2>/dev/null')
  if v:shell_error != 0
    let err = systemlist('go doc '.arg.' 1>/dev/null')
    echohl ErrorMsg | echomsg err | echohl None
    return
  endif
  if a:bang == '!'
    call s:OpenReadOnlyTab('' , arg, res)
  else
    call s:OpenReadOnlyBuffer('' , arg, res)
  endif
  setlocal ft=godoc
  nnoremap <buffer> <silent> q :q<cr>
endfunction
function! s:CompleteGoDoc(arg_lead, cmdline, cursor_pos)
    return filter(copy(s:GoList()), 'stridx(v:val, a:arg_lead)==0')
endfunction
command -nargs=1 -bang -complete=customlist,s:CompleteGoDoc GoDoc cal s:GoDoc('<bang>', <f-args>)

" CtrlPGoDoc
" depending the s:GoDoc above
command! CtrlPGoDoc cal ctrlp#init(ctrlp#godoc#id())
nnoremap <c-e>g :<c-u>CtrlPGoDoc<cr>

