::2025.04.17

@echo off
Title 批量启动程序
color 0a
cls

::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::从批处理所在位置到Software文件夹,共跨了3层
cd ..\..\..\Software

:delete
::删除firefox配置文件夹误生成的cache2文件夹
rd /s /q "%cd%\..\Profiles\FxProfiles\cache2"

::删除N_m3u8DL-RE下载失败的缓存和日志
rd /s /q "%cd%\N_m3u8DL-RE\cache"
rd /s /q "%cd%\N_m3u8DL-RE\Logs"

::删除ztasker User文件夹中的无用文件
rd /s /q "%cd%\zTasker\User\Backup"
rd /s /q "%cd%\zTasker\User\Custom"
rd /s /q "%cd%\zTasker\User\Logs"
rd /s /q "%cd%\zTasker\User\pinyin.db"
rd /s /q "%cd%\zTasker\User\TasksBackup"
rd /s /q "%cd%\zTasker\User\Temp"


::删除FoxmailUpdate文件夹, 有可能导致foxmail无法启动
rd /s /q "%cd%\..\..\Tencent\Foxmail\FoxmailUpdate"

::清空文件夹，但不会删除文件夹本身
del /s /q /f "C:\Users\%USERNAME%\Downloads\*"
del /s /q /f "C:\Users\%USERNAME%\AppData\Local\Temp\*"

:run
:listary
::Listary5代
::start  "" "%cd%\Listary5\UserData\Run_listary5.cmd"

::Listary6代
::需要获取完整路径才行
pushd
call "%cd%\Listary6\UserProfile\Settings\Run_Listary6.cmd"
popd

::管理员启动WeaselServer.exe
mshta vbscript:createobject("shell.application").shellexecute("""%cd%\RimeIMEPortable\weasel\WeaselServer.exe""","::",,"runas",1)(window.close)

::普通啟動，start 会启动一个新窗口并在其中运行命令
start "" "%cd%\..\..\PyBingWallpaper\BingWallpaper.exe"
start  "" "%cd%\TrafficMonitor\TrafficMonitor.exe"
start  "" "%cd%\Ditto\Ditto.exe"
start  "" "%cd%\PixPin\PixPin.exe"
::start  "" "%cd%\Snipaste\Snipaste.exe"
start  "" "%cd%\ProcessLassoPro\_Start-ProcessLasso.cmd"

:foxmail
::启動Foxmail后，关闭Foxmail的主窗口但不终止进程
start "" "%cd%\..\..\Tencent\Foxmail\Foxmail.exe"
REM 等待Foxmail完全启动，可根据需要调整等待时间
timeout /t 10 /nobreak >nul
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


:capslock
::必须使用pushd+cd方式获取并保存路径的方式启動，相對路径的動作和命令才能生效
::必须跳转到Capslock+文件夹，启動時会生成配置文件
cd .\Capslock+\
start  "" "%cd%\Capslock+_v3.3.0.exe"
