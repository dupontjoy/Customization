::2021.08.14

@echo off
::�����ASNI���a


::���ݲ��ֿ�ʼ
Title �����̎�����ϰ� by Cing
::�����С��ColsΪ��LinesΪ��
COLOR 0a
MODE con: COLS=90 LINES=25
cls

cd /d %~dp0


::�O���R�r�ļ��A
set TempFolder="D:\Temp"
set TargetFolder="D:"


::�O��Profiles�ς���ַ
set "TargetFolder1=E:\My Documents\Nutstore\NutStoreSync\Firefox\Profiles"


:Profiles
cls
@echo off
CALL "%~dp0Modules\Profiles-Files.cmd"
CALL "%~dp0Modules\Profiles-Zip.cmd"
call :when_done
@echo.
Goto eof


:when_done
::���������ͣһ��ʱ��رմ��ڣ���ֹ���б���ʱֱ�ӹرմ��ڡ�
:when_done
timeout /t 3 /nobreak


goto :eof