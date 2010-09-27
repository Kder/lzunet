#coding:utf-8
import sys,os
import urllib,urllib2,cookielib

def con_auth(ul, bd, rf, tu):
    cj = cookielib.CookieJar()
    op = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
    if sys.platform == 'win32':
        op.addheaders = [('User-Agent','Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.3 (KHTML, like Gecko) Chrome/6.0.472.63 Safari/534.3'),
                         ('Accept','application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5'),
                         rf]
    else:
        op.addheaders = [('User-Agent','Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.10) Gecko/20100916 Firefox/3.6.10'),
                         ('Accept','text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'), rf]
    urllib2.install_opener(op)
    req = urllib2.Request(ul,urllib.urlencode(bd))
    u = urllib2.urlopen(req)
    ret = u.read().decode('gb2312')
    if os.getenv('LNA_DEBUG'):
        print(ret)
    if u'不可用' in ret:
        print(u'服务不可用，请稍后再试')
        return 6
    elif u'过期' in ret:
        print(u'帐号欠费，测试期间可携带校园卡来网络中心办理。 ')
        return 5
    elif u'范围' in ret:
        print(u'在线用户超出允许的范围：帐号已在别处登录，如果确认不是自己登录的，可以联系网络中心踢对方下线。')
        return 4
    elif 'Timeout' in ret:
        try:
            f = urllib2.urlopen(tu).read(21)
            if not ('PUBLIC' in f):
                print(u'已连接 Connected')
                return 0
        except:
            print(u'验证超时(不影响正常上网，请打开浏览器刷新页面即可) Timeout')
        return 2
    elif 'Password error' in ret:
        print(u'用户名或密码错误 Username or Password error')
        return 1
    elif u'限制' in ret:
        print(u'流量用完，可以在校内的网上转转，等下个月即可恢复。')
    elif 'logout.htm' in ret:
        print(u'登录成功 Login successfully.')
    elif 'index.htm' in ret:
        print(u'已下线 Logout successfully.')
    return 0

if len(sys.argv) == 2: #For logout
    if sys.argv[1] == 'logout':
        url = 'http://1.1.1.1/userout.magi'
        body = (('imageField', 'logout'),('userout','logout'))
        referer = ('Referer', 'http://1.1.1.1/logout.htm')
elif len(sys.argv) == 3: #For login
    url = 'http://1.1.1.1/passwd.magi'
    body = (
    ('userid',sys.argv[1]),
    ('passwd',sys.argv[2]),
    ('serivce','internet'),
    ('chap','0'),
    ('random','internet'),
    )
    referer = ('Referer', 'http://1.1.1.1/')
else:
    print(u'''用法：

    把下载到的压缩包中的“登录.bat”中的“邮箱 密码”替换为你的邮箱和上网认证密码，保存，然后双击即可登录。"下线.bat"不必更改，要下线直接双击就行。 

    Linux用户请svn checkout源代码，同上修改对应的conn.sh即可。 \n''')
    sys.exit(3)

test_url = 'http://www.baidu.com/'
#fenc = sys.getfilesystemencoding()

try:
    if con_auth(url, body, referer, test_url) == 0:
        print(u'操作完成 OK')
except:
    print(u'发生错误，请稍后再试 Error occured. Please try again later.')
#finally:
#    raw_input('请按回车键退出 Press Return to quit...'.decode('utf-8').encode(fenc))
