::2025.02.26

@echo off
setlocal enabledelayedexpansion

title һ������MaaResource

::�����С��ColsΪ��LinesΪ��
COLOR 0a
cls

pushd %~dp0

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
goto :update_MaaResource

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

:update_MaaResource
echo. downloading MaaResource
%Curl_Download% -O %GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip

:: x��ѹ��v��ʾ���й��̣�fʹ�õ������֣��мǣ�������������һ������
tar -xvf .\MaaResource-main.zip
xcopy "%cd%\MaaResource-main\cache" "%cd%\cache"  /s /y /i
xcopy "%cd%\MaaResource-main\resource" "%cd%\resource"  /s /y /i

del /s /q .\MaaResource-main.zip
rd /s /q MaaResource-main

