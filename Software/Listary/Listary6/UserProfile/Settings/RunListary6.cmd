::2025.02.27

::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a

:Profiles
rem �O�Â��·���Լ��R�r�ļ��A
@echo ��ʱ����Listaryʱ�������־���ٕr�ļ�


::����ʹ��pushd+cd��ʽ��ȡ������·���ķ�ʽ��ӣ�����·���Ą��������������Ч
::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

::��ת��Listary6�ļ���
cd ..\..\

::��ֹһЩ����
taskkill /f /t /im Listary*

::ɾ����־����ʱ�ļ�
rd /s /q "%cd%\UserProfile\Cache"
del /s /q "%cd%\UserProfile\Settings\PathHistory.json"
del /s /q "%cd%\UserProfile\Settings\SearchHistory.json"

::��������
start "" "%cd%\Listary.exe"

:end
timeout /t 3 /nobreak

exit