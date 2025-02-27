::2025.02.26

@echo off

title update mpv scripts
color 0a

pushd %~dp0

::ɾ��mpv����
echo. delete cache
rd /s /q "%cd%\cache"

:: Set download command
set Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs

:: start updating
call :updating_scripts
call :updating_uosc
call :updating_yt-dlp
call :updating_mpv
call :updating_ffmpeg
call :unzip_mpv_ffmpeg
call :end
goto :eof

:updating_scripts
setlocal enabledelayedexpansion

:: ����Ŀ¼����������ڣ�
mkdir scripts 2>nul
mkdir script-opts 2>nul

:: ����Ҫ���ص�URLд����ʱ�ļ�
(
echo https://gh-proxy.com/https://raw.githubusercontent.com/mpv-player/mpv/master/TOOLS/lua/autoload.lua
echo https://gh-proxy.com/https://raw.githubusercontent.com/dyphire/mpv-config/master/scripts/quality-menu.lua
echo https://gh-proxy.com/https://raw.githubusercontent.com/Eisa01/mpv-scripts/master/scripts/SmartCopyPaste.lua
echo https://gh-proxy.com/https://raw.githubusercontent.com/FinnRaze/mpv-stats-zh/master/stats.lua
echo https://gh-proxy.com/https://raw.githubusercontent.com/dyphire/mpv-config/master/script-opts/quality-menu.conf
echo https://gh-proxy.com/https://raw.githubusercontent.com/Eisa01/mpv-scripts/master/script-opts/SmartCopyPaste.conf
echo https://gh-proxy.com/https://raw.githubusercontent.com/dyphire/mpv-config/master/script-opts/stats.conf
echo https://gh-proxy.com/https://raw.githubusercontent.com/dyphire/mpv-config/master/script-opts/uosc.conf
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
goto :eof

:updating_uosc
echo. downloading uosc.zip
%Download% -o "%cd%\uosc.zip" https://gh-proxy.com/https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip

:: ɾ���ɰ�uosc�ļ�
:: rd /s /q "%cd%\scripts\uosc"

:: ��ѹ
echo. extracting uosc.zip
tar -xvf .\uosc.zip
goto :eof

:updating_yt-dlp
:: Download latest yt-dlp
echo. downloading yt-dlp.exe
%Download% -o "%cd%\..\yt-dlp.exe" https://gh-proxy.com/https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
goto :eof

:updating_mpv
setlocal enabledelayedexpansion

:: ��ȡ�ű�����·��
set "script_dir=%~dp0"
set "target_dir=%script_dir%..\"

:: GitHub API ��ַ���ļ���ƥ��ģʽ
set "api_url=https://api.github.com/repos/zhongfly/mpv-winbuild/releases/latest"
set "mpv_file_pattern=mpv-x86_64.*\.7z"

:: ʹ�� PowerShell ������������
powershell -Command "$response = Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json; $asset = $response.assets | Where-Object { $_.name -match '%mpv_file_pattern%' } | Select-Object -First 1; if ($asset) { $asset.browser_download_url } else { exit 1 }" > mpv_download_url.tmp

:: ����Ƿ��ȡ����������
if %errorlevel% neq 0 (
    echo δ�ҵ�ƥ����ļ�
    del mpv_download_url.tmp 2>nul
    exit /b 1
)

:: ��ȡ�������Ӳ���Ӿ������
set /p mpv_original_url=<mpv_download_url.tmp
set "mpv_download_url=https://gh-proxy.com/%mpv_original_url%"

:: �����ļ�
echo ��������: %mpv_download_url%
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%mpv_download_url%' -OutFile 'mpv-x86_64_Latest.7z' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: �ƶ��ļ����ϼ�Ŀ¼
if exist "mpv-x86_64_Latest.7z" (
    echo �����ƶ��ļ����ϼ�Ŀ¼...
    move /Y "mpv-x86_64_Latest.7z" "%target_dir%" >nul
    echo �ļ�����λ��: "%target_dir%mpv-x86_64_Latest.7z"
) else (
    echo �����ļ�����ʧ��
    exit /b 1
)

:: ������ʱ�ļ�
del mpv_download_url.tmp 2>nul
goto :eof

:updating_ffmpeg
setlocal enabledelayedexpansion

:: ��ȡ�ű�����·��
set "script_dir=%~dp0"
set "target_dir=%script_dir%..\"

:: GitHub API ��ַ���ļ���ƥ��ģʽ
set "api_url=https://api.github.com/repos/zhongfly/mpv-winbuild/releases/latest"
set "ffmpeg_file_pattern=ffmpeg-x86_64-git.*\.7z"

:: ʹ�� PowerShell ������������
powershell -Command "$response = Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json; $asset = $response.assets | Where-Object { $_.name -match '%ffmpeg_file_pattern%' } | Select-Object -First 1; if ($asset) { $asset.browser_download_url } else { exit 1 }" > ffmpeg_download_url.tmp

:: ����Ƿ��ȡ����������
if %errorlevel% neq 0 (
    echo δ�ҵ�ƥ����ļ�
    del ffmpeg_download_url.tmp 2>nul
    exit /b 1
)

:: ��ȡ�������Ӳ���Ӿ������
set /p ffmpeg_original_url=<ffmpeg_download_url.tmp
set "ffmpeg_download_url=https://gh-proxy.com/%ffmpeg_original_url%"

:: �����ļ�
echo ��������: %ffmpeg_download_url%
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%ffmpeg_download_url%' -OutFile 'ffmpeg-x86_64-git_Latest.7z' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: �ƶ��ļ����ϼ�Ŀ¼
if exist "ffmpeg-x86_64-git_Latest.7z" (
    echo �����ƶ��ļ����ϼ�Ŀ¼...
    move /Y "ffmpeg-x86_64-git_Latest.7z" "%target_dir%" >nul
    echo �ļ�����λ��: "%target_dir%ffmpeg-x86_64-git_Latest.7z"
) else (
    echo �����ļ�����ʧ��
    exit /b 1
)

:: ������ʱ�ļ�
del ffmpeg_download_url.tmp 2>nul
goto :eof

:unzip_mpv_ffmpeg
:: ��ѹ�ļ�
pushd %~dp0
cd ..\
set zip=7z\7zr.exe
:: ��ѹ�°�mpv�ļ�
%zip% x -y -aoa -sccUTF-8 -scsWIN .\mpv-x86_64_Latest.7z
:: ��ѹ�°�ffmpeg�ļ�
%zip% x -y -aoa -sccUTF-8 -scsWIN .\ffmpeg-x86_64-git_Latest.7z
:: del /s /q .\mpv-x86_64_Latest.7z
:: del /s /q .\ffmpeg-x86_64-git_Latest.7z

popd

goto :eof


:end
timeout /t 3 /nobreak
