::2020.08.20

@echo off

::�Զ��Թ���Ա�������bat�ļ�
::cd /d %~dp0
::%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

::���ݲ��ֿ�ʼ
Title Win_WiFi �����̎�����ϰ� by Cing
::�����С��ColsΪ��LinesΪ��
COLOR 0a
MODE con: COLS=77 LINES=20
cd /d %~dp0
::�O��ģ�K·��
::����ǰĿ¼���浽����b��,�Ⱥ�ǰ��Ҫ�пո�
set b=%cd%

:menu
cls
ECHO.
ECHO  Windows WiFi                     
ECHO.
ECHO  1. Build_WiFi
ECHO. *****************************
ECHO  2. Open_WiFi
ECHO. *****************************
ECHO  3. Restart_WiFi���Զ�������
ECHO. *****************************
ECHO  4. Close_WiFi
ECHO. *****************************
ECHO  5. DHCP
ECHO.
set /p a=�����������Ų��س���1��2����
cls

if %a%==1 goto Build_WiFi
if %a%==2 goto Open_WiFi
if %a%==3 goto Restart_WiFi
if %a%==4 goto Close_WiFi
if %a%==5 goto DHCP

:Build_WiFi
cls
@echo off
CALL "%b%\Modules\Build_WiFi.cmd"
@echo.
Goto menu

:Open_WiFi
cls
@echo off
CALL "%b%\Modules\Open_WiFi.cmd"
@echo.
Goto menu

:Restart_WiFi
cls
@echo off
CALL "%b%\Modules\Restart_WiFi.cmd"
@echo.
Goto menu

:Close_WiFi
cls
@echo off
CALL "%b%\Modules\Close_WiFi.cmd"
@echo.
Goto menu

:DHCP
cls
@echo off
CALL "%b%\Modules\DHCP.cmd"
@echo.
Goto menu