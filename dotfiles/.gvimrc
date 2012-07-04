" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .gvimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 04-Jul-2012.

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
if s:is_win
  colorscheme cosine
elseif s:is_unix
  colorscheme molokai
elseif s:is_mac
  set transparency=5
  set linespace=2
  colorscheme cosine
  nnoremap <silent> <up> :call <SID>UpTransparency()<cr>
  nnoremap <silent> <down> :call <SID>DownTransparency()<cr>
endif
let transsplit = 20
let g:translevel = 100 / transsplit
function! s:UpTransparency()
  let &transparency = &transparency - (&transparency % g:translevel) + g:translevel
endfunction
function! s:DownTransparency()
  let &transparency = &transparency - (&transparency % g:translevel) - g:translevel
endfunction

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
    set guifont=Monospace
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
if s:is_mac || s:is_win
  call s:setFont_Ricty()
elseif s:is_unix
  call s:setFont_default()
endif
" /=font }}}

