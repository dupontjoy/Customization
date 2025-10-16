::2025.04.25

@echo off

::界面颜色大小，Cols为宽，Lines为高
COLOR 0a


:settings
rem 設置路徑
@echo 定时启动maa时，先终止运行中的maa，断开adb连接

pushd %~dp0

::从批处理所在文件夹到ProgramFiles文件夹,共跨了1层
set "MAA=MAA.exe"

:start
::adb断连
start /b "" cmd /c "cd /d %cd%\..\MuMuPlayer\nx_device\12.0\shell && adb disconnect 127.0.0.1:16384&exit"
start /b "" cmd /c "cd /d %cd%\..\MuMuPlayer\nx_main && adb disconnect 127.0.0.1:16384&exit"
start /b "" cmd /c "cd /d %cd%\adb\platform-tools && adb disconnect 127.0.0.1:16384&exit"

::终止一些进程
taskkill /f /t /im adb.exe
taskkill /f /t /im maa*
taskkill /f /t /im mumu*

::删除几个无用的文件
del /s /q "%cd%\compact_log.txt"
del /s /q "%cd%\MaaResource_update.log"
del /s /q "%cd%\main.zip"

::启动MAA
start "" "%MAA%"

:: 完成后退出
exit