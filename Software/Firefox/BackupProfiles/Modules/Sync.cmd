::2025.10.23
::ע��Q�з������ǣ�windows��CR+LF��

Title �����ļ����й���վ
::������ɫ��С��ColsΪ��LinesΪ��
color 0a
cls


::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

::�O���ļ�����λ��
::�������������ļ��е�Profiles�ļ��У�������2��
set "BackupDir=..\..\FxProfiles"
set "softDir=E:\Cing@Soft"
set "OutputDir=E:\My Documents\Nutstore\NutStoreSync"

:abdm
robocopy "C:\Users\Cing\.abdm\config" "%OutputDir%\Customization\Software\ABDM\config" /MIR /ZB /R:3 /W:5

:anytxt
robocopy "C:\ProgramData\Anytxt\config" "%OutputDir%\Customization\Software\Anytxt\config" /MIR /ZB /R:3 /W:5

:cangjie5
::�����ļ��Еr��Դ�ļ��в�Ҫ��б�ܣ�Ŀ���ļ��д�б�ܡ�ĩβд/s /y /i
::�����ļ��r��ĩβд/y
::Ŀ���usr���ܴ�б�ܡ�/MIR������ģʽ������ȫͬ��ԴĿ¼��Ŀ��Ŀ¼��������Ŀ¼���ļ���
robocopy "%BackupDir%\..\..\Software\RimeIMEPortable\usr" "%OutputDir%\RimeIMEPortable\usr" /MIR /ZB /R:3 /W:5
xcopy "%BackupDir%\..\..\Software\RimeIMEPortable\install.bat" "%OutputDir%\RimeIMEPortable\" /y
xcopy "%BackupDir%\..\..\Software\RimeIMEPortable\uninstall.bat" "%OutputDir%\RimeIMEPortable\" /y
xcopy "%BackupDir%\..\..\Software\RimeIMEPortable\readme.txt" "%OutputDir%\RimeIMEPortable\" /y


:capslock
::���Capslock+�O��
xcopy "%BackupDir%\..\..\Software\Capslock+\CapsLock+settings.ini" "%OutputDir%\Customization\Software\Capslock+\" /y

:CCleaner
xcopy "%BackupDir%\..\..\Software\CCleaner\ccleaner.ini" "%OutputDir%\Customization\Software\CCleaner\" /y

:clashverge
xcopy "C:\Users\%USERNAME%\AppData\Roaming\io.github.clash-verge-rev.clash-verge-rev\profiles.yaml" "%OutputDir%\Customization\Software\ClashVerge\" /y
xcopy "C:\Users\%USERNAME%\AppData\Roaming\io.github.clash-verge-rev.clash-verge-rev\verge.yaml" "%OutputDir%\Customization\Software\ClashVerge\" /y

:firefox
::��ݎׂ�Firefox�ļ�
::��ɾ���ɱ����ļ���
rd /s /q "%OutputDir%\Customization\Software\Firefox"
timeout /t 3 /nobreak
xcopy "%BackupDir%\user.js" "%OutputDir%\Customization\Software\Firefox\" /y
xcopy "%BackupDir%\bookmarks.html" "%OutputDir%\Customization\Software\Firefox\" /y
robocopy "%BackupDir%\bookmarkbackups" "%OutputDir%\Customization\Software\Firefox\bookmarkbackups" /MIR /ZB /R:3 /W:5
robocopy "%BackupDir%\chrome" "%OutputDir%\Customization\Software\Firefox\chrome" /MIR /ZB /R:3 /W:5
robocopy "%BackupDir%\..\BackupProfiles" "%OutputDir%\Customization\Software\Firefox\BackupProfiles" /MIR /ZB /R:3 /W:5

:foobar
xcopy "%BackupDir%\..\..\..\foobar2000\profile\config.sqlite" "%OutputDir%\Customization\Software\foobar2000\profile\" /y

:GitExtensions
xcopy "%BackupDir%\..\..\..\GitExtensions\GitExtensions.settings" "%OutputDir%\Customization\Software\GitExtensions\" /y
xcopy "C:\Users\%USERNAME%\.gitconfig" "%OutputDir%\Customization\Software\GitExtensions\" /y

