Set WshShell = WScript.CreateObject("WScript.Shell") 
WshShell.run "cmd /c RunCommon.cmd",vbhide
WScript.Sleep 10000
WshShell.run "cmd /c RunWork.cmd",vbhide
WScript.Sleep 10000
WshShell.run "cmd /c RunDelete.cmd",vbhide