::2023.12.09
::�Ƽ�����ΪASNI����

@echo off & setlocal enabledelayedexpansion

::��ʼ
Title N_m3u8DL-RE����ƽ̨��DASH/HLS/MSS���ع��� by nilaoda

::������ɫ��С��ColsΪ��LinesΪ��
color 0a
cls

pushd %~dp0

::---------------�˵�����---------------
:menu
echo ��ѡ���ܣ�Ĭ��ʹ��1��������Ƶ��
echo.&choice /C 12 /T 1 /D 1 /M "1��������Ƶ 2��ֱ��¼��"
IF "%ERRORLEVEL%"=="1" (goto video_download)
IF "%ERRORLEVEL%"=="2" (goto live_record)


::����ѡ��
:video_download
cls
echo.&echo ������Ƶ...
echo.
call :common_input
call :setting_video_download
call :video_downloading
call :when_done
goto :eof

:live_record
cls
echo.&echo ֱ��¼��...
echo.
call :common_input & call :record_limit_input
call :setting_live_record
call :live_recording
call :when_done
goto :eof


::---------------���벿��---------------
:common_input
::��������/�ļ���
:set_link
set "link="
set /p "link=����������: "
if "!link!"=="" (
    echo �������벻��Ϊ�գ�
    goto set_link
)

:set_filename 
set "filename="
set /p "filename=�������ļ��������ܰ���"\/:*?"<>|"�κ�֮һ��: "
if "!filename!"=="" (
    echo �������벻��Ϊ�գ�
    goto set_filename
)

::�ӱ�ǩ�м���goto :eof������˳��ӱ�ǩ��������ִ�����������������
goto :eof


:record_limit_input
set "record_limit="
set /p "record_limit=������¼��ʱ������(��ʽ��HH:mm:ss, ��Ϊ��): "
if "!record_limit!"=="" (
    set live_record_limit=
) else (
    set live_record_limit=--live-record-limit %record_limit%
    )
goto :eof


:custom_range_input
set "custom_range="
set /p "custom_range=�������Ƭ��Χ(��ʽ��0-10��10-��-99��05:00-20:00, ��Ϊ��): "
if "!custom_range!"=="" (
    set custom_range=
) else (
    set custom_range=--custom-range %custom_range%
    )
goto :eof


::---------------���ò���---------------
:setting_video_download
::����video��������
::��%filename%�����ţ���ֹ�ļ�������ĳЩ���ŵ���·��ʶ�eʧ��
set video_download=N_m3u8DL-RE "%link%" --save-name "%filename%" @config_video_download.conf @config_dir.conf
goto :eof

:setting_live_record
::����ֱ��¼������
set live_record=N_m3u8DL-RE "%link%" --save-name "%filename%" %live_record_limit% @config_live_record.conf @config_dir.conf
goto :eof


::---------------���в���---------------
:video_downloading
::�����������
cls
echo.�������%video_download%
echo.
::��ʼ����
%video_download%
goto :eof

:live_recording
::�����������
cls
echo.�������%live_record%
echo.
::��ʼ¼��
%live_record%
goto :eof


::---------------��������---------------
::���������ͣһ��ʱ��رմ��ڣ���ֹ���б���ʱֱ�ӹرմ��ڣ���������������Ϣ��
:when_done
timeout /t 3 /nobreak
goto :eof
