@echo off
cd /d %~dp0
rem for /f "tokens=1,2* delims= " %%i in (lzunet.txt) do set userid=%%i&&set passwd=%%j
rem lua5.1 lzunet.lua %userid% %passwd%
lua5.1 lzunet.lua login
pause
