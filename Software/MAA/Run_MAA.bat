::2024.08.04

@echo off

::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a

:update_MaaResource


:settings
rem �O��·��
@echo ��ʱ����maaʱ������ֹ�����е�maa���Ͽ�adb����

pushd %~dp0

::������������λ�õ�ProgramFiles�ļ���,������1��
set MAA=MAA.exe
set Player=..\MuMuPlayer\shell\MuMuPlayer.exe
set nircmd=..\CingFox\Software\nircmd\nircmd.exe


:start
::��ֹһЩ����
taskkill /f /t /im maa*
taskkill /f /t /im mumu*


::adb����
start cmd /k "cd/d %~dp0\..\MuMuPlayer\shell&&adb disconnect 127.0.0.1:16384&exit"
start cmd /k "cd/d %~dp0\adb\platform-tools&&adb disconnect 127.0.0.1:16384&exit"

::ɾ��debug�ļ��У������˸��ֽ�ͼ����־
rd /s /q "%cd%\debug"

::�ȴ�һ��ʱ��
timeout /t 3 /nobreak

::����MAA
mshta vbscript:createobject("shell.application").shellexecute("""%MAA%""","::",,"runas",1)(window.close)

::�ȴ�һ��ʱ��
timeout /t 3 /nobreak

::����ģ����
::mshta vbscript:createobject("shell.application").shellexecute("""%Player%""","::",,"runas",1)(window.close)
