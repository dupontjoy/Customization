Set WshShell = WScript.CreateObject("WScript.Shell") 

'以管理员权限运行VBS脚本
If WScript.Arguments.Length = 0 Then 
  Set ObjShell = CreateObject("Shell.Application") 
  ObjShell.ShellExecute "wscript.exe" _ 
  , """" & WScript.ScriptFullName & """ RunAsAdministrator", , "runas", 1 
  WScript.Quit 
End if 

WshShell.run "cmd /c RunCommon.cmd",vbhide