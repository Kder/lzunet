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
����������֤ϵͳ�Զ���¼���ߡ�����ʵ��һ����¼/һ�����ߣ�������������
�������ֶ�������������롣
by Kder [http://www.kder.info]
�÷���
    �����ص���ѹ�����е�lzunet.txt�е� test@lzu.cn testpassword �滻Ϊ��������������֤���룬���棬
    Ȼ��˫�� ��¼.bat ���ɵ�¼������.bat ���ظ��ģ�Ҫ����ֱ��˫�����С�
:EndComment
rem cls
TITLE lzunet-bat ����������֤ϵͳ��¼����
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

    if "�ʺŲ����ڣ�  " equ "%rz%" echo ����lzunet.txt�е�����������Ƿ�������ȷ
)
if "%flow%" neq "" (
if "����������Ϊ" equ "%flow:~0,6%" (
    echo ��¼�ɹ���%flow%��
) else (
    echo %flow%
)
if "����������Ϊ" neq "%rz:~0,6%" (
    echo %rz%
)
rem | find "alert" urlencode -ascii)
echo\
pause
rem del %cookie% temp.html
rem set s=%ss:LANGUAGE=l% 