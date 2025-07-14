::2025.05.10

@echo off
title һ������MaaResource

::�����С��ColsΪ��LinesΪ��
COLOR 0a
cls

:: ��С����ǰ����
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

pushd %~dp0

:: ���ع�������
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

::=======================================
:: ������
::=======================================
:menu
call :testGHmirror
call :update_maa_ota
call :update_MaaResource
call :end
goto :eof

::=======================================
:: �ӳ���
::=======================================
:testGHmirror
CALL "%cd%\..\CingFox\Profiles\BackupProfiles\Modules\testGHmirror.cmd"
goto :eof

:update_maa_ota
setlocal enabledelayedexpansion

:: ��ȡ���µ������汾��
echo. 
echo ��������MAA�汾...
for /f "tokens=1,2" %%a in ('powershell -command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $tags = (Invoke-RestMethod -Uri 'https://api.github.com/repos/MaaAssistantArknights/MaaRelease/releases').tag_name | Where-Object { $_ -match '^v\d+\.\d+\.\d+$' } | Sort-Object { [version]($_.Substring(1)) } -Descending; if ($tags.Count -ge 2) { write-output ($tags[1] + ' ' + $tags[0]) } else { exit 1 }"') do (
    set "version1=%%a"
    set "version2=%%b"
)
echo. �������߰汾: %version2%

:: ���汾�Ż�ȡ���
if not defined version1 (
    echo. δ��ȡ���汾��1.
    exit /b 1
)
if not defined version2 (
    echo. δ��ȡ���汾��2.
    exit /b 1
)

:: ��ȡ���ر���İ汾��
set "old_version1="
set "old_version2="
if exist versions_maa.txt (
    for /f "tokens=1,2" %%i in (versions_maa.txt) do (
        set "old_version1=%%i"
        set "old_version2=%%j"
    )
) else (
    set "old_version2=%version1%"
)
echo. ���ذ汾: %old_version2%

:: �Ƚϰ汾���Ƿ���ͬ
    if defined old_version2 (
        if "!old_version2!" == "%version2%" (
            echo. ��ǰ�������°汾��!version2!���������.
            exit /b 0
        )
    )

:: �����°汾
echo. 
echo. �����°汾: %old_version2% to %version2%
set "download_url=%GH_PROXY%/https://github.com/MaaAssistantArknights/MaaRelease/releases/download/%version2%/MAAComponent-OTA-%old_version2%_%version2%-win-x64.zip"
echo. [����] %download_url%

:: ʹ�� PowerShell �����ļ�
powershell -Command "Invoke-WebRequest -Uri '%download_url%' -OutFile 'MAAComponent-OTA-win-x64.zip' -ErrorAction Stop"
if errorlevel 1 (
    echo ����ʧ��.
    exit /b 1
)

:: �����°汾�ŵ��ļ�
echo. 
echo. %old_version2% %version2% > versions_maa.txt
echo. ������� �� �����°汾�ŵ��ļ�.

endlocal

:: ��ѹ
taskkill /f /t /im maa*
echo. 
echo. ��ѹMAAComponent-OTA-win-x64.zip ...
echo. 
tar -xf .\MAAComponent-OTA-win-x64.zip
del /s /q .\MAAComponent-OTA-win-x64.zip

goto :eof

:update_MaaResource
setlocal enabledelayedexpansion

:: GitHub API ��ַ
set "api_url=https://api.github.com/repos/MaaAssistantArknights/MaaResource/commits/main"

:: ʹ�� PowerShell ��ȡ�����ύ�r��
echo. 
echo ��ȡMaaResource�����ύ�r��...
for /f %%i in ('powershell -Command "(Invoke-WebRequest -Uri '%api_url%' -UseBasicParsing | ConvertFrom-Json).commit.committer.date"') do (
    set "last_date=%%i"
)
echo. ���������ύ�r��: %last_date%

:: ��ȡ���ر���İ汾��
set "local_date="
if exist versions_maaresource.txt (
    for /f "tokens=1,2" %%i in (versions_maaresource.txt) do (
        set "local_date=%%i"
    )
)
echo. ���ؕr��: %local_date%

:: �Ƚϰ汾���Ƿ���ͬ
    if defined local_date (
        if "!local_date!" == "%last_date%" (
            echo. ��ǰ�������°汾: %last_date%���������.
            exit /b 0
        )
    )

:: ������Դ
echo.
echo. [����] %GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip
%Curl_Download% -O %GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip

:: ���±��ؕr���ļ�
echo. 
(echo|set /p="%last_date%") > versions_maaresource.txt

echo ������ɣ��r���Ѹ���Ϊ��%last_date%
echo. 

:: x��ѹ��v��ʾ���й��̣�fʹ�õ������֣�������������
tar -xf .\MaaResource-main.zip
xcopy "%cd%\MaaResource-main\cache" "%cd%\cache"  /s /y /i
xcopy "%cd%\MaaResource-main\resource" "%cd%\resource"  /s /y /i

del /s /q .\MaaResource-main.zip
rd /s /q MaaResource-main

goto :eof

:end
timeout /t 3 /nobreak
