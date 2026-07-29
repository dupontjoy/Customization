::2026.06.21
::注意換行符必须是：windows（CR+LF）

Title 备份文件到托管网站
::界面颜色大小，Cols为宽，Lines为高
color 0a
cls

:: 最小化当前窗口（ztasker复合任务中的脚本不要添加，会同时运行）
if not "%1"=="min" start /min "" "%~f0" min & exit /b

::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::設置文件所在位置
::从批处理所在文件夹到Profiles文件夹，共跨了2层
set "BackupDir=..\..\FxProfiles"
set "SoftDir=E:\Cing@Soft"
set "SyncDir=E:\My Documents\Nutstore\NutStoreSync"

:delete_cache
::删除D:\Temp文件夹
rd /s /q "D:\Temp"

::删除N_m3u8DL-RE下载失败的缓存和日志
rd /s /q "%BackupDir%\..\..\Software\N_m3u8DL-RE\cache"
rd /s /q "%BackupDir%\..\..\Software\N_m3u8DL-RE\Logs"

::删除docbox的缓存数据
rd /s /q "C:\Users\%USERNAME%\AppData\Roaming\DocBox"

::删除calibre的缓存数据
rd /s /q "C:\Users\%USERNAME%\Calibre 书库\.caltrash"


:delete_log
::删除一些软件的log文件
rd /s /q "C:\ProgramData\Anytxt\log"
rd /s /q "C:\ProgramData\Winhance\Logs"
rd /s /q "C:\ProgramData\Thunder Network\Logs"
rd /s /q "C:\ProgramData\Nutstore\logs"
rd /s /q "%BackupDir%\..\..\Software\v2rayN\guiLogs"
rd /s /q "%BackupDir%\..\..\Software\ImageGlass\ThumbnailsCache"

::删除pixpin自动保存的贴图
rd /s /q "%BackupDir%\..\..\Software\PixPin\Data"


:anytxt
robocopy "C:\ProgramData\Anytxt\config" "%SyncDir%\Customization\Software\Anytxt\config" /MIR /ZB /R:3 /W:5

:Archivarius3000
xcopy "C:\Users\%USERNAME%\AppData\Roaming\Archivarius 3000\Archivarius3000.cfg" "%SyncDir%\Customization\Software\Archivarius3000\" /y

:cangjie5
::复制文件夹時，源文件夹不要带斜杠，目标文件夹带斜杠。末尾写/s /y /i
::复制文件時，末尾写/y
::目标的usr不能带斜杠。/MIR（镜像模式），完全同步源目录和目标目录，包括子目录和文件。
robocopy "%BackupDir%\..\..\Software\RimeIMEPortable\usr" "%SyncDir%\RimeIMEPortable\usr" /MIR /ZB /R:3 /W:5
xcopy "%BackupDir%\..\..\Software\RimeIMEPortable\install.bat" "%SyncDir%\RimeIMEPortable\" /y
xcopy "%BackupDir%\..\..\Software\RimeIMEPortable\uninstall.bat" "%SyncDir%\RimeIMEPortable\" /y
xcopy "%BackupDir%\..\..\Software\RimeIMEPortable\README.md" "%SyncDir%\RimeIMEPortable\" /y
xcopy "%BackupDir%\..\..\Software\RimeIMEPortable\readme.txt" "%SyncDir%\RimeIMEPortable\" /y


:capslock
::備份Capslock+設置
xcopy "%BackupDir%\..\..\Software\Capslock+\CapsLock+settings.ini" "%SyncDir%\Customization\Software\Capslock+\" /y

:CCleaner
xcopy "%BackupDir%\..\..\Software\CCleaner\ccleaner.ini" "%SyncDir%\Customization\Software\CCleaner\" /y

:clashverge（CVR）
robocopy "C:\Users\%USERNAME%\AppData\Roaming\io.github.clash-verge-rev.clash-verge-rev" "%SyncDir%\Software\CVR\io.github.clash-verge-rev.clash-verge-rev" /MIR /ZB /R:3 /W:5

:docker-desktop
xcopy "C:\Users\%USERNAME%\.docker\config.json" "%SyncDir%\Customization\Software\docker-desktop\" /y

:fab
xcopy "%BackupDir%\..\..\Software\fab\Fab-Rules.ini" "%SyncDir%\Customization\Software\fab\" /y

