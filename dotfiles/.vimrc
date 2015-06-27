" vim:set ts=8 sts=2 sw=2 tw=0:
" vim:set fdm=marker:
"
" File:        .vimrc
" Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
" Last Change: 27-Jun-2015.

syntax on
filetype plugin on
filetype indent on

" load util functions
let s:utilfile = expand($HOME.'/.vimrc.util')
if filereadable(s:utilfile)
  execute "silent! source " . s:utilfile
endif

" set $DOTFILES
let s:dirpath = $HOME . '/Develop/dotfiles/dotfiles'
if !exists('$DOTFILES') && finddir(s:dirpath) != ''
  let $DOTFILES = s:dirpath
endif

" load pure run command
call UtilSourceFile($HOME . "/.virc")

" load mapping configuration
call UtilSourceFile($HOME . "/.vimrc.map")

" load autocommand configuration
call UtilSourceFile($HOME . "/.vimrc.autocmd")

" load environment configuration
let s:envfile = $HOME . "/.vimrc.unix"
if UtilIsDarwin()
  let s:envfile = $HOME . "/.vimrc.darwin"
elseif UtilIsWindows()
  let s:envfile = $HOME . "/.vimrc.windows"
endif
cal UtilSourceFile(s:envfile)

" load plugin configuration
call UtilSourceFile($HOME . "/.vimrc.plugin")

" set colorscheme
silent! colorscheme concise

" load local configuration
call UtilSourceFile($HOME . "/.vimrc.local")

