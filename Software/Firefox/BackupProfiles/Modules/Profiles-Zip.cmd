@echo off
Title 打包Firefox配置(仅必要文件)
color 0a
cls
setlocal enabledelayedexpansion

:: 打包操作
:Profiles-zip

:: 显示原始日期
echo 原始日期: [%date%]

:: 只提取数字
set "DATE_NUM=%date%"
:: 去除所有非数字字符
set "DATE_NUM=%DATE_NUM: =%"
set "DATE_NUM=%DATE_NUM:/=%"
set "DATE_NUM=%DATE_NUM:-=%"
set "DATE_NUM=%DATE_NUM:周一=%"
set "DATE_NUM=%DATE_NUM:周二=%"
set "DATE_NUM=%DATE_NUM:周三=%"
set "DATE_NUM=%DATE_NUM:周四=%"
set "DATE_NUM=%DATE_NUM:周五=%"
set "DATE_NUM=%DATE_NUM:周六=%"
set "DATE_NUM=%DATE_NUM:周日=%"
set "DATE_NUM=%DATE_NUM:星期一=%"
set "DATE_NUM=%DATE_NUM:星期二=%"
set "DATE_NUM=%DATE_NUM:星期三=%"
set "DATE_NUM=%DATE_NUM:星期四=%"
set "DATE_NUM=%DATE_NUM:星期五=%"
set "DATE_NUM=%DATE_NUM:星期六=%"
set "DATE_NUM=%DATE_NUM:星期日=%"

echo 数字部分: [!DATE_NUM!]

:: 提取年月日
if "!DATE_NUM:~4,1!"=="" (
    :: 2位年份: 260822 -> 2026年08月22日
    set "YY=20!DATE_NUM:~0,2!"
    set "MON=!DATE_NUM:~2,2!"
    set "DD=!DATE_NUM:~4,2!"
) else (
    :: 4位年份: 20260822
    set "YY=!DATE_NUM:~0,4!"
    set "MON=!DATE_NUM:~4,2!"
    set "DD=!DATE_NUM:~6,2!"
)

:: 去除可能的前导空格
set "YY=!YY: =!"
set "MON=!MON: =!"
set "DD=!DD: =!"

:: ===== 修正：补零时使用字符串比较，避免八进制问题 =====
:: 检查月份是否只有1位（如 "8" 而不是 "08"）
if "!MON:~0,1!"=="0" (
    :: 已经是两位（如 08），不需要补零
    rem 保持原样
) else (
    :: 检查是否小于10（数字比较，但避免八进制问题）
    set /a "MON_NUM=MON" 2>nul
    if !MON_NUM! LSS 10 set "MON=0!MON_NUM!"
)

:: 同样处理日期
if "!DD:~0,1!"=="0" (
    rem 已经是两位，保持原样
) else (
    set /a "DD_NUM=DD" 2>nul
    if !DD_NUM! LSS 10 set "DD=0!DD_NUM!"
)

echo 解析结果: YY=[!YY!], MON=[!MON!], DD=[!DD!]

:: 计算黄帝历年份
set /a "YY_HD=YY + 2697"

:: 处理时间
set "t_hh=%time:~0,2%"
set /a "t_hh=1!t_hh! - 100" 2>nul
if "!t_hh!"=="-99" set "t_hh=00"
if !t_hh! LSS 10 set "t_hh=0!t_hh!"
set "hh=!t_hh!"
set "mm=%time:~3,2%"
set "ss=%time:~6,2%"

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
move /Y "%TargetFolder%\!Name!" "%TargetFolder1%\!Name!" >nul 2>&1

:: 清理临时文件夹
timeout /t 3 /nobreak
rd /s /q "%TempFolder%"
:: 用powershell再删除一遍
powershell -Command "& {Remove-Item -Path '%TempFolder%' -Recurse -Force -ErrorAction SilentlyContinue; New-Item -Path '%TempFolder%' -ItemType Directory -Force | Out-Null}"

@echo 備份完成！保留最近%keep%個版本，新包位置: "%TargetFolder1%\!Name!"
endlocal