:firefox
::備份幾個Firefox文件
::先删除旧备份文件夹
rd /s /q "%SyncDir%\Customization\Software\Firefox"
timeout /t 3 /nobreak
xcopy "%BackupDir%\user.js" "%SyncDir%\Customization\Software\Firefox\" /y
xcopy "%BackupDir%\bookmarks.html" "%SyncDir%\Customization\Software\Firefox\" /y
robocopy "%BackupDir%\bookmarkbackups" "%SyncDir%\Customization\Software\Firefox\bookmarkbackups" /MIR /ZB /R:3 /W:5
robocopy "%BackupDir%\chrome" "%SyncDir%\Customization\Software\Firefox\chrome" /MIR /ZB /R:3 /W:5
robocopy "%BackupDir%\..\BackupProfiles" "%SyncDir%\Customization\Software\Firefox\BackupProfiles" /MIR /ZB /R:3 /W:5

:foobar
robocopy "%BackupDir%\..\..\..\foobar2000\profile\foobox\config" "%SyncDir%\Customization\Software\foobar2000\profile\foobox\config" /MIR /ZB /R:3 /W:5
robocopy "%BackupDir%\..\..\..\foobar2000\profile\playlists-v2.0" "%SyncDir%\Customization\Software\foobar2000\profile\playlists-v2.0" /MIR /ZB /R:3 /W:5
xcopy "%BackupDir%\..\..\..\foobar2000\profile\config.sqlite" "%SyncDir%\Customization\Software\foobar2000\profile\" /y

:GitExtensions
xcopy "%BackupDir%\..\..\..\GitExtensions\GitExtensions.settings" "%SyncDir%\Customization\Software\GitExtensions\" /y
xcopy "%BackupDir%\..\..\..\GitExtensions\updateGitExtensions.cmd" "%SyncDir%\Customization\Software\GitExtensions\" /y
xcopy "C:\Users\%USERNAME%\.gitconfig" "%SyncDir%\Customization\Software\GitExtensions\" /y

:Glary
xcopy "%BackupDir%\..\..\Software\GlaryUtilities\Data\settings\Glarysoft.cmd" "%SyncDir%\Customization\Software\Glary\" /y
xcopy "%BackupDir%\..\..\Software\GlaryUtilities\Data\settings\Glarysoft.reg" "%SyncDir%\Customization\Software\Glary\" /y
xcopy "%BackupDir%\..\..\Software\GlaryUtilities\Data\settings\GlarysoftW32.reg" "%SyncDir%\Customization\Software\Glary\" /y

:GoldenDict
xcopy "%BackupDir%\..\..\..\GoldenDict\portable\config" "%SyncDir%\Customization\Software\GoldenDict\" /y
xcopy "%BackupDir%\..\..\..\GoldenDict\updateGoldenDict.cmd" "%SyncDir%\Customization\Software\GoldenDict\" /y

:GuoheView
xcopy "%BackupDir%\..\..\Software\GuoheViewPortable\config.ini" "%SyncDir%\Customization\Software\GuoheView\" /y

:IDMan
xcopy "%BackupDir%\..\..\..\IDM\!)选项配置.reg" "%SyncDir%\Customization\Software\IDMan\" /y

:ImageGlass
xcopy "%BackupDir%\..\..\Software\ImageGlass\igconfig.json" "%SyncDir%\Customization\Software\ImageGlass\" /y
xcopy "%BackupDir%\..\..\Software\ImageGlass\updateImageGlass.cmd" "%SyncDir%\Customization\Software\ImageGlass\" /y

:imFile
xcopy "C:\Users\%USERNAME%\AppData\Roaming\imFile\user.json" "%SyncDir%\Customization\Software\imFile\" /y
xcopy "C:\Users\%USERNAME%\AppData\Roaming\imFile\system.json" "%SyncDir%\Customization\Software\imFile\" /y

:licalender
xcopy "C:\Users\%USERNAME%\AppData\Roaming\pro.softsoft.li-calendar\liConfig.json" "%SyncDir%\Customization\Software\licalender\" /y

:listary5
::備份Listary5設置
xcopy "%BackupDir%\..\..\Software\Listary5\UserData\CopyFileName.vbs" "%SyncDir%\Customization\Software\Listary\Listary5\" /y
xcopy "%BackupDir%\..\..\Software\Listary5\UserData\Preferences.json" "%SyncDir%\Customization\Software\Listary\Listary5\" /y
xcopy "%BackupDir%\..\..\Software\Listary5\UserData\RunListary5.cmd" "%SyncDir%\Customization\Software\Listary\Listary5\" /y

