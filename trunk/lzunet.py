#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
lzunet %s by Kder < http://www.kder.info >

兰大上网认证系统自动登录工具。可以实现一键登录/一键下线，无需打开浏览器，
无需再手动输入邮箱和密码。

基本用法：
    Windows 和 Linux 用户分别运行下列文件即可(首次运行时会提示输入账号信息)。
        登录：登录.bat 或 login.sh
        下线：下线.bat 或 logout.sh

    如果提示信息无法显示（例如在Linux终端下中文可能会乱码），可手动把lzunet.ini
    中的 test@lzu.cn testpassword 替换为你的邮箱和上网认证密码，保存，然后再运行
    上述对应的文件。

其他用法【不建议】：
    直接使用lzunet.py，命令格式为：
        登录：
            lzunet "邮箱" "密码"
        下线：
            lzunet logout

'''

__author__ = 'Kder'
__copyright__ = 'Copyright 2010 Kder'
__credits__ = ['Kder']
__maintainer__ = "Kder"
__email__ = '[kderlin (#) gmail dot com]'
__url__ = 'http://www.kder.info'
__license__ = 'GNU General Public License v3'
__status__ = 'Release'
__projecturl__ = 'http://code.google.com/p/lzunet/'

__version__ = '1.3.2'
__revision__ = "$Revision$"
__date__ = '$Date$'
__author__ = '$Author$'


import os
import sys
import re
import locale
import random

try:
    import configparser as cp
    import urllib.request as urlrequest
    import urllib.parse as urlparse
    import http.cookiejar as cookie
except:
    import ConfigParser as cp
    import urllib2 as urlrequest
    import urllib as urlparse
    import cookielib as cookie


LZUNET_MSGS = ('登录成功\t Login successfully.\n',
               '帐号不存在\n',
               '已下线\t\t Logout successfully.\n',
               '用户名或密码错误 Username or Password error.\n',
               '在线用户超出允许的范围：帐号已在别处登录，如果确认不是自己登录的，\
               可以联系网络中心踢对方下线。\n',
               '帐号欠费，测试期间可携带校园卡来网络中心办理。\n',
               '服务不可用，请稍后再试\n',
               '流量用完，可以在校内的网上转转，等下个月即可恢复。:(\n',
               '操作完成\t OK.\n',
               '发生错误，请稍后再试\t Error occured. Please try again later.\n',
               '\n请输入您的上网账号和密码\n',
               '账号：',
               '密码：',
               '本机IP:\t\t ',
               '您可用流量为\t %.3f M\n',
               '发生错误，请检查网络连接是否正常（网线没接好或者网络连接受限）\n',
               )
LZUNET_FIND_STRS = ('M)',
                '帐号不存在',
                '下线',
                '密码错误',
                '范围',
                '过期',
                '不可用',
                '限制',
                )


path0 = sys.path[0]
if os.path.isdir(sys.path[0]):
    PROGRAM_PATH = path0
else:
    PROGRAM_PATH = os.path.dirname(path0)
#    PROGRAM_PATH = os.path.join(path0, os.pardir)

CONF = PROGRAM_PATH + os.sep + 'lzunet.ini'
config = cp.RawConfigParser()

SYS_ENCODING = locale.getdefaultlocale()[1]
isPy2 = False
if sys.version_info.major is 2:
    isPy2 = True
    input = raw_input
    __doc__ = unicode(__doc__, 'utf-8').encode(SYS_ENCODING)
    LZUNET_MSGS = [unicode(i, 'utf-8').encode(SYS_ENCODING) for i in LZUNET_MSGS]
    LZUNET_FIND_STRS = [unicode(i, 'utf-8') for i in LZUNET_FIND_STRS]
__doc__ = __doc__ % __version__


def loadconf():
    try:
        if config.read(CONF) != []:
            userpass = (config.get('UserPass', 'UserID'), 
                        config.get('UserPass', 'Password'))
            usertime = config.get('AuthInfo', 'usertime')
        else:
            config.add_section('UserPass')
            config.set('UserPass', 'UserID', 'test@lzu.cn')
            config.set('UserPass', 'Password', 'testpassword')
            config.add_section('AuthInfo')
            config.set('AuthInfo', 'usertime', '3146400')
            saveconf()
#        f = open(CONF)
#        userpass = re.split('\s+', f.readline().strip(), maxsplit=1)
#        f.close()
#    except Exception as e:
    except:
        return 8, 3146400
#        sys.stderr.write(str(e))
    return userpass, usertime

def saveconf():
    with open(CONF,'w') as configfile:
        config.write(configfile)

def getuserpass():
    sys.stdout.write(LZUNET_MSGS[10])
    userid = input(LZUNET_MSGS[11])
    passwd = input(LZUNET_MSGS[12])
    userpass = (userid, passwd)
    if '' not in userpass:
        config.set('UserPass', 'UserID', userid)
        config.set('UserPass', 'Password', passwd)
        saveconf()
#        with open(CONF,'w') as f:
#            f.write('%s %s' % userpass)
    return userpass


def con_auth(ul, bd, rf, tu):
    cj = cookie.CookieJar()
    op = urlrequest.build_opener(urlrequest.HTTPCookieProcessor(cj))
    if sys.platform == 'win32':
        op.addheaders = [('User-Agent', 'Mozilla/5.0 (Windows NT 5.1; rv:2.0b8) \
Gecko/20100101 Firefox/4.0b8'),
        ('Accept', 'application/xml,application/xhtml+xml,\
text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5'),
                         rf]
    else:
        op.addheaders = [('User-Agent', 'Mozilla/5.0 (X11; U; Linux i686;\
 en-US; rv:1.9.2.10) Gecko/20100916 Firefox/3.6.10'),
        ('Accept', 'text/html,application/xhtml+xml,application/xml;\
q=0.9,*/*;q=0.8'), rf]

    try:
        encoded_bd = bytes(urlparse.urlencode(bd), 'gbk')
    except:
        encoded_bd = urlparse.urlencode(bd)
    urlrequest.install_opener(op)
    req = urlrequest.Request(ul, encoded_bd)
    try:
        u = urlrequest.urlopen(req)
    except:
        sys.stdout.write(LZUNET_MSGS[15])
        sys.exit(15)
    ret = u.read().decode('gb2312')
    if os.getenv('LNA_DEBUG'):
        sys.stdout.write(ret)

    if LZUNET_FIND_STRS[0] in ret:
        try:
            usertime = re.findall('''"usertime" value='(\d+)''', ret)[0]
            config.set('AuthInfo', 'usertime', usertime)
            saveconf()
        except:
            pass #return -1
        flow_available = float(re.findall('([\d.]+) M', ret)[0])
        return flow_available
    else:
        for i in range(1, 8):
            if LZUNET_FIND_STRS[i] in ret:
                sys.stdout.write(LZUNET_MSGS[i])
                return i
    


