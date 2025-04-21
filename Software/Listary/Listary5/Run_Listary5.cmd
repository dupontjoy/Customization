::2023.07.13

::界面颜色大小，Cols为宽，Lines为高
COLOR 0a

:Profiles
rem 設置備份路徑以及臨時文件夾
@echo 定时启动Listary时，清除日志和临時文件

cd /d %~dp0

::从批处理所在位置到ProgramFiles文件夹,共跨了1层
set Listary=..\Listary.exe


::终止一些进程
taskkill /f /t /im Listary*

::Listary五代
::删除日志和临时文件
del  /s /q "listary_log.log"
del  /s /q "*.tmp"

::管理员方式启动程序
mshta vbscript:createobject("shell.application").shellexecute("""%Listary%""","::",,"runas",1)(window.close)

:end
timeout /t 3 /nobreak