:listary6
::備份Listary6設置
xcopy "%BackupDir%\..\..\Software\Listary6\DataFolderRedirection.txt" "%SyncDir%\Customization\Software\Listary\Listary6\" /y
xcopy "%BackupDir%\..\..\Software\Listary6\UserProfile\Settings\CopyFileName.vbs" "%SyncDir%\Customization\Software\Listary\Listary6\UserProfile\Settings\" /y
xcopy "%BackupDir%\..\..\Software\Listary6\UserProfile\Settings\Preferences.json" "%SyncDir%\Customization\Software\Listary\Listary6\UserProfile\Settings\" /y
xcopy "%BackupDir%\..\..\Software\Listary6\UserProfile\Settings\Runlistary7.cmd" "%SyncDir%\Customization\Software\Listary\Listary6\UserProfile\Settings\" /y


:listary7
::備份Listary7設置
xcopy "%BackupDir%\..\..\Software\Listary7\DataFolderRedirection.txt" "%SyncDir%\Customization\Software\Listary\Listary7\" /y
xcopy "%BackupDir%\..\..\Software\Listary7\UserProfile\Settings\CopyFileName.vbs" "%SyncDir%\Customization\Software\Listary\Listary7\UserProfile\Settings\" /y
xcopy "%BackupDir%\..\..\Software\Listary7\UserProfile\Settings\Preferences.json" "%SyncDir%\Customization\Software\Listary\Listary7\UserProfile\Settings\" /y
xcopy "%BackupDir%\..\..\Software\Listary7\UserProfile\Settings\Runlistary7.cmd" "%SyncDir%\Customization\Software\Listary\Listary7\UserProfile\Settings\" /y

:localsend
xcopy "%BackupDir%\..\..\..\LocalSend\updateLocalSend.cmd" "%SyncDir%\Customization\Software\LocalSend\" /y

:LXmusicDesktop
xcopy "%BackupDir%\..\..\..\lx-music-desktop\updateLXmusicDesktop.cmd" "%SyncDir%\Customization\Software\LXmusic\" /y
robocopy "C:\Users\%USERNAME%\AppData\Roaming\lx-music-desktop\LxDatas" "%SyncDir%\Customization\Software\LXmusic\LxDatas" /MIR /ZB /R:3 /W:5

:MAA
xcopy "%BackupDir%\..\..\..\MAA\RunMAA.cmd" "%SyncDir%\Customization\Software\MAA\" /y
xcopy "%BackupDir%\..\..\..\MAA\updateMaaResource.cmd" "%SyncDir%\Customization\Software\MAA\" /y
xcopy "%BackupDir%\..\..\..\MAA\config\gui.json" "%SyncDir%\Customization\Software\MAA\" /y

:MotrixNext
xcopy "C:\Users\%USERNAME%\AppData\Roaming\com.motrix.next\config.json" "%SyncDir%\Customization\Software\MotrixNext\" /y
xcopy "C:\Users\%USERNAME%\AppData\Roaming\com.motrix.next\system.json" "%SyncDir%\Customization\Software\MotrixNext\" /y

:MPV
robocopy "%BackupDir%\..\..\Software\MPV\installer" "%SyncDir%\Customization\Software\MPV\installer" /MIR /ZB /R:3 /W:5
robocopy "%BackupDir%\..\..\Software\MPV\portable_config" "%SyncDir%\Customization\Software\MPV\portable_config" /MIR /ZB /R:3 /W:5
xcopy "%BackupDir%\..\..\Software\MPV\RunYT-dlp.cmd" "%SyncDir%\Customization\Software\MPV\" /y
xcopy "%BackupDir%\..\..\Software\MPV\README.md" "%SyncDir%\Customization\Software\MPV\" /y
xcopy "%BackupDir%\..\..\Software\MPV\yt-dlp.conf" "%SyncDir%\Customization\Software\MPV\" /y
xcopy "%BackupDir%\..\..\Software\MPV\settings.xml" "%SyncDir%\Customization\Software\MPV\" /y
::删除不需要备份的播放进度
rd /s /q "%SyncDir%\Customization\Software\MPV\portable_config\cache"
rd /s /q "%SyncDir%\Customization\Software\MPV\portable_config\watch_later"

:N_m3u8DL-RE
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\N_m3u8DL-RE.exe" "%SyncDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\RunNm3u8DLRE.cmd" "%SyncDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_ad_keyword.conf" "%SyncDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_common.conf" "%SyncDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_live_record.conf" "%SyncDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\README.md" "%SyncDir%\Customization\Software\N_m3u8DL-RE\" /y

