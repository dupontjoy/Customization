::2025.01.04

Title ���Firefox����(����Ҫ�ļ�) by Cing
color 0a
cls

::���

:Profiles-zip
cls

::�������ں͕r�g
set YY=%date:~2,2%
set MON=%date:~5,2%
set DD=%date:~8,2%
set hh=%time:~0,2%
set mm=%time:~3,2%
set ss=%time:~6,2%

::ݔ���ļ���
set Name=FxProfiles_%ver%_%YY%.%MON%%DD%(t%hh%%mm%).7z

::С�r��С��10��r������
set /a hh=%time:~0,2%*1
if %hh% LSS 10 set hh=0%hh%
::ݔ���ļ���
set Name=FxProfiles_%ver%_%YY%.%MON%%DD%(t%hh%%mm%).7z

rem �_ʼ���s
::-mx9����ѹ��
::-mhc���������ļ�ͷѹ��
::-msĬ�����ù�ʵģʽ
::-mmt=N ���ѡ�Ĭ��2
::-mfb=N ��fastbytes���ʴ�С���������������΢�Ӵ�ѹ���������ٶ�
::-r�ݹ鵽���е���Ŀ¼
::u����ѹ�����е��ļ�
%zip% -mx9 -mhc -ms -mmt -mfb=273 -r u %TargetFolder%\%Name% "%TempFolder%\Profiles\BackupProfiles" "%TempFolder%\Profiles\FxProfiles" "%TempFolder%\Profiles\Run"


::΢��
move %TargetFolder%\%Name% %TargetFolder1%


:end
@echo �����ɣ����h���R�r�ļ��A��
rd "%TempFolder%" /s /q