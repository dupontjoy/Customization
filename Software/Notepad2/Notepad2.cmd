::2016.03.01

@echo off
Title Notepad2ӳ��ٳ���Q�Դ����±�
::�����С��ColsΪ��LinesΪ��
MODE con: COLS=80 LINES=25

set regkey=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe

::�Զ��Թ���Ա�������bat�ļ�
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

:menu
cls
ECHO.
ECHO  1�����±�[δ�ٳ�]���Ƿ����ٳ֣�
ECHO  2�����±�[�ѽٳ�]���Ƿ�ȡ���ٳ֣�
ECHO.
set /p a=�����������Ų��س���1��2����
cls

if %a%==1 goto notepad2
if %a%==2 goto undo

:notepad2
reg add "%regkey%" /v "Debugger" /t REG_SZ /d "%~dp0Notepad2.exe /z" /f
goto exit

:undo
reg delete "%regkey%" /f
goto exit