::2023.07.11

@echo off

Title 批量启动程序
color 0a
cls

::設置程序文件夾位置
cd /d %~dp0
::从批处理所在位置到Software文件夹,共跨了3层
set SoftDir=..\..\..\Software


::等待一段时间
timeout /t 5 /nobreak


::延迟启动
start "" "%SoftDir%\..\..\PyBingWallpaper\BingWallpaper.exe"
start "" "%SoftDir%\..\..\Tencent\Foxmail\Foxmail.exe"
start "" "%SoftDir%\..\..\Tencent\WeChat\WeChat.exe"


::完成後退出
exit
