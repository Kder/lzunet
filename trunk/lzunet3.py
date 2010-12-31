#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
lzunet for Python3

兰大上网认证系统自动登录工具。可以实现一键登录/一键下线，无需打开浏览器，
无需再手动输入邮箱和密码。

用法：

    把下载到的压缩包中的lzunet.txt中的 test@lzu.cn testpassword 替换为你的邮箱和上网认证密码，保存，
    然后双击 登录.bat 即可登录。"下线.bat"不必更改，要下线直接双击就行。

    Linux用户请svn checkout源代码，设置好connect.sh中对应的mail和pass，
    运行connect.sh即可登录，logout.sh不要修改，直接运行就可以下线。

    要直接使用lzunet，命令格式为：
        登录：
            lzunet "邮箱" "密码"
        退出：
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

__version__ = '1.1.0'
__revision__ = "$Revision$"
__date__ = '$Date$'
__author__ = '$Author$'


import sys
import os
import urllib
import urllib.request
import urllib.parse
import http.cookiejar
import re


def con_auth(ul, bd, rf, tu):
    cj = http.cookiejar.CookieJar()
    op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    encoded_bd = bytes(urllib.parse.urlencode(bd), 'utf8')
    # print(len(encoded_bd))
    if sys.platform == 'win32':
        op.addheaders = [('User-Agent', 'Mozilla/5.0 (Windows; U; \
Windows NT 5.1; en-US) AppleWebKit/534.3 (KHTML, like Gecko) \
Chrome/6.0.472.63 Safari/534.3'),
        ('Accept', 'application/xml, application/xhtml+xml, \
text/html;q=0.9, text/plain;q=0.8, image/png,*/*;q=0.5'),
        # ('Content-type', 'application/x-www-form-urlencoded'),
        # ('Content-length', len(encoded_bd)),
        rf]
    else:
        op.addheaders = [('User-Agent', 'Mozilla/5.0 (X11; U; Linux i686; \
en-US; rv:1.9.2.10) Gecko/20100916 Firefox/3.6.10'),
                         ('Accept', 'text/html, application/xhtml+xml, \
application/xml;q=0.9,*/*;q=0.8'), 
        # ('Content-type', 'application/x-www-form-urlencoded'),
        # ('Content-length', len(encoded_bd)),
        rf]
    urllib.request.install_opener(op)
    req = urllib.request.Request(ul, encoded_bd)
    # u = urllib.request.urlopen(req)
    u = op.open(req)
    ret = u.read().decode('gb2312')
    if os.getenv('LNA_DEBUG'):
        print(ret)
    if '不可用' in ret:
        print('服务不可用，请稍后再试')
        return 6
    elif '过期' in ret:
        print('帐号欠费，测试期间可携带校园卡来网络中心办理。 ')
        return 5
    elif '范围' in ret:
        print('在线用户超出允许的范围：帐号已在别处登录，如果确认不是自己登录的，\
可以联系网络中心踢对方下线。')
        return 4
    elif 'Timeout' in ret:
        try:
            f = urllib.request.urlopen(tu)
            r = f.read(21)
            if not ('PUBLIC' in f):
                print('已连接 Connected')
                return 0
        except Exception as e:
            print('验证超时(不影响正常上网，请打开浏览器刷新页面即可) Timeout', e)
        return 2
    elif 'Password error' in ret:
        print('用户名或密码错误 Username or Password error')
        return 1
    elif '限制' in ret:
        print('流量用完，可以在校内的网上转转，等下个月即可恢复。')
    elif 'M)' in ret:
        match_flow_available = '[\d.]+ M'
        print('您可用流量为 %s' % re.findall(match_flow_available, ret)[0])
        print('登录成功 Login successfully.')
    elif 'Logout OK' in ret:
        print('已下线 Logout successfully.')
    return 0

#Get the IP address of local machine
#code from:
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
        struct.pack('256s', ifname[:15])
    )[20:24])

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
            ipAddr = adNode.ipAddress
            if ipAddr:
                yield ipAddr

#            while True:
#                ipAddr = adNode.ipAddress
#                if ipAddr:
#                    yield ipAddr
#                adNode = adNode.__next__
#                if not adNode:
#                    break


def get_ip():
    if sys.platform == 'win32':
        return [x for x in getIPAddresses()]
    else:
        return get_ip_address('eth0')


if __name__ == '__main__':
    ip = get_ip()[0]
    #logout
    if len(sys.argv) == 2:
        if sys.argv[1] == 'logout':
            url = 'http://1.1.1.1/userout.magi'
            body = (('imageField', 'logout'),)
            referer = ('Referer', 'http://1.1.1.1/logout.htm')
    #login
    elif len(sys.argv) == 3:
        url = 'http://202.201.1.140/portalAuthAction.do'
        body = (
        ('userid', sys.argv[1]),
        ('passwd', sys.argv[2]),
        ('wlanuserip', ip),
        ('wlanacname', 'BAS_138'),
        ('auth_type', 'PAP'),
        ('wlanacIp', '202.201.1.138'),
        ('chal_id', ''),
        ('chal_vector', ''),
        ('seq_id', ''),
        ('req_id', ''),
        )
        referer = ('Referer', 'http://202.201.1.140/portalReceiveAction.do?wlanuserip=%s&wlanacname=BAS_138' % ip)
    else:
        print(__doc__)
        sys.exit(3)

    test_url = 'http://www.baidu.com/'
    #fenc = sys.getfilesystemencoding()

    try:
        if con_auth(url, body, referer, test_url) == 0:
            print(('Your IP: ' + str(ip,'utf-8')))
            print('操作完成 OK')
    except Exception as e:
        print(e)
        print('发生错误，请稍后再试 Error occured. Please try again later.')
    #finally:
    #    raw_input('''请按回车键退出 Press Return to quit...
#    '''.decode('utf-8').encode(fenc))


#vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
