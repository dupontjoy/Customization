::2024.09.29

@echo off

Title 批量启动程序
color 0a
cls

::設置程序文件夾位置
cd /d %~dp0
::从批处理所在位置到Software文件夹,共跨了3层
set SoftDir=..\..\..\Software

::删除firefox配置文件夹误生成的cache文件夹
rd /s /q "%SoftDir%\..\Profiles\CingProfiles\cache2"

::删除N_m3u8DL-RE下载失败的缓存和日志
rd /s /q "%SoftDir%\N_m3u8DL-RE\cache"
rd /s /q "%SoftDir%\N_m3u8DL-RE\Logs"

::普通啟動
::start  "" "%SoftDir%\PixPin\PixPin.exe"
start  "" "%SoftDir%\Snipaste\Snipaste.exe"
start  "" "%SoftDir%\Ditto\Ditto.exe"
start  "" "%SoftDir%\ProcessLassoPro\_Start-ProcessLasso.bat"


timeout /t 5 /nobreak

::启动程序
::Listary5代
start  "" "%SoftDir%\Listary Pro\UserData\Run_listary.bat"

::Listary6代
::start  "" "%SoftDir%\Listary 6\listary.exe"

::管理员启动
mshta vbscript:createobject("shell.application").shellexecute("""%SoftDir%\RimeIME Portable\weasel\WeaselServer.exe""","::",,"runas",1)(window.close)
