::2024.03.20

Title 备份Firefox配置(仅必要文件) by Cing
color 0a
cls

:Profiles
pushd %~dp0

:: Set download command
set Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs


::一次性设置7-zip程序地址
set zip=..\..\..\..\7-Zip\7z.exe


rem 設置備份路徑以及臨時文件夾
@echo 關閉火狐瀏覽器后自動開始備份……

taskkill /f /t /im firefox.exe


::从批处理所在位置到Profiles文件夹,共跨了2层
set BackDir=..\..\FxProfiles

::設置臨時文件夾
set TempFolder1="%TempFolder%\1"
set TempFolder2="%TempFolder%\2"
set TempFolder3="%TempFolder%\3"


::等待一段时间
timeout /t 5 /nobreak

::删除一些文件
rd /s /q "%BackDir%\chrome_debugger_profile"
rd /s /q "%BackDir%\extensions\staged"
rd /s /q "%BackDir%\extensions\trash"
rd /s /q "%BackDir%\storage\permanent"
rd /s /q "%BackDir%\storage\to-be-removed"

::storage文件夹特殊处理
Set fn="%BackDir%\storage\default"

::删除网站缓存信息
For /f "tokens=*" %%i in ('dir /ad /b /s "%fn%"^|findstr /c:"http"') do (rd /s /q "%%i\cache" "%%i\idb")


rem 复制目标文件到臨時文件夾

::备份批处理
xcopy "%BackDir%\..\BackupProfiles" %TempFolder%\Profiles\BackupProfiles\ /s /y /i
xcopy "%BackDir%\..\Run" %TempFolder%\Profiles\Run\ /s /y /i

::以下是文件夾
xcopy "%BackDir%\bookmarkbackups" %TempFolder%\Profiles\FxProfiles\bookmarkbackups\  /s /y /i
xcopy "%BackDir%\chrome" %TempFolder%\Profiles\FxProfiles\chrome\  /s /y /i
xcopy "%BackDir%\extensions" %TempFolder%\Profiles\FxProfiles\extensions\ /s /y /i
xcopy "%BackDir%\gmp-gmpopenh264" %TempFolder%\Profiles\FxProfiles\gmp-gmpopenh264\ /s /y /i
xcopy "%BackDir%\gmp-widevinecdm" %TempFolder%\Profiles\FxProfiles\gmp-widevinecdm\ /s /y /i
xcopy "%BackDir%\storage" %TempFolder%\Profiles\FxProfiles\storage\ /s /y /i


::/**以下是文件**/
::扩展
xcopy "%BackDir%\addons*.*" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::Cookies: 保留着你曾访问过的网站信息，通常是你的网站首选项信息或登录状态
xcopy "%BackDir%\cookies.sqlite" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::extensions.json: 扩展状态(是否禁用)
xcopy "%BackDir%\extension*.json" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::favicons.sqlite: 首页及书签图标文件
xcopy "%BackDir%\favicons.sqlite" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::handlers.json：保存了Firefox 如何处理这些文件的方式，如pdf在firefox中打开还是下载或询问
xcopy "%BackDir%\handlers.json" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::站点自定的首选项: 保存了许多针对站点的权限设置（比如，它保存着哪些网站被允许显示弹出窗口），或者针对站点的页面缩放级别
xcopy "%BackDir%\permissions.sqlite" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::书签和浏览历史
xcopy "%BackDir%\places.sqlite" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::搜索引擎
xcopy "%BackDir%\search.json.mozlz4" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::参数设置
xcopy "%BackDir%\user.js" %TempFolder%\Profiles\FxProfiles\  /s /y /i
xcopy "%BackDir%\prefs.js" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::其它文件
::storage-sync-v2必要,保存了一些扩展的设置（如HeaderEditor，BypassWalls等）
xcopy "%BackDir%\storage*.sqlite*" %TempFolder%\Profiles\FxProfiles\  /s /y /i


::讀取版本號和日期及時間
::从批处理所在位置到Firefox程序文件夹（firefox）
for /f "usebackq eol=; tokens=1,2 delims==" %%i in ("..\..\..\Firefox\application.ini")do (if %%i==Version set ver=%%j)
