REBOL [title: "Raw HTTP POST"]

; 'split' is from http://snippets.dzone.com/posts/show/1108
split: func [string delim /local result data] [
        result: copy []
        parse/all string [
            ; The ANY bit ensures we don't insert NONE values.
            any [copy data to delim (insert tail result any [data copy ""]) delim]
            copy data to end (insert tail result any [data copy ""])
        ]
        result
    ]

logout: func ["for logout"]
[url: http://1.1.1.1/userout.magi
act: to-url "logout"
data: rejoin [{imageField=} act {&userout=} act]

result: read/custom url reduce ['post data]
if find result "Logout OK" [alert "Logout OK"]
]

login: func ["for login"]
[
userpass: split read %lzunet.txt "^/"
userid: first userpass
passwd: second userpass
qr: rejoin [{userid=} userid {&passwd=} passwd {&serivce=internet&chap=0&random=internet}]
login_request: rejoin [{POST /passwd.magi HTTP/1.1
Host: 1.1.1.1:80
User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.3 (KHTML, like Gecko) Chrome/6.0.472.63 Safari/534.3
Accept: application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
Referer: http://1.1.1.1/
Content-Length: } length? qr {
Content-Type: application/x-www-form-urlencoded
} "^/" qr]


port: open tcp://1.1.1.1:80
insert port login_request
result: copy port
close port
page: find result "^/^/"

parse page [thru {("} copy alert_msg to {")}]
parse page [thru {"(} copy flow_aval to {)"}]
if not find alert_msg {(} [print alert_msg]
error? try [print flow_aval]
ask "^/请按Enter键退出……"
;input
]

ans: request ["Select an action:" "Login" "Logout" "Cancel"] 
either ans
[login] 
[either ans = none [quit] [logout]]

comment [	
if find page "可用流量" [print ["登录成功 Login successfully."]]
halt
wait 2
print page
{POST /passwd.magi HTTP/1.1
Host: 1.1.1.1:80
User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.3 (KHTML, like Gecko) Chrome/6.0.472.63 Safari/534.3
Accept: application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
Content-Length: 36
Content-Type: application/x-www-form-urlencoded

userid=liulf06@lzu.cn&passwd=Wlrz 10
}

]