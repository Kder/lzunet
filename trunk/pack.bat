@cd /d %~p0
F:\Python27\python.exe setup.py py2exe && upx dist/lzunet.exe
move dist\lzunet.exe .
7z a lzunet-1.0.2-win.7z lzunet.exe µÇÂ¼.bat ÏÂÏß.bat
@pause