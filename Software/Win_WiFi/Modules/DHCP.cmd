::�Զ��Թ���Ա�������bat�ļ�
cd /d %~dp0
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit

::�����С��ColsΪ��LinesΪ��
COLOR 0a
MODE con: COLS=77 LINES=20

:DHCP
cls
::������Ϊ�ֶ����Զ���ȡ
netsh interface ip set address name="��̫��" source=dhcp
netsh interface IP add dns name="��̫��" 114.114.114.114
netsh interface ip set dns name="��̫��" source=dhcp