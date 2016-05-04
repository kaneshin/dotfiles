" C filetype plugin
" Language:     C
" Maintainer:   Shintaro Kaneko
" Last Change:  18-Oct-2012.

scriptencoding utf-8

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin_c")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin_c = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal autoindent
setlocal cindent
setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=8
setlocal smarttab

let &cpo = s:save_cpo
