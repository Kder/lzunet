@echo off
cd /d %~dp0
7z a lzunet-1.2.0.68-src.7z lzunet.py lzunet3.py startup.py lzunet.txt login.sh logout.sh µÇÂ¼.bat ÏÂÏß.bat
rem 7z a -tzip -xr!*.svn* lzunet-lua-1.2.3.zip lzunet-lua
pause