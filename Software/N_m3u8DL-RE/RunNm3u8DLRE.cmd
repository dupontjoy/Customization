@echo off & setlocal enabledelayedexpansion

:: 初始化设置
Title N_m3u8DL-RE：跨平台的DASH/HLS/MSS下载工具 by nilaoda
color 0a & cls
pushd %~dp0

:: 主菜单
:menu
cls
echo.
echo *****************************
echo.
echo  1、下载视频
echo.  
echo  2、直播录制
echo.
echo *****************************
echo.
choice /C 12 /N /M "请选择操作:"
if errorlevel 2 goto live_record
if errorlevel 1 goto video_download_no_ad
goto menu

:: 功能选项
:video_download_no_ad
cls & echo.& echo 下载视频 & echo.
call :common_input
call :check_mixed_m3u8
call :analyze_ad_segments_from_config
if "!ad_detected!"=="0" call :analyze_ad_segments
set "video_download=N_m3u8DL-RE @config_common.conf @config_ad_keyword.conf !custom_ad_keyword! !custom-hls-key! %format_px% --save-name "!filename!" "!link!""
echo.
echo.运行命令：!video_download! & echo.
!video_download!
goto :end

:live_record
cls & echo.& echo 直播录制 & echo.
call :common_input
call :record_limit_input
set "live_record=N_m3u8DL-RE @config_common.conf @config_live_record.conf !live_record_limit! %format_px% --save-name "!filename!" "!link!""
echo.
echo.运行命令：!live_record! & echo.
!live_record!
goto :end

:: 输入处理
:common_input
:set_link
set "link=" & set /p "link=请输入 链接: "
if "!link!"=="" (echo 错误：输入不能为空！ & goto :set_link)

:set_key
set "key="
set /p "key=请输入 HLS解密KEY（HEX或Base64, 可为空）: "
if "!key!"=="" (set "custom-hls-key=") else set "custom-hls-key=--custom-hls-key !key!"

:set_proxy
set "px="
set /p "px=是否启用代理7897（y或空）： "
if "!px!"=="" (
    set "format_px="
) else (
    set "format_px=--custom-proxy 127.0.0.1:7897"
)

:set_filename 
set "filename=" & set /p "filename=请输入 文件名（不能包含\/:*?^<>|）: "
if "!filename!"=="" (echo 错误：输入不能为空！ & goto :set_filename)

goto :eof

:check_mixed_m3u8
curl -s "!link!" > temp.m3u8
findstr /i "mixed.m3u8" temp.m3u8 >nul || goto :no_mixed
for /f "delims=" %%a in ('findstr /i "mixed.m3u8" temp.m3u8') do set "mixed_line=%%a"
set "base_url=!link:index.m3u8=!"
if not "!base_url:~-1!"=="/" if not "!base_url:~-1!"=="\" set "base_url=!base_url:/index.m3u8=!"
set "new_link=!base_url!!mixed_line!"
echo 新链接: !new_link!
curl -s "!new_link!" > temp_analyze.m3u8
goto :mixed_done

:no_mixed
copy temp.m3u8 temp_analyze.m3u8 >nul
:mixed_done
del temp.m3u8
goto :eof

:: 改进后的广告片段检测函数
:analyze_ad_segments_from_config
set "ad_detected=0"
set "custom_ad_keyword="

:: 读取 config_ad_keyword.conf 文件中的所有正则表达式
echo.
if exist config_ad_keyword.conf (
    for /f "tokens=2 delims= " %%a in (config_ad_keyword.conf) do (
        set "regex_pattern=%%a"
        echo 正在使用正则表达式: !regex_pattern! 检测广告片段...
        for /f "delims=" %%b in ('type temp_analyze.m3u8 ^| findstr /r /i /c:"!regex_pattern!"') do (
            set "ad_detected=1"
            echo. 使用正则表达式: !regex_pattern! 检测到广告片段: %%b
            del temp_analyze.m3u8
            goto :eof
        )
    )
)

echo 没有匹配到广告片段
goto :eof

:: 原来的广告片段检测函数
:analyze_ad_segments
set "first_ts_length=0" & set "ad_detected=0"
set "ad_count=0"
set "ad_segments="
set "custom_ad_keyword="
set "first_ts_id="
set "total_segments=0"

:: 首先计算总片段数
echo.
echo 正在使用 對比分片ID长度方法 检测广告...
for /f %%a in ('type temp_analyze.m3u8 ^| find /c ".ts"') do set "total_segments=%%a"
echo 总片段数: !total_segments!

:: 如果总片段数为0，跳过广告检测
if !total_segments! equ 0 (
    echo 没有找到.ts片段，跳过广告检测
    del temp_analyze.m3u8
    goto :eof
)

:: 使用更高效的方式处理m3u8内容
for /f "delims=" %%a in ('type temp_analyze.m3u8 ^| find ".ts"') do (
    :: 提取片段ID（保留.ts后缀）
    for /f "tokens=1 delims=?" %%b in ("%%a") do set "segment_id=%%~nxb"
    set "segment_id=!segment_id:*/=!"
    set "segment_id=!segment_id:.ts=!"

    :: 计算片段ID的长度
    call :get_length_fast "!segment_id!"
    set "length=!length!"

    if !first_ts_length! equ 0 (
        :: 设置首个.ts片段的长度作为基准
        set "first_ts_length=!length!"
        echo.
        echo 首个.ts片段ID: !segment_id!.ts
        echo 长度: !first_ts_length!
    ) else (
        if !length! neq !first_ts_length! (
            set /a "ad_count+=1"
            set "ad_detected=1"
            
            :: 收集广告片段
            set "ad_segments=!ad_segments! !segment_id!"
            echo 检测到广告片段 [!ad_count!/!total_segments!]: !segment_id!.ts
            echo 长度: !length! (首个.ts长度: !first_ts_length!)
        )
    )
)

if !ad_detected! equ 1 (
    echo. 
    echo 共检测到 !ad_count! 个广告片段(共!total_segments!个片段)
    
    echo 正在生成广告正则表达式...
    
    :: 生成广告正则表达式
    set "ad_regex="
    for %%a in (!ad_segments!) do (
        if "!ad_regex!"=="" (
            set "ad_regex=.*%%a.*"
        ) else (
            set "ad_regex=!ad_regex!|.*%%a.*"
        )
    )
    
    :: 简化用户确认流程
    echo.
    echo 生成的广告正则: !ad_regex!
    echo.
    set /p "apply_regex=是否应用此广告正则表达式(Y/N)? "
    if /i "!apply_regex!"=="y" (
        set "custom_ad_keyword=--ad-keyword "!ad_regex!""
        echo 已应用广告正则表达式
    ) else (
        echo 已跳过广告正则应用
    )
) else (
    echo 未检测到广告片段特征
)
del temp_analyze.m3u8
goto :eof

:: 更快速的字符串长度计算
:get_length_fast
set "line=%~1"
set "length=0"
:length_loop_fast
if not "!line:~%length%,1!"=="" (set /a length+=1 & goto :length_loop_fast)
exit /b

:record_limit_input
set "record_limit="
set /p "record_limit=请输入 录制时长限制(格式：HH:mm:ss, 可为空): "
if "!record_limit!"=="" (set "live_record_limit=") else set "live_record_limit=--live-record-limit !record_limit!"
goto :eof

:: 结束处理
:end
timeout /t 3 /nobreak >nul