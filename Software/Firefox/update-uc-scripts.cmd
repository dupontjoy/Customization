:: 2025.04.01

@echo off

title 一键更新Firefox uc脚本 和 customCSS样式
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
CALL "%cd%\..\..\..\BackupProfiles\Modules\test_fastest_ghmirror.cmd"

::=======================================
:: 主流程
::=======================================
:menu
call :updating_uc
call :updating_flashgot
call :updating_customCSS
call :end
goto :eof

::=======================================
:: 子程序：更新UC脚本
::=======================================
:updating_uc
setlocal enabledelayedexpansion
echo.&echo █ 正在更新UC脚本...

:: 生成下载列表
(
echo %GH_PROXY%/https://github.com/benzBrake/userChrome.js-Loader/archive/refs/heads/main.zip
echo %GH_PROXY%/https://raw.githubusercontent.com/benzBrake/Firefox-downloadPlus.uc.js/main/downloadPlus_Fx136.uc.js
) > urls.tmp

:: 批量下载文件
for /f "delims=" %%a in (urls.tmp) do (
    set "raw_url=%%a"
    set "safe_url=!raw_url:&=^&!"
    set "safe_url=!safe_url:<=^<!"
    set "safe_url=!safe_url:>=^>!"
    
    :: 提取文件名
    for /f "tokens=1 delims=?" %%U in ("!raw_url!") do (
        for %%P in ("%%~nxU") do (
            set "filename=%%~nxP"
            set "filename=!filename:%%20= !"
        )
    )
    
    echo [下载] "!filename!"
    powershell -Command "$url='!safe_url!'; $outfile='!filename!'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile($url, $outfile)"
)

:: 解压fx100zip并移动到指定文件夹
:: x解压，v显示所有过程，f使用档案名字，切记，这个参数是最后一个参数
tar -xvf .\main.zip
xcopy "%cd%\userChrome.js-Loader-main\profile\chrome\userChromeJS" "%cd%\..\userChromeJS"  /s /y /i
xcopy "%cd%\userChrome.js-Loader-main\profile\chrome\utils" "%cd%\..\utils"  /s /y /i
xcopy "%cd%\userChrome.js-Loader-main\profile\chrome\userChrome.js" "%cd%\..\"  /s /y /i
xcopy "%cd%\userChrome.js-Loader-main\program\defaults" "%cd%\..\..\..\..\Firefox\defaults"  /s /y /i
xcopy "%cd%\userChrome.js-Loader-main\program\config.js" "%cd%\..\..\..\..\Firefox\"  /s /y /i
rd /s /q "%cd%\userChrome.js-Loader-main"

:: del /s /q .\main.zip

del urls.tmp
endlocal
goto :eof

::=======================================
:: 子程序：更新FlashGot
::=======================================
:updating_flashgot
setlocal enabledelayedexpansion
echo.&echo █ 正在更新FlashGot...

set "save_path=..\UserTools\flashgot.exe"
if not exist "..\UserTools\" md "..\UserTools"

%Curl_Download% -o "%save_path%" "%GH_PROXY%/https://github.com/benzBrake/Firefox-downloadPlus.uc.js/releases/latest/download/flashgot.exe"
endlocal
goto :eof

::=======================================
:: 子程序：更新CustomCSS
::=======================================
:updating_customCSS
setlocal enabledelayedexpansion
echo.&echo █ 正在更新CustomCSS...

:: GitHub API 地址和文件名匹配模式
set "api_url=https://api.github.com/repos/Aris-t2/CustomCSSforFx/releases/latest"
set "file_pattern=custom_css_for_fx_.*\.zip"

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
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%download_url%' -OutFile '%cd%\..\CustomCSSforFx_Latest.zip' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: 清理临时文件
del download_url.tmp 2>nul
endlocal


:: 删除旧版customCSS文件
rd /s /q "%cd%\..\config"
rd /s /q "%cd%\..\css"
rd /s /q "%cd%\..\image"
del /s /q "%cd%\..\userChrome.css"
del /s /q "%cd%\..\userContent.css"

pushd %~dp0
cd ..\
:: 解压新版customCSS文件
tar -xvf .\CustomCSSforFx_Latest.zip
:: del /s /q .\CustomCSSforFx_Latest.zip
popd

goto :eof

:end
timeout /t 3 /nobreak