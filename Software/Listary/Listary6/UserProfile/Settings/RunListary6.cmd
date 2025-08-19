::2025.02.27

::界面颜色大小，Cols为宽，Lines为高
COLOR 0a

:Profiles
rem 設置備份路徑以及臨時文件夾
@echo 定时启动Listary时，清除日志和临時文件

:: === 修改点：使用原生CMD命令最小化当前窗口 ===
if not defined _MINIMIZED_ (
    set "_MINIMIZED_=1"
    start /min cmd /c "%~f0"
    exit
)

::必须使用pushd+cd方式获取并保存路径的方式启動，相對路径的動作和命令才能生效
::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::跳转到Listary6文件夹
cd ..\..\

::终止一些进程
taskkill /f /t /im Listary*

::删除日志和临时文件
rd /s /q "%cd%\UserProfile\Cache"

::启动程序
start "" "%cd%\Listary.exe"

:end
timeout /t 3 /nobreak