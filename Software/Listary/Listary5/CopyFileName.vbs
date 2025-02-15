path = WScript.Arguments(0)
Set fso = CreateObject("Scripting.FileSystemObject")
Set wsShell = CreateObject("WScript.Shell")
FileName = fso.GetFileName(path)
wsShell.Run "mshta vbscript:ClipboardData.SetData(""text""," &Chr(34)& FileName &Chr(34)& ")(close)",0,True