# Get the IP address of local machine
# code from:
# http://hi.baidu.com/yangyingchao/blog/item/8d26b544f6059f45500ffe78.html

# for Linux
def get_ip_address(ifname):
    import socket
    import fcntl
    import struct
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15]))[20:24])

#get_ip_address('lo')
#get_ip_address('eth0')


# for Windows
def getIPAddresses():
    from ctypes import Structure, windll, sizeof
    from ctypes import POINTER, byref
    from ctypes import c_ulong, c_uint, c_ubyte, c_char

    MAX_ADAPTER_DESCRIPTION_LENGTH = 128
    MAX_ADAPTER_NAME_LENGTH = 256
    MAX_ADAPTER_ADDRESS_LENGTH = 8

    class IP_ADDR_STRING(Structure):
        pass
    LP_IP_ADDR_STRING = POINTER(IP_ADDR_STRING)
    IP_ADDR_STRING._fields_ = [
        ("next", LP_IP_ADDR_STRING),
        ("ipAddress", c_char * 16),
        ("ipMask", c_char * 16),
        ("context", c_ulong)]

    class IP_ADAPTER_INFO (Structure):
        pass
    LP_IP_ADAPTER_INFO = POINTER(IP_ADAPTER_INFO)
    IP_ADAPTER_INFO._fields_ = [
        ("next", LP_IP_ADAPTER_INFO),
        ("comboIndex", c_ulong),
        ("adapterName", c_char * (MAX_ADAPTER_NAME_LENGTH + 4)),
        ("description", c_char * (MAX_ADAPTER_DESCRIPTION_LENGTH + 4)),
        ("addressLength", c_uint),
        ("address", c_ubyte * MAX_ADAPTER_ADDRESS_LENGTH),
        ("index", c_ulong),
        ("type", c_uint),
        ("dhcpEnabled", c_uint),
        ("currentIpAddress", LP_IP_ADDR_STRING),
        ("ipAddressList", IP_ADDR_STRING),
        ("gatewayList", IP_ADDR_STRING),
        ("dhcpServer", IP_ADDR_STRING),
        ("haveWins", c_uint),
        ("primaryWinsServer", IP_ADDR_STRING),
        ("secondaryWinsServer", IP_ADDR_STRING),
        ("leaseObtained", c_ulong),
        ("leaseExpires", c_ulong)]
    GetAdaptersInfo = windll.iphlpapi.GetAdaptersInfo
    GetAdaptersInfo.restype = c_ulong
    GetAdaptersInfo.argtypes = [LP_IP_ADAPTER_INFO, POINTER(c_ulong)]
    adapterList = (IP_ADAPTER_INFO * 10)()
    buflen = c_ulong(sizeof(adapterList))
    rc = GetAdaptersInfo(byref(adapterList[0]), byref(buflen))
    if rc == 0:
        for a in adapterList:
            adNode = a.ipAddressList
            if isPy2:
                while True:
                    ipAddr = adNode.ipAddress
                    if ipAddr:
                        yield ipAddr
                    adNode = adNode.next
                    if not adNode:
                        break
            else:
                ipAddr = adNode.ipAddress
                if ipAddr:
                    yield ipAddr


