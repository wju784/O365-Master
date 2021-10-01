cls
# Create temp directory
if (-Not (Get-Item C:\Temp)) { New-Item -ItemType dir "C:\Temp" }
# Check for required powershell modules
Write-Host -ForegroundColor Yellow Checking for required Modules...
If (Get-Module -ListAvailable -name ExchangeOnlineManagement) {
        Write-Host "Exchange Online Management Module Detected"
    }
    else {
        Write-Host "Exchange Online Management Module was not found"
        Write-Host "Installing Exchange Online Management Module..."
        Install-Module -Name ExchangeOnlineManagement -AllowClobber -WarningAction SilentlyContinue -Force
    }
# Connect to Exchange Online
Write-Host "Starting Office 365 Authentication..."
Connect-ExchangeOnline -ShowBanner:$false
Sleep -s 1
Write-Host -ForegroundColor Green "Connected successfully"
# Collect mailbox statistics for all accounts
Write-Host "Gathering Exchange Online Mailbox Statistics, please wait..."
Get-ExoMailbox | Get-ExoMailboxStatistics | Format-Table DisplayName, TotalItemSize, ItemCount -Autosize | FT >> c:\temp\MITS-MailboxSizeReport.txt
# Exit current powershell session
Get-pssession | remove-pssession
# Open Mailbox Size Report for review
start c:\temp\MITS-MailboxSizeReport.txt