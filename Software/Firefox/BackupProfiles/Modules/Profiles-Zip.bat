::2025.01.04

Title 打包Firefox配置(仅必要文件) by Cing
color 0a
cls

::打包

:Profiles-zip
cls

::完整日期和時間
set YY=%date:~2,2%
set MON=%date:~5,2%
set DD=%date:~8,2%
set hh=%time:~0,2%
set mm=%time:~3,2%
set ss=%time:~6,2%

::輸出文件名
set Name=FxProfiles_%ver%_%YY%.%MON%%DD%(t%hh%%mm%).7z

::小時數小于10点時的修正
set /a hh=%time:~0,2%*1
if %hh% LSS 10 set hh=0%hh%
::輸出文件名
set Name=FxProfiles_%ver%_%YY%.%MON%%DD%(t%hh%%mm%).7z

rem 開始壓縮
::-mx9极限压缩
::-mhc开启档案文件头压缩
::-ms默认设置固实模式
::-mmt=N 多核选项，默认2
::-mfb=N 填fastbytes单词大小，此数字增大会稍微加大压缩但减慢速度
::-r递归到所有的子目录
::u更新压缩包中的文件
%zip% -mx9 -mhc -ms -mmt -mfb=273 -r u %TargetFolder%\%Name% "%TempFolder%\Profiles\BackupProfiles" "%TempFolder%\Profiles\FxProfiles" "%TempFolder%\Profiles\Run"


::微云
move %TargetFolder%\%Name% %TargetFolder1%


:end
@echo 備份完成！并刪除臨時文件夾！
rd "%TempFolder%" /s /q