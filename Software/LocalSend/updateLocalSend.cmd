:: 2025.03.19

@echo off
title һ������localsend
COLOR 0A
cls

:: === �޸ĵ㣺ʹ��ԭ��CMD������С����ǰ���� ===
if not defined _MINIMIZED_ (
    set "_MINIMIZED_=1"
    start /min cmd /c "%~f0"
    exit
)

::=======================================
:: ��ʼ������
::=======================================
pushd "%~dp0"

:: ���ع�������
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

:: �汾�ļ�
set "version_file=versions_localsend.txt"
::=======================================
:: ������
::=======================================
:menu
call :testGHmirror
call :check_version
if "%need_update%"=="1" (
    call :update_localsend
    call :unzip_localsend
    (echo|set /p="%latest_version%") > "%version_file%"
    echo �Ѹ��µ����°汾: %latest_version%
) else (
    echo ��ǰ�������°汾: %latest_version%���������
    del download_url.tmp 2>nul
)
call :end
goto :eof

::=======================================
:: �ӳ���
::=======================================
:testGHmirror
CALL "%cd%\..\CingFox\Profiles\BackupProfiles\Modules\testGHmirror.cmd"
goto :eof

:check_version
setlocal enabledelayedexpansion
echo.&echo �� ���ڼ��localsend�汾...

:: GitHub API ��ַ
set "api_url=https://api.github.com/repos/localsend/localsend/releases/latest"

:: ��ȡ���°汾���r��
for /f %%i in ('powershell -Command "(Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json).published_at"') do (
    set "latest_version=%%i"
)
echo ���߰汾: %latest_version%

:: ��ȡ���ذ汾���r��
set "local_version="
if exist "%version_file%" (
    for /f "usebackq delims=" %%i in ("%version_file%") do (
        set "local_version=%%i"
    )
)
echo ���ذ汾: %local_version%

:: �Ƚϰ汾
if "%latest_version%"=="%local_version%" (
    set "need_update=0"
) else (
    set "need_update=1"
)
echo �汾�ȽϽ��: %need_update%

endlocal & set "need_update=%need_update%" & set "latest_version=%latest_version%"
goto :eof

:update_localsend
setlocal enabledelayedexpansion
echo.&echo �� ���ڸ���localsend...

:: GitHub API ��ַ���ļ���ƥ��ģʽ
set "api_url=https://api.github.com/repos/localsend/localsend/releases/latest"
set "file_pattern=localsend-.*-windows-x86-64\.zip"

:: ʹ�� PowerShell ������������
powershell -Command "$response = Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json; $asset = $response.assets | Where-Object { $_.name -match '%file_pattern%' } | Select-Object -First 1; if ($asset) { $asset.browser_download_url } else { exit 1 }" > download_url.tmp

:: ����Ƿ��ȡ����������
if %errorlevel% neq 0 (
    echo δ�ҵ�ƥ����ļ�
    del download_url.tmp 2>nul
    exit /b 1
)

:: ��ȡ�������Ӳ���Ӿ������
set /p original_url=<download_url.tmp
set "download_url=%GH_PROXY%/%original_url%"

:: �����ļ�
echo [����] %download_url%
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%download_url%' -OutFile '%cd%\localsend-latest.zip' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: ������ʱ�ļ�
del download_url.tmp 2>nul
endlocal
goto :eof

:unzip_localsend
::��ѹ
tar -xf .\localsend-latest.zip
del /s /q .\localsend-latest.zip

goto :eof

::=======================================
:: ��������
::=======================================
:end
timeout /t 3 /nobreak
