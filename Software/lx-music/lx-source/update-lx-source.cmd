::2025.06.04

@echo off
title һ������lx music��Դ
color 0a

:: ��С����ǰ����
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

pushd %~dp0

:: ���ع�������
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

::=======================================
:: ������
::=======================================
:menu
call :test_fastest_ghmirror
call :update_fixed
call :update_change
call :end
goto :eof

::=======================================
:: �ӳ���
::=======================================
:test_fastest_ghmirror
CALL "D:\Program Files\CingFox\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"
goto :eof

:update_fixed
echo. [����] sixyin��Դ
%Curl_Download% -o "%cd%\sixyin.js" %GH_PROXY%/https://raw.githubusercontent.com/pdone/lx-music-source/main/sixyin/latest.js
echo. [����] huibq��Դ
%Curl_Download% -o "%cd%\huibq.js" %GH_PROXY%/https://raw.githubusercontent.com/pdone/lx-music-source/main/huibq/latest.js
echo. [����] flower��Դ
%Curl_Download% -o "%cd%\flower.js" %GH_PROXY%/https://raw.githubusercontent.com/pdone/lx-music-source/main/flower/latest.js
echo. [����] grass��Դ
%Curl_Download% -o "%cd%\grass.js" %GH_PROXY%/https://raw.githubusercontent.com/pdone/lx-music-source/main/grass/latest.js
echo. [����] freelisten��Դ
%Curl_Download% -o "%cd%\freelisten.js" https://fastly.jsdelivr.net/gh/lyswhut/lx-music-source/dist/lx-music-source.js

goto :eof

:update_change
setlocal

set "user=xzh767"
set "repo=lxmusic-source-all"
set "branch=main"

echo.
echo ���ڼ���ԡ��ۺϡ���ͷ���ļ�...
echo.

:: ʹ���ύ��ʷ��ȡ�ļ�����ʱ�䣨���ɿ��ķ�����
powershell -NoProfile -Command ^
    "$files = Invoke-RestMethod -Uri 'https://api.github.com/repos/%user%/%repo%/contents/';" ^
    "$matchingFiles = $files | Where-Object { $_.name -match '^�ۺ�' };" ^
    "$fileInfoList = @();" ^
    "foreach ($file in $matchingFiles) {" ^
        "$commitUrl = 'https://api.github.com/repos/%user%/%repo%/commits?path=' + [Uri]::EscapeDataString($file.name) + '&per_page=1';" ^
        "$commitInfo = Invoke-RestMethod -Uri $commitUrl;" ^
        "if ($commitInfo) {" ^
            "$commitDate = [datetime]$commitInfo[0].commit.committer.date;" ^
            "$fileInfo = New-Object PSObject -Property @{ Name = $file.name; CommitDate = $commitDate };" ^
            "$fileInfoList += $fileInfo;" ^
        "}" ^
    "}" ^
    "$sortedFiles = $fileInfoList | Sort-Object CommitDate -Descending | Select-Object -First 2;" ^
    "Write-Host '�ҵ������������ļ�:' $sortedFiles.Count; " ^
    "foreach ($file in $sortedFiles) {" ^
        "$url = '%GH_PROXY%/https://raw.githubusercontent.com/%user%/%repo%/%branch%/' + $file.Name;" ^
        "Write-Host '��������: ' $url;" ^
        "Invoke-WebRequest -Uri $url -OutFile $file.Name;" ^
    "}" ^
    "if ($sortedFiles.Count -gt 0) { Write-Host '������ɣ�' } else { Write-Host 'δ�ҵ�ƥ���ļ�' }"

echo.
echo ������ɣ��������ص��ļ�

goto :eof

:end
timeout /t 3 /nobreak
