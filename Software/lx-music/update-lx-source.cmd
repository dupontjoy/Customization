::2023.11.03

@echo off
title 一键下载 Huibq版lx music音源
color 0a

:: 最小化当前窗口
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

pushd %~dp0

:: 下载工具配置
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

::=======================================
:: 主流程
::=======================================
:menu
call :test_fastest_ghmirror
call :updating
call :end
goto :eof

::=======================================
:: 子程序
::=======================================
:test_fastest_ghmirror
CALL "%cd%\..\CingFox\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"
goto :eof

:updating
:: scripts
echo. [下载] https://fastly.jsdelivr.net/gh/Huibq/keep-alive/render_api.js
%Curl_Download% -o "%cd%\render_api.js" https://fastly.jsdelivr.net/gh/Huibq/keep-alive/render_api.js


:end
timeout /t 3 /nobreak
