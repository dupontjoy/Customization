::界面颜色大小，Cols为宽，Lines为高
COLOR 0a

::pushd命令，将当前目录的路径保存下来，并且切换到你指定的新目录路径。
pushd %~dp0

::终止一些进程
taskkill /f /t /im ProcessGovernor.exe
taskkill /f /t /im ProcessLasso.exe
taskkill /f /t /im bitsumsessionagent.exe

::启動
START ProcessGovernor.exe "/configfolder=./config" "/logfolder=%tmp%"
START ProcessLasso.exe "/configfolder=./config" "/logfolder=%tmp%"

exit
