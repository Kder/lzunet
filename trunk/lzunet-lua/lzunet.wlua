-- coding=utf-8 --

require('lzunet')
VCL = require'vcl'



f = io.open('lzunet.txt','r')
s = f:read()

userpass = string.split(s,' ',1)
userid,passwd = userpass[1],userpass[2]


function login()
    url = 'http://1.1.1.1/passwd.magi'
    body = 'userid='..userid..'&passwd='..passwd..'&serivce=internet&chap=0&random=internet'
    referer = 'http://1.1.1.1/'
    retcode, msg = con_auth(url, body, referer, test_url)
    if retcode == 0 then
        if msg ~= nil then
            VCL.MessageDlg(msgs.MSG_LOGIN..'\n'..msg,'mtInformation', {'mbOK'})
        else
            VCL.MessageDlg(msgs.MSG_LOGIN,'mtInformation', {'mbOK'})
        end
    else
        VCL.MessageDlg(msg,'mtError', {'mbOK'})
    end
end

function check()
    MB,HOUR = checkflow(userid,passwd)
    print(MB,HOUR)
--~     if string.find(MB, msgs.ERR_CODE) then
    if HOUR == togbk(msgs.ERR_CODE) then
        VCL.MessageDlg(msgs.ERR,'mtError', {'mbOK'})
    elseif MB == 1 then
        s = string.Str:new(HOUR, {'gbk'}):enc('utf8')
        VCL.MessageDlg(s,'mtError', {'mbOK'})
    elseif HOUR ~= nil then
        VCL.MessageDlg(string.format(msgs.MSG_FLOW, MB, HOUR),'mtInformation', {'mbOK'})
    end
end

function check_ip()

    VCL.MessageDlg(ip,'mtInformation', {'mbOK'})
end

function logout()
    url = 'http://1.1.1.1/userout.magi'
    body = 'imageField=logout&userout=logout'
    referer = 'http://1.1.1.1/logout.htm'
    retcode, msg = con_auth(url, body, referer, test_url)
    if retcode == 0 then
        VCL.MessageDlg(msg,'mtInformation', {'mbOK'})
    else
        VCL.MessageDlg(msgs.ERR,'mtError', {'mbOK'})
    end

end

function quit()
--~     mainForm:Free()
    mainForm:Close()
end

function about()
    VCL.MessageDlg(msgs.MSG_ABOUT,'mtInformation', {'mbOK'})
end

function usage()
    VCL.MessageDlg(msgs.USAGE,'mtInformation', {'mbOK'})
--~     msgs.TITLE_USAGE
end



functions = {'login', 'check', 'logout', 'quit'}
button_labels = {msgs.TITLE_LOGIN, msgs.TITLE_FLOW, msgs.TITLE_LOGOUT, msgs.TITLE_EXIT}
buttons = {}


mainForm = VCL.Form{name="mainForm", caption='lzunet v1.3',BorderIcons="biSystemMenu"}
    VCL.Button(mainForm)._ = { name='btn1',left=10, width=60, top=3, caption = button_labels[1], onclick = functions[1]}
    VCL.Button(mainForm)._ = { name='btn2',left=80, width=60, top=3, caption = button_labels[2], onclick = functions[2]}
    VCL.Button(mainForm)._ = { name='btn3',left=10, width=60, top=30, caption = button_labels[3], onclick = functions[3]}
    VCL.Button(mainForm)._ = { name='btn4',left=80, width=60, top=30, caption = button_labels[4], onclick = functions[4]}

--~ for k,v in pairs(button_labels) do
--~     VCL.Button(mainForm, { name=functions[k], caption = button_labels[k], onclick = functions[k]})
--~ end
mainForm._= { position="podesktopcenter", height=80, width=150,}
--~ mainForm.onclick = "onFormClick"

mainMenu = VCL.MainMenu(mainForm,"mainMenu")
mainMenu:LoadFromTable({
    {name="mmfile", caption=msgs.TITLE_FILE..'(&F)',
        submenu={
            {caption=msgs.TITLE_IP..'(&I)' , onclick='check_ip'},
            {caption="-",},
            {caption=msgs.TITLE_EXIT, onclick="quit", shortcut="Alt+F4"},
        }
    },
    {name="mmhelp", caption=msgs.TITLE_HELP..'(&H)', --RightJustify=true,
        submenu = {
            {caption=msgs.TITLE_USAGE..'(&U)', onclick='usage', shortcut="F1"},
            {caption="-",},
            {caption=msgs.TITLE_ABOUT ..'(&A)', onclick='about'},
        }
    }
})

mainForm.onclosequery = "onCloseQueryEventHandler"

function onCloseQueryEventHandler(Sender)
    return true -- the form can be closed
end

function onFormClick(sender)

    VCL.ShowMessage(sender.name, sender.width)

end

mainForm:ShowModal()
mainForm:Free()
