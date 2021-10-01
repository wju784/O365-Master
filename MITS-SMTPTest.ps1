cls
Write-Host "Office 365 SMTP Protocol Authentication Test" -ForegroundColor Yellow
Sleep 1
 
$Copier = Read-Host -Prompt "Enter email address of Scanner/Copier account"
$Recipient = Read-Host -Prompt "Enter the recipient email address to test mail flow"
Write-Host "Starting Authentication, please enter copier Office 365 credentials to test outbound mailflow" -ForegroundColor Yellow
$creds = get-credential -Credential $Copier
 
Try {
    Write-Host "Starting SMTP protocol test on port 587, Please wait..." -ForegroundColor Yellow
    Send-MailMessage –From $Copier –To $Recipient –Subject "Test Email" –Body "Test SMTP Service from Powershell on Port 587 w/ O365 app password." -SmtpServer smtp.office365.com -Credential $creds -UseSsl -Port 587 -ErrorAction STOP
    Sleep 2
    Write-Host "Message queued for delivery successfully!" -ForegroundColor Green
    } Catch [Exception] { 
    Write-host " "
    Write-host "Sending email from $Copier to $Recipient failed - Please try again." -ForegroundColor Red
    Write-host " "
    Write-host " -- Error Message -- " -ForegroundColor Yellow
    $Exception = $_.Exception.GetType().FullName
    $Message = $_.Exception.Message
    Write-host " $Exception" -ForegroundColor Yellow 
    Write-host " $Message" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host ""
    Write-Host "Closing session, please wait..." -ForegroundColor Yellow
    Get-PSSession | Remove-PSSession
    Pause
    