:Pixpin
::備份Pixpin設置
xcopy "%BackupDir%\..\..\Software\PixPin\Config\PixPinConfig.json" "%SyncDir%\Customization\Software\PixPin\Config\" /y

:Processlasso
robocopy "%BackupDir%\..\..\Software\ProcessLassoPro\config" "%SyncDir%\Customization\Software\ProcessLasso\config" /MIR /ZB /R:3 /W:5
xcopy "%BackupDir%\..\..\Software\ProcessLassoPro\RunProcessLasso.cmd" "%SyncDir%\Customization\Software\ProcessLasso\" /y

:readest
xcopy "%BackupDir%\..\..\..\readest\updateReadest.cmd" "%SyncDir%\Customization\Software\readest\" /y

:Snipaste
xcopy "%BackupDir%\..\..\Software\Snipaste\config.ini" "%SyncDir%\Customization\Software\Snipaste\" /y

:steamcommunity_302
xcopy "%BackupDir%\..\..\Software\steamcommunity_302\S302.ini" "%SyncDir%\Customization\Software\steamcommunity_302\" /y

:stranslate
robocopy "%BackupDir%\..\..\..\STranslate-win-Portable\current\PortableConfig\Settings" "%SyncDir%\Customization\Software\STranslate\Settings" /MIR /ZB /R:3 /W:5

:tc
::備份Total Commander設置
xcopy "%BackupDir%\..\..\Software\totalcmd64\wcx_ftp.ini" "%SyncDir%\Customization\Software\TotalCMD\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\wincmd.ini" "%SyncDir%\Customization\Software\TotalCMD\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\DEFAULT.BAR" "%SyncDir%\Customization\Software\TotalCMD\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\Default.br2" "%SyncDir%\Customization\Software\TotalCMD\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\Default.br144" "%SyncDir%\Customization\Software\TotalCMD\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\user\user.ini" "%SyncDir%\Customization\Software\TotalCMD\user\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\user\TCIgnore.ini" "%SyncDir%\Customization\Software\TotalCMD\user\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\Tools\Everything.ini" "%SyncDir%\Customization\Software\TotalCMD\Tools\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\Tools\Everything-1.5a.ini" "%SyncDir%\Customization\Software\TotalCMD\Tools\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\Tools\updateNotepad4.cmd" "%SyncDir%\Customization\Software\TotalCMD\Tools\" /y

:trafficmonitor
xcopy "%BackupDir%\..\..\Software\TrafficMonitor\config.ini" "%SyncDir%\Customization\Software\TrafficMonitor\" /y
xcopy "%BackupDir%\..\..\Software\TrafficMonitor\global_cfg.ini" "%SyncDir%\Customization\Software\TrafficMonitor\" /y

:v2rayN（VRN）
robocopy "%BackupDir%\..\..\Software\v2rayN\guiConfigs" "%SyncDir%\Software\VRN\guiConfigs" /MIR /ZB /R:3 /W:5

:Win设置
xcopy "%SoftDir%\Microsoft\NewPC-Tools\SoftSettingsRecover.cmd" "%SyncDir%\Customization\Software\Win系统设置\" /y

:xyr
robocopy "%SoftDir%\Microsoft\NewPC-Tools\xyr系统优化\Config" "%SyncDir%\Customization\Software\xyr系统优化\Config" /MIR /ZB /R:3 /W:5


:ztasker
::備份ztasker設置
xcopy "%BackupDir%\..\..\Software\zTasker\User\Config.dat" "%SyncDir%\Customization\Software\zTasker\User\" /y
xcopy "%BackupDir%\..\..\Software\zTasker\User\Tasks.dat" "%SyncDir%\Customization\Software\zTasker\User\" /y


::GitHub放最后
:GitHub
::从Nutstore复制到GitHub
::先删除旧备份文件夹
rd /s /q "%SyncDir%\..\..\GitHub\Customization\Rules"
rd /s /q "%SyncDir%\..\..\GitHub\Customization\Software"
rd /s /q "%SyncDir%\..\..\GitHub\RimeIMEPortable\usr"
rd /s /q "%SyncDir%\..\..\GitHub\RimeIMEPortable\book"
timeout /t 3 /nobreak
xcopy "%SyncDir%\Customization" "%SyncDir%\..\..\GitHub\Customization\"  /s /y /i
xcopy "%SyncDir%\RimeIMEPortable" "%SyncDir%\..\..\GitHub\RimeIMEPortable\"  /s /y /i

:end
timeout /t 3 /nobreak
exit