::2025.04.25

@echo off

::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a


:settings
rem �O��·��
@echo ��ʱ����maaʱ������ֹ�����е�maa���Ͽ�adb����

pushd %~dp0

::�������������ļ��е�ProgramFiles�ļ���,������1��
set "MAA=MAA.exe"

:start
::adb����
start /b "" cmd /c "cd /d %cd%\..\MuMuPlayer\nx_device\12.0\shell && adb disconnect 127.0.0.1:16384&exit"
start /b "" cmd /c "cd /d %cd%\..\MuMuPlayer\nx_main && adb disconnect 127.0.0.1:16384&exit"
start /b "" cmd /c "cd /d %cd%\adb\platform-tools && adb disconnect 127.0.0.1:16384&exit"

::��ֹһЩ����
taskkill /f /t /im adb.exe
taskkill /f /t /im maa*
taskkill /f /t /im mumu*

::ɾ���������õ��ļ�
del /s /q "%cd%\compact_log.txt"
del /s /q "%cd%\MaaResource_update.log"
del /s /q "%cd%\main.zip"

::����MAA
start "" "%MAA%"

:: ��ɺ��˳�
exit