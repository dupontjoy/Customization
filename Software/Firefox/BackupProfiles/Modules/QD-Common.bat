::2023.08.05

@echo off

Title ������������
color 0a
cls

::�O�ó����ļ��Aλ��
cd /d %~dp0
::������������λ�õ�Software�ļ���,������3��
set SoftDir=..\..\..\Software

::ɾ��mpv����
rd /s /q "%SoftDir%\MPV\portable_config\cache"


::ɾ��N_m3u8DL-RE����ʧ�ܵĻ������־
rd /s /q "%SoftDir%\N_m3u8DL-RE\cache"
rd /s /q "%SoftDir%\N_m3u8DL-RE\Logs"

::��ͨ����
start  "" "%SoftDir%\PixPin\PixPin.exe"
start  "" "%SoftDir%\Ditto\Ditto.exe"
::start  "" "%SoftDir%\ProcessLassoPro\_Start-ProcessLasso.bat"


timeout /t 5 /nobreak

::��������
::Listary5��
start  "" "%SoftDir%\Listary Pro\UserData\Run_listary.bat"

::Listary6��
::start  "" "%SoftDir%\Listary 6\listary.exe"

::����Ա����
mshta vbscript:createobject("shell.application").shellexecute("""%SoftDir%\RimeIME Portable\weasel\WeaselServer.exe""","::",,"runas",1)(window.close)