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

:: x解压，v显示所有过程，f使用档案名字（这个参数放最后）
tar -xf .\MaaResource-main.zip
xcopy "%cd%\MaaResource-main\cache" "%cd%\cache"  /s /y /i
xcopy "%cd%\MaaResource-main\resource" "%cd%\resource"  /s /y /i

del /s /q .\MaaResource-main.zip
rd /s /q MaaResource-main

goto :eof

:update_maa_ota
setlocal enabledelayedexpansion

:: 配置参数
set "base_url=https://ota.maa.plus/MaaAssistantArknights/MaaRelease/releases/download"
set "version_file=maa_versions.txt"
set "output_file=MAAComponent-OTA-win-x64.zip"

:: 获取最新两个稳定版版本号
echo 正在获取MAA最新两个稳定版版本信息...
powershell -Command "$html = (Invoke-WebRequest -Uri '%base_url%/' -UseBasicParsing).Content; [regex]::Matches($html, 'href=\""(v\d+\.\d+\.\d+)/\""') | %% { $_.Groups[1].Value } | Where-Object { $_ -notmatch 'beta' } | Sort-Object { [version]$_.Substring(1) } -Descending | Select-Object -First 2" > new_versions.tmp

:: 检查版本获取结果
if not exist new_versions.tmp (
    echo 错误：版本信息获取失败
    exit /b 1
)

:: 读取新版本号
set "new_v1="
set "new_v2="
set /a line=0
for /f "delims=" %%i in (new_versions.tmp) do (
    set /a line+=1
    if !line! equ 1 set "new_v1=%%i"
    if !line! equ 2 set "new_v2=%%i"
)

:: 清理版本号中的特殊字符
for /f "delims=" %%a in ("%new_v1%") do set "new_v1=%%a"
for /f "delims=" %%a in ("%new_v2%") do set "new_v2=%%a"

:: 验证版本号格式
if "%new_v1:~0,1%" neq "v" (
    echo 错误：无效版本格式：%new_v1%
    del new_versions.tmp
    exit /b 1
)

:: 读取旧版本号
set "old_v1="
set "old_v2="
if exist "%version_file%" (
    set /a line=0
    for /f "delims=" %%i in (%version_file%) do (
        set /a line+=1
        if !line! equ 1 set "old_v1=%%i"
        if !line! equ 2 set "old_v2=%%i"
    )
)

:: 版本对比逻辑
if defined old_v1 (
    if "%new_v1%%new_v2%" == "%old_v1%%old_v2%" (
        echo 当前已是最新版本（%old_v2% → %old_v1%）
        del new_versions.tmp
        exit /b 0
    )
    echo 发现新版本：
    echo 旧版本：%old_v2% → %old_v1%
    echo 新版本：%new_v2% → %new_v1%
) else (
    echo 首次下载版本：%new_v2% → %new_v1%
)

:: 生成下载链接
set "download_url=%base_url%/%new_v1%/MAAComponent-OTA-%new_v2%_%new_v1%-win-x64.zip"

:: 执行下载
echo 正在下载新版本...
%Curl_Download% --output "%output_file%" "%download_url%"
if errorlevel 1 (
    echo 错误：文件下载失败
    del new_versions.tmp
    exit /b 1
)

:: 更新版本记录（原子操作）
move /y new_versions.tmp "%version_file%" >nul 2>&1

:: 验证更新结果
if exist "%version_file%" (
    echo 版本记录已更新：
    type "%version_file%"
    echo 文件已保存为：%output_file%
) else (
    echo 错误：版本文件更新失败
    exit /b 1
)

endlocal

:: 解压
tar -xf .\MAAComponent-OTA-win-x64.zip
del /s /q .\MAAComponent-OTA-win-x64.zip

goto :eof

:end
timeout /t 3 /nobreak