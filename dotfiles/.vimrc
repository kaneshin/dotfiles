" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .pvimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 27-Aug-2012.
" Descriptsion:
"   This file contains Shintaro's primary vimrc setting

scriptencoding utf-8

if exists('g:loaded_pvimrc') && g:loaded_pvimrc
  finish
endif
let g:loaded_pvimrc = 1

syntax on
filetype plugin on
filetype indent on

" be improved
set nocompatible
" lazy mapping
nnoremap ; :

" variables {{{
" Windows
let s:is_win = has( 'win32' ) || has( 'win64' )
" Mac
let s:is_mac = has( 'mac' )
" UNIX
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

" $DROPBOX
if !exists( '$DROPBOX' ) && finddir('Dropbox', $HOME) != ''
  let $DROPBOX = $HOME.'/Dropbox'
endif

" $DOTFILES
" NOTE: Dotfiles directory is in dropbox directory.
if !exists( '$DOTFILES' ) && finddir('dev/dotfiles/dotfiles', $DROPBOX) != ''
  let $DOTFILES = $DROPBOX.'/dev/dotfiles/dotfiles'
endif
" /=variables }}}
"
" options {{{
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
  " autocmd BufReadPost * loadview
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
set listchars=eol:\ ,tab:>\ ,trail:S,extends:<

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
set clipboard=unnamed
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
" /=options }}}

