#encoding:utf-8

from distutils.core import setup
import py2exe
import lzunet

#class Target:
#    def __init__(self, **kw):
        # for the versioninfo resources
#        self.name = "lzunet"
#        self.description = u"一键登录兰大上网认证系统 One-click login/logout for LZU internet authorization."
#        self.company_name = 'Kder <kderlin # gmail.com>'
#        self.copyright = 'Copyright 2010 Kder'
#        self.version = "1.0" #sharedutil.__version_string__
        #self.comments = "These are some comments." * 100
#        self.__dict__.update(kw)

#the dict is from http://osdir.com/ml/python.py2exe/2004-08/msg00065.html
console_dict = {"script": "lzunet.py",
#"icon_resources": [(0,'bialix.ico')],
"name": "lzunet",
"version": '%s.%s' % (lzunet.__version__, lzunet.__revision__.split(':')[1][:-1].strip()),
"description": u"一键登录兰大上网认证系统",
"author": 'Kder <kderlin (at) gmail.com>',
"copyright": 'Copyright 2010 Kder',
"comments": u"一键登录兰大上网认证系统 by Kder <kderlin (at) gmail.com>",
"company_name": 'Kder <kderlin (at) gmail.com>',
}

setup(name = "lzunet",
      author= 'Kder <kderlin # gmail.com>',
#      console=[Target('lzunet.py')],
      console=[console_dict],
      zipfile = None,
      options = {'py2exe': 
                 {'bundle_files': 1,
                  'optimize': 2,
                  'compressed': 1,
                  'excludes' : ['_ssl', '_hashlib', 'doctest',
                  'pdb', 'unittest', 'difflib', 'pyreadline',
                  'logging', 'email', 'bz2', 'inspect', 'optparse',
                  'pickle','unicodedata'],
                    #'dll_excludes' : ['msvcr71.dll'],
                  }
                },
)
