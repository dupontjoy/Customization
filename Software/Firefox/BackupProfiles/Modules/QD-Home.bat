::2025.02.05

@echo off

Title 批量启动程序
color 0a
cls

::設置程序文件夾位置
cd /d %~dp0
::从批处理所在位置到Software文件夹,共跨了3层
set SoftDir=..\..\..\Software


::启動Foxmail
start "" "%SoftDir%\..\..\Tencent\Foxmail\Foxmail.exe"
REM 等待Foxmail完全启动，可根据需要调整等待时间
timeout /t 3 /nobreak >nul
:: 使用PowerShell脚本关闭Foxmail的主窗口但不终止进程
powershell -command "& {$app = Get-Process -Name Foxmail; if ($app) { $app.CloseMainWindow() | Out-Null } else { Write-Host 'Foxmail is not running.' }}"

::普通启动
start "" "%SoftDir%\..\..\PyBingWallpaper\BingWallpaper.exe"
start "" "%SoftDir%\..\..\Tencent\Weixin\Weixin.exe"

::完成後退出
exit
