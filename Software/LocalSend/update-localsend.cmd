:: 2025.03.19

@echo off
setlocal enabledelayedexpansion

title 一键更新localsend
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


:test_fastest_ghmirror
CALL "%cd%\..\CingFox\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"

::=======================================
:: 主流程
::=======================================
:menu
call :updating_localsend
call :end
exit /b


::=======================================
:: 子程序
::=======================================
:updating_localsend
setlocal
echo.&echo █ 正在更新localsend...

:: GitHub API 地址和文件名匹配模式
set "api_url=https://api.github.com/repos/localsend/localsend/releases/latest"
set "file_pattern=localsend-.*-windows-x86-64\.zip"

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
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%download_url%' -OutFile '%cd%\localsend-latest.zip' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: 清理临时文件
del download_url.tmp 2>nul

::解压
tar -xvf .\localsend-latest.zip

::=======================================
:: 结束处理
::=======================================
:end
echo.&echo █ 操作已完成！5秒后自动关闭...
timeout /t 5 /nobreak
exit /b