@echo off
setlocal enabledelayedexpansion

:testGHmirror
:: 测试链接和镜像列表
:: 镜像来源：Github 增强 - 高速下载
set "test_url=Jackchows/Cangjie5/raw/master/largefile.zip"
set "proxies=gh.nxnow.top, gh.zwy.one, ghpxy.hwinzniej.top, fastgit.cc, github.boki.moe, cors.isteed.cc"

:: 初始化最快记录
set "fastest_proxy="
set "fastest_speed=0"
set "second_proxy="
set "second_speed=0"
set "third_proxy="
set "third_speed=0"

:: 将逗号分隔的镜像列表转换为空格分隔
set "proxies=!proxies:,= !"

:: 计算镜像总数
set "total=0"
for %%p in (!proxies!) do set /a "total+=1"

:: 测试每个镜像
set "count=0"
for %%p in (!proxies!) do (
    set /a "count+=1"
    echo [!count!/!total!] 测试镜像站点: %%p
    set "current_speed=0"
    for /f "tokens=*" %%t in ('curl --max-time 20 -o tempfile -s -w "%%{speed_download}" "https://%%p/%test_url%" 2^>NUL ^|^| echo 0') do (
        set "current_speed=%%t"
    )
    del tempfile
    echo  下载速度: !current_speed! 字节/秒
    
    :: 更新前三名
    if !current_speed! gtr !fastest_speed! (
        set "third_speed=!second_speed!"
        set "third_proxy=!second_proxy!"
        set "second_speed=!fastest_speed!"
        set "second_proxy=!fastest_proxy!"
        set "fastest_speed=!current_speed!"
        set "fastest_proxy=%%p"
    ) else if !current_speed! gtr !second_speed! (
        set "third_speed=!second_speed!"
        set "third_proxy=!second_proxy!"
        set "second_speed=!current_speed!"
        set "second_proxy=%%p"
    ) else if !current_speed! gtr !third_speed! (
        set "third_speed=!current_speed!"
        set "third_proxy=%%p"
    )
)

:: 显示前三名
echo ------------------------
echo 最快的三个镜像站点:
echo 1. !fastest_proxy! (下载速度 !fastest_speed! 字节/秒)
echo 2. !second_proxy! (下载速度 !second_speed! 字节/秒)
echo 3. !third_proxy! (下载速度 !third_speed! 字节/秒)

:: 随机选择其中一个
set /a "random_index=%random% %% 3 + 1"
if !random_index! equ 1 (
    set "selected_proxy=!fastest_proxy!"
    set "selected_speed=!fastest_speed!"
) else if !random_index! equ 2 (
    set "selected_proxy=!second_proxy!"
    set "selected_speed=!second_speed!"
) else (
    set "selected_proxy=!third_proxy!"
    set "selected_speed=!third_speed!"
)

:: 输出结果
echo ------------------------
echo 随机选择的镜像站点是: !selected_proxy! (下载速度 !selected_speed! 字节/秒)
set "GH_PROXY=https://!selected_proxy!"
endlocal & set "GH_PROXY=%GH_PROXY%"
echo GH_PROXY=%GH_PROXY%

:end
timeout /t 3 /nobreak