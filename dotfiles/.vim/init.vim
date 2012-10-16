" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        init.vim
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 17-Oct-2012.

scriptencoding utf-8
syntax on
filetype plugin on
filetype indent on

" windows
let s:is_win = has('win32') || has('win64')
" mac
let s:is_mac = has('mac')
" unix
let s:is_unix = has('unix')

" key mapping {{{
" use emacs key bind during command mode and a movement of insert mode
" start of line
cnoremap <c-a> <Home>
inoremap <c-a> <home>
" back one character
cnoremap <c-b> <Left>
inoremap <c-b> <Left>
" delete character under cursor
cnoremap <c-d> <Del>
" end of line
cnoremap <c-e> <End>
inoremap <c-e> <end>
" forward one character
cnoremap <c-f> <Right>
inoremap <c-f> <Right>
" recall newer command-line
cnoremap <c-n> <Down>
" recall previous (older) command-line
cnoremap <c-p> <Up>
" delete character backward
cnoremap <c-h> <BS>

" normal node
" searching
nnoremap n nzz
nnoremap N Nzz
nnoremap <silent> <ESC><ESC> :nohlsearch<CR>
" spliting window
nnoremap <silent> <C-x>0 :close<CR>
nnoremap <silent> <C-x>1 :only<CR>
nnoremap <silent> <C-x>2 :split<CR>
nnoremap <silent> <C-x>3 :vsplit<CR>
nnoremap <silent> <C-x>n :bnext<CR>
nnoremap <silent> <C-x>p :bprevious<CR>
nnoremap <silent> <C-x>k :close<CR>

" visual mode
vnoremap ; :
vnoremap <silent> > >gv
vnoremap <silent> < <gv
vnoremap f <esc>

" command mode
cmap <C-x> <C-r>=expand('%:p:h')<CR>/
cmap <C-z> <C-r>=expand('%:p:r')<CR>
" /=key mapping }}}

" autocmds {{{
augroup MyVimOptions
  autocmd!
  " change directory if you open a file.
  autocmd BufEnter * execute ':lcd '.expand('%:p:h')
augroup END
" /=autocmds }}}

" plugin {{{
" vundle {{{
filetype off
set rtp+=$VIMHOME/bundle/vundle
call vundle#rc('$VIMHOME/bundle')
" vundle is managed by itself
Bundle 'gmarik/vundle'

Bundle 'mattn/webapi-vim'
Bundle 'mattn/gist-vim'
Bundle 'mattn/zencoding-vim'

" ctrlp
Bundle 'kien/ctrlp.vim'

" Twitter
Bundle 'TwitVim'

filetype plugin indent on
" /=vundle }}}

" ctrlp.vim {{{
" Set this to 0 to show the match window at the top of the screen
let g:ctrlp_match_window_bottom = 1
" Change the listing order of the files in the match window
let g:ctrlp_match_window_reversed = 1
" Set the maximum height of the match window
let g:ctrlp_max_height = 20
let g:ctrlp_switch_buffer = 2
let g:ctrlp_working_path_mode = 2
let g:ctrlp_use_caching = 1
let g:ctrlp_max_files = 10000
let g:ctrlp_mruf_max = 250
let g:ctrlp_max_depth = 40
let g:ctrlp_use_migemo = 0
if finddir('.cache/ctrlp', $VIMHOME) == ''
  cal mkdir(expand('$VIMHOME/.cache/ctrlp'), "p")
endif
let g:ctrlp_cache_dir = $VIMHOME.'/.cache/ctrlp'
let g:ctrlp_extensions = [
      \]
" }}}

" TwitVim {{{
let g:twitvim_count = 50
if s:is_win
  let g:twitvim_browser_cmd
        \ = $HOME.'\AppData\Local\Google\Chrome\Application\chrome.exe'
elseif s:is_mac
  let g:twitvim_browser_cmd
        \ = '/Applications/Safari.app'
elseif s:is_unix
  let g:twitvim_browser_cmd
        \ = ''
endif
nnoremap <silent> ,tp :<C-u>PosttoTwitter<CR>
nnoremap <silent> ,tt :tabnew<CR>:<C-u>FriendsTwitter<CR>:close<CR>
nnoremap <silent> ,tf :tabnew<CR>:<C-u>FavTwitter<CR>:close<CR>
nnoremap <silent> ,tu :tabnew<CR>:<C-u>UserTwitter<CR>:close<CR>
nnoremap <silent> ,tr :tabnew<CR>:<C-u>RepliesTwitter<CR>:close<CR>
function! s:twitvim_options()
  setlocal nowrap
  nnoremap <buffer> <silent> ,tt :<C-u>FriendsTwitter<CR>
  nnoremap <buffer> <silent> ,tf :<C-u>FavTwitter<CR>
  nnoremap <buffer> <silent> ,tu :<C-u>UserTwitter<CR>
  nnoremap <buffer> <silent> ,tr :<C-u>RepliesTwitter<CR>
  nnoremap <buffer> <silent> <C-n> :<C-u>NextTwitter<CR>
  nnoremap <buffer> <silent> <C-p> :<C-u>BackTwitter<CR>
endfunction
augroup TwitVimOptions
  autocmd!
  autocmd FileType twitvim :call s:twitvim_options()
augroup END
" /=TwitVim }}}

" gist-vim {{{
let g:gist_show_privates = 1
if s:is_mac
  let g:gist_clip_command = 'pbcopy'
elseif s:is_unix
  let g:gist_clip_command = 'xclip -selection clipboard'
endif
" /=gist-vim }}}
" /=plugin }}}

if has('gui_running')
  set guioptions=agirLt
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
    colorscheme cosine
    set transparency=5
    set linespace=2
  endif
endif
