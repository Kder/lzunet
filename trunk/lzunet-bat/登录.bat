@echo off
MODE CON: COLS=50 LINES=20
:::兰大上网认证系统自动登录工具。可以实现一键登录/一键下线，无需打开浏览器，
:::无需再手动输入邮箱和密码。
:::by Kder [http://www.kder.info]
:::用法：
:::    把下载到的压缩包中的lzunet.txt中的 test@lzu.cn testpassword 替换为你的邮箱和上网认证密码，保存，
:::    然后双击 登录.bat 即可登录。下线.bat 不必更改，要下线直接双击就行。

::: -- Set the window size --
rem cls
TITLE lzunet-bat 兰大上网认证系统登录程序
color 79
echo\

cd /d %~dp0
for /f "tokens=1,2* delims= " %%i in (lzunet.txt) do set userid=%%i&&set passwd=%%j

curl -c ck.log  --silent "http://202.201.1.140/portalReceiveAction.do?wlanuserip=219.246.62.167&wlanacname=BAS_138" > nul

curl -b ck.log --silent --data "wlanuserip=219.246.62.167&wlanacname=BAS_138&auth_type=PAP&wlanacIp=202.201.1.138&userid=%userid%&passwd=%passwd%&chal_id=''&chal_vector=''&seq_id=''&req_id=''" --referer "http://202.201.1.140/portalReceiveAction.do?wlanuserip=219.246.62.167&wlanacname=BAS_138"  --user-agent "Mozilla/5.0 (Windows NT 5.1; rv:2.0b8) Gecko/20100101 Firefox/4.0b8" "http://202.201.1.140/portalAuthAction.do" -o temp.html

for /f "usebackq tokens=*" %%i in (`findstr /r "red>(.*)" temp.html`) do set flow=%%i 
for /f "usebackq tokens=*" %%i in (`findstr /r "alert(.*)" temp.html`) do set rz=%%i 
for /f "tokens=1,2 delims=(" %%a in ("%flow%") do set flow=%%b
for /f "tokens=1,2 delims=)" %%b in ("%flow%") do set flow=%%b
for /f "tokens=1,2 delims=(" %%j in ("%rz%") do set rz=%%k
set rz=%rz:);=%
set rz=%rz:'=%
if %rz% neq temp (
	echo\
rem 	echo %rz%>out
rem ) else (
rem     SETLOCAL ENABLEDELAYEDEXPANSION
rem     set s=@@@%flow%
    if "您可用流量为" == "%flow:~0,6%" echo 登录成功

    if "帐号不存在！  " equ "%rz%" echo 请检查lzunet.txt中的邮箱和密码是否设置正确
	if "%flow%" neq "" echo %flow%
)

rem | find "alert" urlencode -ascii)
echo\
pause
del ck.log temp.html
rem set s=%ss:LANGUAGE=l% 