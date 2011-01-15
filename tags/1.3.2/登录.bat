@echo off
set PATHEXT=%PATHEXT%;.py;.pyw
cd /d %~dp0
REM for /f "tokens=1,2* delims= " %%i in (lzunet.txt) do set userid=%%i&&set passwd=%%j
.\lzunet
pause
