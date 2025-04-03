:: 2025.04.01

@echo off
setlocal enabledelayedexpansion

goto :test_fastest_ghmirror

:compare_speed
if "%~2"=="" exit /b
set "speed=%~2"
:: ��ȡ��������
for /f "tokens=1 delims=." %%i in ("!speed!") do set "int_speed=%%i"
if "!int_speed!"=="" set "int_speed=0"
if !int_speed! gtr !fastest_speed! (
    set "fastest_speed=!int_speed!"
    set "fastest_proxy=%~1"
)
exit /b

:test_fastest_ghmirror
:: �������Ӻ;����б�
:: ������Դ��Github ��ǿ - ��������
set "test_url=Jackchows/Cangjie5/raw/master/largefile.zip"
set "proxies=ghproxy.monkeyray.net,hub.gitmirror.com,ghproxy.cfd,github.boki.moe, gh.jasonzeng.dev, gh.monlor.com, fastgit.cc, mirrors.chenby.cn, gh.chjina.com, gh-proxy.ygxz.in"

:: ��ʼ������¼
set "fastest_proxy="
set "fastest_speed=0"

:: �����ŷָ��ľ����б�ת��Ϊ�ո�ָ�
set "proxies=!proxies:,= !"

:: ����ÿ������
for %%p in (!proxies!) do (
    echo ���Ծ���վ��: %%p
    set "current_speed=0"
    for /f "tokens=*" %%t in ('curl --max-time 20 -o tempfile -s -w "%%{speed_download}" "https://%%p/%test_url%" 2^>NUL ^|^| echo 0') do (
        set "current_speed=%%t"
    )
    del tempfile
    echo  �����ٶ�: !current_speed! �ֽ�/��
    call :compare_speed %%p !current_speed!
)

:: ������
echo ------------------------
echo ���ľ���վ����: !fastest_proxy! (�����ٶ� !fastest_speed! �ֽ�/��)
set "GH_PROXY=https://!fastest_proxy!"
endlocal & set "GH_PROXY=%GH_PROXY%"
echo GH_PROXY=%GH_PROXY%
