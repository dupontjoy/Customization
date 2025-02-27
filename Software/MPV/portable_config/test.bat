@echo off
setlocal enabledelayedexpansion

:: 创建目录（如果不存在）
mkdir scripts 2>nul
mkdir script-opts 2>nul

:: 将需要下载的URL写入临时文件
(
echo https://gh-proxy.com/https://raw.githubusercontent.com/mpv-player/mpv/master/TOOLS/lua/autoload.lua
echo https://gh-proxy.com/https://raw.githubusercontent.com/dyphire/mpv-config/master/scripts/quality-menu.lua
echo https://gh-proxy.com/https://raw.githubusercontent.com/dyphire/mpv-config/master/script-opts/quality-menu.conf
echo https://gh-proxy.com/https://raw.githubusercontent.com/Eisa01/mpv-scripts/master/script-opts/SmartCopyPaste.conf
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
echo 所有文件已分类下载完成
pause