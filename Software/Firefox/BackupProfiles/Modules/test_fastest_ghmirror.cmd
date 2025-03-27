@echo off
setlocal enabledelayedexpansion

goto :test_fastest_ghmirror

:compare_speed
if "%~2"=="" exit /b
set "speed=%~2"
:: 提取整数部分
for /f "tokens=1 delims=." %%i in ("!speed!") do set "int_speed=%%i"
if "!int_speed!"=="" set "int_speed=0"
if !int_speed! gtr !fastest_speed! (
    set "fastest_speed=!int_speed!"
    set "fastest_proxy=%~1"
)
exit /b

:test_fastest_ghmirror
:: 测试链接和镜像列表
:: 镜像来源：Github 增强 - 高速下载
set "test_url=Jackchows/Cangjie5/raw/master/largefile.zip"
set "proxies=gh-proxy.com,ghfast.top,ghproxy.1888866.xyz,gh.ddlc.top,hub.gitmirror.com,ghproxy.cfd,github.yongyong.online,github.boki.moe"

:: 初始化最快记录
set "fastest_proxy="
set "fastest_speed=0"

:: 将逗号分隔的镜像列表转换为空格分隔
set "proxies=!proxies:,= !"

:: 测试每个镜像
for %%p in (!proxies!) do (
    echo 测试镜像站点: %%p
    set "current_speed=0"
    for /f "tokens=*" %%t in ('curl --max-time 20 -o tempfile -s -w "%%{speed_download}" "https://%%p/%test_url%" 2^>NUL ^|^| echo 0') do (
        set "current_speed=%%t"
    )
    del tempfile
    echo  下载速度: !current_speed! 字节/秒
    call :compare_speed %%p !current_speed!
)

:: 输出结果
echo ------------------------
echo 最快的镜像站点是: !fastest_proxy! (下载速度 !fastest_speed! 字节/秒)
set "GH_PROXY=https://!fastest_proxy!"
endlocal & set "GH_PROXY=%GH_PROXY%"
echo GH_PROXY=%GH_PROXY%