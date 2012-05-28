@echo off
echo Run C:\freebox\bin\cmd_init.bat
echo;
echo ++++++++++ Set alias(doskey) ++++++++++
doskey /macrofile=C:\Users\kaneshin\.ckw\.doskey
doskey /macros
echo;
echo ++++++++++ Set PATH ++++++++++
set BIN_LOCAL=C:\Users\kaneshin
set ADD_PATH=%BIN_LOCAL%;
echo set PATH=%PATH%;%ADD_PATH%
set PATH=%PATH%;%ADD_PATH%
echo;
echo ========== End of my definition ==========
echo;

