@echo off

goto :test_fastest_proxy
 
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

:test_fastest_proxy
:: �����������
set "test_url=https://github.com/Jackchows/Cangjie5/raw/master/README.md"

:: ���徵��վ���б�
set "proxies=gh-proxy.com ghproxy.net"

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