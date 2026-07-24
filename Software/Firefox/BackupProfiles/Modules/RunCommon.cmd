::2026.01.17

@echo off
Title 批量启动程序
color 0a
cls

::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::从批处理所在位置到Software文件夹,共跨了3层
cd ..\..\..\Software


:run

:listary
::Listary5代
::start  "" "%cd%\Listary5\UserData\Runlistary5.cmd"

::Listary7代
::需要获取完整路径才行
set "listary7_dir=%cd%\Listary7"
start "" /D "%listary7_dir%" "%listary7_dir%\UserProfile\Settings\RunListary7.cmd"

:run
::普通啟動，start 会启动一个新窗口并在其中运行命令
start "" "%cd%\RimeIMEPortable\weasel\WeaselServer.exe"
start "" "%cd%\ProcessLassoPro\RunProcessLasso.cmd"
::start "" "%cd%\..\..\PyBingWallpaper\BingWallpaper.exe"
start "" "%cd%\BingWallpaperDesktop\BingWallpaperDesktop.exe"
start "" "%cd%\TrafficMonitor\TrafficMonitor.exe"
start "" "%cd%\Ditto\Ditto.exe"
start "" "%cd%\PixPin\PixPin.exe"
::start "" "%cd%\Snipaste\Snipaste.exe"

:capslock
::需要获取完整路径才行
set "capslock_dir=%cd%\Capslock+"
start "" /D "%capslock_dir%" "%capslock_dir%\Capslock+_v3.3.0.exe"

:foxmail
::启動Foxmail后，关闭Foxmail的主窗口但不终止进程
start "" "%cd%\..\..\Tencent\Foxmail\Foxmail.exe"
REM 等待Foxmail完全启动，可根据需要调整等待时间
timeout /t 8 /nobreak >nul
:: 使用PowerShell脚本关闭Foxmail的主窗口但不终止进程
powershell -command "& {$app = Get-Process -Name Foxmail; if ($app) { $app.CloseMainWindow() | Out-Null } else { Write-Host 'Foxmail is not running.' }}"

:weixin
::启動微信并点击登录
start "" "%cd%\..\..\Tencent\Weixin\Weixin.exe"

REM 等待微信界面加载（时间可根据实际情况调整）
timeout /t 8 /nobreak >nul

REM 生成临时VBS脚本模拟键盘操作
echo Set WshShell = CreateObject("WScript.Shell") > click.vbs
echo WshShell.AppActivate "微信" >> click.vbs
echo WScript.Sleep 500 >> click.vbs
echo WshShell.SendKeys "{ENTER}" >> click.vbs

REM 执行脚本并清理
cscript //nologo click.vbs
del click.vbs
