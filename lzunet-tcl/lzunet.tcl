# lzunet-tcl.tcl
# lzunet tcl version
# by Kder
# license: GPLv3


package require http


proc put {input} {
    puts [encoding convertfrom utf-8 [encoding convertto $input]]
}


proc con_auth { url body refer test_url } {
	::http::config -useragent "Mozilla/5.0 (Windows; U; Windows NT 5.1;\
	 en-GB; rv:1.9.2.12) Gecko/20101026 Firefox/3.6.12" -accept \
	"application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;\
	q=0.8,image/png,*/*;q=0.5"
	set token [::http::geturl $url -query $body -headers {Referer $refer}]
	::http::wait $token
	set ret [::http::data $token ]
	::http::cleanup $token

    set ret [encoding convertfrom gb2312 $ret]

    global env
    set LNA [lindex [array get env LNA_DEBUG] 1]
    if {[lindex $LNA 0] == true} {
        put $ret
	}
    
	if {$ret == ""} {
		put "请检查网络是否连接正常。\n"
		return 1
	} 
	if { [string first 不可用 $ret] != -1 } {
        put "服务不可用，请稍后再试。"
        return 6
    } elseif { [string first 过期 $ret] != -1 } {
        put "帐号欠费，测试期间可携带校园卡来网络中心办理。" 
        return 5
    } elseif { [string first 范围 $ret] != -1 } {
        put "在线用户超出允许的范围：帐号已在别处登录，如果确认不是自己登录的，\
可以联系网络中心踢对方下线。"
        return 4
    } elseif { [string first "Timeout" $ret] != -1 } {
        put 验证超时，不影响正常上网，刷新一下浏览器页面即可。Timeout.
        set token [::http::geturl $test_url]
        ::http::wait $token
        set ret [::http::data $token ]
        ::http::cleanup $token        
        if { [string first "Baidu" $ret] != -1 } {
            put 已连接。Connected.
            return 0
        }
    } elseif { [string first "Password error" $ret] != -1 } {
        put "用户名不存在或密码错。Username or password error"
        return 2
    } elseif { [string first "限制" $ret] != -1 } {
        put "流量用完，可以在校内的网上转转，等下个月即可恢复。"
    } elseif { [string first "logout.htm" $ret] != -1 } {
        put "登录成功。Login successfully."
    } elseif { [string first "Logout OK" $ret] != -1 } {
        put "已下线。Logout successfully."
    } else {
        puts $ret
        return 1
    }
    return 0
}

#~ proc below is from http://wiki.tcl.tk/3015
proc ip:address {} {
        # find out localhost's IP address
        # courtesy David Gravereaux, Heribert Dahms
        set TheServer [socket -server none -myaddr [info hostname] 0]
        set MyIP [lindex [fconfigure $TheServer -sockname] 0]
        close $TheServer
        return $MyIP
}

if { $argc == 1 } {
    set body [::http::formatQuery imageField logout userout logout]
    set url "http://1.1.1.1/userout.magi"
	set refer "http://1.1.1.1/"
} elseif { $argc == 2 } {
    set body [::http::formatQuery userid [lindex $argv 0] passwd [lindex $argv 1]\
     chap 0 serivce internet random internet]
    set url "http://1.1.1.1/passwd.magi"
	set refer "http://1.1.1.1/logout.htm"
} else {
	put "usage:
    logout:
        lzunet logout
    login:
        lzunet mail password
	"
	exit
}

set test_url "http://www.baidu.com/"

if {[con_auth $url $body $refer $test_url] == 0} {
	put "操作完成。OK."
} else {
	put "出错了，请稍后重试。Error occured. Please try again later."
}

puts "Your IP: [ip:address]"
