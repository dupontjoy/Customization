::2025.07.14
::ע��Q�з������ǣ�windows��CR+LF��

Title ��װϵͳ��ָ�һЩ���������
::������ɫ��С��ColsΪ��LinesΪ��
color 0a
cls

:: === �޸ĵ㣺ʹ��ԭ��CMD������С����ǰ���� ===
if not defined _MINIMIZED_ (
    set "_MINIMIZED_=1"
    start /min cmd /c "%~f0"
    exit
)

::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

::�O���ļ�����λ��
set "SettingsDir=E:\My Documents\Nutstore\NutStoreSync"

:anytxt
robocopy "%SettingsDir%\Customization\Software\Anytxt\config" "C:\ProgramData\Anytxt\config" /MIR /ZB /R:3 /W:5

:gitextension
xcopy "%SettingsDir%\Customization\Software\GitExtensions\.gitconfig" "C:\Users\%USERNAME%\" /y

:zlib
::zlib��������
xcopy "%SettingsDir%\Customization\Software\z-library\config.json" "C:\Users\%USERNAME%\AppData\Roaming\z-library\" /y

:end
timeout /t 3 /nobreak >nul
exit