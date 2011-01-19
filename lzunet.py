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
    中的userid和password等号后的test分别替换为你上网认证的账号和密码，
    保存，然后再运行上述对应的文件。

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

__version__ = '1.4.0'
__revision__ = "$Revision$"
__date__ = '$Date$'
__author__ = '$Author$'


import os
import sys
import re
import locale
import random
import traceback
try:
    import configparser as cp
    import urllib.request as urlrequest
    import urllib.parse as urlparse
    import http.cookiejar as cookie
    # from urllib.error import URLError, HTTPError
except:
    import ConfigParser as cp
    import urllib2 as urlrequest
    import urllib as urlparse
    import cookielib as cookie
    # from urllib2 import URLError, HTTPError


LZUNET_MSGS = (
   '登录成功\t Login successfully.\n',                       # 0
   '帐号不存在\n',                                           # 1
   '已下线\t\t Logout successfully.\n',                      # 2
   '用户名或密码错误 Username or password error.\n',         # 3
   '在线用户超出允许的范围：帐号已在别处登录，\
   如果确认不是自己登录的，可以联系网络中心踢对方下线。\n',  # 4
   '帐号欠费，测试期间可携带校园卡来网络中心办理。\n',       # 5
   '服务不可用，请稍后再试\n',                               # 6
   '流量用完:(，可以在校内的网上转转，等下个月即可恢复\n',   # 7
   '操作完成\t OK.\n',                                       # 8
   '操作过快，服务器还没反应过来呢，请等会再试\n',           # 9
   '\n请输入您的上网账号和密码\n',                           # 10
   '账号：',                                                 # 11
   '密码：',                                                 # 12
   '本机IP:\t\t ',                                           # 13
   '您可用流量为\t %.3f M\n',                                # 14
   '网络连接错误（网线没接好或网络连接受限）\n',             # 15
   '本帐号已使用时间 : %d天 %d小时 %d分钟\n',                # 16
   '本帐号已使用流量 : %dT %dG %.3fM Bytes\n',               # 17
   )

LZUNET_FIND_STRS = (
    'M)',                          # 0
    '帐号不存在',                  # 1
    '下线',                        # 2
    '密码错误',                    # 3
    '范围',                        # 4
    '过期',                        # 5
    '不可用',                      # 6
    '限制',                        # 7
    '您已经成功登录',              # 8
    '请您确认要注销',              # 9
    '注销成功',                    # 10
    '帐号或密码不对，请重新输入',  # 11
    '请输入您的帐号和密码',        # 12
    '信息返回',                    # 13
    )

TFMMSG = {0: '',
          2: "该账号正在使用中，请您与网管联系 !!!\n",
          3: "本帐号只能在指定地址使用\n",  # :+pp+xip
          4: "本帐号费用超支\n",
          5: "本帐号暂停使用\n",
          6: "System buffer full\n",
          #7: UT+UF+UM,
          8: "本帐号正在使用,不能修改\n",
          9: "新密码与确认新密码不匹配,不能修改\n",
          10: "密码修改成功\n",
          11: "本帐号只能在指定地址使用\n",  # :+pp+mac
          14: "注销成功 Logout OK\n",
          15: "登录成功 Login OK\n",
          'error0': "本 IP 不允许Web方式登录\n",
          'error1': "本帐号不允许Web方式登录\n",
          'error2': "本帐号不允许修改密码\n",
          'error_userpass': '帐号或密码不对，请重新输入\n',
}

path0 = sys.path[0]
if os.path.isdir(sys.path[0]):
    PROGRAM_PATH = path0
else:
    PROGRAM_PATH = os.path.dirname(path0)
#    PROGRAM_PATH = os.path.join(path0, os.pardir)

CONF = PROGRAM_PATH + os.sep + 'lzunet.ini'
config = cp.RawConfigParser()

SYS_ENCODING = locale.getdefaultlocale()[1]
ispy2 = False
if sys.version_info.major is 2:
    ispy2 = True
    input = raw_input
    __doc__ = unicode(__doc__, 'utf-8').encode(SYS_ENCODING)
    LZUNET_MSGS = [unicode(i, 'utf-8').encode(SYS_ENCODING) \
                    for i in LZUNET_MSGS]
    LZUNET_FIND_STRS = [unicode(i, 'utf-8') for i in LZUNET_FIND_STRS]
    for i in TFMMSG:
        TFMMSG[i] = unicode(TFMMSG[i], 'utf-8').encode(SYS_ENCODING)
__doc__ = __doc__ % __version__


def loadconf():
    userpass, usertime = 8, 3146400
    try:
        if config.read(CONF) != []:
            userpass = (config.get('AuthInfo', 'userid'),
                        config.get('AuthInfo', 'password'))
            usertime = config.get('AuthInfo', 'usertime')
        else:
            createconf()
    except:
        createconf()
    return userpass, usertime


def saveconf():
    with open(CONF, 'w') as configfile:
        config.write(configfile)


def createconf():
    config.add_section('AuthInfo')
    config.set('AuthInfo', 'userid', 'test@lzu.cn')
    config.set('AuthInfo', 'password', 'testpassword')
    # config.add_section('AuthInfo')
    config.set('AuthInfo', 'usertime', '3146400')
    saveconf()


def getuserpass():
    sys.stdout.write(LZUNET_MSGS[10])
    userid = input(LZUNET_MSGS[11])
    passwd = input(LZUNET_MSGS[12])
    userpass = (userid, passwd)
    if '' not in userpass:
        config.set('AuthInfo', 'userid', userid)
        config.set('AuthInfo', 'password', passwd)
        saveconf()
    return userpass


