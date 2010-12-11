-- coding=utf-8 --

require( 'iuplua' )
--~ require('lzunet')
--~ if os.getenv('OS') == 'Windows_NT' then
--~     require('lzunet_gbk')
--~ else
    require('lzunet')
--~ end
--~ print(getLocalIP())

f = io.open('lzunet.txt','r')
s = f:read()
--~     print(type(s))
userpass = string.split(s,' ',1)
userid,passwd = userpass[1],userpass[2]

--~ code from http://lua-users.org/wiki/SplitJoin


function login()
    url = 'http://1.1.1.1/passwd.magi'
    body = 'userid='..userid..'&passwd='..passwd..'&serivce=internet&chap=0&random=internet'
    referer = 'http://1.1.1.1/'
    retcode, msg = con_auth(url, body, referer, test_url)
    if retcode == 0 then
        if msg ~= nil then
            iup.Message(msgs.MSG_OK, msgs.MSG_LOGIN..'\n'..msg)
        else
            iup.Message(msgs.MSG_OK, msgs.MSG_LOGIN)
        end
    else
        iup.Message('Error', msg)
    end
end

function check()
    MB,HOUR = checkflow(userid,passwd)
    print(MB,HOUR)
--~     if string.find(MB, msgs.ERR_CODE) then
    if HOUR == msgs.ERR_CODE then
        iup.Message('Error', msgs.ERR)
    elseif MB == 1 then
        iup.Message('Error', HOUR)
    elseif HOUR ~= nil then
        iup.Message(msgs.TITLE_FLOW,string.format(msgs.MSG_FLOW, MB, HOUR))
    end
end

function check_ip()

    iup.Message('Your IP',ip)
end

function logout()
    url = 'http://1.1.1.1/userout.magi'
    body = 'imageField=logout&userout=logout'
    referer = 'http://1.1.1.1/logout.htm'
    retcode, msg = con_auth(url, body, referer, test_url)
    if retcode == 0 then
        iup.Message(msgs.MSG_OK, msg)
    else
        iup.Message('Error', msgs.ERR)
    end

end

function quit()
    dlg:hide()
end

function about()
    iup.Message(msgs.TITLE_ABOUT,msgs.MSG_ABOUT)
    size='QUARTERxQUARTER'
end

function usage()
    ml = iup.multiline{readonly = 'YES', expand='YES', value=msgs.USAGE, border='NO', wordwrap = 'YES' ,scrollbar = 'NO'}
    abt_dlg = iup.dialog{ml; title=msgs.TITLE_USAGE, size='280x280'}
    abt_dlg:show()
end


item_about = iup.item {title = msgs.TITLE_ABOUT..'(A)', key = 'K_A'} --, active = 'NO'
item_ip = iup.item {title = msgs.TITLE_IP..'(I)', key = 'K_I'}
item_usage = iup.item {title = msgs.TITLE_USAGE..'(U)', key = 'K_U'}
item_exit = iup.item {title = msgs.TITLE_EXIT..' Ctrl+Q', key = 'K_x'}

menu_file = iup.menu {item_exit}
menu_help = iup.menu {item_ip, item_about, item_usage}

submenu_file = iup.submenu {menu_file; title = msgs.TITLE_FILE..'(F)', key = 'K_F'}
submenu_help = iup.submenu {menu_help; title = msgs.TITLE_HELP..'(H)', key = 'K_H'}

-- Creates main menu with two submenus
menu = iup.menu {submenu_file, submenu_help}


item_exit.action = quit
item_about.action = about
item_usage.action = usage
item_ip.action = check_ip


functions = {login, check, logout, quit}
button_labels = {msgs.TITLE_LOGIN, msgs.TITLE_FLOW, msgs.TITLE_LOGOUT, msgs.TITLE_EXIT}
buttons = {}

for k,v in pairs(button_labels) do
    buttons[k] = iup.button{ title = button_labels[k]}
    buttons[k].action = functions[k]
end

-- press&release, active, ignore , , EIGHTHxEIGHTH

--~ , resize = 'NO', menubox = 'NO', maxbox = 'NO', minbox = 'NO'
dlg = iup.dialog{ menu = menu,
        iup.frame{
        iup.vbox{iup.fill{},
            iup.hbox{ iup.fill{}, buttons[1], iup.fill{}, buttons[2], iup.fill{} ;
                alignment='ACENTER'
            },iup.fill{},
            iup.hbox{ iup.fill{}, buttons[3], iup.fill{}, buttons[4], iup.fill{} ;
                alignment='ACENTER'},iup.fill{},
            };
        alignment = 'ACENTER'},title = 'lzunet 1.2',size = '120x80'
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

