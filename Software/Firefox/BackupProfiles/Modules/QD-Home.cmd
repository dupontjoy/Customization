::2025.02.05

@echo off

Title 批量启动程序
color 0a
cls

::設置程序文件夾位置
cd /d %~dp0
::从批处理所在位置到Software文件夹,共跨了3层
set SoftDir=..\..\..\Software

start "" "%SoftDir%\steamcommunity_302\steamcommunity_302.exe"

::完成後退出
exit
