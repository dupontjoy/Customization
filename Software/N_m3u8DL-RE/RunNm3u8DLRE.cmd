@echo off & setlocal enabledelayedexpansion

:: ��ʼ������
Title N_m3u8DL-RE����ƽ̨��DASH/HLS/MSS���ع��� by nilaoda
color 0a & cls
pushd %~dp0

:: ���˵�
:menu
cls
echo.
echo *****************************
echo.
echo  1��������Ƶ
echo.  
echo  2��ֱ��¼��
echo.
echo *****************************
echo.
choice /C 12 /N /M "��ѡ�����:"
if errorlevel 2 goto live_record
if errorlevel 1 goto video_download_no_ad
goto menu

:: ����ѡ��
:video_download_no_ad
cls & echo.& echo ������Ƶ & echo.
call :common_input
call :check_mixed_m3u8
call :analyze_ad_segments_from_config
if "!ad_detected!"=="0" call :analyze_ad_segments
set "video_download=N_m3u8DL-RE @config_common.conf @config_ad_keyword.conf !custom_ad_keyword! !custom-hls-key! --save-name "!filename!" "!link!""
echo.
echo.�������!video_download! & echo.
!video_download!
goto :end

:live_record
cls & echo.& echo ֱ��¼�� & echo.
call :common_input
call :record_limit_input
set "live_record=N_m3u8DL-RE @config_common.conf @config_live_record.conf !live_record_limit! --save-name "!filename!" "!link!""
echo.
echo.�������!live_record! & echo.
!live_record!
goto :end

:: ���봦��
:common_input
:set_link
set "link=" & set /p "link=������ ����: "
if "!link!"=="" (echo �������벻��Ϊ�գ� & goto :set_link)

:set_key
set "key="
set /p "key=������ HLS����KEY��HEX��Base64, ��Ϊ�գ�: "
if "!key!"=="" (set "custom-hls-key=") else set "custom-hls-key=--custom-hls-key !key!"

:set_filename 
set "filename=" & set /p "filename=������ �ļ��������ܰ���\/:*?^<>|��: "
if "!filename!"=="" (echo �������벻��Ϊ�գ� & goto :set_filename)
goto :eof

:check_mixed_m3u8
curl -s "!link!" > temp.m3u8
findstr /i "mixed.m3u8" temp.m3u8 >nul || goto :no_mixed
for /f "delims=" %%a in ('findstr /i "mixed.m3u8" temp.m3u8') do set "mixed_line=%%a"
set "base_url=!link:index.m3u8=!"
if not "!base_url:~-1!"=="/" if not "!base_url:~-1!"=="\" set "base_url=!base_url:/index.m3u8=!"
set "new_link=!base_url!!mixed_line!"
echo ������: !new_link!
curl -s "!new_link!" > temp_analyze.m3u8
goto :mixed_done

:no_mixed
copy temp.m3u8 temp_analyze.m3u8 >nul
:mixed_done
del temp.m3u8
goto :eof

:: �Ľ���Ĺ��Ƭ�μ�⺯��
:analyze_ad_segments_from_config
set "ad_detected=0"
set "custom_ad_keyword="

:: ��ȡ config_ad_keyword.conf �ļ��е�����������ʽ
echo.
if exist config_ad_keyword.conf (
    for /f "tokens=2 delims= " %%a in (config_ad_keyword.conf) do (
        set "regex_pattern=%%a"
        echo ����ʹ��������ʽ: !regex_pattern! �����Ƭ��...
        for /f "delims=" %%b in ('type temp_analyze.m3u8 ^| findstr /r /i /c:"!regex_pattern!"') do (
            set "ad_detected=1"
            echo. ʹ��������ʽ: !regex_pattern! ��⵽���Ƭ��: %%b
            del temp_analyze.m3u8
            goto :eof
        )
    )
)

echo û��ƥ�䵽���Ƭ��
goto :eof

:: ԭ���Ĺ��Ƭ�μ�⺯��
:analyze_ad_segments
set "first_ts_length=0" & set "ad_detected=0"
set "ad_count=0"
set "ad_segments="
set "custom_ad_keyword="
set "first_ts_id="
set "total_segments=0"

:: ���ȼ�����Ƭ����
echo.
echo ����ʹ�� ���ȷ�ƬID���ȷ��� �����...
for /f %%a in ('type temp_analyze.m3u8 ^| find /c ".ts"') do set "total_segments=%%a"
echo ��Ƭ����: !total_segments!

:: �����Ƭ����Ϊ0�����������
if !total_segments! equ 0 (
    echo û���ҵ�.tsƬ�Σ����������
    del temp_analyze.m3u8
    goto :eof
)

:: ʹ�ø���Ч�ķ�ʽ����m3u8����
for /f "delims=" %%a in ('type temp_analyze.m3u8 ^| find ".ts"') do (
    :: ��ȡƬ��ID������.ts��׺��
    for /f "tokens=1 delims=?" %%b in ("%%a") do set "segment_id=%%~nxb"
    set "segment_id=!segment_id:*/=!"
    set "segment_id=!segment_id:.ts=!"

    :: ����Ƭ��ID�ĳ���
    call :get_length_fast "!segment_id!"
    set "length=!length!"

    if !first_ts_length! equ 0 (
        :: �����׸�.tsƬ�εĳ�����Ϊ��׼
        set "first_ts_length=!length!"
        echo.
        echo �׸�.tsƬ��ID: !segment_id!.ts
        echo ����: !first_ts_length!
    ) else (
        if !length! neq !first_ts_length! (
            set /a "ad_count+=1"
            set "ad_detected=1"
            
            :: �ռ����Ƭ��
            set "ad_segments=!ad_segments! !segment_id!"
            echo ��⵽���Ƭ�� [!ad_count!/!total_segments!]: !segment_id!.ts
            echo ����: !length! (�׸�.ts����: !first_ts_length!)
        )
    )
)

if !ad_detected! equ 1 (
    echo. 
    echo ����⵽ !ad_count! �����Ƭ��(��!total_segments!��Ƭ��)
    
    echo �������ɹ��������ʽ...
    
    :: ���ɹ��������ʽ
    set "ad_regex="
    for %%a in (!ad_segments!) do (
        if "!ad_regex!"=="" (
            set "ad_regex=.*%%a.*"
        ) else (
            set "ad_regex=!ad_regex!|.*%%a.*"
        )
    )
    
    :: ���û�ȷ������
    echo.
    echo ���ɵĹ������: !ad_regex!
    echo.
    set /p "apply_regex=�Ƿ�Ӧ�ô˹��������ʽ(Y/N)? "
    if /i "!apply_regex!"=="y" (
        set "custom_ad_keyword=--ad-keyword "!ad_regex!""
        echo ��Ӧ�ù��������ʽ
    ) else (
        echo �������������Ӧ��
    )
) else (
    echo δ��⵽���Ƭ������
)
del temp_analyze.m3u8
goto :eof

:: �����ٵ��ַ������ȼ���
:get_length_fast
set "line=%~1"
set "length=0"
:length_loop_fast
if not "!line:~%length%,1!"=="" (set /a length+=1 & goto :length_loop_fast)
exit /b

:record_limit_input
set "record_limit="
set /p "record_limit=������ ¼��ʱ������(��ʽ��HH:mm:ss, ��Ϊ��): "
if "!record_limit!"=="" (set "live_record_limit=") else set "live_record_limit=--live-record-limit !record_limit!"
goto :eof

:: ��������
:end
timeout /t 3 /nobreak >nul