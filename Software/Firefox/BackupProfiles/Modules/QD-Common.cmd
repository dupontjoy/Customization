::2025.03.02

@echo off
setlocal enabledelayedexpansion

Title ������������
color 0a
cls

::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

::������������λ�õ�Software�ļ���,������3��
cd ..\..\..\Software

::ɾ��firefox�����ļ��������ɵ�cache�ļ���
rd /s /q "%cd%\..\Profiles\FxProfiles\cache2"

::ɾ��N_m3u8DL-RE����ʧ�ܵĻ������־
rd /s /q "%cd%\N_m3u8DL-RE\cache"
rd /s /q "%cd%\N_m3u8DL-RE\Logs"

::����û�\�����ļ���
rd /s /q "C:\Users\%USERNAME%\Downloads"

::����Ա����WeaselServer.exe
mshta vbscript:createobject("shell.application").shellexecute("""%cd%\RimeIME Portable\weasel\WeaselServer.exe""","::",,"runas",1)(window.close)


::��ͨ����
start "" "%cd%\..\..\PyBingWallpaper\BingWallpaper.exe"
start  "" "%cd%\TrafficMonitor\TrafficMonitor.exe"
start  "" "%cd%\PixPin\PixPin.exe"
::start  "" "%cd%\Snipaste\Snipaste.exe"
start  "" "%cd%\Ditto\Ditto.exe"


:foxmail
::���Foxmail�󣬹ر�Foxmail�������ڵ�����ֹ����
start "" "%cd%\..\..\Tencent\Foxmail\Foxmail.exe"
REM �ȴ�Foxmail��ȫ�������ɸ�����Ҫ�����ȴ�ʱ��
timeout /t 10 /nobreak >nul
:: ʹ��PowerShell�ű��ر�Foxmail�������ڵ�����ֹ����
powershell -command "& {$app = Get-Process -Name Foxmail; if ($app) { $app.CloseMainWindow() | Out-Null } else { Write-Host 'Foxmail is not running.' }}"

:weixin
::���΢�Ų������¼
start "" "%cd%\..\..\Tencent\Weixin\Weixin.exe"

REM �ȴ�΢�Ž�����أ�ʱ��ɸ���ʵ�����������
timeout /t 5 /nobreak >nul

REM ������ʱVBS�ű�ģ����̲���
echo Set WshShell = CreateObject("WScript.Shell") > click.vbs
echo WshShell.AppActivate "΢��" >> click.vbs
echo WScript.Sleep 300 >> click.vbs
echo WshShell.SendKeys "{ENTER}" >> click.vbs

REM ִ�нű�������
cscript //nologo click.vbs
del click.vbs

:listary
REM �ȵ��΢�ŵ�¼����������
timeout /t 5 /nobreak >nul
::Listary5��
::start  "" "%cd%\Listary Pro\UserData\Run_listary.bat"

::Listary6��
start  "" "%cd%\Listary6\UserProfile\Settings\Run_Listary6.bat"

:capslock
::����ʹ��pushd+cd��ʽ��ȡ������·���ķ�ʽ��ӣ�����·���Ą��������������Ч
::��ת��Capslock+�ļ���
cd .\Capslock+\
start  "" "%cd%\Capslock+_v3.3.0.exe"

