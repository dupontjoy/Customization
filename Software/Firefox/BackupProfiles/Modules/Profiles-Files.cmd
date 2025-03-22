::2024.03.20

Title ����Firefox����(����Ҫ�ļ�) by Cing
color 0a
cls

:Profiles
pushd %~dp0

:: Set download command
set Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs


::һ��������7-zip�����ַ
set zip=..\..\..\..\7-Zip\7z.exe


rem �O�Â��·���Լ��R�r�ļ��A
@echo �P�]����g�[�����Ԅ��_ʼ��ݡ���

taskkill /f /t /im firefox.exe


::������������λ�õ�Profiles�ļ���,������2��
set BackDir=..\..\FxProfiles

::�O���R�r�ļ��A
set TempFolder1="%TempFolder%\1"
set TempFolder2="%TempFolder%\2"
set TempFolder3="%TempFolder%\3"


::�ȴ�һ��ʱ��
timeout /t 5 /nobreak

::ɾ��һЩ�ļ�
rd /s /q "%BackDir%\chrome_debugger_profile"
rd /s /q "%BackDir%\extensions\staged"
rd /s /q "%BackDir%\extensions\trash"
rd /s /q "%BackDir%\storage\permanent"
rd /s /q "%BackDir%\storage\to-be-removed"

::storage�ļ������⴦��
Set fn="%BackDir%\storage\default"

::ɾ����վ������Ϣ
For /f "tokens=*" %%i in ('dir /ad /b /s "%fn%"^|findstr /c:"http"') do (rd /s /q "%%i\cache" "%%i\idb")


rem ����Ŀ���ļ����R�r�ļ��A

::����������
xcopy "%BackDir%\..\BackupProfiles" %TempFolder%\Profiles\BackupProfiles\ /s /y /i
xcopy "%BackDir%\..\Run" %TempFolder%\Profiles\Run\ /s /y /i

::�������ļ��A
xcopy "%BackDir%\bookmarkbackups" %TempFolder%\Profiles\FxProfiles\bookmarkbackups\  /s /y /i
xcopy "%BackDir%\chrome" %TempFolder%\Profiles\FxProfiles\chrome\  /s /y /i
xcopy "%BackDir%\extensions" %TempFolder%\Profiles\FxProfiles\extensions\ /s /y /i
xcopy "%BackDir%\gmp-gmpopenh264" %TempFolder%\Profiles\FxProfiles\gmp-gmpopenh264\ /s /y /i
xcopy "%BackDir%\gmp-widevinecdm" %TempFolder%\Profiles\FxProfiles\gmp-widevinecdm\ /s /y /i
xcopy "%BackDir%\storage" %TempFolder%\Profiles\FxProfiles\storage\ /s /y /i


::/**�������ļ�**/
::��չ
xcopy "%BackDir%\addons*.*" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::Cookies: �������������ʹ�����վ��Ϣ��ͨ���������վ��ѡ����Ϣ���¼״̬
xcopy "%BackDir%\cookies.sqlite" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::extensions.json: ��չ״̬(�Ƿ����)
xcopy "%BackDir%\extension*.json" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::favicons.sqlite: ��ҳ����ǩͼ���ļ�
xcopy "%BackDir%\favicons.sqlite" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::handlers.json��������Firefox ��δ�����Щ�ļ��ķ�ʽ����pdf��firefox�д򿪻������ػ�ѯ��
xcopy "%BackDir%\handlers.json" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::վ���Զ�����ѡ��: ������������վ���Ȩ�����ã����磬����������Щ��վ��������ʾ�������ڣ����������վ���ҳ�����ż���
xcopy "%BackDir%\permissions.sqlite" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::��ǩ�������ʷ
xcopy "%BackDir%\places.sqlite" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::��������
xcopy "%BackDir%\search.json.mozlz4" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::��������
xcopy "%BackDir%\user.js" %TempFolder%\Profiles\FxProfiles\  /s /y /i
xcopy "%BackDir%\prefs.js" %TempFolder%\Profiles\FxProfiles\  /s /y /i
::�����ļ�
::storage-sync-v2��Ҫ,������һЩ��չ�����ã���HeaderEditor��BypassWalls�ȣ�
xcopy "%BackDir%\storage*.sqlite*" %TempFolder%\Profiles\FxProfiles\  /s /y /i


::�xȡ�汾̖�����ڼ��r�g
::������������λ�õ�Firefox�����ļ��У�firefox��
for /f "usebackq eol=; tokens=1,2 delims==" %%i in ("..\..\..\Firefox\application.ini")do (if %%i==Version set ver=%%j)
