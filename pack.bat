@cd /d %~p0
F:\Python27\python.exe setup.py py2exe && upx dist/lzunet.exe
move dist\lzunet.exe .
7z a lzunet-1.1.0-win.7z lzunet.exe µÇÂ¼.bat ÏÂÏß.bat
7z a -t7z -xr!*.svn* lzunet-lua-1.2-win.7z lzunet-lua
@pause