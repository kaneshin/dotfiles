@echo on
set LINKDIR=%HOMEDRIVE%%HOMEPATH%
set TARGETDIR=D:\home\kaneshin\Dropbox\dotfiles
mklink %LINKDIR%\.vimrc %TARGETDIR%\.vimrc
mklink %LINKDIR%\.gvimrc %TARGETDIR%\.gvimrc
