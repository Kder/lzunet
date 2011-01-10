@echo off
cd /d %~dp0
F:\Python27\python.exe setup.py py2exe
move dist\lzunet.exe . && upx lzunet.exe
7z a lzunet-1.2.0-win.7z lzunet.exe µÇÂ¼.bat ÏÂÏß.bat
rem 7z a -tzip -xr!*.svn* lzunet-lua-1.2.3.zip lzunet-lua
pause