@echo off
Title ���Firefox����(����Ҫ�ļ�) by Cing
color 0a
cls
setlocal enabledelayedexpansion

:: �������
:Profiles-zip

:: ����ʱ�䴦���޸�08:00��ʽ���⣩
set "YY=%date:~0,4%"
set /a "YY_HD=YY + 2697"
set "MON=%date:~5,2%"
set "DD=%date:~8,2%"
set "t_hh=%time:~0,2%"
set /a "t_hh=1!t_hh! - 100" 2>nul
if "!t_hh!"=="-99" set "t_hh=00"
if !t_hh! LSS 10 set "t_hh=0!t_hh!"
set "hh=!t_hh!"
set "mm=%time:~3,2%"
set "ss=%time:~6,2%"

:: ����ѹ�����ļ�����ǿ���޿ո�
set "Name=FxProfiles_(%YY_HD%)%YY%.%MON%%DD%.%hh%%mm%_%ver%.7z"

:: ѹ��������·���ϸ����Ű�����
"%zip%" -mx9 -mhc -ms -mmt -mfb=273 -r u "%TargetFolder%\!Name!" "%TempFolder%\Profiles\BackupProfiles" "%TempFolder%\Profiles\FxProfiles" "%TempFolder%\Profiles\Run"

:: ȷ��Ŀ���ļ��д��ڣ��޸�����Ƕ�ף�
if not exist "%TargetFolder1%" (
    echo ����Ŀ���ļ���: "%TargetFolder1%"
    mkdir "%TargetFolder1%"
)

:: ��������2����ѹ��������ǿɾ���߼���
set "keep=2"
set "count=0"
for /f "delims=" %%F in ('dir /b /o-d "%TargetFolder1%\FxProfiles_*.7z" 2^>nul') do (
    set /a count+=1
    if !count! gtr %keep% (
        echo [ɾ�����ļ�] "%%F"
        del /f /q "%TargetFolder1%\%%F" >nul 2>&1
    )
)

:: �ƶ���ѹ�������޸�·��ƴ�ӣ�
move /Y "%TargetFolder%\!Name!" "%TargetFolder1%\!Name!" >nul 2>&1

:: ������ʱ�ļ���
:end
if exist "%TempFolder%" (
    rd /s /q "%TempFolder%" 2>nul
    echo ��ʱ�ļ���������
)

@echo �����ɣ��������%keep%���汾���°�λ��: "%TargetFolder1%\!Name!"
endlocal

