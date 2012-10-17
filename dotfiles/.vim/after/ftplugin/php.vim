" PHP filetype plugin
" Language:     PHP
" Maintainer:   Shintaro Kaneko
" Last Change:  18-Oct-2012.

scriptencoding utf-8

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin_php")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin_php = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal autoindent
setlocal cindent
setlocal cinoptions=s,e0,n0,f0,{0,}0,^0,:s,=s,l0,b0,gs,hs,ps,ts,is,+s,c3,C0,/0,(s,us,U0,w0,W0,m1,j0,)100,*30,#0
setlocal expandtab
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4
setlocal smarttab

let &cpo = s:save_cpo
