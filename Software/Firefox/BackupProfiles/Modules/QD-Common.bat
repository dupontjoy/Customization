::2025.01.22

@echo off

Title ������������
color 0a
cls

::�O�ó����ļ��Aλ��
cd /d %~dp0
::������������λ�õ�Software�ļ���,������3��
set SoftDir=..\..\..\Software

::ɾ��firefox�����ļ��������ɵ�cache�ļ���
rd /s /q "%SoftDir%\..\Profiles\FxProfiles\cache2"

::ɾ��N_m3u8DL-RE����ʧ�ܵĻ������־
rd /s /q "%SoftDir%\N_m3u8DL-RE\cache"
rd /s /q "%SoftDir%\N_m3u8DL-RE\Logs"

::��ͨ����
start  "" "%SoftDir%\TrafficMonitor\TrafficMonitor.exe"
start  "" "%SoftDir%\PixPin\PixPin.exe"
::start  "" "%SoftDir%\Snipaste\Snipaste.exe"
start  "" "%SoftDir%\Ditto\Ditto.exe"
::start  "" "%SoftDir%\ProcessLassoPro\_Start-ProcessLasso.bat"

timeout /t 5 /nobreak

::��������
::Listary5��
start  "" "%SoftDir%\Listary Pro\UserData\Run_listary.bat"

::Listary6��
::start  "" "%SoftDir%\Listary 6\listary.exe"

::��steamcommunity_302.exe��ӵ�����ǽ������ӳ���
:: ����Ƿ����ͬ���ķ���ǽ����
netsh advfirewall firewall show rule name=steamcommunity_302.exe >nul 2>&1

if %errorlevel%==0 (
    echo ����ǽ���� 'steamcommunity_302.exe' �Ѿ����ڡ�
) else (
    :: ��������ڣ�������µķ���ǽ����
    netsh advfirewall firewall add rule name="steamcommunity_302.exe" dir=in action=allow program="%SoftDir%\steamcommunity_302\steamcommunity_302.exe" protocol=any
    if %errorlevel%==0 (
        echo �ɹ���ӷ���ǽ���� 'steamcommunity_302.exe'.
    ) else (
        echo ��ӷ���ǽ����ʧ�ܣ�����Ȩ�޻�·���Ƿ���ȷ��
    )
)
timeout /t 5 /nobreak
start  "" "%SoftDir%\steamcommunity_302\steamcommunity_302.exe"

::����Ա����
mshta vbscript:createobject("shell.application").shellexecute("""%SoftDir%\RimeIME Portable\weasel\WeaselServer.exe""","::",,"runas",1)(window.close)

