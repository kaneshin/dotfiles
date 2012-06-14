@echo]
@echo Switch to super user.
@echo]

@rem Do not use "echo off" to not affect any child calls.
@setlocal

@rem Get the absolute path to the home directory.
@if not exist "%HOME%" @set HOME=%HOMEDRIVE%%HOMEPATH%

@rem Get the absolute path to the directory of this file.
@set CWD=%~dp0
@set DOTDIR=dotfiles
@set DOTDOTDIR=%CWD%%DOTDIR%
@set WINDIR=winenv
@set DOTWINDIR=%CWD%%WINDIR%

@rem Make a symbolic links from dotfiles and winenv.
@for %%i in (.vimrc .gvimrc) do @mklink %HOME%\%%i %DOTDOTDIR%\%%i
@for %%i in (.doskey) do @copy %DOTWINDIR%\%%i %HOME%

@pause

