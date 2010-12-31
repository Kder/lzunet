@echo off
set PATHEXT=%PATHEXT%;.py;.pyw
cd /d %~p0
for /f "tokens=1,2* delims= " %%i in (lzunet.txt) do set userid=%%i&&set passwd=%%j
startup.py %userid% %passwd%
pause
