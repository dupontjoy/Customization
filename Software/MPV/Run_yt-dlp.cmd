::2024.07.05
::�ǵñ���ΪASNI����

@echo off & setlocal enabledelayedexpansion

::������ɫ��С��ColsΪ��LinesΪ��
COLOR 0a
cls

::��ʼ
Title yt-dlp������Ƶ

cd /d %~dp0


::����ѡ��
:yt-dlp
cls
call :common_input
call :setting_path
call :setting_yt-dlp_params
call :yt-dlp_downloading
call :when_done
goto :eof

::---------------���벿��---------------
:common_input
::��������
:set_link
set "link="
set /p "link=����������: "
if "!link!"=="" (
    echo �������벻��Ϊ�գ�
    goto set_link
)

::���÷ֱ���
:set_format_res
set "res="
set /p "res=�ֱ��ʣ���480/720[Ĭ��]/1080����Ϊ�գ�: "
if "!res!"=="" (
    set format_res=--format-sort res:720
) else (
    set format_res=--format-sort res:%res%
)


::---------------���ò���---------------
:setting_path
::����firefox����Ŀ¼
set firefox_profile=..\..\Profiles\FxProfiles

::�������Ŀ¼
set SaveDir=E:\Download\

::����ffmpeg.exe·��
set ffmpeg=ffmpeg.exe

goto :eof

:setting_yt-dlp_params
::����yt-dlp���ز���
set title=%%(title)s@%%(uploader)s.%%(ext)s
set yt-dlp_params=--cookies-from-browser firefox:"%firefox_profile%" %format_res% --ffmpeg-location %ffmpeg% -o "%title%"
::������Ƶת����mp4����--merge-output-format������
set yt-dlp_download=yt-dlp --merge-output-format mp4 %yt-dlp_params% -P %SaveDir% "%link%"
goto :eof


::---------------����˵��---------------
::--cookies-from-browser BROWSER[+KEYRING][:PROFILE][::CONTAINER]   ����cookie
::--format-sort                                                     ���ø�ʽ��res:720��ʾ�ֱ���720P
::--ffmpeg-location PATH                                            ����ffmpeg·��
::-P PATH                                                           �����ļ�����·��


::---------------���в���---------------
:yt-dlp_downloading
::��������
cls
echo.�������%yt-dlp_download%
%yt-dlp_download%
goto :eof


::---------------��������---------------
::���������ͣһ��ʱ��رմ��ڣ���ֹ���б���ʱֱ�ӹرմ��ڡ�
:when_done
timeout /t 3 /nobreak
exit
goto :eof
