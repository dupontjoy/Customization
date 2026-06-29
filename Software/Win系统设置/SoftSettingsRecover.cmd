::2026.06.18
::注意換行符必须是：windows（CR+LF）

Title 安装系统后恢复一些软件的设置
::界面颜色大小，Cols为宽，Lines为高
color 0a
cls


::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::設置文件所在位置
set "SettingsDir=E:\My Documents\Nutstore\NutStoreSync"


:anytxt
robocopy "%SettingsDir%\Customization\Software\Anytxt\config" "C:\ProgramData\Anytxt\config" /MIR /ZB /R:3 /W:5

:Archivarius3000
xcopy "%SettingsDir%\Customization\Software\Archivarius3000\Archivarius3000.cfg" "C:\Users\%USERNAME%\AppData\Roaming\Archivarius 3000\" /y

:clashverge（CVR）
robocopy "%SettingsDir%\Software\CVR\profiles" "C:\Users\%USERNAME%\AppData\Roaming\io.github.clash-verge-rev.clash-verge-rev\profiles" /MIR /ZB /R:3 /W:5
xcopy "%SettingsDir%\Software\CVR\profiles.yaml" "C:\Users\%USERNAME%\AppData\Roaming\io.github.clash-verge-rev.clash-verge-rev\" /y
xcopy "%SettingsDir%\Software\CVR\verge.yaml" "C:\Users\%USERNAME%\AppData\Roaming\io.github.clash-verge-rev.clash-verge-rev\" /y

:gitextension
xcopy "%SettingsDir%\Customization\Software\GitExtensions\.gitconfig" "C:\Users\%USERNAME%\" /y

:licalender
xcopy "%SettingsDir%\Customization\Software\licalender\liConfig.json" "C:\Users\%USERNAME%\AppData\Roaming\pro.softsoft.li-calendar\" /y

:LXmusicDesktop
robocopy "%SettingsDir%\Customization\Software\LXmusic\LxDatas" "C:\Users\%USERNAME%\AppData\Roaming\lx-music-desktop\LxDatas" /MIR /ZB /R:3 /W:5

:MotrixNext
xcopy "%OutputDir%\Customization\Software\MotrixNext\config.json" "C:\Users\%USERNAME%\AppData\Roaming\com.motrix.next\" /y
xcopy "%OutputDir%\Customization\Software\MotrixNext\system.json" "C:\Users\%USERNAME%\AppData\Roaming\com.motrix.next\" /y

:end
timeout /t 3 /nobreak >nul
exit