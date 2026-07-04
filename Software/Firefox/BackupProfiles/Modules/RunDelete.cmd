::2026.01.17

@echo off
Title 批量启动程序
color 0a
cls

::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::从批处理所在位置到Software文件夹,共跨了3层
cd ..\..\..\Software


:delete
::删除D:\Temp文件夹
rd /s /q "D:\Temp"

::删除firefox配置文件夹误生成的cache2文件夹
rd /s /q "%cd%\..\Profiles\FxProfiles\cache2"

::删除docbox的缓存数据
rd /s /q "C:\Users\%USERNAME%\AppData\Roaming\DocBox"

::删除calibre的缓存数据
rd /s /q "C:\Users\%USERNAME%\Calibre 书库\.caltrash"

::删除一些软件的log文件
rd /s /q "C:\ProgramData\Anytxt\log"
rd /s /q "C:\ProgramData\Winhance\Logs"
rd /s /q "C:\ProgramData\Thunder Network\Logs"
rd /s /q "C:\ProgramData\Nutstore\logs"

::删除ztasker User文件夹中的无用文件
rd /s /q "%cd%\zTasker\User\Backup"
rd /s /q "%cd%\zTasker\User\Custom"
rd /s /q "%cd%\zTasker\User\Logs"
rd /s /q "%cd%\zTasker\User\TasksBackup"
rd /s /q "%cd%\zTasker\User\Temp"

::删除FoxmailUpdate文件夹, 有可能导致foxmail无法启动
rd /s /q "%cd%\..\..\Tencent\Foxmail\FoxmailUpdate"

::清空文件夹，但不会删除文件夹本身
del /s /q /f "C:\Users\%USERNAME%\Downloads\*"

::清理WinSxS，存储了Windows操作系统更新和补丁后的备份文件
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase