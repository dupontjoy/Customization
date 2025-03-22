::2021.08.14

@echo off
::保存為ASNI編碼


::备份部分开始
Title 備份批處理整合版 by Cing
::界面大小，Cols为宽，Lines为高
COLOR 0a
MODE con: COLS=90 LINES=25
cls

cd /d %~dp0


::設置臨時文件夾
set TempFolder="D:\Temp"
set TargetFolder="D:"


::設置Profiles上傳地址
set "TargetFolder1=E:\My Documents\Nutstore\NutStoreSync\Firefox\Profiles"


:Profiles
cls
@echo off
CALL "%~dp0Modules\Profiles-Files.cmd"
CALL "%~dp0Modules\Profiles-Zip.cmd"
call :when_done
@echo.
Goto eof


:when_done
::下载完成暂停一段时间关闭窗口，防止运行报错时直接关闭窗口。
:when_done
timeout /t 3 /nobreak


goto :eof