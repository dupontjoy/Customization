::2024.07.03

Title 备份文件到托管网站
::界面颜色大小，Cols为宽，Lines为高
color 0a
cls

::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::設置文件所在位置
::从批处理所在文件夹到Profiles文件夹，共跨了2层
set BackupDir=..\..\CingProfiles
set appdataDir=C:\Users\Cing\AppData\Roaming
set softDir=E:\Cing@Soft
set OutputDir=E:\My Documents\Nutstore\NutStoreSync


:cangjie5
xcopy "%BackupDir%\..\..\Software\RimeIME Portable\usr\cangjie5.dict.yaml" "%OutputDir%\RimeIME-Portable\config\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\RimeIME Portable\usr\cangjie5.custom.yaml" "%OutputDir%\RimeIME-Portable\config\" /s /y /i
xcopy "%BackupDir%\..\..\Software\RimeIME Portable\usr\weasel.custom.yaml" "%OutputDir%\RimeIME-Portable\config\" /s /y /i
xcopy "%BackupDir%\..\..\Software\RimeIME Portable\usr\skins-backup.yaml" "%OutputDir%\RimeIME-Portable\config\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\RimeIME Portable\usr\README.md" "%OutputDir%\RimeIME-Portable\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\RimeIME Portable\usr\update-cangjie5-dict.bat" "%OutputDir%\RimeIME-Portable\config\"  /s /y /i

:capslock+
::備份Capslock+設置
xcopy "%BackupDir%\..\..\Software\Capslock+\CapsLock+settings.ini" "%OutputDir%\Customization\Software\Capslock+\"  /s /y /i

:CCleaner
xcopy "%BackupDir%\..\..\Software\CCleaner\ccleaner.ini" "%OutputDir%\Customization\Software\CCleaner\"  /s /y /i

:firefox
::備份幾個Firefox文件
::先删除旧备份文件夹
rd /s /q "%OutputDir%\Customization\Software\Firefox\BackupProfiles"
timeout /t 3 /nobreak
xcopy "%BackupDir%\user.js" "%OutputDir%\Customization\Software\Firefox\"  /s /y /i
xcopy "%BackupDir%\..\BackupProfiles" "%OutputDir%\Customization\Software\Firefox\BackupProfiles"  /s /y /i

:GlaryUtilites
xcopy "%BackupDir%\..\..\Software\GlaryUtilities\Data\settings\Glarysoft.reg" "%OutputDir%\Customization\Software\GlaryUtilities\Data\settings\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\GlaryUtilities\Data\settings\GlarysoftW32.reg" "%OutputDir%\Customization\Software\GlaryUtilities\Data\settings\"  /s /y /i


:GoldenDict
xcopy "%BackupDir%\..\..\..\GoldenDict\portable\config" "%OutputDir%\Customization\Software\GoldenDict\"  /s /y /i

:IDM
xcopy "%BackupDir%\..\..\..\IDM\!)选项配置.reg" "%OutputDir%\Customization\Software\IDM\"  /s /y /i

:koodo-reader
xcopy "%appdataDir%\Koodo-Reader\uploads" "%OutputDir%\Customization\Software\Koodo-Reader\"  /s /y /i


:listary5
::備份Listary 5設置
xcopy "%BackupDir%\..\..\Software\Listary Pro\UserData\Preferences.json" "%OutputDir%\Customization\Software\Listary\Listary 5代\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\Listary Pro\UserData\Run_Listary.bat" "%OutputDir%\Customization\Software\Listary\Listary 5代\"  /s /y /i

:listary6
::備份Listary 6設置
xcopy "%BackupDir%\..\..\Software\Listary 6\DataFolderRedirection.txt" "%OutputDir%\Customization\Software\Listary\Listary 6代\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\Listary 6\UserProfile\Settings" "%OutputDir%\Customization\Software\Listary\Listary 6代\UserProfile\Settings\"  /s /y /i

:MAA
xcopy "%BackupDir%\..\..\..\MAA\Run_MAA.bat" "%OutputDir%\Customization\Software\MAA\"  /s /y /i
xcopy "%BackupDir%\..\..\..\MAA\Update_MaaResource.ps1" "%OutputDir%\Customization\Software\MAA\"  /s /y /i
xcopy "%BackupDir%\..\..\..\MAA\config\gui.json" "%OutputDir%\Customization\Software\MAA\"  /s /y /i

:mail-filter
xcopy "%BackupDir%\..\..\..\Tencent\Foxmail\Storage\dupontjoy@163.com\Filter\1.fter" "%OutputDir%\Customization\Software\Foxmail-Filter\mail-filter.fter"  /s /y /i

