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

::��������
start "" "%Listary%"

exit
