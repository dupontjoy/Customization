@echo OFF

pushd %~dp0

set updater_script="%~dp0\update_MaaResource.ps1"

powershell -NoProfile -NoLogo -ExecutionPolicy Bypass -File %updater_script%