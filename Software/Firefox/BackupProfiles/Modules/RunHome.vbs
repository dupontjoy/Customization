'以管理员权限运行VBS脚本
Set WshShell = WScript.CreateObject("WScript.Shell") 
If WScript.Arguments.Length = 0 Then 
  Set ObjShell = CreateObject("Shell.Application") 
  ObjShell.ShellExecute "wscript.exe" _ 
  , """" & WScript.ScriptFullName & """ RunAsAdministrator", , "runas", 1 
  WScript.Quit 
End if 

WshShell.run "cmd /c RunCommon.cmd",vbhide
WScript.Sleep 10000
WshShell.run "cmd /c RunHome.cmd",vbhide