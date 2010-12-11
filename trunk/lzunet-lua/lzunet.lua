-- coding=utf-8 --
--~ lzunet.lua v1.2
--~ 兰大上网认证系统自动登录工具
--~ by Kder [http://www.kder.info]
--~ license: GPLv3

require 'ex'
require 'socket'
local http = require('socket.http')
local ltn12 = require('ltn12')
--~ local ustr = require('icu.ustring')
require 'ul_str'

msgs = {
['ERR'] = '发生错误，请稍后再试 Error occured. Please try again later.',
['ERR_CODE'] = '验证码错误，请重新提交。',
['ERR_CONF'] = '无法打开配置文件lzunet.txt或者文件格式错误，请确认文件存在，且格式为 邮箱 密码',
['ERR_CONNECTION'] = '请检查网络是否连接正常\n',
['ERR_EXCEEDED'] = '在线用户超出允许的范围：帐号已在别处登录，如果确认不是自己登录的，可以联系网络中心踢对方下线。',
['ERR_EXPIRED'] = '帐号欠费，测试期间可携带校园卡来网络中心办理。 ',
['ERR_UNAVAILABLE'] = '服务不可用，请稍后再试',
['ERR_AUTH'] = '请检查lzunet.txt中的邮箱和密码是否正确(格式为"邮箱 密码"，不含引号)',
['ERR_OCR'] = '请检查lzunet.txt中的邮箱和密码是否正确；如果设置正确，请稍候再试一次',
['ERR_FLOW'] = '流量用完，可以在校内的网上转转，等下个月即可恢复。',
['ERR_TESSERACT'] = 'tesseract错误，请确认tesseract是否正确安装',
['ERR_DJPEG'] = 'djpeg错误，请确认libjpeg是否正确安装且djpeg命令可用',
['ERR_IO'] = '文件写入错误，请确认程序所在目录有读写权限',
['MSG_FLOW'] = '您本月已经使用的流量为 %s MB\n您本月已经上网 %s 小时',
['MSG_OK'] = '操作完成 OK',
['MSG_ABOUT'] = '兰大上网认证系统自动登录工具 \nlzunet 1.2\n作者： Kder\n项目主页： http://code.google.com/p/lzunet/ \nLicense : GPLv3',
['MSG_LOGIN'] = '登录成功^_^ Login Successfully',
['MSG_FLOW_AVAILABLE'] = '您本月的可用流量为：%s',
['MSG_CONNECTED'] = '已连接 Connected',
['MSG_LOGOUT'] = '您已经成功退出:-) Logout Successfully',
['FND_UNAVAILABLE'] = '不可用',
['FND_EXPIRED'] = '过期',
['FND_EXCEEDED'] = '范围',
['FND_FLOW'] = '限制',
['TITLE_FILE'] = '文件',
['TITLE_HELP'] = '帮助',
['TITLE_LOGIN'] = '登录外网',
['TITLE_LOGOUT'] = '退出外网',
['TITLE_EXIT'] = '退出程序',
['TITLE_ABOUT'] = '关于',
['TITLE_IP'] = '本机IP',
['TITLE_USAGE'] = '用法',
['TITLE_ERR'] = '错误',
['TITLE_FLOW'] = '流量查询',
['USAGE'] = [[
lzunet - 兰大上网认证系统自动登录工具。

主要功能

    一键登录/退出、流量查询（支持验证码识别）

使用方法

    解压后，修改lzunet.txt，把自己的用户名和密码填入。
    运行 启动.bat(Windows下) 或 lzunet.wlua(linux下) 就会出现主界面。

    ]],
}

--~ option = 'alert("(.-M)");'
--~ option = '%b()'
match_flow_available = '[%d.]- M'
match_flow_used = '>.?[%d.]+&nbsp;.?.?M'
match_time_used = '>[%d.]+&nbsp;.?.?H'
match_err_msg = '<font color=red>%S+'

ISWIN = false
if os.getenv('OS')=='Windows_NT' then
    ISWIN = true
end

function togbk(str)
--~     return ustr.encode(ustr(str),'gbk')
    return string.Str:new(str):enc('gbk')
end

function gprint(str)
    print(togbk(str))
end

--~ if ISWIN then
--~     for k,v in pairs(msgs) do
--~         msgs[k] = string.Str:new(v):enc('gbk')
--~     end
--~ end


--~ code from http://lua-users.org/wiki/SplitJoin
function string:split(sSeparator, nMax, bRegexp)
    assert(sSeparator ~= '')
    assert(nMax == nil or nMax >= 1)

    local aRecord = {}

    if self:len() > 0 then
        local bPlain = not bRegexp
        nMax = nMax or -1

        local nField=1 nStart=1
        local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
        while nFirst and nMax ~= 0 do
            aRecord[nField] = self:sub(nStart, nFirst-1)
            nField = nField+1
            nStart = nLast+1
            nFirst,nLast = self:find(sSeparator, nStart, bPlain)
            nMax = nMax-1
        end
        aRecord[nField] = self:sub(nStart)
    end

    return aRecord
end

function sleep(sec)
    socket.select(nil, nil, sec)
end



function ocr(data)
    --[[input: jpeg image string stream
       output: ocr result string
    ]]
    img_name = 'code.jpg'
    local img_file = io.open(img_name, 'wb')
    img_file:write(data)
    img_file:flush()
    img_file:close()

--~         return 5
    if not ISWIN then
        io.popen('djpeg -bmp code.jpg > code.bmp')
        img_name = 'code.bmp'
--~             return 6
    end
    os.setenv('TESSDATA_PREFIX', './')
    args = 'tesseract.exe '..img_name..' ocr nobatch digits'

--~     proc = io.popen(args)
    if ISWIN then
        require('luacom')
        wsh = luacom.CreateObject('WScript.Shell')
        ret = wsh:Run(args,0,true)
--~         gprint(ret)
--~     repeat
--~         os.sleep(0.1)
--~     until ret.Status ~= 0

--~
--~         pid = os.spawn{'tesseract',img_name,'ocr'}
--~         retcode = pid:wait(pid)
    else
        retcode = os.execute(args)
    end
--~     if retcode ~= 0 then
--~         return 7
--~     end
    local f = io.input('ocr.txt')
    s = f:read()
    f:close()
--~     repeat
--~         sleep(0.5)
--~     until pcall(
--~         function ()
--~             sleep(0.5)
--~             local f = io.input('ocr.txt')
--~             s = f:read()--.strip()
--~             f:close()
--~             return true
--~         end
--~     )
    os.remove('ocr.txt')
    os.remove(img_name)
    return s
end

function verify(userid, passwd, headers)
    --ocr识别验证码并登录认证系统
    response_body = {}
    http.request{
        url = 'http://a.lzu.edu.cn/servlet/AuthenCodeImage',
        headers = headers,
        sink = ltn12.sink.table(response_body)
    }
    imgdata = table.concat(response_body)
    s = ocr(imgdata)
    if type(s) ~= 'string' then return s end

--~     os.exit()

    request_body = 'user_id='..userid..'&passwd='..passwd..'&validateCode='..s

    headers['Content-Length'] = string.len(request_body)
    -- a post request
    http.request{
        url = 'http://a.lzu.edu.cn/selfLogonAction.do',
        method = 'POST',
        headers = headers,
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body)
    }
    ret = table.concat(response_body)
    err_found = string.match(ret, match_err_msg)
    if err_found ~= nil then
        err = string.split(err_found,'>',1)
