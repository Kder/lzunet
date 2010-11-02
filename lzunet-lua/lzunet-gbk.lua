--~ socket = require("socket")
http = require("socket.http")
--~ urllib = require("socket.url")


function con_auth(ul, bd, rf, tu)
    request_body = bd
    response_body = {}
    http.request{
        url = ul,
        method = "POST",
        headers = {
            ['User-Agent'] = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.3 (KHTML, like Gecko) Chrome/6.0.472.63 Safari/534.3',
            ['Accept'] = 'application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
            ["Content-Length"] = string.len(request_body),
            ["Content-Type"] =  "application/x-www-form-urlencoded",
            ['Referer'] = rf
         },
         source = ltn12.source.string(request_body),
         sink = ltn12.sink.table(response_body)
    }

--~     bd = urllib.escape(bd)
--~     res = {}
--~     res = http.request(ul, bd)
--~     ret = table.concat(res,'\n')
    ret = table.concat(response_body)

    if os.getenv('LNA_DEBUG') then
        print(ret)
    end

--~     print(ul,bd,res)
    if string.find(ret, '不可用') then
        print('服务不可用，请稍后再试')
        return 6
    elseif string.find(ret, '过期') then
        print('帐号欠费，测试期间可携带校园卡来网络中心办理。 ')
        return 5
    elseif string.find(ret, '范围') then
        print('在线用户超出允许的范围：帐号已在别处登录，如果确认不是自己登录的，\
可以联系网络中心踢对方下线。')
        return 4
    elseif string.find(ret, 'Timeout') then
--~         try:
            f = http.request(tu)
--~             print(f)
            if string.find(f, '百度') then
                print('已连接 Connected')
                return 0
            end
--~         except:
--~             print('验证超时(不影响正常上网，请打开浏览器刷新页面即可) Timeout')
--~         return 2
    elseif string.find(ret, 'Password error') then
        print('用户名或密码错误 Username or Password error')
        return 1
    elseif string.find(ret, '限制') then
        print('流量用完，可以在校内的网上转转，等下个月即可恢复。')
    elseif string.find(ret, 'logout.htm') then
        print('登录成功 Login successfully.')
    elseif string.find(ret, 'Logout OK') then
        print('已下线 Logout successfully.')
    else
        print(ret)
    end
    return 0
end

--~ #logout
if #arg == 1 then
    if arg[1] == 'logout' then
        url = 'http://1.1.1.1/userout.magi'
        body = 'imageField=logout&userout=logout'
        referer = 'http://1.1.1.1/logout.htm'
    end
--~ #login
elseif #arg == 2 then
    url = 'http://1.1.1.1/passwd.magi'
    body = 'userid='..arg[1]..'&passwd='..arg[2]..'&serivce=internet&chap=0&random=internet'
    referer = 'http://1.1.1.1/'
else
    print([[usage:
    logout:
        lzunet logout
    login:
        lzunet mail password
    ]])
    os.exit(3)
end

test_url = 'http://www.baidu.com/'
--~ #fenc = sys.getfilesystemencoding()
if con_auth(url, body, referer, test_url) == 0 then
    print('操作完成 OK')
end
--~ try:
--~     if con_auth(url, body, referer, test_url) == 0:
--~         print('Your IP: ' + str(get_ip()))
--~         print(u'操作完成 OK')
--~ except Exception as e:
--~     print(e)
--~     print(u'发生错误，请稍后再试 Error occured. Please try again later.')

--~ $Id$
