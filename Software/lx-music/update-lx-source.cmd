::2023.11.03

@echo off
title һ������ Huibq��lx music��Դ
color 0a

:: ��С����ǰ����
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

pushd %~dp0

:: ���ع�������
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

:test_fastest_ghmirror
CALL "D:\Program Files\CingFox\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"

::=======================================
:: ������
::=======================================
:menu
call :updating
call :end
goto :eof

:updating
:: scripts
echo. [����] https://fastly.jsdelivr.net/gh/Huibq/keep-alive/render_api.js
%Curl_Download% -o "%cd%\render_api.js" https://fastly.jsdelivr.net/gh/Huibq/keep-alive/render_api.js


:end
timeout /t 3 /nobreak
