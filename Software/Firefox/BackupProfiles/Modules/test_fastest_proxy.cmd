@echo off

goto :test_fastest_proxy
 
:compare_time
if "%~2"=="" exit /b
setlocal
set "time=%~2"
:: 移除可能的逗号（某些区域设置使用逗号作小数点）
set "time=!time:,=.!"
:: 浮点数比较需要特殊处理
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
:: 定义测试链接
set "test_url=https://github.com/Jackchows/Cangjie5/raw/master/README.md"

:: 定义镜像站点列表
set "proxies=gh-proxy.com ghproxy.net"

:: 初始化变量
set "fastest_proxy="
set "fastest_time=9999.999"

:: 循环测试每个镜像站点
for %%p in (%proxies%) do (
    echo 测试镜像站点: %%p
    for /f "tokens=*" %%t in ('curl --max-time 20 -o NUL -s -w "%%{time_total}" "https://%%p/%test_url%" 2^>^&1 ^|^| echo 9999') do (
        set "current_time=%%t"
        echo  耗时: !current_time! 秒
        call :compare_time %%p !current_time!
    )
)

:: 输出结果
echo ------------------------
echo 最快的镜像站点是: %fastest_proxy%
set "GH_PROXY=https://%fastest_proxy%"
echo GH_PROXY=%GH_PROXY%