::2025.02.26

@echo off

title һ������MaaResource

::�����С��ColsΪ��LinesΪ��
COLOR 0a
cls

pushd %~dp0

:: ���ع�������
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"
set "GH_PROXY=https://gh-proxy.com"

echo. downloading MaaResource
%Curl_Download% -O %GH_PROXY%/https://github.com/MaaAssistantArknights/MaaResource/archive/refs/heads/main.zip

:: x��ѹ��v��ʾ���й��̣�fʹ�õ������֣��мǣ�������������һ������
tar -xvf .\MaaResource-main.zip
xcopy "%cd%\MaaResource-main\cache" "%cd%\cache"  /s /y /i
xcopy "%cd%\MaaResource-main\resource" "%cd%\resource"  /s /y /i

del /s /q .\MaaResource-main.zip
rd /s /q MaaResource-main

