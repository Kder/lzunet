#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''lzunet startup script
to start corresponding version of lzunet for Python version 2 or 3
'''

import sys
import os
import re


def loadconf():
    try:
        f = open('lzunet.txt')
#        userid, passwd = string.split(f.readline().strip(), maxsplit=1)
        userid, passwd = re.split('\s+', f.readline().strip(), maxsplit=1)
        f.close()
#    except Exception as e:
    except:
        return 8
#        sys.stderr.write(str(e))
    return userid, passwd

userpass = loadconf()
if userpass is 8: 
    sys.stderr.write('Cannot read config file.\n')
    sys.exit()
lzunet = 'lzunet3.py'
if sys.version_info[0] is 2:
	lzunet = 'lzunet.py'
if 'logout' in sys.argv:
	os.system('%s logout' % lzunet)
else:
	os.system('%s %s %s' % (lzunet, userpass[0], userpass[1]))
