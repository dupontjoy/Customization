::2023.07.11

@echo off

Title ������������
color 0a
cls

::�O�ó����ļ��Aλ��
cd /d %~dp0
::������������λ�õ�Software�ļ���,������3��
set SoftDir=..\..\..\Software


::�ȴ�һ��ʱ��
timeout /t 5 /nobreak


::�ӳ�����
start "" "%SoftDir%\..\..\PyBingWallpaper\BingWallpaper.exe"
start "" "%SoftDir%\..\..\Tencent\Foxmail\Foxmail.exe"
start "" "%SoftDir%\..\..\Tencent\WeChat\WeChat.exe"


::������˳�
exit
