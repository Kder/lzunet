@echo off
MODE CON: COLS=50 LINES=20
:::����������֤ϵͳ�Զ���¼���ߡ�����ʵ��һ����¼/һ�����ߣ�������������
:::�������ֶ�������������롣
:::by Kder [http://www.kder.info]
:::�÷���
:::    �����ص���ѹ�����е�lzunet.txt�е� test@lzu.cn testpassword �滻Ϊ��������������֤���룬���棬
:::    Ȼ��˫�� ��¼.bat ���ɵ�¼������.bat ���ظ��ģ�Ҫ����ֱ��˫�����С�

::: -- Set the window size --
rem cls
TITLE lzunet-bat ����������֤ϵͳ��¼����
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
    if "����������Ϊ" == "%flow:~0,6%" echo ��¼�ɹ�

    if "�ʺŲ����ڣ�  " equ "%rz%" echo ����lzunet.txt�е�����������Ƿ�������ȷ
	if "%flow%" neq "" echo %flow%
)

rem | find "alert" urlencode -ascii)
echo\
pause
del ck.log temp.html
rem set s=%ss:LANGUAGE=l% 