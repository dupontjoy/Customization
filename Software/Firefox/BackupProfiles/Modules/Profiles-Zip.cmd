@echo off
Title 打包Firefox配置(仅必要文件) by Cing
color 0a
cls
setlocal enabledelayedexpansion

:: 打包操作
:Profiles-zip

:: 日期时间处理（修复08:00格式问题）
set "YY=%date:~0,4%"
set /a "YY_HD=YY + 2697"
set "MON=%date:~5,2%"
set "DD=%date:~8,2%"
set "t_hh=%time:~0,2%"
set /a "t_hh=1!t_hh! - 100" 2>nul
if "!t_hh!"=="-99" set "t_hh=00"
if !t_hh! LSS 10 set "t_hh=0!t_hh!"
set "hh=!t_hh!"
set "mm=%time:~3,2%"
set "ss=%time:~6,2%"

:: 生成压缩包文件名（强制无空格）
set "Name=FxProfiles_(%YY_HD%)%YY%.%MON%%DD%.%hh%%mm%_%ver%.7z"

:: 压缩操作（路径严格引号包裹）
"%zip%" -mx9 -mhc -ms -mmt -mfb=273 -r u "%TargetFolder%\!Name!" "%TempFolder%\Profiles\BackupProfiles" "%TempFolder%\Profiles\FxProfiles" "%TempFolder%\Profiles\Run"

:: 确保目标文件夹存在（修复引号嵌套）
if not exist "%TargetFolder1%" (
    echo 创建目标文件夹: "%TargetFolder1%"
    mkdir "%TargetFolder1%"
)

:: 保留最新2个旧压缩包（增强删除逻辑）
set "keep=2"
set "count=0"
for /f "delims=" %%F in ('dir /b /o-d "%TargetFolder1%\FxProfiles_*.7z" 2^>nul') do (
    set /a count+=1
    if !count! gtr %keep% (
        echo [删除旧文件] "%%F"
        del /f /q "%TargetFolder1%\%%F" >nul 2>&1
    )
)

:: 移动新压缩包（修复路径拼接）
:: move /Y "%TargetFolder%\!Name!" "%TargetFolder1%\!Name!" >nul 2>&1

:: 清理临时文件夹
timeout /t 3 /nobreak
rd /s /q "%TempFolder%"
Remove-Item -Path $env:TempFolder -Recurse -Force -ErrorAction SilentlyContinue

@echo 備份完成！保留最近%keep%個版本，新包位置: "%TargetFolder1%\!Name!"
endlocal

