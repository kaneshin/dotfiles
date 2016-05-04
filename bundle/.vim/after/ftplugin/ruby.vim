" Ruby filetype plugin
" Language:     Ruby
" Maintainer:   Shintaro Kaneko
" Last Change:  18-Oct-2012.

scriptencoding utf-8

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin_ruby")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin_ruby = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal autoindent
setlocal cindent
setlocal expandtab
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal tabstop=2
setlocal smarttab

let &cpo = s:save_cpo
