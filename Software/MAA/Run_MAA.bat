::2025.02.27

@echo off

::界面颜色大小，Cols为宽，Lines为高
COLOR 0a

:: 最小化当前窗口
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

:settings
rem 設置路徑
@echo 定时启动maa时，先终止运行中的maa，断开adb连接

pushd %~dp0

::从批处理所在位置到ProgramFiles文件夹,共跨了1层
set MAA=MAA.exe
set Player=..\MuMuPlayer\shell\MuMuPlayer.exe


:start
::终止一些进程
taskkill /f /t /im maa*
taskkill /f /t /im mumu*


::adb断连
start /b "" cmd /c "cd /d %~dp0\..\MuMuPlayer\shell && adb disconnect 127.0.0.1:16384&exit"
start /b "" cmd /c "cd /d %~dp0\adb\platform-tools&&adb disconnect 127.0.0.1:16384&exit"

::删除debug文件夹（保存了各种截图和日志），和几个无用的文件
rd /s /q "%cd%\debug"
del /s /q "%cd%\compact_log.txt"
del /s /q "%cd%\filelist.txt"
del /s /q "%cd%\MaaResource_update.log"

::启动MAA
mshta vbscript:createobject("shell.application").shellexecute("""%MAA%""","::",,"runas",1)(window.close)

::启动模拟器
mshta vbscript:createobject("shell.application").shellexecute("""%Player%""","::",,"runas",1)(window.close)

:: 等待模拟器启动（根据电脑性能调整等待时间）
timeout /t 3 /nobreak

:: 创建临时VBS脚本执行最小化操作
echo Set WshShell = CreateObject("WScript.Shell") > minimize.vbs
echo WshShell.AppActivate "MuMuPlayer" >> minimize.vbs
echo WshShell.SendKeys "%% " >> minimize.vbs
echo WshShell.SendKeys "n" >> minimize.vbs

:: 执行VBS脚本并删除临时文件
start /wait minimize.vbs
del minimize.vbs
