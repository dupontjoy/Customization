:: 2025.04.01

@echo off

title һ������Firefox uc�ű� �� customCSS��ʽ
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
CALL "%cd%\..\..\..\BackupProfiles\Modules\test_fastest_ghmirror.cmd"

::=======================================
:: ������
::=======================================
:menu
call :updating_uc
call :updating_flashgot
call :updating_customCSS
call :end
goto :eof

::=======================================
:: �ӳ��򣺸���UC�ű�
::=======================================
:updating_uc
setlocal enabledelayedexpansion
echo.&echo �� ���ڸ���UC�ű�...

:: ���������б�
(
echo %GH_PROXY%/https://github.com/benzBrake/userChrome.js-Loader/archive/refs/heads/main.zip
echo %GH_PROXY%/https://raw.githubusercontent.com/benzBrake/Firefox-downloadPlus.uc.js/main/downloadPlus_Fx136.uc.js
) > urls.tmp

:: ���������ļ�
for /f "delims=" %%a in (urls.tmp) do (
    set "raw_url=%%a"
    set "safe_url=!raw_url:&=^&!"
    set "safe_url=!safe_url:<=^<!"
    set "safe_url=!safe_url:>=^>!"
    
    :: ��ȡ�ļ���
    for /f "tokens=1 delims=?" %%U in ("!raw_url!") do (
        for %%P in ("%%~nxU") do (
            set "filename=%%~nxP"
            set "filename=!filename:%%20= !"
        )
    )
    
    echo [����] "!filename!"
    powershell -Command "$url='!safe_url!'; $outfile='!filename!'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile($url, $outfile)"
)

:: ��ѹfx100zip���ƶ���ָ���ļ���
:: x��ѹ��v��ʾ���й��̣�fʹ�õ������֣��мǣ�������������һ������
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
:: �ӳ��򣺸���FlashGot
::=======================================
:updating_flashgot
setlocal enabledelayedexpansion
echo.&echo �� ���ڸ���FlashGot...

set "save_path=..\UserTools\flashgot.exe"
if not exist "..\UserTools\" md "..\UserTools"

%Curl_Download% -o "%save_path%" "%GH_PROXY%/https://github.com/benzBrake/Firefox-downloadPlus.uc.js/releases/latest/download/flashgot.exe"
endlocal
goto :eof

::=======================================
:: �ӳ��򣺸���CustomCSS
::=======================================
:updating_customCSS
setlocal enabledelayedexpansion
echo.&echo �� ���ڸ���CustomCSS...

:: GitHub API ��ַ���ļ���ƥ��ģʽ
set "api_url=https://api.github.com/repos/Aris-t2/CustomCSSforFx/releases/latest"
set "file_pattern=custom_css_for_fx_.*\.zip"

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
powershell -Command "$maxRetry=3; $retryCount=0; do { try { Invoke-WebRequest -Uri '%download_url%' -OutFile '%cd%\..\CustomCSSforFx_Latest.zip' -TimeoutSec 30; break } catch { $retryCount++; if ($retryCount -ge $maxRetry) { throw }; Start-Sleep -Seconds 5 } } while ($true)"

:: ������ʱ�ļ�
del download_url.tmp 2>nul
endlocal


:: ɾ���ɰ�customCSS�ļ�
rd /s /q "%cd%\..\config"
rd /s /q "%cd%\..\css"
rd /s /q "%cd%\..\image"
del /s /q "%cd%\..\userChrome.css"
del /s /q "%cd%\..\userContent.css"

pushd %~dp0
cd ..\
:: ��ѹ�°�customCSS�ļ�
tar -xvf .\CustomCSSforFx_Latest.zip
:: del /s /q .\CustomCSSforFx_Latest.zip
popd

goto :eof

:end
timeout /t 3 /nobreak