@echo off
MODE CON: COLS=50 LINES=20
TITLE lzunet-bat 兰大上网认证系统登录程序
for /f "tokens=1,2 delims= " %%i in ('arp.exe -a ^| find "Interface"') do set IP=%%j
echo\
color 79
for /f "tokens=*" %%i in ('curl --silent --data "wlanuserip=%IP%&wlanacname=BAS_138&wlanacIp=202.201.1.138&portalUrl=''&usertime=3146400&imageField=''" --referer http://202.201.1.140/portalAuthAction.do  --user-agent "Mozilla/5.0 (Windows NT 5.1; rv:2.0b8) Gecko/20100101 Firefox/4.0b8"  "http://202.201.1.140/portalDisconnAction.do" ^| findstr /r "alert(.*)"') do set ss=%%i 
for /f "tokens=1,2 delims=(" %%j in ("%ss%") do set str=%%k
set str=%str:);=% 
rem for /f "useback tokens=*" %%a in ('%str%') do set str=%%~a
echo %str:'=%
@rem remove );
echo\
pause