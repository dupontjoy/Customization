::2025.04.21

@echo off
title 一键更新MaaResource

::界面大小，Cols为宽，Lines为高
COLOR 0a
cls

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
call :update_maa_ota
:: call :update_maa
call :update_MaaResource
call :end
goto :eof

::=======================================
:: 子程序
::=======================================
:test_fastest_ghmirror
CALL "%cd%\..\CingFox\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"
goto :eof

:update_maa_ota
setlocal enabledelayedexpansion

:: 获取最新的两个版本号
echo. 
echo. 查找最新MAA版本...
for /f "tokens=1,2" %%a in ('powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $tags = (Invoke-RestMethod -Uri 'https://api.github.com/repos/MaaAssistantArknights/MaaRelease/releases').tag_name | Where-Object { $_ -match '^v\d+\.\d+\.\d+$' } | Sort-Object { [version]($_.Substring(1)) } -Descending; if ($tags.Count -ge 2) { write-output ($tags[1] + ' ' + $tags[0]) } else { exit 1 }"') do (
    set "version1=%%a"
    set "version2=%%b"
)

:: 检查版本号获取结果
if not defined version1 (
    echo. 未获取到版本号1.
    exit /b 1
)
if not defined version2 (
    echo. 未获取到版本号2.
    exit /b 1
)

:: 读取本地保存的版本号
set "old_version1="
set "old_version2="
if exist maa_versions.txt (
    for /f "tokens=1,2" %%i in (maa_versions.txt) do (
        set "old_version1=%%i"
        set "old_version2=%%j"
    )
)

:: 比较版本号是否相同
if defined old_version1 (
    if defined old_version2 (
        if "!old_version1!" == "%version1%" if "!old_version2!" == "%version2%" (
            echo. 已是最新版本.
            exit /b 0
        )
    )
)

:: 下载新版本
echo. 
echo. 发现新版本: %version1% to %version2%
set "download_url=%GH_PROXY%/https://github.com/MaaAssistantArknights/MaaRelease/releases/download/%version2%/MAAComponent-OTA-%version1%_%version2%-win-x64.zip"
echo. [下载] %download_url%

:: 使用 PowerShell 下载文件
powershell -Command "Invoke-WebRequest -Uri '%download_url%' -OutFile 'MAAComponent-OTA-win-x64.zip' -ErrorAction Stop"
if errorlevel 1 (
    echo 下载失败.
    exit /b 1
)

:: 保存新版本号到文件
echo. 
echo. %version1% %version2% > maa_versions.txt
echo. 下载完成 且 保存新版本号到文件.

endlocal

:: 解压
tar -xf .\MAAComponent-OTA-win-x64.zip
del /s /q .\MAAComponent-OTA-win-x64.zip

goto :eof

:update_maa
setlocal
echo.&echo █ 正在更新maa...

:: GitHub API 地址和文件名匹配模式
set "api_url=https://api.github.com/repos/MaaAssistantArknights/MaaAssistantArknights/releases/latest"
set "file_pattern=MAA-.*-win-x64\.zip"

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
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%download_url%' -OutFile '%cd%\maa-latest.zip' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: 清理临时文件
del download_url.tmp 2>nul
endlocal

::解压
tar -xf .\maa-latest.zip
del /s /q .\maa-latest.zip

goto :eof

:update_MaaResource
echo. [下载] %GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip
%Curl_Download% -O %GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip

:: x解压，v显示所有过程，f使用档案名字（这个参数放最后）
tar -xf .\MaaResource-main.zip
xcopy "%cd%\MaaResource-main\cache" "%cd%\cache"  /s /y /i
xcopy "%cd%\MaaResource-main\resource" "%cd%\resource"  /s /y /i

del /s /q .\MaaResource-main.zip
rd /s /q MaaResource-main

goto :eof

:end
timeout /t 3 /nobreak
