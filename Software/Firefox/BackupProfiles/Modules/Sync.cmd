::2025.06.14

Title 备份文件到托管网站
::界面颜色大小，Cols为宽，Lines为高
color 0a
cls

:: 最小化当前窗口
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::設置文件所在位置
::从批处理所在文件夹到Profiles文件夹，共跨了2层
set "BackupDir=..\..\FxProfiles"
set "softDir=E:\Cing@Soft"
set "OutputDir=E:\My Documents\Nutstore\NutStoreSync"

:cangjie5
::复制文件夹時，源文件夹不要带斜杠，目标文件夹带斜杠。末尾写/s /y /i
::复制文件時，末尾写/y
::使用robocopy复制usr時排除usr\build文件夹
robocopy "%BackupDir%\..\..\Software\RimeIMEPortable\usr" "%OutputDir%\RimeIME-Portable\usr\" /E /ZB /R:3 /W:5 /XD "build"
xcopy "%BackupDir%\..\..\Software\RimeIMEPortable\install.bat" "%OutputDir%\RimeIME-Portable\" /y
xcopy "%BackupDir%\..\..\Software\RimeIMEPortable\uninstall.bat" "%OutputDir%\RimeIME-Portable\" /y
xcopy "%BackupDir%\..\..\Software\RimeIMEPortable\readme.txt" "%OutputDir%\RimeIME-Portable\" /y


:capslock
::備份Capslock+設置
xcopy "%BackupDir%\..\..\Software\Capslock+\CapsLock+settings.ini" "%OutputDir%\Customization\Software\Capslock+\" /y

:CCleaner
xcopy "%BackupDir%\..\..\Software\CCleaner\ccleaner.ini" "%OutputDir%\Customization\Software\CCleaner\" /y

:firefox
::備份幾個Firefox文件
::先删除旧备份文件夹
rd /s /q "%OutputDir%\Customization\Software\Firefox\BackupProfiles"
timeout /t 3 /nobreak
xcopy "%BackupDir%\user.js" "%OutputDir%\Customization\Software\Firefox\" /y
xcopy "%BackupDir%\chrome\userChromeJS\update-uc-scripts.cmd" "%OutputDir%\Customization\Software\Firefox\" /y
xcopy "%BackupDir%\..\BackupProfiles" "%OutputDir%\Customization\Software\Firefox\BackupProfiles\" /s /y /i

:foobar
xcopy "%BackupDir%\..\..\..\foobar2000\profile\config.sqlite" "%OutputDir%\Customization\Software\foobar2000\profile\" /y

:GoldenDict
xcopy "%BackupDir%\..\..\..\GoldenDict\portable\config" "%OutputDir%\Customization\Software\GoldenDict\" /y
xcopy "%BackupDir%\..\..\..\GoldenDict\update-goldendict.cmd" "%OutputDir%\Customization\Software\GoldenDict\" /y

:IDMan
xcopy "%BackupDir%\..\..\..\IDM\!)选项配置.reg" "%OutputDir%\Customization\Software\IDMan\" /y

:ImageGlass
xcopy "%BackupDir%\..\..\Software\ImageGlass\igconfig.json" "%OutputDir%\Customization\Software\ImageGlass\" /y
xcopy "%BackupDir%\..\..\Software\ImageGlass\update-imageglass.cmd" "%OutputDir%\Customization\Software\ImageGlass\" /y

:listary5
::備份Listary 5設置
xcopy "%BackupDir%\..\..\Software\Listary5\UserData\CopyFileName.vbs" "%OutputDir%\Customization\Software\Listary\Listary5\" /y
xcopy "%BackupDir%\..\..\Software\Listary5\UserData\Preferences.json" "%OutputDir%\Customization\Software\Listary\Listary5\" /y
xcopy "%BackupDir%\..\..\Software\Listary5\UserData\Run_Listary5.cmd" "%OutputDir%\Customization\Software\Listary\Listary5\" /y


:listary6
::備份Listary 6設置
xcopy "%BackupDir%\..\..\Software\Listary6\DataFolderRedirection.txt" "%OutputDir%\Customization\Software\Listary\Listary6\" /y
xcopy "%BackupDir%\..\..\Software\Listary6\UserProfile\Settings\CopyFileName.vbs" "%OutputDir%\Customization\Software\Listary\Listary6\UserProfile\Settings\" /y
xcopy "%BackupDir%\..\..\Software\Listary6\UserProfile\Settings\Preferences.json" "%OutputDir%\Customization\Software\Listary\Listary6\UserProfile\Settings\" /y
xcopy "%BackupDir%\..\..\Software\Listary6\UserProfile\Settings\Run_Listary6.cmd" "%OutputDir%\Customization\Software\Listary\Listary6\UserProfile\Settings\" /y

:localsend
xcopy "%BackupDir%\..\..\..\LocalSend\update-localsend.cmd" "%OutputDir%\Customization\Software\LocalSend\" /y

:lx_music_desktop
xcopy "%BackupDir%\..\..\..\lx-music-desktop\update-lx_music_desktop.cmd" "%OutputDir%\Customization\Software\lx-music\" /y

:MAA
xcopy "%BackupDir%\..\..\..\MAA\Run_MAA.cmd" "%OutputDir%\Customization\Software\MAA\" /y
xcopy "%BackupDir%\..\..\..\MAA\update_MaaResource.cmd" "%OutputDir%\Customization\Software\MAA\" /y
xcopy "%BackupDir%\..\..\..\MAA\config\gui.json" "%OutputDir%\Customization\Software\MAA\" /y
:mail-filter
xcopy "%BackupDir%\..\..\..\Tencent\Foxmail\Storage\dupontjoy@163.com\Filter\1.fter" "%OutputDir%\Customization\Software\Foxmail-Filter\mail-filter.fter" /y