--~         gprint(err[2])
        return err[2]
    end
end

function checkflow(userid, passwd)
    headers = {
            ['User-Agent'] = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.3 (KHTML, like Gecko) Chrome/6.0.472.63 Safari/534.3',
            ['Accept'] = 'application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
            ['Content-Type'] =  'application/x-www-form-urlencoded',
            ['Referer'] = rf
         }
    http.request{
        url = 'http://a.lzu.edu.cn',
        headers = headers,
    }


    r, c, h = http.request{
        url = 'http://a.lzu.edu.cn/selfLogon.do',
        headers = headers,
    }

    headers['Cookie'] = h['set-cookie']

    res = verify(userid, passwd, headers)
--~     if res == msgs.ERR_CODE then
    if res ~= nil then
        return 1,res
--~         os.sleep(0.6)
--~         verify(userid, passwd, headers)
    end

--~     for i = 1, 5 do
--~         local continue
--~         repeat
--~             res = verify(userid, passwd, headers)

--~             if res == nil then
--~                 break
--~             elseif res == '验证码错误，请重新提交。' then
--~                 sleep(0.6)
--~                 continue = true;break
--~             else
--~                 return res
--~             end

--~             continue = true
--~         until true
--~         if not continue then break end
--~     end

    headers['Content-Length'] = nil
    http.request{
        url = 'http://a.lzu.edu.cn/selfIndexAction.do',
        headers = headers
    }

    response_body = {}

    http.request{
        url = 'http://a.lzu.edu.cn/userQueryAction.do',
        headers = headers,
        sink = ltn12.sink.table(response_body)
    }

    local data = table.concat(response_body)
    if data ~= nil then
        data1 = string.match(data, match_flow_used )
        data2 = string.match(data, match_time_used)

        if data1 ~= nil and data2 ~= nil then
            mb = string.match(data1, '[%d.]+')
            hour = string.match(data2, '[%d.]+')
        end
        if mb ~= nil then
            return mb, hour
        end
    end
end

