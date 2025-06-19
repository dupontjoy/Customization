::2023.07.13

::界面颜色大小，Cols为宽，Lines为高
COLOR 0a

:Profiles
rem 設置備份路徑以及臨時文件夾
@echo 定时启动Listary时，清除日志和临時文件

cd /d %~dp0

::从批处理所在位置到Listary.exe文件夹,共跨了1层
set Listary=..\Listary.exe


::终止一些进程
taskkill /f /t /im Listary*

::Listary五代
::删除日志和临时文件
del  /s /q "*.log"
del  /s /q "*.tmp"

::禁止Listary*.exe联网，防止激活码被检测失效
:: 直接请求管理员权限（不依赖VBScript）
if not "%1"=="admin" (
    fltmc >nul 2>&1 || (
        echo 正在请求管理员权限...
        PowerShell Start -WindowStyle Hidden -Verb RunAs -FilePath "cmd.exe" -ArgumentList "/c cd /d ""%cd%"" & ""%~f0"" admin"
        exit
    )
)

:: 管理员权限下执行
echo 已获得管理员权限！
echo 当前目录文件列表：
dir Listary*.exe /b

:: 遍历并添加规则
for %%f in (Listary*.exe) do (
    echo 正在阻止: %%f
    netsh advfirewall firewall delete rule name="Block_%%~nf" 2>nul
    netsh advfirewall firewall add rule name="Block_%%~nf" dir=out action=block program="%%~ff" enable=yes
)

::等待一段时间
timeout /t 3 /nobreak

::管理员方式启动程序
mshta vbscript:createobject("shell.application").shellexecute("""%Listary%""","::",,"runas",1)(window.close)

exit
