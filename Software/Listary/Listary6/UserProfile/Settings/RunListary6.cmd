::2025.02.27

::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a

:Profiles
rem �O�Â��·���Լ��R�r�ļ��A
@echo ��ʱ����Listaryʱ�������־���ٕr�ļ�

:: ��С����ǰ����
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

::����ʹ��pushd+cd��ʽ��ȡ������·���ķ�ʽ��ӣ�����·���Ą��������������Ч
::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

::��ת��Listary6�ļ���
cd ..\..\

::��ֹһЩ����
taskkill /f /t /im Listary*

::ɾ����־����ʱ�ļ�
rd /s /q "%cd%\UserProfile\Cache"

::��ֹListary*.exe��������ֹ�����뱻���ʧЧ
:: ֱ���������ԱȨ�ޣ�������VBScript��
if not "%1"=="admin" (
    fltmc >nul 2>&1 || (
        echo �����������ԱȨ��...
        PowerShell Start -WindowStyle Hidden -Verb RunAs -FilePath "cmd.exe" -ArgumentList "/c cd /d ""%cd%"" & ""%~f0"" admin"
        exit
    )
)

:: ����ԱȨ����ִ��
echo �ѻ�ù���ԱȨ�ޣ�
echo ��ǰĿ¼�ļ��б�
dir Listary*.exe /b

:: ��������ӹ���
for %%f in (Listary*.exe) do (
    echo ������ֹ: %%f
    netsh advfirewall firewall delete rule name="Block_%%~nf" 2>nul
    netsh advfirewall firewall add rule name="Block_%%~nf" dir=out action=block program="%%~ff" enable=yes
)

::����Ա��ʽ��������
mshta vbscript:createobject("shell.application").shellexecute("""%cd%\Listary.exe""","::",,"runas",1)(window.close)

:end
timeout /t 3 /nobreak