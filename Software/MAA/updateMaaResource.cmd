::2025.05.10

@echo off
title 一键更新MaaResource

::界面大小，Cols为宽，Lines为高
COLOR 0a
cls

pushd %~dp0

:: 下载工具配置
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

::=======================================
:: 主流程
::=======================================
:menu
call :testGHmirror
::call :update_maa_ota
call :update_MaaResource
call :end
goto :eof

::=======================================
:: 子程序
::=======================================
:testGHmirror
CALL "%cd%\..\CingFox\Profiles\BackupProfiles\Modules\testGHmirror.cmd"
goto :eof

:update_maa_ota
setlocal enabledelayedexpansion

:: 获取最新的两个版本号
echo. 
echo 查找最新MAA版本...
for /f "tokens=1,2" %%a in ('powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $tags = (Invoke-RestMethod -Uri 'https://api.github.com/repos/MaaAssistantArknights/MaaRelease/releases').tag_name | Where-Object { $_ -match '^v\d+\.\d+\.\d+$' } | Sort-Object { [version]($_.Substring(1)) } -Descending; if ($tags.Count -ge 2) { write-output ($tags[1] + ' ' + $tags[0]) } else { exit 1 }"') do (
    set "version1=%%a"
    set "version2=%%b"
)
echo. 最新在线版本: %version2%

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
if exist versions_maa.txt (
    for /f "tokens=1,2" %%i in (versions_maa.txt) do (
        set "old_version1=%%i"
        set "old_version2=%%j"
    )
) else (
    set "old_version2=%version1%"
)
echo. 本地版本: %old_version2%

:: 比较版本号是否相同
    if defined old_version2 (
        if "!old_version2!" == "%version2%" (
            echo. 当前已是最新版本：!version2!，无需更新.
            exit /b 0
        )
    )

:: 下载新版本
echo. 
echo. 发现新版本: %old_version2% to %version2%
set "download_url=%GH_PROXY%/https://github.com/MaaAssistantArknights/MaaRelease/releases/download/%version2%/MAAComponent-OTA-%old_version2%_%version2%-win-x64.zip"
echo. [下载] %download_url%

:: 使用 PowerShell 下载文件
powershell -Command "Invoke-WebRequest -Uri '%download_url%' -OutFile 'MAAComponent-OTA-win-x64.zip' -ErrorAction Stop"
if errorlevel 1 (
    echo 下载失败.
    exit /b 1
)

:: 保存新版本号到文件
echo. 
echo. %old_version2% %version2% > versions_maa.txt
echo. 下载完成 且 保存新版本号到文件.

endlocal

:: 解压
taskkill /f /t /im maa*

echo. 
echo. 解压MAAComponent-OTA-win-x64.zip ...
echo. 
tar -xf .\MAAComponent-OTA-win-x64.zip
del /s /q .\MAAComponent-OTA-win-x64.zip

goto :eof

:update_MaaResource
setlocal enabledelayedexpansion

:: GitHub API 地址
set "api_url=https://api.github.com/repos/MaaAssistantArknights/MaaResource/commits/main"

:: 使用 PowerShell 获取最新提交時间
echo. 
echo 获取MaaResource最新提交時间...
for /f %%i in ('powershell -Command "(Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json).commit.committer.date"') do (
    set "last_date=%%i"
)
echo. 最新在线提交時间: %last_date%

:: 读取本地保存的版本号
set "local_date="
if exist versions_maaresource.txt (
    for /f "tokens=1,2" %%i in (versions_maaresource.txt) do (
        set "local_date=%%i"
    )
)
echo. 本地時间: %local_date%

:: 比较版本号是否相同
    if defined local_date (
        if "!local_date!" == "%last_date%" (
            echo. 当前已是最新版本: %last_date%，无需更新.
            exit /b 0
        )
    )

:: 下载资源
:: echo.
:: echo. [下载] %GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip
:: %Curl_Download% -O %GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip

:: 使用 PowerShell 下载文件
echo.
set "download_url=%GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip"
echo. [下载] %download_url%
powershell -Command "Invoke-WebRequest -Uri '%download_url%' -OutFile 'MaaResource-main.zip' -ErrorAction Stop"
if errorlevel 1 (
    echo 下载失败.
    exit /b 1
)

:: 更新本地時间文件
echo. 
(echo|set /p="%last_date%") > versions_maaresource.txt

echo 下载完成，時间已更新为：%last_date%
echo. 

:: x解压，v显示所有过程，f使用档案名字（这个参数放最后）
tar -xf .\MaaResource-main.zip
xcopy "%cd%\MaaResource-main\cache" "%cd%\cache"  /s /y /i
xcopy "%cd%\MaaResource-main\resource" "%cd%\resource"  /s /y /i

del /s /q .\MaaResource-main.zip
rd /s /q MaaResource-main

goto :eof

:end
timeout /t 3 /nobreak
