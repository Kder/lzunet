@echo off
set PATHEXT=%PATHEXT%;.py;.pyw
cd /d %~dp0
for /f "tokens=1,2* delims= " %%i in (lzunet.txt) do set userid=%%i&&set passwd=%%j
if not exist startup.py (
    lzunet %userid% %passwd%
) else (
    .\startup %userid% %passwd%
)
rem startup.py login
pause
