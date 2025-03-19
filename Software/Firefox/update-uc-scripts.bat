:: 2025.02.28

@echo off
setlocal enabledelayedexpansion

title һ������Firefox uc�ű� �� customCSS��ʽ
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
set "proxies=gh-proxy.com ghproxy.net github.moeyy.xyz"

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
call :updating_uc
call :updating_flashgot
call :updating_customCSS
call :end
exit /b

::=======================================
:: �ӳ��򣺸���UC�ű�
::=======================================
:updating_uc
setlocal
echo.&echo �� ���ڸ���UC�ű�...

:: ���������б�
(
echo %GH_PROXY%/https://raw.githubusercontent.com/benzBrake/FirefoxCustomize/master/userChromeJS/Loader/fx100.zip
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
tar -xvf .\fx100.zip
xcopy "%cd%\profile\chrome\userChromeJS" "%cd%\..\userChromeJS"  /s /y /i
xcopy "%cd%\profile\chrome\utils" "%cd%\..\utils"  /s /y /i
xcopy "%cd%\profile\chrome\userChrome.js" "%cd%\..\"  /s /y /i
xcopy "%cd%\program\defaults" "%cd%\..\..\..\..\Firefox\defaults"  /s /y /i
xcopy "%cd%\program\config.js" "%cd%\..\..\..\..\Firefox\"  /s /y /i
rd /s /q "%cd%\profile"
rd /s /q "%cd%\program"

del urls.tmp
endlocal
exit /b

::=======================================
:: �ӳ��򣺸���FlashGot
::=======================================
:updating_flashgot
setlocal
echo.&echo �� ���ڸ���FlashGot...

set "save_path=..\UserTools\flashgot.exe"
if not exist "..\UserTools\" md "..\UserTools"

%Curl_Download% -o "%save_path%" "%GH_PROXY%/https://github.com/benzBrake/Firefox-downloadPlus.uc.js/releases/latest/download/flashgot.exe"
endlocal
exit /b

::=======================================
:: �ӳ��򣺸���CustomCSS
::=======================================
:updating_customCSS
setlocal
echo.&echo �� ���ڸ���CustomCSS...

:: ��ȡ�ű�����·��
set "script_dir=%~dp0"
set "target_dir=%script_dir%..\"

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
popd

goto :eof

::=======================================
:: ��������
::=======================================
:end
echo.&echo �� ��������ɣ�5����Զ��ر�...
timeout /t 5 /nobreak
exit /b