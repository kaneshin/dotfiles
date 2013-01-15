" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .gvimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 11-Jan-2013.

scriptencoding utf-8

set guioptions=agirLt

set linespace=1
set columns=80
set lines=40
set cmdheight=2
colorscheme cosine

if has('mac')
  set transparency=3
  set linespace=2
endif

if has('mac')
  set guifont=Ricty:h14
else
