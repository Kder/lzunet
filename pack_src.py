#coding:utf8
import os
import sys
import lzunet


def checkdigit(x):
  if x.isdigit():
    return x

rev = filter(checkdigit, lzunet.__revision__)

fenc = sys.getfilesystemencoding()
os.system(u'7z a lzunet-%s.%s-src.7z lzunet.py lzunet.txt login.sh logout.sh 登录.bat 下线.bat'.encode(fenc) % (lzunet.__version__, rev))
