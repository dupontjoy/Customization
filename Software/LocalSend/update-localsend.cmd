:: 2025.03.19

@echo off
setlocal enabledelayedexpansion

title һ������localsend
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


:test_fastest_ghmirror
CALL "%cd%\..\CingFox\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"

::=======================================
:: ������
::=======================================
:menu
call :updating_localsend
call :end
exit /b


::=======================================
:: �ӳ���
::=======================================
:updating_localsend
setlocal
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

::��ѹ
tar -xvf .\localsend-latest.zip

::=======================================
:: ��������
::=======================================
:end
echo.&echo �� ��������ɣ�5����Զ��ر�...
timeout /t 5 /nobreak
exit /b