::2025.02.27

::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a

:Profiles
rem �O�Â��·���Լ��R�r�ļ��A
@echo ��ʱ����Listaryʱ�������־���ٕr�ļ�

:: === �޸ĵ㣺ʹ��ԭ��CMD������С����ǰ���� ===
if not defined _MINIMIZED_ (
    set "_MINIMIZED_=1"
    start /min cmd /c "%~f0"
    exit
)

::����ʹ��pushd+cd��ʽ��ȡ������·���ķ�ʽ��ӣ�����·���Ą��������������Ч
::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

::��ת��Listary6�ļ���
cd ..\..\

::��ֹһЩ����
taskkill /f /t /im Listary*

::ɾ����־����ʱ�ļ�
rd /s /q "%cd%\UserProfile\Cache"

::��������
start "" "%cd%\Listary.exe"

:end
timeout /t 3 /nobreak