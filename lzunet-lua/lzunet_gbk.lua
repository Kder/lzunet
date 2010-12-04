-- coding=gbk --
--~ lzunet_gbk.lua
--~ lzunet lua version for gbk environment
--~ by Kder
--~ license: GPLv3

require "socket"
http = require("socket.http")


option1 = '>.?[%d.]+&nbsp;��M'
option2 = '>[%d.]+&nbsp;��H'
option3 = '<font color=red>%S+'


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
    if os.getenv("OS") ~= 'Windows_NT' then
        io.popen('djpeg -bmp code.jpg > code.bmp')
        img_name = 'code.bmp'
--~             return 6
	end

    args = 'tesseract '..img_name..' ocr'
    proc = io.popen(args)
--~     if retcode!=0
--~         return 7
    local s
	
    repeat
        sleep(0.2)
    until pcall(
        function ()
            local f = io.input('ocr.txt')
            s = f:read()--.strip()
            f:close()
            os.remove(img_name)
            os.remove('ocr.txt')
            return true
        end
    )
    
    return s
end

function verify(userid, passwd, headers)
    --ocrʶ����֤�벢��¼��֤ϵͳ

    response_body = {}
    http.request{
        url = "http://a.lzu.edu.cn/servlet/AuthenCodeImage",
        headers = headers,
        sink = ltn12.sink.table(response_body)
    }
    imgdata = table.concat(response_body)
    s = ocr(imgdata)
    if type(s) ~= type("") then return s end

--~ 	os.exit()

    request_body = 'user_id='..userid..'&passwd='..passwd..'&validateCode='..s

    headers["Content-Length"] = string.len(request_body)
    -- a post request
    http.request{
        url = "http://a.lzu.edu.cn/selfLogonAction.do",
        method = "POST",
        headers = headers,
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body)
    }
    ret = table.concat(response_body)
    err_found = string.match(ret, option3)
    if err_found ~= nil then
        err = string.split(err_found,">",1)
        print(err[2])
        return err[2]
    end
end

function checkflow(userid, passwd)
    headers = {
            ['User-Agent'] = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.3 (KHTML, like Gecko) Chrome/6.0.472.63 Safari/534.3',
            ['Accept'] = 'application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5',
            ["Content-Type"] =  "application/x-www-form-urlencoded",
            ['Referer'] = rf
         }
    http.request{
        url = "http://a.lzu.edu.cn",
        headers = headers,
    }


    r, c, h = http.request{
        url = "http://a.lzu.edu.cn/selfLogon.do",
        headers = headers,
    }

    headers["Cookie"] = h["set-cookie"]
--~ 	verify(userid, passwd, headers)

    for i = 1, 5 do
        local continue
		repeat
			res = verify(userid, passwd, headers)

			if res == nil then
				break
			elseif res == '��֤������������ύ��' then
				sleep(0.2)
				continue = true;break
			else
				return res
            end

            continue = true
        until true
        if not continue then break end
	end

    headers["Content-Length"] = nil
    http.request{
        url = "http://a.lzu.edu.cn/selfIndexAction.do",
        headers = headers
    }

    response_body = {}

    http.request{
        url = "http://a.lzu.edu.cn/userQueryAction.do",
        headers = headers,
        sink = ltn12.sink.table(response_body)
    }

    local data = table.concat(response_body)
    if data ~= nil then
        data1 = string.match(data, option1)
        data2 = string.match(data, option2)
        if data1 ~= nil and data2 ~= nil then
            mb = string.match(data1, "[%d.]+")
            hour = string.match(data2, "[%d.]+")
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

    ret = table.concat(response_body)

	if ret == '' then
		print('���������Ƿ���������\n')
		return 1
	end

    if os.getenv('LNA_DEBUG') then
        print(ret)
    end

--~     print(ul,bd,res)
    if string.find(ret, '������') then
        print('���񲻿��ã����Ժ�����')
        return 6
    elseif string.find(ret, '����') then
        print('�ʺ�Ƿ�ѣ������ڼ��Я��У԰�����������İ��� ')
        return 5
    elseif string.find(ret, '��Χ') then
        print('�����û���������ķ�Χ���ʺ����ڱ𴦵�¼�����ȷ�ϲ����Լ���¼�ģ�\
������ϵ���������߶Է����ߡ�')
        return 4
    elseif string.find(ret, 'Timeout') then
        f = http.request(tu)
--~         print(f)
        if string.find(f, 'Baid') then
            print('������ Connected')
--~         print('��֤��ʱ(��Ӱ��������������������ˢ��ҳ�漴��) Timeout')
            return 0
        end

    elseif string.find(ret, 'Password error') then
        print('�û������������ Username or Password error')
        return 2
    elseif string.find(ret, '����') then
        print('�������꣬������У�ڵ�����תת�����¸��¼��ɻָ���')
		return 7
    elseif string.find(ret, 'logout.htm') then
        print('��¼�ɹ� Login successfully.')
    elseif string.find(ret, 'Logout OK') then
        print('������ Logout successfully.')
    else
        print(ret)
        return 1
    end
    return 0
end



function getLocalIP()
    if os.getenv("OS")=='Windows_NT' then
        require('luacom')
        computer = "."
        oWMIService = luacom.GetObject ("winmgmts:{impersonationLevel=Impersonate}!\\\\" ..computer.. "\\root\\cimv2")
        oRefresher = luacom.CreateObject ("WbemScripting.SWbemRefresher")
        refobjProcessor = oRefresher:AddEnum(oWMIService,"Win32_PerfFormattedData_PerfOS_Processor").ObjectSet
        IPConfigSet = oWMIService:ExecQuery("Select IPAddress from Win32_NetworkAdapterConfiguration ")
        oRefresher:Refresh ()

        for index,item in luacomE.pairs (IPConfigSet) do
            if item.IPAddress(index-1) ~= nil then
                ip = item:IPAddress(index-1)
        --~ 		print(ip,#ip)
                return ip
            end
        end

    else
--~ 	the following code(8 lines) is from irserversb project (http://code.google.com/p/irserversb/)
        local ipaddr
        local cmd = io.popen("/sbin/ifconfig eth0")
        for line in cmd:lines() do
                ipaddr = string.match(line, "inet addr:([%d%.]+)")
                if ipaddr ~= nil then break end
        end
        cmd:close()
        return ipaddr or "?.?.?.?"
    end

end

function main()
    local ip = getLocalIP()
	print('Your IP: '..ip)

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
        print([[usage:
        logout:
            lzunet logout
        login:
            lzunet mail password
        ]])
    --~     os.exit(3)
    end

    test_url = 'http://www.baidu.com/'
    if con_auth(url, body, referer, test_url) == 0 then
		print('������� OK')
	else
		print('�����������Ժ����� Error occured. Please try again later.')
	end
end


if (#arg == 1 or #arg == 2) then
    main()
end


--~ $Id$