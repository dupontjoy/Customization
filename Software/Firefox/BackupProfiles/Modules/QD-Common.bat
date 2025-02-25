::2025.01.22

@echo off

Title 批量启动程序
color 0a
cls


::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::从批处理所在位置到Software文件夹,共跨了3层
cd ..\..\..\Software

::删除firefox配置文件夹误生成的cache文件夹
rd /s /q "%cd%\..\Profiles\FxProfiles\cache2"

::删除N_m3u8DL-RE下载失败的缓存和日志
rd /s /q "%cd%\N_m3u8DL-RE\cache"
rd /s /q "%cd%\N_m3u8DL-RE\Logs"

::管理员启动
mshta vbscript:createobject("shell.application").shellexecute("""%cd%\RimeIME Portable\weasel\WeaselServer.exe""","::",,"runas",1)(window.close)

::普通啟動
start "" "%cd%\..\..\PyBingWallpaper\BingWallpaper.exe"
start  "" "%cd%\TrafficMonitor\TrafficMonitor.exe"
start  "" "%cd%\PixPin\PixPin.exe"
::start  "" "%cd%\Snipaste\Snipaste.exe"
start  "" "%cd%\Ditto\Ditto.exe"
start "" "%cd%\..\..\Tencent\Weixin\Weixin.exe"

::启动程序
::Listary5代
::start  "" "%cd%\Listary Pro\UserData\Run_listary.bat"

::Listary6代
start  "" "%cd%\Listary6\UserProfile\Settings\Run_Listary6.bat"

::启動Foxmail
start "" "%cd%\..\..\Tencent\Foxmail\Foxmail.exe"
REM 等待Foxmail完全启动，可根据需要调整等待时间
timeout /t 5 /nobreak >nul
:: 使用PowerShell脚本关闭Foxmail的主窗口但不终止进程
powershell -command "& {$app = Get-Process -Name Foxmail; if ($app) { $app.CloseMainWindow() | Out-Null } else { Write-Host 'Foxmail is not running.' }}"

::跳转到Capslock+文件夹
cd .\Capslock+\
start  "" "%cd%\Capslock+_v3.3.0.exe"