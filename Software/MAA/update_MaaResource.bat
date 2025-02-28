::2025.02.26

@echo off

title 一键更新MaaResource

::界面大小，Cols为宽，Lines为高
COLOR 0a
cls

pushd %~dp0

:: 下载工具配置
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"
set "GH_PROXY=https://gh-proxy.com"

echo. downloading MaaResource
%Curl_Download% -O %GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip

:: x解压，v显示所有过程，f使用档案名字，切记，这个参数是最后一个参数
tar -xvf .\MaaResource-main.zip
xcopy "%cd%\MaaResource-main\cache" "%cd%\cache"  /s /y /i
xcopy "%cd%\MaaResource-main\resource" "%cd%\resource"  /s /y /i

del /s /q .\MaaResource-main.zip
rd /s /q MaaResource-main

