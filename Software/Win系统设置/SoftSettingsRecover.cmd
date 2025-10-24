::2025.10.23
::注意換行符必须是：windows（CR+LF）

Title 安装系统后恢复一些软件的设置
::界面颜色大小，Cols为宽，Lines为高
color 0a
cls


::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::設置文件所在位置
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
::zlib可用域名
xcopy "%SettingsDir%\Customization\Software\z-library\config.json" "C:\Users\%USERNAME%\AppData\Roaming\z-library\" /y

:end
timeout /t 3 /nobreak >nul
exit