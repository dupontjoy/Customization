::2023.11.03

@echo off

title Ò»¼üÏÂÔØ Huibq/keep-alive/master/render_api.js
color 0a

pushd %~dp0

:: Set download command
set Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs

:: start updating
call :updating
call :end
goto :eof

:updating
:: scripts
echo. downloading render_api.js
%Download% -o "%cd%\render_api.js" https://raw.niuma666bet.buzz/Huibq/keep-alive/master/render_api.js


:end
timeout /t 3 /nobreak
