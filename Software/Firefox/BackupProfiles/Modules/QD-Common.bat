::2025.01.22

@echo off

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

::����Ա����
mshta vbscript:createobject("shell.application").shellexecute("""%cd%\RimeIME Portable\weasel\WeaselServer.exe""","::",,"runas",1)(window.close)

::��ͨ����
start "" "%cd%\..\..\PyBingWallpaper\BingWallpaper.exe"
start  "" "%cd%\TrafficMonitor\TrafficMonitor.exe"
start  "" "%cd%\PixPin\PixPin.exe"
::start  "" "%cd%\Snipaste\Snipaste.exe"
start  "" "%cd%\Ditto\Ditto.exe"
start "" "%cd%\..\..\Tencent\Weixin\Weixin.exe"

::��������
::Listary5��
::start  "" "%cd%\Listary Pro\UserData\Run_listary.bat"

::Listary6��
start  "" "%cd%\Listary6\UserProfile\Settings\Run_Listary6.bat"

::���Foxmail
start "" "%cd%\..\..\Tencent\Foxmail\Foxmail.exe"
REM �ȴ�Foxmail��ȫ�������ɸ�����Ҫ�����ȴ�ʱ��
timeout /t 5 /nobreak >nul
:: ʹ��PowerShell�ű��ر�Foxmail�������ڵ�����ֹ����
powershell -command "& {$app = Get-Process -Name Foxmail; if ($app) { $app.CloseMainWindow() | Out-Null } else { Write-Host 'Foxmail is not running.' }}"

::��ת��Capslock+�ļ���
cd .\Capslock+\
start  "" "%cd%\Capslock+_v3.3.0.exe"