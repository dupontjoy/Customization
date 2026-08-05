::2026.06.18
::注意換行符必须是：windows（CR+LF）

Title 安装系统后恢复一些软件的设置
::界面颜色大小，Cols为宽，Lines为高
color 0a
cls


::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::設置文件所在位置
set "SyncDir=E:\My Documents\Nutstore\NutStoreSync"


:anytxt
robocopy "%SyncDir%\Customization\Software\Anytxt\config" "C:\ProgramData\Anytxt\config" /MIR /ZB /R:3 /W:5

:Archivarius3000
xcopy "%SyncDir%\Customization\Software\Archivarius3000\Archivarius3000.cfg" "C:\Users\%USERNAME%\AppData\Roaming\Archivarius 3000\" /y

:clashverge（CVR）
robocopy "%SyncDir%\PSoftware\CVR\io.github.clash-verge-rev.clash-verge-rev" "C:\Users\%USERNAME%\AppData\Roaming\io.github.clash-verge-rev.clash-verge-rev" /MIR /ZB /R:3 /W:5

:docker-desktop
xcopy "%SyncDir%\Customization\Software\docker-desktop\config.json" "C:\Users\%USERNAME%\.docker\" /y

:gitextension
xcopy "%SyncDir%\Customization\Software\GitExtensions\.gitconfig" "C:\Users\%USERNAME%\" /y

:karing
robocopy "%SyncDir%\PSoftware\karing\karing" "C:\Users\%USERNAME%\AppData\Roaming\karing\karing" /MIR /ZB /R:3 /W:5

:licalender
xcopy "%SyncDir%\Customization\Software\licalender\liConfig.json" "C:\Users\%USERNAME%\AppData\Roaming\pro.softsoft.li-calendar\" /y

:LXmusicDesktop
robocopy "%SyncDir%\PSoftware\LXmusic\LxDatas" "C:\Users\%USERNAME%\AppData\Roaming\lx-music-desktop\LxDatas" /MIR /ZB /R:3 /W:5

:MotrixNext
xcopy "%SyncDir%\Customization\Software\MotrixNext\config.json" "C:\Users\%USERNAME%\AppData\Roaming\com.motrix.next\" /y
xcopy "%SyncDir%\Customization\Software\MotrixNext\system.json" "C:\Users\%USERNAME%\AppData\Roaming\com.motrix.next\" /y

:end
timeout /t 3 /nobreak >nul
exit