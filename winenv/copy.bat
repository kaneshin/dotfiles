@set TARGET=%HOMEDRIVE%
@set ORGDIR=%HOMEDRIVE%%HOMEPATH%\Dropbox\dev\dotfiles\winenv
@for %%i in (gvim.bat initcmd.bat) do copy %ORGDIR%\bin\%%i %TARGET%\bin\

@pause

