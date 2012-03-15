" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set foldmethod=marker foldmarker={{{,}}}:
"===========================================================================
" File: .gvimrc
" Last Change: 10-Mar-2012.
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
"===========================================================================

" ##### basic setting
scriptencoding utf-8
set guioptions=agirLt

" ##### variables {{{
" Windows (not on terminal)
let s:is_win = has( 'win32' ) || has( 'win64' )
" Mac (not on terminal)
let s:is_mac = has( 'mac' )
" UNIX
let s:is_unix = has( 'unix' ) && !s:is_mac && !s:is_win
" /=variables }}}

" ##### display {{{
set linespace=1
set columns=90
set lines=40
set cmdheight=2
colorscheme desert
if s:is_win
  colorscheme molokai
elseif s:is_mac
  set transparency=5
  set linespace=2
  " colorscheme Wombat
  colorscheme molokai
endif
" /=display }}}

nnoremap <silent> <C-F11> :call MyGuioptions()<CR>
function! MyGuioptions()
  if &guioptions =~ 'm'
    exec 'set guioptions-=m'
  else
    exec 'set guioptions+=m'
  endif
endfunction

" ##### cursor color {{{
if has( 'multi_byte_ime' )
  highlight cursor guifg=NONE guibg=Gray
  highlight cursorIM guifg=NONE guibg=Purple
endif
" /=cursor color }}}

" ##### font {{{
" Consolas
function! s:font_consolas()
  if s:is_win
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
  if s:is_win
    set guifont=Ricty:h11:cSHIFTJIS
    if has( 'kaoriya' )
      set ambiwidth=auto
    endif
  elseif s:is_mac
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
