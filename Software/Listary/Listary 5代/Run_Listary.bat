::2023.07.13

::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a

:Profiles
rem �O�Â��·���Լ��R�r�ļ��A
@echo ��ʱ����Listaryʱ�������־���ٕr�ļ����ؽ�����

cd /d %~dp0

::������������λ�õ�ProgramFiles�ļ���,������1��
set Listary=..\Listary.exe


::��ֹһЩ����
taskkill /f /t /im Listary*

::Listary���
::ɾ����־����ʱ�ļ�
del  /s /q "listary_log.log"
del  /s /q "DiskSearch.db"
del  /s /q "*.tmp"

::�ȴ�һ��ʱ��
timeout /t 3 /nobreak

::����Ա��ʽ��������
mshta vbscript:createobject("shell.application").shellexecute("""%Listary%""","::",,"runas",1)(window.close)

exit
