@echo off
cd /d %~p0
for /f "tokens=1,2* delims= " %%i in (lzunet.txt) do set userid=%%i&&set passwd=%%j
lua5.1 lzunet.lua %userid% %passwd%
pause
