:: 2025.04.14

@echo off
title 一键更新lx_music_desktop
COLOR 0A
cls

:: 最小化当前窗口
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

::=======================================
:: 初始化配置
::=======================================
pushd "%~dp0"

:: 下载工具配置
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

:: 版本文件
set "version_file=versions_lx_music.txt"

::=======================================
:: 主流程
::=======================================
:menu
call :test_fastest_ghmirror
call :check_version
if "%need_update%"=="1" (
    call :update_lx_music_desktop
    call :unzip_lx_music_desktop
    (echo|set /p="%latest_version%") > "%version_file%"
    echo 已更新到最新版本: %latest_version%
) else (
    echo 当前已是最新版本: %latest_version%，无需更新
)
call :end
goto :eof

::=======================================
:: 子程序
::=======================================
:test_fastest_ghmirror
CALL "%cd%\..\CingFox\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"
goto :eof

:check_version
setlocal enabledelayedexpansion
echo.&echo █ 正在检查lx_music_desktop版本...

:: GitHub API 地址
set "api_url=https://api.github.com/repos/lyswhut/lx-music-desktop/releases/latest"

:: 获取最新版本更新時间
for /f %%i in ('powershell -Command "(Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json).published_at"') do (
    set "latest_version=%%i"
)
echo 在线版本: %latest_version%

:: 读取本地版本更新時间
set "local_version="
if exist "%version_file%" (
    for /f "usebackq delims=" %%i in ("%version_file%") do (
        set "local_version=%%i"
    )
)
echo 本地版本: %local_version%

:: 比较版本
if "%latest_version%"=="%local_version%" (
    set "need_update=0"
) else (
    set "need_update=1"
)
echo 版本比较结果: %need_update%

endlocal & set "need_update=%need_update%" & set "latest_version=%latest_version%"
goto :eof

:update_lx_music_desktop
setlocal enabledelayedexpansion
echo.&echo █ 正在更新lx_music_desktop...

:: GitHub API 地址和文件名匹配模式
set "api_url=https://api.github.com/repos/lyswhut/lx-music-desktop/releases/latest"
set "file_pattern=lx-music-desktop-.*-win_x64-green\.7z"

:: 使用 PowerShell 解析下载链接
powershell -Command "$response = Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json; $asset = $response.assets | Where-Object { $_.name -match '%file_pattern%' } | Select-Object -First 1; if ($asset) { $asset.browser_download_url } else { exit 1 }" > download_url.tmp

:: 检查是否获取到下载链接
if %errorlevel% neq 0 (
    echo 未找到匹配的文件
    del download_url.tmp 2>nul
    exit /b 1
)

:: 读取下载链接并添加镜像代理
set /p original_url=<download_url.tmp
set "download_url=%GH_PROXY%/%original_url%"

:: 下载文件
echo [下载] %download_url%
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%download_url%' -OutFile '%cd%\lx_music_desktop-latest.7z' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: 清理临时文件
del download_url.tmp 2>nul
endlocal
goto :eof

:unzip_lx_music_desktop
:: 解压文件
set "zip=..\7-Zip\7z.exe"
%zip% x -y -aoa -sccUTF-8 -scsWIN .\lx_music_desktop-latest.7z

del /s /q  .\lx_music_desktop-latest.7z

goto :eof

::=======================================
:: 结束处理
::=======================================
:end
timeout /t 3 /nobreak