:GoldenDict
xcopy "%BackupDir%\..\..\..\GoldenDict\portable\config" "%OutputDir%\Customization\Software\GoldenDict\" /y
xcopy "%BackupDir%\..\..\..\GoldenDict\updateGoldenDict.cmd" "%OutputDir%\Customization\Software\GoldenDict\" /y

:IDMan
xcopy "%BackupDir%\..\..\..\IDM\!)ѡ������.reg" "%OutputDir%\Customization\Software\IDMan\" /y

:ImageGlass
xcopy "%BackupDir%\..\..\Software\ImageGlass\igconfig.json" "%OutputDir%\Customization\Software\ImageGlass\" /y
xcopy "%BackupDir%\..\..\Software\ImageGlass\updateImageGlass.cmd" "%OutputDir%\Customization\Software\ImageGlass\" /y

:listary5
::���Listary 5�O��
xcopy "%BackupDir%\..\..\Software\Listary5\UserData\CopyFileName.vbs" "%OutputDir%\Customization\Software\Listary\Listary5\" /y
xcopy "%BackupDir%\..\..\Software\Listary5\UserData\Preferences.json" "%OutputDir%\Customization\Software\Listary\Listary5\" /y
xcopy "%BackupDir%\..\..\Software\Listary5\UserData\RunListary5.cmd" "%OutputDir%\Customization\Software\Listary\Listary5\" /y


:listary6
::���Listary 6�O��
xcopy "%BackupDir%\..\..\Software\Listary6\DataFolderRedirection.txt" "%OutputDir%\Customization\Software\Listary\Listary6\" /y
xcopy "%BackupDir%\..\..\Software\Listary6\UserProfile\Settings\CopyFileName.vbs" "%OutputDir%\Customization\Software\Listary\Listary6\UserProfile\Settings\" /y
xcopy "%BackupDir%\..\..\Software\Listary6\UserProfile\Settings\Preferences.json" "%OutputDir%\Customization\Software\Listary\Listary6\UserProfile\Settings\" /y
xcopy "%BackupDir%\..\..\Software\Listary6\UserProfile\Settings\RunListary6.cmd" "%OutputDir%\Customization\Software\Listary\Listary6\UserProfile\Settings\" /y

:localsend
xcopy "%BackupDir%\..\..\..\LocalSend\updateLocalSend.cmd" "%OutputDir%\Customization\Software\LocalSend\" /y

:LXmusicDesktop
xcopy "%BackupDir%\..\..\..\lx-music-desktop\updateLXmusicDesktop.cmd" "%OutputDir%\Customization\Software\LXmusic\" /y
robocopy "C:\Users\%USERNAME%\AppData\Roaming\lx-music-desktop\LxDatas" "%OutputDir%\Customization\Software\LXmusic\LxDatas" /MIR /ZB /R:3 /W:5

:MAA
xcopy "%BackupDir%\..\..\..\MAA\RunMAA.cmd" "%OutputDir%\Customization\Software\MAA\" /y
xcopy "%BackupDir%\..\..\..\MAA\updateMaaResource.cmd" "%OutputDir%\Customization\Software\MAA\" /y
xcopy "%BackupDir%\..\..\..\MAA\config\gui.json" "%OutputDir%\Customization\Software\MAA\" /y

:MPV
robocopy "%BackupDir%\..\..\Software\MPV\installer" "%OutputDir%\Customization\Software\MPV\installer" /MIR /ZB /R:3 /W:5
robocopy "%BackupDir%\..\..\Software\MPV\portable_config" "%OutputDir%\Customization\Software\MPV\portable_config" /MIR /ZB /R:3 /W:5
xcopy "%BackupDir%\..\..\Software\MPV\RunYT-dlp.cmd" "%OutputDir%\Customization\Software\MPV\" /y
xcopy "%BackupDir%\..\..\Software\MPV\README.md" "%OutputDir%\Customization\Software\MPV\" /y
xcopy "%BackupDir%\..\..\Software\MPV\yt-dlp.conf" "%OutputDir%\Customization\Software\MPV\" /y
xcopy "%BackupDir%\..\..\Software\MPV\settings.xml" "%OutputDir%\Customization\Software\MPV\" /y
::ɾ������Ҫ���ݵĲ��Ž���
rd /s /q "%OutputDir%\Customization\Software\MPV\portable_config\cache"
rd /s /q "%OutputDir%\Customization\Software\MPV\portable_config\watch_later"

