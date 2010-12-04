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
		iup.Message('操作完成 OK', "上线成功 Login successfully.")
    elseif retcode == 6 then
        iup.Message("Error", '服务不可用，请稍后再试')
    elseif retcode == 5 then
        iup.Message("Error", '帐号欠费，测试期间可携带校园卡来网络中心办理。 ')
    elseif retcode == 4 then
        iup.Message("Error", '在线用户超出允许的范围：帐号已在别处登录，如果确认不是自己登录的，\
可以联系网络中心踢对方下线')

    elseif retcode == 2 then
        iup.Message("Error", '用户名或密码错误 Username or Password error')
    elseif retcode == 7 then
        iup.Message("Error", '流量用完，可以在校内的网上转转，等下个月即可恢复。')

	else
		iup.Message("Error", '发生错误，请稍后再试 Error occured. Please try again later.')
	end
end

function check()
    MB,HOUR = checkflow(userid,passwd)
	print(MB,HOUR)
	iup.Message("流量查询","已用流量："..MB.."MB\n".."上网时长："..HOUR.."小时")
end

function check_ip()

	iup.Message("Your IP",ip)
end

function logout()
	url = 'http://1.1.1.1/userout.magi'
	body = 'imageField=logout&userout=logout'
	referer = 'http://1.1.1.1/logout.htm'
	if con_auth(url, body, referer, test_url) == 0 then
		iup.Message('操作完成 OK', "已下线 Logout successfully.")
	else
		iup.Message("Error", '发生错误，请稍后再试 Error occured. Please try again later.')
	end

end

function quit()
	dlg:hide()
end

function about()
	iup.Message("关于","兰大上网认证系统自动登录工具 \nlzunet 1.2\n作者： Kder\n项目主页： http://code.google.com/p/lzunet/ \nLicense : GPLv3")
	size="QUARTERxQUARTER"
end

function usage()
	ml = iup.multiline{readonly = "YES", expand="YES", value=[[
	lzunet - 兰大上网认证系统自动登录工具。

主要功能

    一键登录/退出、流量查询（支持验证码识别）

使用方法

    解压后，修改lzunet.txt，把自己的用户名密码填入。 运行 lzunet.exe或lzunet.wlua 就会出来主界面。

系统要求

TODO

	]], border="NO", wordwrap = "YES" ,scrollbar = "NO"}
	abt_dlg = iup.dialog{ml; title="用法说明", size="280x280"}
	abt_dlg:show()
end


item_about = iup.item {title = "关于(A)", key = "K_A"} --, active = "NO"
item_ip = iup.item {title = "本机IP(I)", key = "K_I"}
item_usage = iup.item {title = "用法(U)", key = "K_U"}
item_exit = iup.item {title = "退出 Ctrl+Q", key = "K_x"}

menu_file = iup.menu {item_exit}
menu_help = iup.menu {item_ip, item_about, item_usage}

submenu_file = iup.submenu {menu_file; title = "文件(F)", key = "K_F"}
submenu_help = iup.submenu {menu_help; title = "帮助(H)", key = "K_H"}

-- Creates main menu with two submenus
menu = iup.menu {submenu_file, submenu_help}


item_exit.action = quit
item_about.action = about
item_usage.action = usage
item_ip.action = check_ip


functions = {login, check, logout, quit}
button_labels = {"登录外网", "查询流量", "退出外网", "退出程序"}
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

