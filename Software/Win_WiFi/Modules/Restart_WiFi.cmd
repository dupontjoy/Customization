::�Զ��Թ���Ա�������bat�ļ�
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

::�����С��ColsΪ��LinesΪ��
COLOR 0a
MODE con: COLS=77 LINES=20

:Restart_WiFi
cls
::�������ں͕r�g
set YY=%date:~0,4%
set MON=%date:~5,2%
set DD=%date:~8,2%
set hh=%time:~0,2%
set mm=%time:~3,2%
set ss=%time:~6,2%
::����ʱ���ʽ
set date=%YY%.%MON%.%DD%-%hh%:%mm%:%ss%

::С�r��С��10��r������
set /a hh=%time:~0,2%*1
if %hh% LSS 10 set hh=0%hh%
::����ʱ���ʽ
set date=%YY%.%MON%.%DD%-%hh%:%mm%:%ss%

::���ʱ��
echo %date% ����WiFi
@echo.
@echo.

::����WiFi
netsh wlan stop hostednetwork
netsh wlan start hostednetwork


@echo.
::120�����Զ�����
@echo off
choice /t 7200 /d y /n >nul

Goto Restart_WiFi