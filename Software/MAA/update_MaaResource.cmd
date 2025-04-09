::2025.04.09

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
call :update_MaaResource
call :update_maa_ota
call :end
goto :eof

::=======================================
:: 子程序
::=======================================
:test_fastest_ghmirror
CALL "%cd%\..\CingFox\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"
goto :eof

:update_MaaResource
echo. [下载] %GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip
%Curl_Download% -O %GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip

:: x解压，v显示所有过程，f使用档案名字，切记，这个参数是最后一个参数
tar -xvf .\MaaResource-main.zip
xcopy "%cd%\MaaResource-main\cache" "%cd%\cache"  /s /y /i
xcopy "%cd%\MaaResource-main\resource" "%cd%\resource"  /s /y /i

del /s /q .\MaaResource-main.zip
rd /s /q MaaResource-main

:update_maa_ota
@echo off
setlocal enabledelayedexpansion

:: 使用PowerShell下载页面内容并提取版本号
echo 正在获取版本信息，请稍候...
powershell -Command "$html = (Invoke-WebRequest -Uri 'https://ota.maa.plus/MaaAssistantArknights/MaaRelease/releases/download/' -UseBasicParsing).Content; $html -split '\n' | ForEach-Object { if ($_ -match 'href=\"(v\d+\.\d+\.\d+)/\"') { $matches[1] } } | Where-Object { $_ -notmatch 'beta' } | Sort-Object { [version]($_.Substring(1)) } -Descending | Select-Object -First 2" > versions.txt

:: 检查是否成功获取版本信息
if not exist versions.txt (
    echo 无法获取版本信息，请检查网络连接
    exit /b 1
)

:: 读取版本号
set /p version1=<versions.txt
set /a line=1
for /f "skip=1 delims=" %%i in (versions.txt) do (
    set /a line+=1
    if !line! equ 2 set "version2=%%i"
)

:: 验证获取到的版本号
if not defined version2 (
    echo 找不到足够的非beta版本
    del versions.txt
    exit /b 1
)

:: 生成下载链接
set "download_url=https://ota.maa.plus/MaaAssistantArknights/MaaRelease/releases/download/%version1%/MAAComponent-OTA-%version2%_%version1%-win-x64.zip"

:: 显示结果
echo.
echo 最新稳定版:       %version1%
echo 上一个稳定版:    %version2%
echo 生成下载地址:     %download_url%
echo.

:: 清理临时文件
del versions.txt

endlocal & set "download_url=%download_url%"

echo. [下载] %download_url%
%Curl_Download% -o "MAAComponent-OTA-win-x64.zip" "%download_url%"

:: x解压，v显示所有过程，f使用档案名字，切记，这个参数是最后一个参数
tar -xvf .\MAAComponent-OTA-win-x64.zip

del /s /q .\MAAComponent-OTA-win-x64.zip
goto :eof

:end
timeout /t 3 /nobreak