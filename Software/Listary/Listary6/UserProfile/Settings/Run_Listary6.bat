::2025.02.15

::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a

:Profiles
rem �O�Â��·���Լ��R�r�ļ��A
@echo ��ʱ����Listaryʱ�������־���ٕr�ļ�

::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

::��ת��Listary6�ļ���
cd ..\..\

::��ֹһЩ����
taskkill /f /t /im Listary*

::ɾ����־����ʱ�ļ�
del  /s /q "%cd%\UserProfile\Cache"

::�ȴ�һ��ʱ��
timeout /t 3 /nobreak

::����Ա��ʽ��������
mshta vbscript:createobject("shell.application").shellexecute("""%cd%\Listary.exe""","::",,"runas",1)(window.close)

exit
