" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set foldmethod=marker foldmarker={{{,}}}:
"===========================================================================
" File: .gvimrc
" Last Change: 20-Nov-2011.
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
"===========================================================================
"
"====================
" basic setting
scriptencoding utf-8
"
"====================
" options
set guioptions=aegimrLt
"
" display
set linespace=1
set columns=90
set lines=40
set cmdheight=2
colorscheme molokai
"
" cursor color
if has( 'multi_byte_ime' )
  highlight cursor guifg=NONE guibg=Gray
  highlight cursorIM guifg=NONE guibg=Purple
endif
"
"====================
" fonts
" Ricty
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
command! FontRicty :call <SID>font_ricty()

" default font
call s:font_ricty()

" EOF