def tfm(msg, msga):
    if int(msg) == 1:
        if msga != '':
            try:
                return(TFMMSG[msga])
            except KeyError:
                return(msga + '\n')
        else:
            return(TFMMSG['error_userpass'])
    else:
        return(TFMMSG[int(msg)])


def process_ret(ret):
    msg = re.findall("Msg=([\d.]+);", ret)
    msga = re.findall("msga='(.*)'", ret)
    # print msg,msga,ret
    msg1 = ''
    if msg != [] and msga != []:
        msg1 = tfm(msg[0], msga[0])
        if msg1 == TFMMSG['error_userpass']:
            return msg1
    flow = re.findall("flow='([\d.]+)\s*'", ret)
    time = re.findall("time='([\d.]+)\s*'", ret)
    if flow != [] and time != []:
        time = int(time[0])  # unit is minute
        flow = int(flow[0])  # unit is kbyte
        days = time / 60 / 24
        hours = time / 60 % 24
        minutes = time % 60
        flow_tb = flow / 1073741824
        flow_gb = flow % 1073741824 / 1048576
        flow_mb = flow / 1024 % 1024 + flow % 1024 / 1024.0
        time_flow = LZUNET_MSGS[16] % (days, hours, minutes) \
         + LZUNET_MSGS[17] % (flow_tb, flow_gb, flow_mb)
    else:
        time_flow = ''
    return msg1 + time_flow


def conn_auth(url, body, referer):
    cj = cookie.CookieJar()
    cookie_handler = urlrequest.HTTPCookieProcessor(cj)
    proxy_handler = urlrequest.ProxyHandler(proxies={})
    op = urlrequest.build_opener(cookie_handler, proxy_handler)
    headers = [
        ('User-Agent', 'Mozilla/5.0 (Windows; U; Windows NT 5.1; \
zh-CN; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13'),
        ('Accept', 'text/html,application/xhtml+xml,application/xml;\
q=0.9,*/*;q=0.8'),
        ('Keep-Alive', '115'),
        ('Connection', 'keep-alive'),
        ('Accept-Language', 'zh-cn,zh;q=0.5'),
        ('Accept-Encoding', 'gzip,deflate'),
        ('Accept-Charset', 'GB2312,utf-8;q=0.7,*;q=0.7'),
        ('Referer', referer)
    ]
    if sys.platform != 'win32':
        headers[0] = ('User-Agent', 'Mozilla/5.0 (X11; U; Linux i686;\
 en-US; rv:1.9.2.10) Gecko/20100916 Firefox/3.6.10')
    op.addheaders = headers
    urlrequest.install_opener(op)
    if body:
        req = urlrequest.Request(url, body)
    else:
        req = urlrequest.Request(url)
    ret = ''
    # ret = urlrequest.urlopen(req).read()
    try:
        # pass
        ret = urlrequest.urlopen(req).read()
    except:
        exctype, value = sys.exc_info()[:2]
        exception = traceback.format_exception_only(exctype, value)
        print(exception[0])
        # '10054':'Reset'
        if '10054' in exception[0]:
            sys.stdout.write(LZUNET_MSGS[9])
        # '10060':'Timeout','10065':'Not Connected','11001':'getaddress failed'
        if '10060' in exception[0] or '10065' in exception[0] or \
                '11001' in exception[0]:
            sys.stdout.write(LZUNET_MSGS[15])
        sys.exit(9)
    if os.getenv('LNA_DEBUG'):
        sys.stdout.write(ret.encode(SYS_ENCODING))
    return ret


# Get the IP address of local machine
# code from:
# http://hi.baidu.com/yangyingchao/blog/item/8d26b544f6059f45500ffe78.html

# for Linux
def get_ip_lin(ifname):
    import socket
    import fcntl
    import struct
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15]))[20:24])

#get_ip_lin('lo')
#get_ip_lin('eth0')


# for Windows
def get_ip_win():
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
            if ispy2:
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
        return [x for x in get_ip_win()]
    else:
        return [get_ip_lin('eth0')]


def login(userpass):
    config = cp.ConfigParser()
    config.read(CONF)
    url = config.get('AuthInfo', 'login_url')
    referer = config.get('AuthInfo', 'login_referer')
    body = config.get('AuthInfo',' body1') + config.get('AuthInfo', 'body2',1)
    ret = conn_auth(url, body, referer).decode('gbk')
    if LZUNET_FIND_STRS[8] in ret:
        sys.stdout.write(TFMMSG[15])
        ret = conn_auth(url, None, referer).decode('gbk')
    pr = process_ret(ret)
    sys.stdout.write(pr)  # .encode(SYS_ENCODING)
    if pr == TFMMSG['error_userpass']:
        return 1
    return 0


def logout():
    config = cp.ConfigParser()
    config.read(CONF)
    url = config.get('AuthInfo', 'logout_url')
    referer = config.get('AuthInfo', 'logout_referer')
    body = None
    ret = conn_auth(url, body, referer).decode('gbk')
    pr = process_ret(ret)
    sys.stdout.write(pr)
    if LZUNET_FIND_STRS[10] in pr:
        return 0
    else:
        return 3


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
    while (ret_code is 3) or (ret_code is 1):
        ret_code = login(getuserpass())
    return ret_code


if __name__ == '__main__':
    ip = get_ip()[0]
    if ispy2:
        ip = unicode(ip, 'utf-8').encode(SYS_ENCODING)
    main()
    try:
        # main()
        pass
    except Exception:  # as e:
        # sys.stdout.write(LZUNET_MSGS[9])
       sys.stdout.write(str(e))


#vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
