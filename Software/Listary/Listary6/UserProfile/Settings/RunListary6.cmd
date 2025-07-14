::2025.02.27

::界面颜色大小，Cols为宽，Lines为高
COLOR 0a

:Profiles
rem 設置備份路徑以及臨時文件夾
@echo 定时启动Listary时，清除日志和临時文件

:: 最小化当前窗口
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

::必须使用pushd+cd方式获取并保存路径的方式启動，相對路径的動作和命令才能生效
::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::跳转到Listary6文件夹
cd ..\..\

::终止一些进程
taskkill /f /t /im Listary*

::删除日志和临时文件
rd /s /q "%cd%\UserProfile\Cache"

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

::管理员方式启动程序
mshta vbscript:createobject("shell.application").shellexecute("""%cd%\Listary.exe""","::",,"runas",1)(window.close)

:end
timeout /t 3 /nobreak