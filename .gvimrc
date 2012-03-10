" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set foldmethod=marker foldmarker={{{,}}}:
"===========================================================================
" File: .gvimrc
" Last Change: 08-Mar-2012.
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
if has( 'mac' )
  set transparency=5
endif
" /=display }}}
if has( 'gui_running' )
  nnoremap <silent> <C-F11> :call MyGuioptions()<CR>
  function! MyGuioptions()
    if &guioptions =~ 'm'
      exec 'set guioptions-=m'
    else
      exec 'set guioptions+=m'
    endif
  endfunction
endif

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
  elseif has( 'mac' )
    set guifont=Ricty:h14
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
