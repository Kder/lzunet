@echo off
set PATHEXT=%PATHEXT%;.py;.pyw
cd /d %~dp0
if not exist startup.py (
    .\lzunet logout
) else (
    .\startup logout
)
pause