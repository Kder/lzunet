@cd /d %~p0
C:\Python27\python.exe setup.py py2exe && upx dist/lzu_net_auth.exe
move dist\lzu_net_auth.exe .
7z a lzunet-1.0.1-win.7z lzu_net_auth.exe ��¼.bat ����.bat
@pause