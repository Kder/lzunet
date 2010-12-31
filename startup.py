#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''lzunet startup script
to start corresponding version of lzunet for Python version 2 or 3
'''

import sys
import os
lzunet = 'lzunet3.py'
if sys.version_info[0] is 2:
	lzunet = 'lzunet.py'
if len(sys.argv) is 2:
	os.system('%s logout' % lzunet)
else:
	os.system('%s %s %s' % (lzunet, sys.argv[1], sys.argv[2]))