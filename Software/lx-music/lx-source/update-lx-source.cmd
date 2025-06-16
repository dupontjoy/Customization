::2025.06.04

@echo off
title 一键下载lx music音源
color 0a

:: 最小化当前窗口
powershell -window minimized -command "Start-Process cmd -ArgumentList '/c %~0' -WindowStyle Hidden"

pushd %~dp0

:: 下载工具配置
set "Curl_Download=curl -LJ --ssl-no-revoke --progress-bar --create-dirs"

::=======================================
:: 主流程
::=======================================
:menu
call :test_fastest_ghmirror
call :update_fixed
call :update_change
call :end
goto :eof

::=======================================
:: 子程序
::=======================================
:test_fastest_ghmirror
CALL "D:\Program Files\CingFox\Profiles\BackupProfiles\Modules\test_fastest_ghmirror.cmd"
goto :eof

:update_fixed
echo. [下载] sixyin音源
%Curl_Download% -o "%cd%\sixyin.js" %GH_PROXY%/https://raw.githubusercontent.com/pdone/lx-music-source/main/sixyin/latest.js
echo. [下载] huibq音源
%Curl_Download% -o "%cd%\huibq.js" %GH_PROXY%/https://raw.githubusercontent.com/pdone/lx-music-source/main/huibq/latest.js
echo. [下载] flower音源
%Curl_Download% -o "%cd%\flower.js" %GH_PROXY%/https://raw.githubusercontent.com/pdone/lx-music-source/main/flower/latest.js
echo. [下载] grass音源
%Curl_Download% -o "%cd%\grass.js" %GH_PROXY%/https://raw.githubusercontent.com/pdone/lx-music-source/main/grass/latest.js
echo. [下载] freelisten音源
%Curl_Download% -o "%cd%\freelisten.js" https://fastly.jsdelivr.net/gh/lyswhut/lx-music-source/dist/lx-music-source.js

goto :eof

:update_change
setlocal

set "user=xzh767"
set "repo=lxmusic-source-all"
set "branch=main"

echo.
echo 正在检查以“聚合”开头的文件...
echo.

:: 使用提交历史获取文件更新时间（更可靠的方法）
powershell -NoProfile -Command ^
    "$files = Invoke-RestMethod -Uri 'https://api.github.com/repos/%user%/%repo%/contents/';" ^
    "$matchingFiles = $files | Where-Object { $_.name -match '^聚合' };" ^
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
    "Write-Host '找到符合条件的文件:' $sortedFiles.Count; " ^
    "foreach ($file in $sortedFiles) {" ^
        "$url = '%GH_PROXY%/https://raw.githubusercontent.com/%user%/%repo%/%branch%/' + $file.Name;" ^
        "Write-Host '正在下载: ' $url;" ^
        "Invoke-WebRequest -Uri $url -OutFile $file.Name;" ^
    "}" ^
    "if ($sortedFiles.Count -gt 0) { Write-Host '下载完成！' } else { Write-Host '未找到匹配文件' }"

echo.
echo 操作完成，请检查下载的文件

goto :eof

:end
timeout /t 3 /nobreak
