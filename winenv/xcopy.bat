@set TARGET=%HOMEDRIVE%%HOMEPATH%
@set ORGDIR=%HOMEDRIVE%%HOMEPATH%\Dropbox\dev\dotfiles\winenv
xcopy %ORGDIR%\bin %TARGET%\bin\
xcopy %ORGDIR%\.ckw %TARGET%\.ckw\

@pause
