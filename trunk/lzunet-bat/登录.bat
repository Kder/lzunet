@echo off
color 79
::: -- Set the window size --
mode con cols=20 lines=2
mode con cols=25 lines=4
mode con cols=30 lines=6
mode con cols=35 lines=8
mode con cols=40 lines=10
mode con cols=45 lines=12
mode con cols=50 lines=14
mode con cols=55 lines=16
mode con cols=57 lines=18
mode con cols=59 lines=19
mode con cols=60 lines=20

GOTO EndComment
兰大上网认证系统自动登录工具。可以实现一键登录/一键下线，无需打开浏览器，
无需再手动输入邮箱和密码。
by Kder [http://www.kder.info]
用法：
    把下载到的压缩包中的lzunet.txt中的 test@lzu.cn testpassword 替换为你的邮箱和上网认证密码，保存，
    然后双击 登录.bat 即可登录。下线.bat 不必更改，要下线直接双击就行。
:EndComment
rem cls
TITLE lzunet-bat 兰大上网认证系统登录程序
echo\
for /f "tokens=1,2 delims= " %%i in ('arp.exe -a ^| find "Interface"') do set IP=%%j
cd /d %~dp0
for /f "tokens=1,2* delims= " %%i in (lzunet.txt) do set userid=%%i&&set passwd=%%j
set lzunet_temp=%temp%\lzunet.html
set cookie=%temp%\lzunet.cookie

curl -c %cookie%  --silent "http://202.201.1.140/portalReceiveAction.do?wlanuserip=%IP%&wlanacname=BAS_138" > nul

curl -b %cookie% --silent --data "wlanuserip=%IP%&wlanacname=BAS_138&auth_type=PAP&wlanacIp=202.201.1.138&userid=%userid%&passwd=%passwd%&chal_id=&chal_vector=&seq_id=&req_id=" --referer "http://202.201.1.140/portalReceiveAction.do?wlanuserip=%IP%&wlanacname=BAS_138"  --user-agent "Mozilla/5.0 (Windows NT 5.1; rv:2.0b8) Gecko/20100101 Firefox/4.0b8" "http://202.201.1.140/portalAuthAction.do" -o %lzunet_temp%

for /f "usebackq tokens=*" %%i in (`findstr /r "br>(.*)" %lzunet_temp%`) do set flow=%%i 
for /f "usebackq tokens=*" %%i in (`findstr /r "alert(.*)" %lzunet_temp%`) do set rz=%%i 
for /f "tokens=1,2 delims=(" %%a in ("%flow%") do set flow=%%b
for /f "tokens=1,2 delims=)" %%b in ("%flow%") do set flow=%%b
for /f "tokens=3 delims=(" %%j in ("%rz%") do set rz=%%j
set rz=%rz:);=%
set rz=%rz:'=%
rem echo rz is %rz% and flow is %flow%
if "%rz%" neq "temp" (
	echo\
rem 	echo %rz%>out
rem ) else (
rem     SETLOCAL ENABLEDELAYEDEXPANSION
rem     set s=@@@%flow%

    if "帐号不存在！  " equ "%rz%" echo 请检查lzunet.txt中的邮箱和密码是否设置正确
)
if "%flow%" neq "" (
if "您可用流量为" equ "%flow:~0,6%" (
    echo 登录成功。%flow%。
) else (
    echo %flow%
)
if "您可用流量为" neq "%rz:~0,6%" (
    echo %rz%
)
rem | find "alert" urlencode -ascii)
echo\
pause
rem del %cookie% temp.html
rem set s=%ss:LANGUAGE=l% 