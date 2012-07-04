" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" Vim color file
"
" File:         cosine.vim
" Maintainer:   Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change:  04-Jul-2012.
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

