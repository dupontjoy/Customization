::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a

::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

START ProcessGovernor.exe "/configfolder=./config" "/logfolder=%tmp%"
START ProcessLasso.exe "/configfolder=./config" "/logfolder=%tmp%"

exit
