#coding:utf8
import os
import sys
fenc = sys.getfilesystemencoding()
os.system(u'7z a lzunet-1.2.0.69-src.7z lzunet.py lzunet3.py startup.py lzunet.txt login.sh logout.sh 登录.bat 下线.bat'.encode(fenc))


