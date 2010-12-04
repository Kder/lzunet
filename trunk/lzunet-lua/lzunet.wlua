require( "iuplua" )
--~ require("lzunet")
if os.getenv("OS") == 'Windows_NT' then
    require("lzunet_gbk")
else
    require("lzunet")
end

--~ print(getLocalIP())

f = io.open("lzunet.txt","r")
s = f:read()
--~ 	print(type(s))
userpass = string.split(s," ",1)
userid,passwd = userpass[1],userpass[2]

--~ code from http://lua-users.org/wiki/SplitJoin


function login()
    url = 'http://1.1.1.1/passwd.magi'
    body = 'userid='..userid..'&passwd='..passwd..'&serivce=internet&chap=0&random=internet'
    referer = 'http://1.1.1.1/'
	retcode = con_auth(url, body, referer, test_url)
	if retcode == 0 then
		iup.Message('������� OK', "���߳ɹ� Login successfully.")
    elseif retcode == 6 then
        iup.Message("Error", '���񲻿��ã����Ժ�����')
    elseif retcode == 5 then
        iup.Message("Error", '�ʺ�Ƿ�ѣ������ڼ��Я��У԰�����������İ��� ')
    elseif retcode == 4 then
        iup.Message("Error", '�����û���������ķ�Χ���ʺ����ڱ𴦵�¼�����ȷ�ϲ����Լ���¼�ģ�\
������ϵ���������߶Է�����')

    elseif retcode == 2 then
        iup.Message("Error", '�û������������ Username or Password error')
    elseif retcode == 7 then
        iup.Message("Error", '�������꣬������У�ڵ�����תת�����¸��¼��ɻָ���')

	else
		iup.Message("Error", '�����������Ժ����� Error occured. Please try again later.')
	end
end

function check()
    MB,HOUR = checkflow(userid,passwd)
	print(MB,HOUR)
	iup.Message("������ѯ","����������"..MB.."MB\n".."����ʱ����"..HOUR.."Сʱ")
end

function check_ip()

	iup.Message("Your IP",ip)
end

function logout()
	url = 'http://1.1.1.1/userout.magi'
	body = 'imageField=logout&userout=logout'
	referer = 'http://1.1.1.1/logout.htm'
	if con_auth(url, body, referer, test_url) == 0 then
		iup.Message('������� OK', "������ Logout successfully.")
	else
		iup.Message("Error", '�����������Ժ����� Error occured. Please try again later.')
	end

end

function quit()
	dlg:hide()
end

function about()
	iup.Message("����","����������֤ϵͳ�Զ���¼���� \nlzunet 1.2\n���ߣ� Kder\n��Ŀ��ҳ�� http://code.google.com/p/lzunet/ \nLicense : GPLv3")
	size="QUARTERxQUARTER"
end

function usage()
	ml = iup.multiline{readonly = "YES", expand="YES", value=[[
	lzunet - ����������֤ϵͳ�Զ���¼���ߡ�

��Ҫ����

    һ����¼/�˳���������ѯ��֧����֤��ʶ��

ʹ�÷���

    ��ѹ���޸�lzunet.txt�����Լ����û����������롣 ���� lzunet.exe��lzunet.wlua �ͻ���������档

ϵͳҪ��

TODO

	]], border="NO", wordwrap = "YES" ,scrollbar = "NO"}
	abt_dlg = iup.dialog{ml; title="�÷�˵��", size="280x280"}
	abt_dlg:show()
end


item_about = iup.item {title = "����(A)", key = "K_A"} --, active = "NO"
item_ip = iup.item {title = "����IP(I)", key = "K_I"}
item_usage = iup.item {title = "�÷�(U)", key = "K_U"}
item_exit = iup.item {title = "�˳� Ctrl+Q", key = "K_x"}

menu_file = iup.menu {item_exit}
menu_help = iup.menu {item_ip, item_about, item_usage}

submenu_file = iup.submenu {menu_file; title = "�ļ�(F)", key = "K_F"}
submenu_help = iup.submenu {menu_help; title = "����(H)", key = "K_H"}

-- Creates main menu with two submenus
menu = iup.menu {submenu_file, submenu_help}


item_exit.action = quit
item_about.action = about
item_usage.action = usage
item_ip.action = check_ip


functions = {login, check, logout, quit}
button_labels = {"��¼����", "��ѯ����", "�˳�����", "�˳�����"}
buttons = {}

for k,v in pairs(button_labels) do
	buttons[k] = iup.button{ title = button_labels[k]}
	buttons[k].action = functions[k]
end

-- press&release, active, ignore , , EIGHTHxEIGHTH

--~ , resize = "NO", menubox = "NO", maxbox = "NO", minbox = "NO"
dlg = iup.dialog{ menu = menu,
		iup.frame{
		iup.vbox{iup.fill{},
			iup.hbox{ iup.fill{}, buttons[1], iup.fill{}, buttons[2], iup.fill{} ;
				alignment="ACENTER"
			},iup.fill{},
			iup.hbox{ iup.fill{}, buttons[3], iup.fill{}, buttons[4], iup.fill{} ;
				alignment="ACENTER"},iup.fill{},
			};
		alignment = "ACENTER"},title = "lzunet 1.2",size = "120x80"
	}


function dlg:k_any(c)
  if c == iup.K_cQ then
    return iup.CLOSE
  end
  return iup.DEFAULT
end


--~ iup.SetFocus(text)
dlg:showxy(iup.CENTER, iup.CENTER)

if (not iup.MainLoopLevel or iup.MainLoopLevel()==0) then
  iup.MainLoop()
end

