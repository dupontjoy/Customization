::2025.02.27

::界面颜色大小，Cols为宽，Lines为高
COLOR 0a

:Profiles
rem 設置備份路徑以及臨時文件夾
@echo 定时启动Listary时，清除日志和临時文件


::必须使用pushd+cd方式获取并保存路径的方式启動，相對路径的動作和命令才能生效
::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::跳转到Listary6文件夹
cd ..\..\

::终止一些进程
taskkill /f /t /im Listary*

::删除日志和临时文件
rd /s /q "%cd%\UserProfile\Cache"
del /s /q "%cd%\UserProfile\Settings\PathHistory.json"
del /s /q "%cd%\UserProfile\Settings\SearchHistory.json"

::启动程序
start "" "%cd%\Listary.exe"

:end
timeout /t 3 /nobreak

exit