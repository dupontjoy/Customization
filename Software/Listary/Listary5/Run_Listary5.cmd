::2023.07.13

::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a

:Profiles
rem �O�Â��·���Լ��R�r�ļ��A
@echo ��ʱ����Listaryʱ�������־���ٕr�ļ�

cd /d %~dp0

::������������λ�õ�Listary.exe�ļ���,������1��
set Listary=..\Listary.exe


::��ֹһЩ����
taskkill /f /t /im Listary*

::Listary���
::ɾ����־����ʱ�ļ�
del  /s /q "*.log"
del  /s /q "*.tmp"

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

::�ȴ�һ��ʱ��
timeout /t 3 /nobreak

::����Ա��ʽ��������
mshta vbscript:createobject("shell.application").shellexecute("""%Listary%""","::",,"runas",1)(window.close)

exit
