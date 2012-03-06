@echo on
set LINKDIR=%HOMEDRIVE%%HOMEPATH%
set TARGETDIR=C:\Users\kaneshin\Dropbox\dotfiles
mklink %LINKDIR%\.vimrc %TARGETDIR%\.vimrc
mklink %LINKDIR%\.gvimrc %TARGETDIR%\.gvimrc
