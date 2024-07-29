::2024.04.07

@echo off

title update mpv scripts
color 0a

pushd %~dp0

:: Set download command
set Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs

:: start updating
call :updating_scripts
call :updating_yt-dlp
call :end
goto :eof

:updating_scripts
:: scripts
echo. downloading autoload.lua
%Download% -o "%cd%\scripts\autoload.lua" https://github.com/dyphire/mpv-config/raw/master/scripts/autoload.lua
echo. downloading autoload.conf
%Download% -o "%cd%\script-opts\autoload.conf" https://github.com/dyphire/mpv-config/raw/master/script-opts/autoload.conf


echo. downloading quality-menu.lua
%Download% -o "%cd%\scripts\quality-menu.lua" https://github.com/dyphire/mpv-config/raw/master/scripts/quality-menu.lua
echo. downloading quality-menu.conf
%Download% -o "%cd%\script-opts\quality-menu.conf" https://github.com/dyphire/mpv-config/raw/master/script-opts/quality-menu.conf

echo. downloading SmartCopyPaste.lua
%Download% -o "%cd%\scripts\SmartCopyPaste.lua" https://github.com/Eisa01/mpv-scripts/raw/master/scripts/SmartCopyPaste.lua
echo. downloading SmartCopyPaste.conf
%Download% -o "%cd%\script-opts\SmartCopyPaste.conf" https://github.com/Eisa01/mpv-scripts/raw/master/script-opts/SmartCopyPaste.conf

echo. downloading stats.lua chs
%Download% -o "%cd%\scripts\stats.lua" https://github.com/FinnRaze/mpv-stats-zh/raw/master/stats.lua
echo. downloading stats.conf
%Download% -o "%cd%\script-opts\stats.conf" https://github.com/hooke007/MPV_lazy/raw/main/portable_config/script-opts/stats.conf

echo. downloading uosc.zip
%Download% -o "%cd%\uosc.zip" https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip
echo. downloading uosc.conf
%Download% -o "%cd%\script-opts\uosc.conf" https://github.com/dyphire/mpv-config/raw/master/script-opts/uosc.conf

:: É¾³ý¾É°æuoscÎÄ¼þ
rd /s /q "%cd%\scripts\uosc"
echo. extracting uosc.zip
tar -xvf .\uosc.zip
goto :eof

:updating_yt-dlp
:: Download latest yt-dlp
setlocal EnableDelayedExpansion
set "instance=0"

for /f "tokens=1,* delims=:" %%A in ('curl -ks https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest ^| find "yt-dlp.exe"') do (
    set /a instance+=1
    if !instance! == 2 (
    	echo. downloading yt-dlp.exe
        %Download% -o "%cd%\..\yt-dlp.exe" %%B
    )
)
goto :eof


:end
timeout /t 3 /nobreak
