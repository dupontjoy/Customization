::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a

::pushd�������ǰĿ¼��·�����������������л�����ָ������Ŀ¼·����
pushd %~dp0

::��ֹһЩ����
taskkill /f /t /im ProcessGovernor.exe
taskkill /f /t /im ProcessLasso.exe
taskkill /f /t /im bitsumsessionagent.exe

::���
START ProcessGovernor.exe "/configfolder=./config" "/logfolder=%tmp%"
START ProcessLasso.exe "/configfolder=./config" "/logfolder=%tmp%"

popd

exit
