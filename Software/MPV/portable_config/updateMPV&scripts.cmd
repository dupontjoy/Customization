::2025.04.10

@echo off
title 一键更新MPV和脚本
color 0a


pushd %~dp0

::删除mpv缓存
echo. delete cache
rd /s /q "%cd%\cache"

:: 下载工具配置
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

::=======================================
:: 主流程
::=======================================
:menu
call :testGHmirror
call :updating_scripts
call :updating_uosc
call :updating_yt-dlp
call :updating_mpv
call :updating_ffmpeg
call :unzip_mpv_ffmpeg
call :end
goto :eof

::=======================================
:: 子程序
::=======================================
:testGHmirror
call "%cd%\..\..\..\Profiles\BackupProfiles\Modules\testGHmirror.cmd"
goto :eof

:updating_scripts
setlocal enabledelayedexpansion

:: 创建目录（如果不存在）
mkdir scripts 2>nul
mkdir script-opts 2>nul

:: 将需要下载的URL写入临时文件
(
echo %GH_PROXY%/https://raw.githubusercontent.com/mpv-player/mpv/master/TOOLS/lua/autoload.lua
echo %GH_PROXY%/https://raw.githubusercontent.com/dyphire/mpv-config/master/scripts/quality-menu.lua
echo %GH_PROXY%/https://raw.githubusercontent.com/Eisa01/mpv-scripts/master/scripts/SmartCopyPaste.lua
echo %GH_PROXY%/https://raw.githubusercontent.com/FinnRaze/mpv-stats-zh/master/stats.lua
echo %GH_PROXY%/https://raw.githubusercontent.com/dyphire/mpv-config/master/script-opts/quality-menu.conf
echo %GH_PROXY%/https://raw.githubusercontent.com/Eisa01/mpv-scripts/master/script-opts/SmartCopyPaste.conf
echo %GH_PROXY%/https://raw.githubusercontent.com/dyphire/mpv-config/master/script-opts/stats.conf
echo %GH_PROXY%/https://raw.githubusercontent.com/dyphire/mpv-config/master/script-opts/uosc.conf
rem 可以继续添加更多链接...
) > urls.tmp

for /f "delims=" %%a in (urls.tmp) do (
    set "raw_url=%%a"
    
    :: 转义特殊字符
    set "safe_url=!raw_url:&=^&!"
    set "safe_url=!safe_url:<=^<!"
    set "safe_url=!safe_url:>=^>!"
    
    :: 提取文件名并处理编码
    for /f "tokens=1 delims=?" %%U in ("!raw_url!") do (
        for %%P in ("%%~nxU") do (
            set "filename=%%~nxP"
            set "filename=!filename:%%20= !"
            set "filename=!filename:%%25=!"
            set "filename=!filename:%%2D=-!"
        )
    )
    
    :: 根据文件后缀判断目录
    for %%F in ("!filename!") do set "file_ext=%%~xF"
    if /i "!file_ext!"==".lua" (
        set "target_folder=scripts"
    ) else if /i "!file_ext!"==".conf" (
        set "target_folder=script-opts"
    ) else (
        set "target_folder=scripts"
        echo 未知文件类型 [!file_ext!] 默认保存到scripts目录
    )
    
    :: 使用PowerShell下载文件
    echo 正在下载到!target_folder!目录: "!filename!"
    powershell -Command "$url='!safe_url!'; $outfile='!target_folder!\!filename!'; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile($url, $outfile)"
)

:: 清理临时文件
del urls.tmp
endlocal

goto :eof

:updating_uosc
echo. [下载] %GH_PROXY%/https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip
%Curl_Download% -o "%cd%\uosc.zip" %GH_PROXY%/https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip

:: 删除旧版uosc文件
:: rd /s /q "%cd%\scripts\uosc"

:: 解压
echo. extracting uosc.zip
tar -xf .\uosc.zip
del /s /q .\uosc.zip

goto :eof

:updating_yt-dlp
:: Download latest yt-dlp
echo. [下载] %GH_PROXY%/https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
%Curl_Download% -o "%cd%\..\yt-dlp.exe" %GH_PROXY%/https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
goto :eof

:updating_mpv
setlocal enabledelayedexpansion

:: GitHub API 地址和文件名匹配模式
set "api_url=https://api.github.com/repos/zhongfly/mpv-winbuild/releases/latest"
set "mpv_file_pattern=mpv-x86_64.*\.7z"

:: 使用 PowerShell 解析下载链接
powershell -Command "$response = Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json; $asset = $response.assets | Where-Object { $_.name -match '%mpv_file_pattern%' } | Select-Object -First 1; if ($asset) { $asset.browser_download_url } else { exit 1 }" > mpv_download_url.tmp

:: 检查是否获取到下载链接
if %errorlevel% neq 0 (
    echo 未找到匹配的文件
    del mpv_download_url.tmp 2>nul
    exit /b 1
)

:: 读取下载链接并添加镜像代理
set /p mpv_original_url=<mpv_download_url.tmp
set "mpv_download_url=%GH_PROXY%/%mpv_original_url%"

:: 下载文件
echo 正在下载: %mpv_download_url%
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%mpv_download_url%' -OutFile '%cd%\..\mpv-x86_64_Latest.7z' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"


:: 清理临时文件
del mpv_download_url.tmp 2>nul
endlocal

goto :eof

:updating_ffmpeg
setlocal enabledelayedexpansion

:: GitHub API 地址和文件名匹配模式
set "api_url=https://api.github.com/repos/zhongfly/mpv-winbuild/releases/latest"
set "ffmpeg_file_pattern=ffmpeg-x86_64-git.*\.7z"

:: 使用 PowerShell 解析下载链接
powershell -Command "$response = Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json; $asset = $response.assets | Where-Object { $_.name -match '%ffmpeg_file_pattern%' } | Select-Object -First 1; if ($asset) { $asset.browser_download_url } else { exit 1 }" > ffmpeg_download_url.tmp

:: 检查是否获取到下载链接
if %errorlevel% neq 0 (
    echo 未找到匹配的文件
    del ffmpeg_download_url.tmp 2>nul
    exit /b 1
)

:: 读取下载链接并添加镜像代理
set /p ffmpeg_original_url=<ffmpeg_download_url.tmp
set "ffmpeg_download_url=%GH_PROXY%/%ffmpeg_original_url%"

:: 下载文件
echo 正在下载: %ffmpeg_download_url%
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%ffmpeg_download_url%' -OutFile '%cd%\..\ffmpeg-x86_64-git_Latest.7z' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: 清理临时文件
del ffmpeg_download_url.tmp 2>nul
endlocal

goto :eof

:unzip_mpv_ffmpeg
:: 解压文件
pushd %~dp0
cd ..\
set "zip=..\..\..\7-Zip\7z.exe"
:: 解压新版mpv文件
%zip% x -y -aoa -sccUTF-8 -scsWIN .\mpv-x86_64_Latest.7z
:: 解压新版ffmpeg文件
%zip% x -y -aoa -sccUTF-8 -scsWIN .\ffmpeg-x86_64-git_Latest.7z
del /s /q .\mpv-x86_64_Latest.7z
del /s /q .\ffmpeg-x86_64-git_Latest.7z

popd

goto :eof


:end
timeout /t 3 /nobreak