:MPV
::先删除旧备份文件夹
rd /s /q "%OutputDir%\Customization\Software\MPV\installer"
rd /s /q "%OutputDir%\Customization\Software\MPV\portable_config"
timeout /t 3 /nobreak
xcopy "%BackupDir%\..\..\Software\MPV\installer" "%OutputDir%\Customization\Software\MPV\installer\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\MPV\portable_config" "%OutputDir%\Customization\Software\MPV\portable_config\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\MPV\Run_yt-dlp.bat" "%OutputDir%\Customization\Software\MPV\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\MPV\README.md" "%OutputDir%\Customization\Software\MPV\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\MPV\updater.bat" "%OutputDir%\Customization\Software\MPV\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\MPV\update-mpv.bat" "%OutputDir%\Customization\Software\MPV\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\MPV\yt-dlp.conf" "%OutputDir%\Customization\Software\MPV\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\MPV\settings.xml" "%OutputDir%\Customization\Software\MPV\"  /s /y /i
::删除不需要备份的播放进度
rd /s /q "%OutputDir%\Customization\Software\MPV\portable_config\cache"

:N_m3u8DL-RE
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\N_m3u8DL-RE.exe" "%OutputDir%\Customization\Software\N_m3u8DL-RE\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\Run_N_m3u8DL-RE.bat" "%OutputDir%\Customization\Software\N_m3u8DL-RE\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_dir.conf" "%OutputDir%\Customization\Software\N_m3u8DL-RE\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_live_record.conf" "%OutputDir%\Customization\Software\N_m3u8DL-RE\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_video_download.conf" "%OutputDir%\Customization\Software\N_m3u8DL-RE\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\README.md" "%OutputDir%\Customization\Software\N_m3u8DL-RE\"  /s /y /i

:Pixpin
::備份Pixpin設置
xcopy "%BackupDir%\..\..\Software\PixPin\Config\config.json" "%OutputDir%\Customization\Software\PixPin\Config\"  /s /y /i

:Processlasso
xcopy "%BackupDir%\..\..\Software\ProcessLassoPro\config\prolasso.ini" "%OutputDir%\Customization\Software\ProcessLasso\config\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\ProcessLassoPro\config\ProlassoCNSettings.reg" "%OutputDir%\Customization\Software\ProcessLasso\config\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\ProcessLassoPro\config\ProlassoEN.reg" "%OutputDir%\Customization\Software\ProcessLasso\config\"  /s /y /i

:steamcommunity_302
xcopy "%BackupDir%\..\..\Software\steamcommunity_302\S302.ini" "%OutputDir%\Customization\Software\steamcommunity_302\"  /s /y /i


:tc
::備份Total Commander設置
xcopy "%BackupDir%\..\..\Software\totalcmd64\wincmd.ini" "%OutputDir%\Customization\Software\TotalCMD\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\totalcmd64\Default.bar" "%OutputDir%\Customization\Software\TotalCMD\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\totalcmd64\Default.br2" "%OutputDir%\Customization\Software\TotalCMD\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\totalcmd64\user\user.ini" "%OutputDir%\Customization\Software\TotalCMD\user\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\totalcmd64\user\TCIgnore.ini" "%OutputDir%\Customization\Software\TotalCMD\user\"  /s /y /i

:trafficmonitor
xcopy "%BackupDir%\..\..\..\TrafficMonitor\config.json" "%OutputDir%\Customization\Software\TrafficMonitor\"  /s /y /i
xcopy "%BackupDir%\..\..\..\TrafficMonitor\global_cfg.ini" "%OutputDir%\Customization\Software\TrafficMonitor\"  /s /y /i

:XnView
xcopy "%BackupDir%\..\..\..\XnViewMP\xnview.ini" "%OutputDir%\Customization\Software\XnViewMP\"  /s /y /i

:xyr
xcopy "%SoftDir%\Microsoft\NewPC-Tools\xyr系统优化\Config\[Clean]Cing's Settings.ini" "%OutputDir%\Customization\Software\xyr系统优化\"  /s /y /i
xcopy "%SoftDir%\Microsoft\NewPC-Tools\xyr系统优化\Config\[Optimization]Cing's Settings.ini" "%OutputDir%\Customization\Software\xyr系统优化\"  /s /y /i
xcopy "%SoftDir%\Microsoft\NewPC-Tools\xyr系统优化\Config\Hashtf.ini" "%OutputDir%\Customization\Software\xyr系统优化\"  /s /y /i
xcopy "%SoftDir%\Microsoft\NewPC-Tools\xyr系统优化\Config\OEMDefaultAssociations.xml" "%OutputDir%\Customization\Software\xyr系统优化\"  /s /y /i

:ztasker
::備份ztasker設置
xcopy "%BackupDir%\..\..\Software\zTasker\User\Tasks.dat" "%OutputDir%\Customization\Software\zTasker\User\"  /s /y /i


::GitHub放最后
:GitHub
::从Cingsync复制到GitHub
::先删除旧备份文件夹
rd /s /q "%OutputDir%\..\..\GitHub\Customization\Rules"
rd /s /q "%OutputDir%\..\..\GitHub\Customization\Software"
rd /s /q "%OutputDir%\..\..\GitHub\RimeIME-Portable\config"
rd /s /q "%OutputDir%\..\..\GitHub\RimeIME-Portable\soft"
timeout /t 3 /nobreak
xcopy "%OutputDir%\Customization" "%OutputDir%\..\..\GitHub\Customization\"  /s /y /i
xcopy "%OutputDir%\RimeIME-Portable" "%OutputDir%\..\..\GitHub\RimeIME-Portable\"  /s /y /i


:when_done
timeout /t 3 /nobreak