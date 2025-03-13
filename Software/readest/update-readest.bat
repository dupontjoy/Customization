:: 2025.02.28

@echo off
setlocal enabledelayedexpansion

title һ������readest portable
COLOR 0A
cls

::=======================================
:: ��ʼ������
::=======================================
pushd "%~dp0"

:: ���ع�������
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"


:test_fastest_proxy
:: �����������
set "test_url=https://github.com/Jackchows/Cangjie5/raw/master/README.md"

:: ���徵��վ���б�
set "proxies=gh-proxy.com ghfast.top ghproxy.net github.moeyy.xyz"

:: ��ʼ������
set "fastest_proxy="
set "fastest_time=9999.999"

:: ѭ������ÿ������վ��
for %%p in (%proxies%) do (
    echo ���Ծ���վ��: %%p
    for /f "tokens=*" %%t in ('curl --max-time 20 -o NUL -s -w "%%{time_total}" "https://%%p/%test_url%" 2^>^&1 ^|^| echo 9999') do (
        set "current_time=%%t"
        echo  ��ʱ: !current_time! ��
        call :compare_time %%p !current_time!
    )
)

:: ������
echo ------------------------
echo ���ľ���վ����: %fastest_proxy%
set "GH_PROXY=https://%fastest_proxy%"
echo GH_PROXY=%GH_PROXY%
goto :menu

:compare_time
if "%~2"=="" exit /b
setlocal
set "time=%~2"
:: �Ƴ����ܵĶ��ţ�ĳЩ��������ʹ�ö�����С���㣩
set "time=!time:,=.!"
:: �������Ƚ���Ҫ���⴦��
set /a int_time=!time:.=! 
set /a int_fastest=!fastest_time:.=!

if !int_time! lss !int_fastest! (
    endlocal
    set "fastest_time=%~2"
    set "fastest_proxy=%~1"
) else (
    endlocal
)
exit /b

::=======================================
:: ������
::=======================================
:menu
call :updating_readest
call :end
exit /b


::=======================================
:: �ӳ��򣺸���CustomCSS
::=======================================
:updating_readest
setlocal
echo.&echo �� ���ڸ���readest...

:: ��ȡ�ű�����·��
set "script_dir=%~dp0"
set "target_dir=%script_dir%..\"

:: GitHub API ��ַ���ļ���ƥ��ģʽ
set "api_url=https://api.github.com/repos/readest/readest/releases/latest"
set "file_pattern=Readest_.*x64-portable\.exe"

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
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%download_url%' -OutFile '%cd%\Readest-portable.exe' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: ������ʱ�ļ�
del download_url.tmp 2>nul



::=======================================
:: ��������
::=======================================
:end
echo.&echo �� ��������ɣ�5����Զ��ر�...
timeout /t 5 /nobreak
exit /b