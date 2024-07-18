::2023.12.09
::推荐保存为ASNI编码

@echo off & setlocal enabledelayedexpansion

::开始
Title N_m3u8DL-RE：跨平台的DASH/HLS/MSS下载工具 by nilaoda

::界面颜色大小，Cols为宽，Lines为高
color 0a
cls

pushd %~dp0

::---------------菜单部分---------------
:menu
echo 请选择功能，默认使用1、下载视频。
echo.&choice /C 12 /T 1 /D 1 /M "1、下载视频 2、直播录制"
IF "%ERRORLEVEL%"=="1" (goto video_download)
IF "%ERRORLEVEL%"=="2" (goto live_record)


::功能选项
:video_download
cls
echo.&echo 下载视频...
echo.
call :common_input
call :setting_video_download
call :video_downloading
call :when_done
goto :eof

:live_record
cls
echo.&echo 直播录制...
echo.
call :common_input & call :record_limit_input
call :setting_live_record
call :live_recording
call :when_done
goto :eof


::---------------输入部分---------------
:common_input
::输入链接/文件名
:set_link
set "link="
set /p "link=请输入链接: "
if "!link!"=="" (
    echo 错误：输入不能为空！
    goto set_link
)

:set_filename 
set "filename="
set /p "filename=请输入文件名（不能包含"\/:*?"<>|"任何之一）: "
if "!filename!"=="" (
    echo 错误：输入不能为空！
    goto set_filename
)

::子标签中加上goto :eof命令即可退出子标签，不继续执行它下面的其它命令
goto :eof


:record_limit_input
set "record_limit="
set /p "record_limit=请输入录制时长限制(格式：HH:mm:ss, 可为空): "
if "!record_limit!"=="" (
    set live_record_limit=
) else (
    set live_record_limit=--live-record-limit %record_limit%
    )
goto :eof


:custom_range_input
set "custom_range="
set /p "custom_range=请输入分片范围(格式：0-10或10-或-99或05:00-20:00, 可为空): "
if "!custom_range!"=="" (
    set custom_range=
) else (
    set custom_range=--custom-range %custom_range%
    )
goto :eof


::---------------设置部分---------------
:setting_video_download
::设置video下载命令
::将%filename%加引号，防止文件名带有某些符号导致路径识別失败
set video_download=N_m3u8DL-RE "%link%" --save-name "%filename%" @config_video_download.conf @config_dir.conf
goto :eof

:setting_live_record
::设置直播录制命令
set live_record=N_m3u8DL-RE "%link%" --save-name "%filename%" %live_record_limit% @config_live_record.conf @config_dir.conf
goto :eof


::---------------运行部分---------------
:video_downloading
::输出运行命令
cls
echo.运行命令：%video_download%
echo.
::开始下载
%video_download%
goto :eof

:live_recording
::输出运行命令
cls
echo.运行命令：%live_record%
echo.
::开始录制
%live_record%
goto :eof


::---------------结束部分---------------
::下载完成暂停一段时间关闭窗口，防止运行报错时直接关闭窗口，来不及看错误信息。
:when_done
timeout /t 3 /nobreak
goto :eof