function con_auth(ul, bd, rf, tu)
    request_body = bd
    response_body = {}
    http.request{
        url = ul,
        method = 'POST',
        headers = {
            ['User-Agent'] = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.3 (KHTML, like Gecko) Chrome/6.0.472.63 Safari/534.3',
            ['Accept'] = 'application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
            ['Content-Length'] = string.len(request_body),
            ['Content-Type'] =  'application/x-www-form-urlencoded',
            ['Referer'] = rf
         },
         source = ltn12.source.string(request_body),
         sink = ltn12.sink.table(response_body)
    }

    ret = table.concat(response_body)

    if ret == '' then
        gprint(msgs.ERR_CONNECTION)
        return 1, msgs.ERR_CONNECTION
    end

    if os.getenv('LNA_DEBUG') then
        gprint(ret)
    end

--~     gprint(ul,bd,res)
    if string.find(ret, msgs.FND_UNAVAILABLE) then
        gprint(msgs.ERR_UNAVAILABLE)
        return 6, msgs.ERR_UNAVAILABLE
    elseif string.find(ret, msgs.FND_EXPIRED) then
        gprint(msgs.ERR_EXPIRED)
        return 5, msgs.ERR_EXPIRED
    elseif string.find(ret, msgs.FND_EXCEEDED) then
        gprint(msgs.ERR_EXCEEDED)
        return 4, msgs.ERR_EXCEEDED
    elseif string.find(ret, 'Timeout') then
        f = http.request(tu)
--~         gprint(f)
        if string.find(f, 'Baid') then
            gprint(msgs.MSG_CONNECTED)
--~         gprint('验证超时(不影响正常上网，请打开浏览器刷新页面即可) Timeout')
            return 0
        end

    elseif string.find(ret, 'Password error') then
        gprint(msgs.ERR_AUTH)
        return 2, msgs.ERR_AUTH
    elseif string.find(ret, msgs.FND_FLOW) then
        gprint(msgs.ERR_FLOW)
        return 7, msgs.ERR_FLOW
    elseif string.find(ret, 'logout.htm') then
        gprint(msgs.MSG_LOGIN)
        flow_available = string.format(msgs.MSG_FLOW_AVAILABLE,string.match(ret, match_flow_available))
        gprint(flow_available)
        return 0, flow_available
    elseif string.find(ret, 'Logout OK') then
        gprint(msgs.MSG_LOGOUT)
        return 0, msgs.MSG_LOGOUT
    else
        gprint(ret)
        return 1
    end
end



function getLocalIP()
    if ISWIN then
        require('luacom')
        computer = '.'
        oWMIService = luacom.GetObject ('winmgmts:{impersonationLevel=Impersonate}!\\\\' ..computer.. '\\root\\cimv2')
        oRefresher = luacom.CreateObject ('WbemScripting.SWbemRefresher')
        refobjProcessor = oRefresher:AddEnum(oWMIService,'Win32_PerfFormattedData_PerfOS_Processor').ObjectSet
        IPConfigSet = oWMIService:ExecQuery('Select IPAddress from Win32_NetworkAdapterConfiguration ')
        oRefresher:Refresh ()

        for index,item in luacomE.pairs (IPConfigSet) do
            if item.IPAddress(index-1) ~= nil then
                ip = item:IPAddress(index-1)
                return ip
            end
        end

    else
--~     the following code(8 lines) is from irserversb project (http://code.google.com/p/irserversb/)
        local ipaddr
        local cmd = io.popen('/sbin/ifconfig eth0')
        for line in cmd:lines() do
                ipaddr = string.match(line, 'inet addr:([%d%.]+)')
                if ipaddr ~= nil then break end
        end
        cmd:close()
        return ipaddr or '?.?.?.?'
    end

end

ip = getLocalIP()
test_url = 'http://www.baidu.com/'

function main()
    gprint('Your IP: '..ip)

    --~ logout
    if #arg == 1 then
        if arg[1] == 'logout' then
            url = 'http://1.1.1.1/userout.magi'
            body = 'imageField=logout&userout=logout'
            referer = 'http://1.1.1.1/logout.htm'
        end
    --~ login
    elseif #arg == 2 then
        url = 'http://1.1.1.1/passwd.magi'
        body = 'userid='..arg[1]..'&passwd='..arg[2]..'&serivce=internet&chap=0&random=internet'
        referer = 'http://1.1.1.1/'
    else
        gprint([[usage:
        logout:
            lzunet logout
        login:
            lzunet mail password
        ]])
    --~     os.exit(3)
    end

    if con_auth(url, body, referer, test_url) == 0 then
        gprint(msgs.MSG_OK)
    else
        gprint(msgs.ERR)
    end
end


if (#arg == 1 or #arg == 2) then
    main()
end


--~ $Id$