:N_m3u8DL-RE
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\N_m3u8DL-RE.exe" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\RunNm3u8DLRE.cmd" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_ad_keyword.conf" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_common.conf" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_live_record.conf" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\README.md" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y

:Pixpin
::���Pixpin�O��
xcopy "%BackupDir%\..\..\Software\PixPin\Config\PixPinConfig.json" "%OutputDir%\Customization\Software\PixPin\Config\" /y

:Processlasso
robocopy "%BackupDir%\..\..\Software\ProcessLassoPro\config" "%OutputDir%\Customization\Software\ProcessLasso\config" /MIR /ZB /R:3 /W:5
xcopy "%BackupDir%\..\..\Software\ProcessLassoPro\RunProcessLasso.cmd" "%OutputDir%\Customization\Software\ProcessLasso\" /y

:readest
xcopy "%BackupDir%\..\..\..\readest\updateReadest.cmd" "%OutputDir%\Customization\Software\readest\" /y

:Snipaste
xcopy "%BackupDir%\..\..\Software\Snipaste\config.ini" "%OutputDir%\Customization\Software\Snipaste\" /y

:steamcommunity_302
xcopy "%BackupDir%\..\..\Software\steamcommunity_302\S302.ini" "%OutputDir%\Customization\Software\steamcommunity_302\" /y


:tc
::���Total Commander�O��
xcopy "%BackupDir%\..\..\Software\totalcmd64\WinCMD.ini" "%OutputDir%\Customization\Software\TotalCMD\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\DEFAULT.BAR" "%OutputDir%\Customization\Software\TotalCMD\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\Default.br2" "%OutputDir%\Customization\Software\TotalCMD\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\user\user.ini" "%OutputDir%\Customization\Software\TotalCMD\user\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\user\TCIgnore.ini" "%OutputDir%\Customization\Software\TotalCMD\user\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\Tools\Everything.ini" "%OutputDir%\Customization\Software\TotalCMD\Tools\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\Tools\updateNotepad4.cmd" "%OutputDir%\Customization\Software\TotalCMD\Tools\" /y

:trafficmonitor
xcopy "%BackupDir%\..\..\..\TrafficMonitor\config.json" "%OutputDir%\Customization\Software\TrafficMonitor\" /y
xcopy "%BackupDir%\..\..\..\TrafficMonitor\global_cfg.ini" "%OutputDir%\Customization\Software\TrafficMonitor\" /y

:Win����
xcopy "%SoftDir%\Microsoft\NewPC-Tools\SoftSettingsRecover.cmd" "%OutputDir%\Customization\Software\Winϵͳ����\" /y

:xyr
robocopy "%SoftDir%\Microsoft\NewPC-Tools\xyrϵͳ�Ż�\Config" "%OutputDir%\Customization\Software\xyrϵͳ�Ż�\Config" /MIR /ZB /R:3 /W:5


:zlib
::zlib��������
xcopy "C:\Users\%USERNAME%\AppData\Roaming\z-library\config.json" "%OutputDir%\Customization\Software\z-library\" /y

:ztasker
::���ztasker�O��
xcopy "%BackupDir%\..\..\Software\zTasker\User\Config.dat" "%OutputDir%\Customization\Software\zTasker\User\" /y
xcopy "%BackupDir%\..\..\Software\zTasker\User\Tasks.dat" "%OutputDir%\Customization\Software\zTasker\User\" /y


::GitHub�����
:GitHub
::��Nutstore���Ƶ�GitHub
::��ɾ���ɱ����ļ���
rd /s /q "%OutputDir%\..\..\GitHub\Customization\Rules"
rd /s /q "%OutputDir%\..\..\GitHub\Customization\Software"
rd /s /q "%OutputDir%\..\..\GitHub\RimeIMEPortable\usr"
rd /s /q "%OutputDir%\..\..\GitHub\RimeIMEPortable\book"
timeout /t 3 /nobreak
xcopy "%OutputDir%\Customization" "%OutputDir%\..\..\GitHub\Customization\"  /s /y /i
xcopy "%OutputDir%\RimeIMEPortable" "%OutputDir%\..\..\GitHub\RimeIMEPortable\"  /s /y /i

:end
timeout /t 3 /nobreak
