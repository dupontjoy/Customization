:: 2025.04.13

@echo off
title һ������imageglass
COLOR 0A
cls

:: ��С����ǰ����
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

::=======================================
:: ��ʼ������
::=======================================
pushd "%~dp0"

:: ���ع�������
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

:: �汾�ļ�
set "version_file=versions_imageglass.txt"

::=======================================
:: ������
::=======================================
:menu
call :test_fastest_ghmirror
call :check_version
if "%need_update%"=="1" (
    call :update_imageglass
    call :unzip_imageglass
    (echo|set /p="%latest_version%") > "%version_file%"
    echo �Ѹ��µ����°汾: %latest_version%
) else (
    echo ��ǰ�������°汾: %latest_version%���������
)
call :end
goto :eof

::=======================================
:: �ӳ���
::=======================================
:test_fastest_ghmirror
CALL "%cd%\..\..\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"
goto :eof

:check_version
setlocal enabledelayedexpansion
echo.&echo �� ���ڼ��ImageGlass�汾...

:: GitHub API ��ַ
set "api_url=https://api.github.com/repos/d2phap/ImageGlass/releases/latest"

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

:update_imageglass
setlocal enabledelayedexpansion
echo.&echo �� ���ڸ���imageglass...

:: GitHub API ��ַ���ļ���ƥ��ģʽ
set "api_url=https://api.github.com/repos/d2phap/ImageGlass/releases/latest"
set "file_pattern=ImageGlass_.*_x64\.zip"

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
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%download_url%' -OutFile '%cd%\imageglass-latest.zip' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: ������ʱ�ļ�
del download_url.tmp 2>nul
endlocal
goto :eof

:unzip_imageglass
setlocal enabledelayedexpansion

:: ��ѹimageglass������ѹ�����ĵ�һ��Ŀ¼(�����޶���Ŀ¼��ZIP�ļ�)
set "zipfile=imageglass-latest.zip"
set "tempdir=%cd%\unzip_temp"

:: ������ʱĿ¼����ѹ
mkdir "%tempdir%" 2>nul
tar -xf "%zipfile%" -C "%tempdir%"

:: �ж���ʱĿ¼���ݲ�����
set "hasSubdir=0"
for /d %%D in ("%tempdir%\*") do (
    set "hasSubdir=1"
    echo ���ڸ����ļ�...
    xcopy /s /e /h /y "%%D\*" ".\" >nul || (
        echo ����: �����ļ�ʧ��
        rmdir /s /q "%tempdir%" 2>nul
        pause
        exit /b 1
    )
)

if "!hasSubdir!"=="0" (
    echo ���ڸ����ļ�...
    xcopy /s /e /h /y "%tempdir%\*" ".\" >nul || (
        echo ����: �����ļ�ʧ��
        rmdir /s /q "%tempdir%" 2>nul
        pause
        exit /b 1
    )
)

:: ������ʱĿ¼
rmdir /s /q "%tempdir%" 2>nul
endlocal

del /s /q .\imageglass-latest.zip
goto :eof

::=======================================
:: ��������
::=======================================
:end
timeout /t 3 /nobreak
