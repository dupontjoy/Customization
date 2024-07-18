::2023.08.22

@echo off

title 一键更新foobox

::界面大小，Cols为宽，Lines为高
COLOR 0a
cls

pushd %~dp0

:: Set download command
set Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs

:: Set 7zr command
set Extract=7zr.exe -y x

:: start updating
call :download_7zr
call :update_foobox
call :end
goto :eof

:download_7zr
:: Download portable 7zip
echo. downloading 7zr
%Download% -O https://www.7-zip.org/a/7zr.exe

:download_foobox
:: Download latest foobox
setlocal EnableDelayedExpansion
set "instance=0"

for /f "tokens=1,* delims=:" %%A in ('curl -ks https://api.github.com/repos/dream7180/foobox-cn/releases/latest ^| find "foobox_"') do (
    set /a instance+=1
    if !instance! == 2 (
    	echo. downloading foobox.7z
        %Download% -o "%cd%\foobox.7z" %%B
    )
)

:: 删除旧版foobox文件
rd /s /q "%cd%\profile"
rd /s /q "%cd%\themes"

:: 解压新版foobox文件
%Extract% .\foobox.7z

:: 复制到指定位置
xcopy "%cd%\foobar2000\profile" "%cd%\profile"  /s /y /i
xcopy "%cd%\foobar2000\themes" "%cd%\themes"  /s /y /i
rd /s /q "%cd%\foobar2000"

goto :eof

:end
timeout /t 5 /nobreak
