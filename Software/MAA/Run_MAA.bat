::2024.08.04

@echo off

::界面颜色大小，Cols为宽，Lines为高
COLOR 0a

:update_MaaResource


:settings
rem 設置路徑
@echo 定时启动maa时，先终止运行中的maa，断开adb连接

pushd %~dp0

::从批处理所在位置到ProgramFiles文件夹,共跨了1层
set MAA=MAA.exe
set Player=..\MuMuPlayer\shell\MuMuPlayer.exe
set nircmd=..\CingFox\Software\nircmd\nircmd.exe


:start
::终止一些进程
taskkill /f /t /im maa*
taskkill /f /t /im mumu*


::adb断连
start cmd /k "cd/d %~dp0\..\MuMuPlayer\shell&&adb disconnect 127.0.0.1:16384&exit"
start cmd /k "cd/d %~dp0\adb\platform-tools&&adb disconnect 127.0.0.1:16384&exit"

::删除debug文件夹，保存了各种截图和日志
rd /s /q "%cd%\debug"

::等待一段时间
timeout /t 3 /nobreak

::启动MAA
mshta vbscript:createobject("shell.application").shellexecute("""%MAA%""","::",,"runas",1)(window.close)

::等待一段时间
timeout /t 3 /nobreak

::启动模拟器
::mshta vbscript:createobject("shell.application").shellexecute("""%Player%""","::",,"runas",1)(window.close)
