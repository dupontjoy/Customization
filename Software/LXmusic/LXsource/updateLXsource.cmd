::2025.06.04

@echo off
title 一键下载lx music音源
color 0a


pushd %~dp0

:: 下载工具配置
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

::=======================================
:: 主流程
::=======================================
:menu
call :testGHmirror
call :update_fixed
call :end
goto :eof

::=======================================
:: 子程序
::=======================================
:testGHmirror
CALL "D:\Program Files\CingFox\Profiles\BackupProfiles\Modules\testGHmirror.cmd"
goto :eof

:update_fixed
echo. [下载] freelisten音源
%Curl_Download% -o "%cd%\freelisten.js" https://fastly.jsdelivr.net/gh/lyswhut/lx-music-source/dist/lx-music-source.js
echo. [下载] flower音源
%Curl_Download% -o "%cd%\flower.js" %GH_PROXY%/https://github.com/pdone/lx-music-source/raw/refs/heads/main/flower/latest.js
echo. [下载] grass音源
%Curl_Download% -o "%cd%\grass.js" %GH_PROXY%/https://github.com/pdone/lx-music-source/raw/refs/heads/main/grass/latest.js
echo. [下载] ikun音源
%Curl_Download% -o "%cd%\ikun.js" %GH_PROXY%/https://github.com/pdone/lx-music-source/raw/refs/heads/main/ikun/latest.js
echo. [下载] lx音源
%Curl_Download% -o "%cd%\lx.js" %GH_PROXY%/https://github.com/pdone/lx-music-source/raw/refs/heads/main/lx/latest.js

goto :eof

:end
timeout /t 3 /nobreak
exit