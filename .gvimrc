" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set foldmethod=marker foldmarker={{{,}}}:
"===========================================================================
" File: .gvimrc
" Last Change: 08-Dec-2011.
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
"===========================================================================

" ##### basic setting
scriptencoding utf-8

" ##### options
set guioptions=agirLt

" ########## display {{{
set linespace=1
set columns=90
set lines=40
set cmdheight=2
colorscheme desert
colorscheme molokai
" /=display }}}

" ########## cursor color {{{
if has( 'multi_byte_ime' )
  highlight cursor guifg=NONE guibg=Gray
  highlight cursorIM guifg=NONE guibg=Purple
endif
" /=cursor color }}}

" ########## font {{{
" Consolas
function! s:font_consolas()
  if has( 'win32' ) || has( 'win64' )
    set guifont=Consolas:h10:cSHIFTJIS
    if has( 'kaoriya' )
      set ambiwidth=auto
    endif
  else
    set guifont=Consolas
  endif
endfunction
" Ricty
command! FontRicty :call <SID>font_ricty()
function! s:font_ricty()
  if has( 'win32' ) || has( 'win64' )
    set guifont=Ricty:h11:cSHIFTJIS
    if has( 'kaoriya' )
      set ambiwidth=auto
    endif
  else
    set guifont=Ricty
  endif
endfunction
" command
command! FontConsolas :call <SID>font_consolas()
command! FontRicty :call <SID>font_ricty()
" default font
call s:font_ricty()
" /=font }}}
"
" EOF
