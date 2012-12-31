" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .vimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 01-Jan-2013.

scriptencoding utf-8

syntax on
filetype plugin on
filetype indent on

" lazy mapping
nnoremap ; :
vnoremap ; :

" windows
let s:is_win = has('win32') || has('win64')
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
if finddir('undo', $VIMHOME) == ''
  cal mkdir(expand('$VIMHOME/undo'), "p")
endif
set undofile
set undodir=$VIMHOME/undo
augroup UndoOptions
  autocmd!
augroup END

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
" set clipboard=unnamed
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

" load .vimrc.init
if (exists('g:unload_vimrc_init') && g:unload_vimrc_init)
  finish
endif
source $HOME/.vimrc.init
