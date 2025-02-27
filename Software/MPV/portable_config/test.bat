@echo off
setlocal enabledelayedexpansion

:: ����Ŀ¼����������ڣ�
mkdir scripts 2>nul
mkdir script-opts 2>nul

:: ����Ҫ���ص�URLд����ʱ�ļ�
(
echo https://gh-proxy.com/https://raw.githubusercontent.com/mpv-player/mpv/master/TOOLS/lua/autoload.lua
echo https://gh-proxy.com/https://raw.githubusercontent.com/dyphire/mpv-config/master/scripts/quality-menu.lua
echo https://gh-proxy.com/https://raw.githubusercontent.com/dyphire/mpv-config/master/script-opts/quality-menu.conf
echo https://gh-proxy.com/https://raw.githubusercontent.com/Eisa01/mpv-scripts/master/script-opts/SmartCopyPaste.conf
rem ���Լ�����Ӹ�������...
) > urls.tmp

for /f "delims=" %%a in (urls.tmp) do (
    set "raw_url=%%a"
    
    :: ת�������ַ�
    set "safe_url=!raw_url:&=^&!"
    set "safe_url=!safe_url:<=^<!"
    set "safe_url=!safe_url:>=^>!"
    
    :: ��ȡ�ļ������������
    for /f "tokens=1 delims=?" %%U in ("!raw_url!") do (
        for %%P in ("%%~nxU") do (
            set "filename=%%~nxP"
            set "filename=!filename:%%20= !"
            set "filename=!filename:%%25=!"
            set "filename=!filename:%%2D=-!"
        )
    )
    
    :: �����ļ���׺�ж�Ŀ¼
    for %%F in ("!filename!") do set "file_ext=%%~xF"
    if /i "!file_ext!"==".lua" (
        set "target_folder=scripts"
    ) else if /i "!file_ext!"==".conf" (
        set "target_folder=script-opts"
    ) else (
        set "target_folder=scripts"
        echo δ֪�ļ����� [!file_ext!] Ĭ�ϱ��浽scriptsĿ¼
    )
    
    :: ʹ��PowerShell�����ļ�
    echo �������ص�!target_folder!Ŀ¼: "!filename!"
    powershell -Command "$url='!safe_url!'; $outfile='!target_folder!\!filename!'; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile($url, $outfile)"
)

:: ������ʱ�ļ�
del urls.tmp
echo �����ļ��ѷ����������
pause