::2025.02.27

@echo off

::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a

:: ��С����ǰ����
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

:settings
rem �O��·��
@echo ��ʱ����maaʱ������ֹ�����е�maa���Ͽ�adb����

pushd %~dp0

::������������λ�õ�ProgramFiles�ļ���,������1��
set MAA=MAA.exe
set Player=..\MuMuPlayer\shell\MuMuPlayer.exe


:start
::��ֹһЩ����
taskkill /f /t /im maa*
taskkill /f /t /im mumu*


::adb����
start /b "" cmd /c "cd /d %~dp0\..\MuMuPlayer\shell && adb disconnect 127.0.0.1:16384&exit"
start /b "" cmd /c "cd /d %~dp0\adb\platform-tools&&adb disconnect 127.0.0.1:16384&exit"

::ɾ��debug�ļ��У������˸��ֽ�ͼ����־�����ͼ������õ��ļ�
rd /s /q "%cd%\debug"
del /s /q "%cd%\compact_log.txt"
del /s /q "%cd%\filelist.txt"
del /s /q "%cd%\MaaResource_update.log"

::����MAA
mshta vbscript:createobject("shell.application").shellexecute("""%MAA%""","::",,"runas",1)(window.close)

::����ģ����
mshta vbscript:createobject("shell.application").shellexecute("""%Player%""","::",,"runas",1)(window.close)

:: �ȴ�ģ�������������ݵ������ܵ����ȴ�ʱ�䣩
timeout /t 3 /nobreak

:: ������ʱVBS�ű�ִ����С������
echo Set WshShell = CreateObject("WScript.Shell") > minimize.vbs
echo WshShell.AppActivate "MuMuPlayer" >> minimize.vbs
echo WshShell.SendKeys "%% " >> minimize.vbs
echo WshShell.SendKeys "n" >> minimize.vbs

:: ִ��VBS�ű���ɾ����ʱ�ļ�
start /wait minimize.vbs
del minimize.vbs
