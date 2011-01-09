#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''lzunet startup script
to start corresponding version of lzunet for Python version 2 or 3
'''

import sys
import os
import re
import locale
import runpy

path0 = sys.path[0]
if os.path.isdir(sys.path[0]):
    PROGRAM_PATH = path0
else:
    PROGRAM_PATH = os.path.dirname(path0)
#    PROGRAM_PATH = os.path.join(path0, os.pardir)

CONF = PROGRAM_PATH + os.sep + 'lzunet.txt'
# CONF2 = PROGRAM_PATH + os.sep + 'lzunet.ini'
SYS_ENCODING = locale.getdefaultlocale()[1]

msg = ['请输入您的上网账号和密码\n', '账号：', '密码：']

def loadconf():
    try:
        f = open(CONF)
        userpass = re.split('\s+', f.readline().strip(), maxsplit=1)
        f.close()
#    except Exception as e:
    except:
        return 8
#        sys.stderr.write(str(e))
    return userpass

def getuserpass():
    global msg, input
    if sys.version_info[0] is 2:
        input = raw_input
        msg = [unicode(i, 'utf-8').encode(SYS_ENCODING) for i in msg]
    userpass = loadconf()
    if userpass is 8 or userpass[0] == 'test@lzu.cn':
        sys.stdout.write(msg[0])
        userid = input(msg[1])
        passwd = input(msg[2])
        userpass = (userid, passwd)
        if '' not in userpass:
            with open(CONF,'w') as f:
                f.write('%s %s' % userpass)
    return userpass

if __name__ == '__main__':
    lzunet = 'lzunet3'
    if sys.version_info[0] is 2:
        lzunet = 'lzunet'
    runpy.run_module(lzunet, run_name="__main__", alter_sys=True)

    # userpass = getuserpass()
    # if 'logout' in sys.argv:
        # os.system('%s logout' % lzunet)
    # else:
        # os.system('%s %s %s' % (lzunet, userpass[0], userpass[1]))
