::2025.10.23
::ע��Q�з������ǣ�windows��CR+LF��

Title ��װϵͳ��ָ�һЩ���������
::������ɫ��С��ColsΪ��LinesΪ��
color 0a
cls


::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

::�O���ļ�����λ��
set "SettingsDir=E:\My Documents\Nutstore\NutStoreSync"

:abdm
robocopy "%SettingsDir%\Customization\Software\ABDM\config" "C:\Users\Cing\.abdm\config" /MIR /ZB /R:3 /W:5

:anytxt
robocopy "%SettingsDir%\Customization\Software\Anytxt\config" "C:\ProgramData\Anytxt\config" /MIR /ZB /R:3 /W:5

:clashverge
xcopy "%SettingsDir%\Customization\Software\ClashVerge\profiles.yaml" "C:\Users\%USERNAME%\AppData\Roaming\io.github.clash-verge-rev.clash-verge-rev\" /y
xcopy "%SettingsDir%\Customization\Software\ClashVerge\verge.yaml" "C:\Users\%USERNAME%\AppData\Roaming\io.github.clash-verge-rev.clash-verge-rev\" /y

:gitextension
xcopy "%SettingsDir%\Customization\Software\GitExtensions\.gitconfig" "C:\Users\%USERNAME%\" /y

:LXmusicDesktop
robocopy "%SettingsDir%\Customization\Software\LXmusic\LxDatas" "C:\Users\%USERNAME%\AppData\Roaming\lx-music-desktop\LxDatas" /MIR /ZB /R:3 /W:5

:zlib
::zlib��������
xcopy "%SettingsDir%\Customization\Software\z-library\config.json" "C:\Users\%USERNAME%\AppData\Roaming\z-library\" /y

:end
timeout /t 3 /nobreak >nul
exit