:: 2025.05.27

@echo off
title 一键更新goldendict
COLOR 0A
cls

:: 最小化当前窗口
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

::=======================================
:: 初始化配置
::=======================================
pushd "%~dp0"

:: 下载工具配置
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-days"

:: 版本文件
set "version_file=versions_goldendict.txt"

::=======================================
:: 主流程
::=======================================
:menu
call :test_fastest_ghmirror
call :check_version
if "%need_update%"=="1" (
    call :update_goldendict
    call :unzip_goldendict
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
echo.&echo █ 正在检查goldendict版本...

:: GitHub API 地址
set "api_url=https://api.github.com/repos/xiaoyifang/goldendict-ng/releases/latest"

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

:update_goldendict
setlocal enabledelayedexpansion
echo.&echo █ 正在更新goldendict...

:: GitHub API 地址和文件名匹配模式
set "api_url=https://api.github.com/repos/xiaoyifang/goldendict-ng/releases/latest"
set "file_pattern=GoldenDict-ng-.*-Windows.*\.7z"

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
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%download_url%' -OutFile '%cd%\goldendict-latest.7z' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

endlocal
goto :eof

:unzip_goldendict
setlocal enabledelayedexpansion
::先终止运行中的goldendict程序
taskkill /f /t /im goldendict*

::解压, 跳過压缩包的第一层目录(兼容无顶层目录的 ZIP 文件)
set "zip=..\7-Zip\7z.exe"
set "zipfile=goldendict-latest.7z"
set "tempdir=%cd%\unzip_temp"

REM 创建临时目录并解压（（注意-o与路径间无空格））
md "%tempdir%" 2>nul
%zip% x "%zipfile%" -o"%tempdir%" -y

:: 判断临时目录内容并复制
set "hasSubdir=0"
for /d %%D in ("%tempdir%\*") do (
    set "hasSubdir=1"
    echo 正在复制文件...
    xcopy /s /e /h /y "%%D\*" ".\" >nul || (
        echo 错误: 复制文件失败
        rmdir /s /q "%tempdir%" 2>nul
        pause
        exit /b 1
    )
)

if "!hasSubdir!"=="0" (
    echo 正在复制文件...
    xcopy /s /e /h /y "%tempdir%\*" ".\" >nul || (
        echo 错误: 复制文件失败
        rmdir /s /q "%tempdir%" 2>nul
        pause
        exit /b 1
    )
)

:: 清理临时目录
rmdir /s /q "%tempdir%" 2>nul
endlocal

del /s /q .\goldendict-latest.7z
goto :eof

::=======================================
:: 结束处理
::=======================================
:end
timeout /t 3 /nobreak >nul