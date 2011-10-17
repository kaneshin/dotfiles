" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set foldmethod=marker foldmarker={{{,}}} :
"===========================================================================
" File: .gvimrc
" Last Change: 18-Oct-2011.
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
"===========================================================================
"
" # basic setting
" {{{
scriptencoding utf-8
" }}}
"
" # GUI setting
" {{{
" ## option
" {{{
set guioptions=aegimrLt
" }}}
" ## display
" {{{
set linespace=1
set columns=90
set lines=40
set cmdheight=2
colorscheme molokai
" }}}
" ## cursor color
" {{{
if has( 'multi_byte_ime' )
  highlight cursor guifg=NONE guibg=Gray
  highlight cursorIM guifg=NONE guibg=Purple
endif
" }}}
" }}}
"
" # font
" {{{
" ## Ricty
" {{{
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
" }}}
" ## あんずもじ等幅
" {{{
function! s:font_anzumoji()
  set guifont=あんずもじ等幅:h12:cSHIFTJIS
endfunction
command! FontAnzumoji :call <SID>font_anzumoji()
" }}}
" ### default font
call s:font_ricty()
" }}}
"
" # .gvimrc setting
" {{{
command! EditgVimrc :tabe $DROPBOX/dotfiles/.gvimrc
command! ReadgVimrc :so $DROPBOX/dotfiles/.gvimrc
nnoremap ,eg :EditgVimrc<CR>
nnoremap ,rg :ReadgVimrc<CR>
" }}}
