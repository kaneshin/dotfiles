" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" Vim color file
"
" File:         cosine.vim
" Maintainer:   Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change:  09-Nov-2012.
" Note:
" This theme is based on the molokai theme by Tomas Restrepo

set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let g:colors_name="cosine"

hi Boolean        guifg=#AE81FF
hi Character      guifg=#E6DB74
hi Number         guifg=#AE81FF
hi String         guifg=#E6DB74               gui=italic
hi Conditional    guifg=#F92672               gui=none
hi Constant       guifg=#AE81FF               gui=none
hi Cursor         guifg=#000000 guibg=#F8F8F0
hi Debug          guifg=#BCA3A3               gui=none
hi Define         guifg=#66D9EF
hi Delimiter      guifg=#8F8F8F
hi DiffAdd                      guibg=#13354A
hi DiffChange     guifg=#89807D guibg=#4C4745
hi DiffDelete     guifg=#960050 guibg=#1E0010
hi DiffText                     guibg=#4C4745 gui=italic,none

hi Directory      guifg=#A6E22E               gui=none
hi Error          guifg=#960050 guibg=#1E0010
hi ErrorMsg       guifg=#F92672 guibg=#232526 gui=none
hi Exception      guifg=#A6E22E               gui=none
hi Float          guifg=#AE81FF
hi FoldColumn     guifg=#99968b guibg=#000000
hi Folded         guifg=#99968b guibg=#000000
hi Function       guifg=#A6E22E
hi Identifier     guifg=#FD971F
hi Ignore         guifg=#808080 guibg=bg
hi IncSearch      guifg=#C4BE89 guibg=#000000

hi Keyword        guifg=#F92672               gui=none
hi Label          guifg=#E6DB74               gui=none
hi Macro          guifg=#C4BE89               gui=italic
hi SpecialKey     guifg=#66D9EF               gui=italic

hi MatchParen     guifg=#000000 guibg=#FD971F gui=none
hi ModeMsg        guifg=#E6DB74
hi MoreMsg        guifg=#E6DB74
hi Operator       guifg=#F92672

" complete menu
hi Pmenu          guifg=#66D9EF guibg=#000000
hi PmenuSel                     guibg=#808080
hi PmenuSbar                    guibg=#080808
hi PmenuThumb     guifg=#66D9EF

hi PreCondit      guifg=#A6E22E               gui=none
hi PreProc        guifg=#A6E22E
hi Question       guifg=#66D9EF
hi Repeat         guifg=#F92672               gui=none
hi Search         guifg=#FFFFFF guibg=#455354
" marks column
hi SignColumn     guifg=#A6E22E guibg=#232526
hi SpecialChar    guifg=#F92672               gui=none
hi SpecialComment guifg=#99968b               gui=none
hi Special        guifg=#66D9EF guibg=bg      gui=italic
hi SpecialKey     guifg=#888A85               gui=italic
if has("spell")
  hi SpellBad     guisp=#FF0000 gui=undercurl
  hi SpellCap     guisp=#7070F0 gui=undercurl
  hi SpellLocal   guisp=#70F0F0 gui=undercurl
  hi SpellRare    guisp=#FFFFFF gui=undercurl
endif
hi Statement      guifg=#F92672               gui=none
hi StatusLine     guifg=#455354 guibg=fg
hi StatusLineNC   guifg=#808080 guibg=#080808
hi StorageClass   guifg=#FD971F               gui=italic
hi Structure      guifg=#66D9EF
hi Tag            guifg=#F92672               gui=italic
hi Title          guifg=#ef5939               gui=bold
hi Todo           guifg=#8f8f8f               gui=italic

hi Typedef        guifg=#66D9EF
hi Type           guifg=#66D9EF               gui=none
hi Underlined     guifg=#808080               gui=underline

hi VertSplit      guifg=#808080 guibg=#080808 gui=none
hi VisualNOS                    guibg=#403D3D
hi Visual                       guibg=#403D3D
hi WarningMsg     guifg=#FFFFFF guibg=#333333 gui=none
hi WildMenu       guifg=#66D9EF guibg=#000000

