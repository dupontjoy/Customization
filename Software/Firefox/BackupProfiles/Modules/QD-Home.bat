::2025.02.05

@echo off

Title ������������
color 0a
cls

::�O�ó����ļ��Aλ��
cd /d %~dp0
::������������λ�õ�Software�ļ���,������3��
set SoftDir=..\..\..\Software


::���Foxmail
start "" "%SoftDir%\..\..\Tencent\Foxmail\Foxmail.exe"
REM �ȴ�Foxmail��ȫ�������ɸ�����Ҫ�����ȴ�ʱ��
timeout /t 3 /nobreak >nul
:: ʹ��PowerShell�ű��ر�Foxmail�������ڵ�����ֹ����
powershell -command "& {$app = Get-Process -Name Foxmail; if ($app) { $app.CloseMainWindow() | Out-Null } else { Write-Host 'Foxmail is not running.' }}"

::��ͨ����
start "" "%SoftDir%\..\..\PyBingWallpaper\BingWallpaper.exe"
start "" "%SoftDir%\..\..\Tencent\Weixin\Weixin.exe"

::������˳�
exit
