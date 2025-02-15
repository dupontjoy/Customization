::2025.02.15

::界面颜色大小，Cols为宽，Lines为高
COLOR 0a

:Profiles
rem 設置備份路徑以及臨時文件夾
@echo 定时启动Listary时，清除日志和临時文件

::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::跳转到Listary6文件夹
cd ..\..\

::终止一些进程
taskkill /f /t /im Listary*

::删除日志和临时文件
del  /s /q "%cd%\UserProfile\Cache"

::等待一段时间
timeout /t 3 /nobreak

::管理员方式启动程序
mshta vbscript:createobject("shell.application").shellexecute("""%cd%\Listary.exe""","::",,"runas",1)(window.close)

exit
