::2023.11.03

@echo off

title һ������ Huibq��lx music��Դ
color 0a

pushd %~dp0

:: ���ع�������
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"
set "GH_PROXY=https://gh-proxy.com"

:: start updating
call :updating
call :end
goto :eof

:updating
:: scripts
echo. downloading render_api.js
%Curl_Download% -o "%cd%\render_api.js" https://fastly.jsdelivr.net/gh/Huibq/keep-alive/render_api.js


:end
timeout /t 3 /nobreak
