::2025.01.22

@echo off

Title ������������
color 0a
cls


::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

::������������λ�õ�Software�ļ���,������3��
set SoftDir=..\..\..\Software

::ɾ��firefox�����ļ��������ɵ�cache�ļ���
rd /s /q "%SoftDir%\..\Profiles\FxProfiles\cache2"

::ɾ��N_m3u8DL-RE����ʧ�ܵĻ������־
rd /s /q "%SoftDir%\N_m3u8DL-RE\cache"
rd /s /q "%SoftDir%\N_m3u8DL-RE\Logs"

::����Ա����
mshta vbscript:createobject("shell.application").shellexecute("""%SoftDir%\RimeIME Portable\weasel\WeaselServer.exe""","::",,"runas",1)(window.close)

::��ͨ����
start "" "%SoftDir%\..\..\PyBingWallpaper\BingWallpaper.exe"
start  "" "%SoftDir%\TrafficMonitor\TrafficMonitor.exe"
start  "" "%SoftDir%\PixPin\PixPin.exe"
::start  "" "%SoftDir%\Snipaste\Snipaste.exe"
start  "" "%SoftDir%\Ditto\Ditto.exe"
::start  "" "%SoftDir%\ProcessLassoPro\_Start-ProcessLasso.bat"
start "" "%SoftDir%\..\..\Tencent\Weixin\Weixin.exe"

::��������
::Listary5��
::start  "" "%SoftDir%\Listary Pro\UserData\Run_listary.bat"

::Listary6��
start  "" "%SoftDir%\Listary6\UserProfile\Settings\Run_Listary6.bat"

::���Foxmail
start "" "%SoftDir%\..\..\Tencent\Foxmail\Foxmail.exe"
REM �ȴ�Foxmail��ȫ�������ɸ�����Ҫ�����ȴ�ʱ��
timeout /t 3 /nobreak >nul
:: ʹ��PowerShell�ű��ر�Foxmail�������ڵ�����ֹ����
powershell -command "& {$app = Get-Process -Name Foxmail; if ($app) { $app.CloseMainWindow() | Out-Null } else { Write-Host 'Foxmail is not running.' }}"
