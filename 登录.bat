@echo off
set PATHEXT=%PATHEXT%;.py;.pyw
cd /d %~p0
rem for /f "tokens=1,2* delims= " %%i in (lzunet.txt) do set userid=%%i&&set passwd=%%j
rem startup.py %userid% %passwd%
startup.py login
pause
