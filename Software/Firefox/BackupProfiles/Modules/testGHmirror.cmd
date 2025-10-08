@echo off
setlocal enabledelayedexpansion

:testGHmirror
:: �������Ӻ;����б�
:: ������Դ��Github ��ǿ - ��������
set "test_url=Jackchows/Cangjie5/raw/master/largefile.zip"
set "proxies=gh.nxnow.top, gh.zwy.one, ghpxy.hwinzniej.top, fastgit.cc, github.boki.moe, cors.isteed.cc"

:: ��ʼ������¼
set "fastest_proxy="
set "fastest_speed=0"
set "second_proxy="
set "second_speed=0"
set "third_proxy="
set "third_speed=0"

:: �����ŷָ��ľ����б�ת��Ϊ�ո�ָ�
set "proxies=!proxies:,= !"

:: ���㾵������
set "total=0"
for %%p in (!proxies!) do set /a "total+=1"

:: ����ÿ������
set "count=0"
for %%p in (!proxies!) do (
    set /a "count+=1"
    echo [!count!/!total!] ���Ծ���վ��: %%p
    set "current_speed=0"
    for /f "tokens=*" %%t in ('curl --max-time 20 -o tempfile -s -w "%%{speed_download}" "https://%%p/%test_url%" 2^>NUL ^|^| echo 0') do (
        set "current_speed=%%t"
    )
    del tempfile
    echo  �����ٶ�: !current_speed! �ֽ�/��
    
    :: ����ǰ����
    if !current_speed! gtr !fastest_speed! (
        set "third_speed=!second_speed!"
        set "third_proxy=!second_proxy!"
        set "second_speed=!fastest_speed!"
        set "second_proxy=!fastest_proxy!"
        set "fastest_speed=!current_speed!"
        set "fastest_proxy=%%p"
    ) else if !current_speed! gtr !second_speed! (
        set "third_speed=!second_speed!"
        set "third_proxy=!second_proxy!"
        set "second_speed=!current_speed!"
        set "second_proxy=%%p"
    ) else if !current_speed! gtr !third_speed! (
        set "third_speed=!current_speed!"
        set "third_proxy=%%p"
    )
)

:: ��ʾǰ����
echo ------------------------
echo ������������վ��:
echo 1. !fastest_proxy! (�����ٶ� !fastest_speed! �ֽ�/��)
echo 2. !second_proxy! (�����ٶ� !second_speed! �ֽ�/��)
echo 3. !third_proxy! (�����ٶ� !third_speed! �ֽ�/��)

:: ���ѡ������һ��
set /a "random_index=%random% %% 3 + 1"
if !random_index! equ 1 (
    set "selected_proxy=!fastest_proxy!"
    set "selected_speed=!fastest_speed!"
) else if !random_index! equ 2 (
    set "selected_proxy=!second_proxy!"
    set "selected_speed=!second_speed!"
) else (
    set "selected_proxy=!third_proxy!"
    set "selected_speed=!third_speed!"
)

:: ������
echo ------------------------
echo ���ѡ��ľ���վ����: !selected_proxy! (�����ٶ� !selected_speed! �ֽ�/��)
set "GH_PROXY=https://!selected_proxy!"
endlocal & set "GH_PROXY=%GH_PROXY%"
echo GH_PROXY=%GH_PROXY%

:end
timeout /t 3 /nobreak