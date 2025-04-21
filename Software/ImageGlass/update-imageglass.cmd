:: 2025.04.13

@echo off
title 一键更新imageglass
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

::=======================================
:: 主流程
::=======================================
:menu
call :test_fastest_ghmirror
call :updating_imageglass
call :unzip_imageglass
call :end
goto :eof

::=======================================
:: 子程序
::=======================================
:test_fastest_ghmirror
CALL "%cd%\..\..\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"
goto :eof

:updating_imageglass
setlocal
echo.&echo █ 正在更新imageglass...

:: GitHub API 地址和文件名匹配模式
set "api_url=https://api.github.com/repos/d2phap/ImageGlass/releases/latest"
set "file_pattern=ImageGlass_.*_x64\.zip"

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
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%download_url%' -OutFile '%cd%\imageglass-latest.zip' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: 清理临时文件
del download_url.tmp 2>nul
endlocal
goto :eof

:unzip_imageglass
setlocal
::解压, 跳過压缩包的第一层目录(兼容无顶层目录的 ZIP 文件)
set "zipfile=imageglass-latest.zip"
set "tempdir=%cd%\unzip_temp"

REM 创建临时目录并解压
mkdir "%tempdir%" 2>nul
tar -xf "%zipfile%" -C "%tempdir%"

REM 判断临时目录中是否有子目录
dir /b "%tempdir%" | findstr /i "[0-9a-zA-Z]" >nul
if %errorlevel% equ 0 (
    for /d %%D in ("%tempdir%\*") do (
        xcopy /s /e /h /y "%%D\*" ".\"
    )
) else (
    xcopy /s /e /h /y "%tempdir%\*" ".\"
)

rd /s /q "%tempdir%"
endlocal

del /s /q .\imageglass-latest.zip
goto :eof

::=======================================
:: 结束处理
::=======================================
:end
timeout /t 3 /nobreak
