" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .gvimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 28-May-2012.

scriptencoding utf-8
set guioptions=agirLt

" Windows (not on terminal)
let s:is_win = has( 'win32' ) || has( 'win64' )
" Mac (not on terminal)
let s:is_mac = has( 'mac' )
" UNIX
let s:is_unix = has( 'unix' ) && !s:is_mac && !s:is_win

" display
set linespace=1
set columns=80
set lines=40
set cmdheight=2
colorscheme desert
if s:is_win || s:is_unix
  colorscheme molokai
elseif s:is_mac
  set transparency=5
  set linespace=2
  colorscheme Wombat
endif

" cursor color
if has( 'multi_byte_ime' )
  highlight cursor guifg=NONE guibg=Gray
  highlight cursorIM guifg=NONE guibg=Purple
endif

" Default font
function! s:setFont_default()
  if s:is_win
    set guifont=Consolas:h10:cSHIFTJIS
    if has( 'kaoriya' )
      set ambiwidth=auto
    endif
  elseif s:is_mac
    set guifont=Courier:h14
  else
    set guifont=Courier
  endif
endfunction
command! FontDefault :call s:setFont_default()
" Ricty
function! s:setFont_Ricty()
  if s:is_win
    set guifont=Ricty:h11:cSHIFTJIS
    if has( 'kaoriya' )
      set ambiwidth=auto
    endif
  elseif s:is_mac
    set guifont=Ricty:h14
  else
    set guifont=Ricty
  endif
endfunction
command! FontRicty :call s:setFont_Ricty()
" set font
call s:setFont_Ricty()
" /=font }}}

