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
--~         try:
            f = http.request(tu)
--~             print(f)
            if string.find(f, '�ٶ�') then
                print('������ Connected')
                return 0
            end
--~         except:
--~             print('��֤��ʱ(��Ӱ��������������������ˢ��ҳ�漴��) Timeout')
--~         return 2
    elseif string.find(ret, 'Password error') then
        print('�û������������ Username or Password error')
        return 1
    elseif string.find(ret, '����') then
        print('�������꣬������У�ڵ�����תת�����¸��¼��ɻָ���')
    elseif string.find(ret, 'logout.htm') then
        print('��¼�ɹ� Login successfully.')
    elseif string.find(ret, 'Logout OK') then
        print('������ Logout successfully.')
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
    print('������� OK')
end
--~ try:
--~     if con_auth(url, body, referer, test_url) == 0:
--~         print('Your IP: ' + str(get_ip()))
--~         print(u'������� OK')
--~ except Exception as e:
--~     print(e)
--~     print(u'�����������Ժ����� Error occured. Please try again later.')

--~ $Id$
