
@echo off
:: 默认程序关联配置备份与恢复工具
:: 创建时间：2025-05-09
:: 作者：当贝AI助手

::=======================================
:: 初始化配置
::=======================================
pushd "%~dp0"

setlocal
set "config_path=%cd%\CustomFileAssoc.xml"

:menu
cls
echo 默认程序关联配置工具
echo ======================
echo.
echo 1. 导出当前默认程序关联配置
echo 2. 导入默认程序关联配置
echo 3. 退出
echo.
set /p choice=请选择操作(1/2/3):

if "%choice%"=="1" goto export
if "%choice%"=="2" goto import
if "%choice%"=="3" exit /b

echo 无效选择，请重新输入
pause
goto menu

:export
echo 正在导出默认程序关联配置...
Dism /online /export-defaultappassociations:"%config_path%"
if %errorlevel% equ 0 (
    echo 导出成功！配置文件已保存到:
    echo %config_path%
) else (
    echo 导出失败，错误代码: %errorlevel%
)
pause
goto menu

:import
echo 正在导入默认程序关联配置...
Dism /online /import-defaultappassociations:"%config_path%"
if %errorlevel% equ 0 (
    echo 导入成功！配置文件为:
    echo %config_path%
) else (
    echo 导入失败，错误代码: %errorlevel%
)
pause
goto menu