def get_ip():
    if sys.platform == 'win32':
        return [x for x in getIPAddresses()]
    else:
        return [get_ip_address('eth0')]

def login(userpass):
    #login
    url = 'http://202.201.1.140/portalAuthAction.do'
    body = (
    ('userid', userpass[0]),
    ('passwd', userpass[1]),
    ('wlanuserip', ip),
    ('wlanacname', 'BAS_138'),
    ('auth_type', 'PAP'),
    ('wlanacIp', '202.201.1.138'),
    ('chal_id', ''),
    ('chal_vector', ''),
    ('seq_id', ''),
    ('req_id', ''),
    )
    referer = ('Referer', 
    'http://202.201.1.140/portalReceiveAction.do?wlanuserip=%s&wlanacname=BAS_138' % ip)
    ret_code = con_auth(url, body, referer, test_url)
    if isinstance(ret_code, float):
        for i in range(3):
            test_ret = urlrequest.urlopen(test_url).read()
            if 'Baidu' in str(test_ret):
                sys.stdout.write(LZUNET_MSGS[14] % ret_code)
                sys.stdout.write(LZUNET_MSGS[0])
#                sys.stdout.write(LZUNET_MSGS[8])
                break
        else:
            login(userpass)
    return ret_code

def logout():
    usertime = loadconf()[1]
    # x <- (0,180) y <- (0,50)
    x = random.randrange(0,180)
    y = random.randrange(0,50)
    url = 'http://202.201.1.140/portalDisconnAction.do'
    referer = ('Referer',
               'http://202.201.1.140/portalAuthAction.do')
    body = (('wlanuserip', ip),
            ('wlanacname', 'BAS_138'),
            ('wlanacIp','202.201.1.138'),
            ('portalUrl', ''),
            ('usertime', usertime),
            ('imageField.x', x),
            ('imageField.y', y)
            )
    ret_code = con_auth(url, body, referer, test_url)
    return ret_code

def main():
    userpass = None
    if len(sys.argv) == 1:
        userpass = loadconf()[0]
        if userpass is 8 or userpass[0] == 'test@lzu.cn':
            userpass = getuserpass()
    elif len(sys.argv) == 3:
        userpass = (sys.argv[1], sys.argv[2]) 
    elif len(sys.argv) == 2:
        if sys.argv[1] == 'logout':
            ret_code = logout()
        elif sys.argv[1] == 'ip':
            sys.stdout.write(LZUNET_MSGS[13] + ip)
        else:
            sys.stdout.write(__doc__)
            sys.exit(3)
    else:
        sys.stdout.write(__doc__)
        sys.exit(3)

    if userpass:
        ret_code = login(userpass)

    if ret_code is 2:
        sys.stdout.write(LZUNET_MSGS[8])
    else:
        while (ret_code is 3) or (ret_code is 1):
            ret_code = login(getuserpass())
    return ret_code

if __name__ == '__main__':
    ip = get_ip()[0]
    if isPy2:
        ip = unicode(ip, 'utf-8').encode(SYS_ENCODING)
    test_url = 'http://www.baidu.com/'

    try:
        main()
#        sys.exit()
#        pass
    except Exception:# as e:
        sys.stdout.write(LZUNET_MSGS[9])
#        sys.stdout.write(str(e))
    #finally:
    #    input('''请按回车键退出 Press Return to quit...
#'''.decode('utf-8').encode(fenc))


#vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