:MPV
::先删除旧备份文件夹
rd /s /q "%OutputDir%\Customization\Software\MPV\installer"
rd /s /q "%OutputDir%\Customization\Software\MPV\portable_config"
timeout /t 3 /nobreak
xcopy "%BackupDir%\..\..\Software\MPV\installer" "%OutputDir%\Customization\Software\MPV\installer\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\MPV\portable_config" "%OutputDir%\Customization\Software\MPV\portable_config\"  /s /y /i
xcopy "%BackupDir%\..\..\Software\MPV\Run_yt-dlp.cmd" "%OutputDir%\Customization\Software\MPV\" /y
xcopy "%BackupDir%\..\..\Software\MPV\README.md" "%OutputDir%\Customization\Software\MPV\" /y
xcopy "%BackupDir%\..\..\Software\MPV\yt-dlp.conf" "%OutputDir%\Customization\Software\MPV\" /y
xcopy "%BackupDir%\..\..\Software\MPV\settings.xml" "%OutputDir%\Customization\Software\MPV\" /y
::删除不需要备份的播放进度
rd /s /q "%OutputDir%\Customization\Software\MPV\portable_config\cache"

:N_m3u8DL-RE
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\N_m3u8DL-RE.exe" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\Run_N_m3u8DL-RE.cmd" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_ad_keyword.conf" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_common.conf" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\config_live_record.conf" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y
xcopy "%BackupDir%\..\..\Software\N_m3u8DL-RE\README.md" "%OutputDir%\Customization\Software\N_m3u8DL-RE\" /y

:Pixpin
::備份Pixpin設置
xcopy "%BackupDir%\..\..\Software\PixPin\Config\PixPinConfig.json" "%OutputDir%\Customization\Software\PixPin\Config\" /y

:Processlasso
xcopy "%BackupDir%\..\..\Software\ProcessLassoPro\config" "%OutputDir%\Customization\Software\ProcessLasso\config\" /s /y /i
xcopy "%BackupDir%\..\..\Software\ProcessLassoPro\_Start-ProcessLasso.cmd" "%OutputDir%\Customization\Software\ProcessLasso\" /y

:readest
xcopy "%BackupDir%\..\..\..\readest\update-readest.cmd" "%OutputDir%\Customization\Software\readest\" /y

:Snipaste
xcopy "%BackupDir%\..\..\Software\Snipaste\config.ini" "%OutputDir%\Customization\Software\Snipaste\" /y

:steamcommunity_302
xcopy "%BackupDir%\..\..\Software\steamcommunity_302\S302.ini" "%OutputDir%\Customization\Software\steamcommunity_302\" /y


:tc
::備份Total Commander設置
xcopy "%BackupDir%\..\..\Software\totalcmd64\wincmd.ini" "%OutputDir%\Customization\Software\TotalCMD\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\Default.bar" "%OutputDir%\Customization\Software\TotalCMD\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\Default.br2" "%OutputDir%\Customization\Software\TotalCMD\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\user\user.ini" "%OutputDir%\Customization\Software\TotalCMD\user\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\user\TCIgnore.ini" "%OutputDir%\Customization\Software\TotalCMD\user\" /y
xcopy "%BackupDir%\..\..\Software\totalcmd64\Tools\Everything.ini" "%OutputDir%\Customization\Software\TotalCMD\Tools\" /y

:trafficmonitor
xcopy "%BackupDir%\..\..\..\TrafficMonitor\config.json" "%OutputDir%\Customization\Software\TrafficMonitor\" /y
xcopy "%BackupDir%\..\..\..\TrafficMonitor\global_cfg.ini" "%OutputDir%\Customization\Software\TrafficMonitor\" /y

:XnView
xcopy "%BackupDir%\..\..\..\XnViewMP\xnview.ini" "%OutputDir%\Customization\Software\XnViewMP\" /y

:xyr
xcopy "%SoftDir%\Microsoft\NewPC-Tools\xyr系统优化\Config" "%OutputDir%\Customization\Software\xyr系统优化\Config\"  /s /y /i


:zlib
::zlib可用域名
xcopy "C:\Users\%USERNAME%\AppData\Roaming\z-library\config.json" "%OutputDir%\Customization\Software\z-library\" /y

:ztasker
::備份ztasker設置
xcopy "%BackupDir%\..\..\Software\zTasker\User\Config.dat" "%OutputDir%\Customization\Software\zTasker\User\" /y
xcopy "%BackupDir%\..\..\Software\zTasker\User\Tasks.dat" "%OutputDir%\Customization\Software\zTasker\User\" /y


::GitHub放最后
:GitHub
::从Cingsync复制到GitHub
::先删除旧备份文件夹
rd /s /q "%OutputDir%\..\..\GitHub\Customization\Rules"
rd /s /q "%OutputDir%\..\..\GitHub\Customization\Software"
rd /s /q "%OutputDir%\..\..\GitHub\RimeIME-Portable\usr"
timeout /t 3 /nobreak
xcopy "%OutputDir%\Customization" "%OutputDir%\..\..\GitHub\Customization\"  /s /y /i
xcopy "%OutputDir%\RimeIME-Portable" "%OutputDir%\..\..\GitHub\RimeIME-Portable\"  /s /y /i


:end
timeout /t 3 /nobreak
