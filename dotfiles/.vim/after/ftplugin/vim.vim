" Vim filetype plugin
" Language:     Vim
" Maintainer:   Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change:  27-May-2012.

scriptencoding utf-8

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin_vim")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin_vim = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal expandtab
setlocal tabstop=2
setlocal softtabstop=2
setlocal shiftwidth=2

let &cpo = s:save_cpo

