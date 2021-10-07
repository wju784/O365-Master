start-process powershell.exe -argument '-nologo -noprofile -executionpolicy bypass -command "Invoke-WebRequest 'https://raw.githubusercontent.com/wju784/O365-Master/main/exo.ps1' -OutFile 'exo.ps1' -UseBasicParsing; .\exo.ps1"; 
read-host "press enter"'
