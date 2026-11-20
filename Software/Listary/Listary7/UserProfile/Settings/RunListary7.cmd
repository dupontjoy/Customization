::2026.11.19

::界面颜色大小，Cols为宽，Lines为高
COLOR 0a

rem 設置備份路徑以及臨時文件夾
@echo 定时启动Listary时，清除日志和临時文件

::必须使用pushd+cd方式获取并保存路径的方式启動，相對路径的動作和命令才能生效
::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::跳转到Listary主文件夹
cd ..\..\

::终止一些进程
taskkill /f /t /im Listary*

:: 请求管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
::添加必要注册表项
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\listary\shell\open\command" /ve /t REG_SZ /d "%cd%\Listary.exe\" --url-schema=\"%%1\"" /f

::删除日志和临时文件
rd /s /q "%cd%\UserProfile\Cache"

::启动程序
start "" "%cd%\Listary.exe"

:end
timeout /t 3 /nobreak

exit