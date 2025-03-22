::2024.07.05
::记得保存为ASNI编码

@echo off & setlocal enabledelayedexpansion

::界面颜色大小，Cols为宽，Lines为高
COLOR 0a
cls

::开始
Title yt-dlp下载视频

cd /d %~dp0


::功能选项
:yt-dlp
cls
call :common_input
call :setting_path
call :setting_yt-dlp_params
call :yt-dlp_downloading
call :when_done
goto :eof

::---------------输入部分---------------
:common_input
::输入链接
:set_link
set "link="
set /p "link=请输入链接: "
if "!link!"=="" (
    echo 错误：输入不能为空！
    goto set_link
)

::设置分辨率
:set_format_res
set "res="
set /p "res=分辨率（如480/720[默认]/1080，可为空）: "
if "!res!"=="" (
    set format_res=--format-sort res:720
) else (
    set format_res=--format-sort res:%res%
)


::---------------设置部分---------------
:setting_path
::设置firefox配置目录
set firefox_profile=..\..\Profiles\FxProfiles

::设置输出目录
set SaveDir=E:\Download\

::设置ffmpeg.exe路径
set ffmpeg=ffmpeg.exe

goto :eof

:setting_yt-dlp_params
::设置yt-dlp下载参数
set title=%%(title)s@%%(uploader)s.%%(ext)s
set yt-dlp_params=--cookies-from-browser firefox:"%firefox_profile%" %format_res% --ffmpeg-location %ffmpeg% -o "%title%"
::下载视频转换成mp4（用--merge-output-format参数）
set yt-dlp_download=yt-dlp --merge-output-format mp4 %yt-dlp_params% -P %SaveDir% "%link%"
goto :eof


::---------------参数说明---------------
::--cookies-from-browser BROWSER[+KEYRING][:PROFILE][::CONTAINER]   设置cookie
::--format-sort                                                     设置格式：res:720表示分辨率720P
::--ffmpeg-location PATH                                            设置ffmpeg路径
::-P PATH                                                           设置文件保存路径


::---------------运行部分---------------
:yt-dlp_downloading
::下载命令
cls
echo.下载命令：%yt-dlp_download%
%yt-dlp_download%
goto :eof


::---------------结束部分---------------
::下载完成暂停一段时间关闭窗口，防止运行报错时直接关闭窗口。
:when_done
timeout /t 3 /nobreak
exit
goto :eof
