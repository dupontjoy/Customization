::2025.08.18

@echo off
Title ������������
color 0a
cls

::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

::������������λ�õ�Software�ļ���,������3��
cd ..\..\..\Software

:delete
::ɾ��firefox�����ļ��������ɵ�cache2�ļ���
rd /s /q "%cd%\..\Profiles\FxProfiles\cache2"

::ɾ��N_m3u8DL-RE����ʧ�ܵĻ������־
rd /s /q "%cd%\N_m3u8DL-RE\cache"
rd /s /q "%cd%\N_m3u8DL-RE\Logs"

::ɾ��ztasker User�ļ����е������ļ�
rd /s /q "%cd%\zTasker\User\Backup"
rd /s /q "%cd%\zTasker\User\Custom"
rd /s /q "%cd%\zTasker\User\Logs"
rd /s /q "%cd%\zTasker\User\pinyin.db"
rd /s /q "%cd%\zTasker\User\TasksBackup"
rd /s /q "%cd%\zTasker\User\Temp"

::ɾ��FoxmailUpdate�ļ���, �п��ܵ���foxmail�޷�����
rd /s /q "%cd%\..\..\Tencent\Foxmail\FoxmailUpdate"

::����ļ��У�������ɾ���ļ��б���
del /s /q /f "C:\Users\%USERNAME%\Downloads\*"
del /s /q /f "C:\Users\%USERNAME%\AppData\Local\Temp\*"

:run
::��ͨ���ӣ�start ������һ���´��ڲ���������������
start "" "%cd%\RimeIMEPortable\weasel\WeaselServer.exe"
::start  "" "%cd%\ProcessLassoPro\RunProcessLasso.cmd"
start "" "%cd%\..\..\PyBingWallpaper\BingWallpaper.exe"
start  "" "%cd%\TrafficMonitor\TrafficMonitor.exe"
start  "" "%cd%\Ditto\Ditto.exe"
start  "" "%cd%\PixPin\PixPin.exe"
::start  "" "%cd%\Snipaste\Snipaste.exe"

:listary
::Listary5��
::start  "" "%cd%\Listary5\UserData\Runlistary5.cmd"

::Listary6��
::��Ҫ��ȡ����·������
set "listary6_dir=%cd%\Listary6"
start "" /D "%listary6_dir%" "%listary6_dir%\UserProfile\Settings\RunListary6.cmd"

:capslock
::��Ҫ��ȡ����·������
set "capslock_dir=%cd%\Capslock+"
start "" /D "%capslock_dir%" "%capslock_dir%\Capslock+_v3.3.0.exe"

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
timeout /t 8 /nobreak >nul

REM ������ʱVBS�ű�ģ����̲���
echo Set WshShell = CreateObject("WScript.Shell") > click.vbs
echo WshShell.AppActivate "΢��" >> click.vbs
echo WScript.Sleep 500 >> click.vbs
echo WshShell.SendKeys "{ENTER}" >> click.vbs

REM ִ�нű�������
cscript //nologo click.vbs
del click.vbs