hi Normal         guifg=#f6f3e8 guibg=#242424 gui=none
hi Comment        guifg=#99968b               gui=none
hi CursorLine                   guibg=#293739
hi CursorColumn                 guibg=#293739
hi LineNr         guifg=#BCBCBC guibg=#232526
hi NonText        guifg=#808080 guibg=#303030 gui=none

"
" Support for 256-color terminal
"
if &t_Co > 255
   hi Boolean         ctermfg=135
   hi Character       ctermfg=144
   hi Number          ctermfg=135
   hi String          ctermfg=144
   hi Conditional     ctermfg=161               cterm=none
   hi Constant        ctermfg=135               cterm=none
   hi Cursor          ctermfg=16  ctermbg=253
   hi Debug           ctermfg=225               cterm=none
   hi Define          ctermfg=81
   hi Delimiter       ctermfg=241

   hi DiffAdd                     ctermbg=24
   hi DiffChange      ctermfg=181 ctermbg=239
   hi DiffDelete      ctermfg=162 ctermbg=53
   hi DiffText                    ctermbg=102 cterm=none

   hi Directory       ctermfg=118               cterm=none
   hi Error           ctermfg=219 ctermbg=89
   hi ErrorMsg        ctermfg=199 ctermbg=16    cterm=none
   hi Exception       ctermfg=118               cterm=none
   hi Float           ctermfg=135
   hi FoldColumn      ctermfg=67  ctermbg=16
   hi Folded          ctermfg=67  ctermbg=16
   hi Function        ctermfg=118
   hi Identifier      ctermfg=208
   hi Ignore          ctermfg=244 ctermbg=232
   hi IncSearch       ctermfg=193 ctermbg=16

   hi Keyword         ctermfg=161               cterm=none
   hi Label           ctermfg=229               cterm=none
   hi Macro           ctermfg=193
   hi SpecialKey      ctermfg=81

   hi MatchParen      ctermfg=16  ctermbg=208 cterm=none
   hi ModeMsg         ctermfg=229
   hi MoreMsg         ctermfg=229
   hi Operator        ctermfg=161

   " complete menu
   hi Pmenu           ctermfg=81  ctermbg=16
   hi PmenuSel                    ctermbg=244
   hi PmenuSbar                   ctermbg=232
   hi PmenuThumb      ctermfg=81

   hi PreCondit       ctermfg=118               cterm=none
   hi PreProc         ctermfg=118
   hi Question        ctermfg=81
   hi Repeat          ctermfg=161               cterm=none
   hi Search          ctermfg=253 ctermbg=66

   " marks column
   hi SignColumn      ctermfg=118 ctermbg=235
   hi SpecialChar     ctermfg=161               cterm=none
   hi SpecialComment  ctermfg=245               cterm=none
   hi Special         ctermfg=81  ctermbg=232
   hi SpecialKey      ctermfg=245

   hi Statement       ctermfg=161               cterm=none
   hi StatusLine      ctermfg=238 ctermbg=253
   hi StatusLineNC    ctermfg=244 ctermbg=232
   hi StorageClass    ctermfg=208
   hi Structure       ctermfg=81
   hi Tag             ctermfg=161
   hi Title           ctermfg=166
   hi Todo            ctermfg=231 ctermbg=232   cterm=none

   hi Typedef         ctermfg=81
   hi Type            ctermfg=81                cterm=none
   hi Underlined      ctermfg=244               cterm=underline

   hi VertSplit       ctermfg=244 ctermbg=232   cterm=none
   hi VisualNOS                   ctermbg=238
   hi Visual                      ctermbg=245
   hi WarningMsg      ctermfg=231 ctermbg=238   cterm=none
   hi WildMenu        ctermfg=81  ctermbg=16

   hi Normal          ctermfg=252 ctermbg=233
   hi Comment         ctermfg=59
   hi CursorLine                  ctermbg=234   cterm=none
   hi CursorColumn                ctermbg=234
   hi LineNr          ctermfg=250 ctermbg=234
   hi NonText         ctermfg=250 ctermbg=234
end

