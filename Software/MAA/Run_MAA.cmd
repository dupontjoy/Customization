::2025.04.25

@echo off

::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a

:: ��С����ǰ����
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

:settings
rem �O��·��
@echo ��ʱ����maaʱ������ֹ�����е�maa���Ͽ�adb����

pushd %~dp0

::�������������ļ��е�ProgramFiles�ļ���,������1��
set "MAA=MAA.exe"
set Player="..\MuMuPlayer\nx_device\12.0\shell\MuMuNxDevice.exe"


:start

::adb����
start /b "" cmd /c "cd /d %cd%\..\MuMuPlayer\nx_device\12.0\shell && adb disconnect 127.0.0.1:16384&exit"
start /b "" cmd /c "cd /d %cd%\..\MuMuPlayer\nx_main && adb disconnect 127.0.0.1:16384&exit"
start /b "" cmd /c "cd /d %cd%\adb\platform-tools && adb disconnect 127.0.0.1:16384&exit"

::��ֹһЩ����
taskkill /f /t /im maa*
taskkill /f /t /im mumu*

::ɾ��debug�ļ��У������˸��ֽ�ͼ����־�����ͼ������õ��ļ�
rd /s /q "%cd%\debug"
del /s /q "%cd%\compact_log.txt"
del /s /q "%cd%\filelist.txt"
del /s /q "%cd%\removelist.txt"
del /s /q "%cd%\MaaResource_update.log"
del /s /q "%cd%\main.zip"

::����MAA
start "" "%MAA%"

::����ģ����
start "" "%Player%"

:: �ȴ�ģ�������������ݵ������ܵ����ȴ�ʱ�䣩
timeout /t 5 /nobreak

:: ������ʱVBS�ű�ִ����С������
echo Set WshShell = CreateObject("WScript.Shell") > minimize.vbs
echo WshShell.AppActivate "MuMu" >> minimize.vbs
echo WshShell.SendKeys "%% " >> minimize.vbs
echo WshShell.SendKeys "n" >> minimize.vbs

:: ִ��VBS�ű���ɾ����ʱ�ļ�
start /wait minimize.vbs
del minimize.vbs

:: ��ɺ��˳�
exit