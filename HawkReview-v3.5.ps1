<##################################################################################################
#
.SYNOPSIS

    WARNING: Make sure you understand what you're doing before running this script!

    1. This script will prompt for authentication to Azure AD, ExchangeOnline & MSOnline when running this script
    2. You can perform a Tenant only investigation with Hawk
    3. You can perform a user based investigation with Hawk
    
    

.NOTES
    FileName:   MITS-HawkReview.ps1
    Author:     Bill Ulrich August 2021
    Version:    3.2
    
#>
###################################################################################################
#Set Execution Policy to Bypass
Set-ExecutionPolicy -Scope Process Bypass -ErrorAction SilentlyContinue -Force
Clear

#Create Temp Directory
New-Item -ItemType directory -Path C:\temp\Hawk -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | out-null

#Start Transcript log of script activity
#Start-Transcript -path c:\temp\Hawk\Hawk-Transcript.txt
# Hawk
$text = @"
@@@@@@@@@E@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@E@.E@.@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@I.@.#.;@,@@@@@@@@@@@@@.,H@@@@@@@@
@@@@@@;iH.;.I.+i;@@@@@@@@@@+...:h@@@@@@@
@@@@@@@........I.#@@@@@@@@.i.....:@@@@@@
@@@@@@@|..........@@@@@@@@........@@@@@@
@@@@@@@@...........,@@@@@:........@@@@@@
@@@@@@@@,............:@E.........#@@@@@@
@@@@@@@@@.......................@@@@@@@@
@@@@@@@@@......................@@@@@@@@@
@@@@@@@@@@...................|@@@@@@@@@@
@@@@@@@@@@@...................O@@@@@@@@@
@@@@@@@@@@@@,...................#@@@@@@@
@@@@@@@@@@@@@;................#@@@@@@@@@
@@@@@@@@@@@@@@=............=@@@@@@@@@@@@
@@@@@@@@@@@O............h@@@@@@@@@@@@@@@
@@@@@@@h.........,:iE@@@@@@@@@@@@@@@@@@@
@@@@@,....+@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
"@
$text
Write-Host "Advance Managed IT - Hawk O365 Investigation Toolkit" -ForegroundColor Red
Write-Host
Write-Host
Sleep -Seconds 2

# NuGet Module Check 
Write-Host -Foregroundcolor Yellow "Checking for Required PowerShell Modules, please wait..."

# Trust PSGallery Repository
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted | out-null

# Check if the NuGet Provider module has already been loaded.
if ( ! ( Get-Module NuGet | out-null ) ) {
    # Check if the NuGet PowerShell module is installed.
    if ( Get-Module -ListAvailable -Name NuGet | out-null ) {
        # The NuGet PowerShell module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor White "Loading the NuGet PowerShell module..."
        Import-Module NuGet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | out-null
    } else {
        Write-Host -ForegroundColor White "Loading the NuGet PowerShell module..."  
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | out-null
        Write-Host "NuGet PowerShell Module loaded successfully"
    }
}

# Check for PowershellGet Module and install if not found      
If (Get-Module -ListAvailable -name PowerShellGet) {
		Write-Host "PowerShellGet Module Detected"
		Update-Module -Scope CurrentUser PowerShellGet
}
    else {
    Write-Host "PowerShellGet Module was not found"
    Write-Host "Installing PowerShellGet Module..."
    Install-Module -Scope CurrentUser PowerShellGet –Repository PSGallery –Force -AllowClobber
    }

if ( ! ( Get-Module AzureAD ) ) {
    # Check if the Azure AD PowerShell module is installed.
    if ( Get-Module -ListAvailable -Name AzureAD ) {
        # The Azure AD PowerShell module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host "Loading AzureAD PowerShell Modules..."
        Sleep -Seconds 1
        Import-Module AzureAD
    } else {
        Install-Module AzureAD
    }
}

# Check for Exchange Online Management Module and install if not found
If (Get-Module -ListAvailable -name ExchangeOnlineManagement) {
    Write-Host "ExchangeOnline Module Detected"
}
else {
    Write-Host "ExchangeOnline Module not found!"
    Write-Host "Installing ExchangeOnlineManagement Module, please wait..."
    Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -RequiredVersion 2.0.3-Preview -AllowPrerelease -AllowClobber -Force
    Write-Host "Exchange Online Management Module prerequisite check is complete"
}

# Check if the Hawk PowerShell module is installed.
if ( ! ( Get-Module Hawk ) ) {
    
    if ( Get-Module -ListAvailable -Name Hawk ) {
    # The Hawk PowerShell module is not load and it is installed. This module
    # must be loaded for other operations performed by this script.
    Write-Host -ForegroundColor White "Loading the Hawk PowerShell module, please wait..."
        Import-Module Hawk
    } else {
        Write-Host
        Write-Host "Installing Hawk Module, please wait..."  
        Install-Module Hawk -ErrorAction SilentlyContinue -Force  
       Write-Host -ForegroundColor Green "Hawk PowerShell Module installed successfully"
    }
}
Write-Host "Powershell Module Verification Complete!" -foregroundcolor Yellow
Write-Host
Write-Host
Write-Host "Please select the type of investigation you wish to perform?" -ForegroundColor Yellow
Write-Host "   1. Perform Tenant Investigation" -ForegroundColor Cyan
Write-Host "   2. Perform User based log investigation" -ForegroundColor Cyan
Write-Host "   3. Exit Hawk Module" -ForegroundColor Cyan

$Choice = Read-Host "Type your selection: 1, 2, or 3 and press Enter"

if ($Choice -eq "1") {
    # Get the Username and ObjectID
    $TenantName = Read-Host "Enter the tenant domain address"
    mkdir c:\temp\Hawk\$TenantName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    Write-Host "Output path: c:\temp\Hawk\$TenantName"
    Set-Location c:\temp\Hawk\$TenantName
    
    # Start O365 Authentication session
    Write-Host
    Write-Host -ForegroundColor Green "Initiating Office 365 Multi-Service Authentication Process"
    Write-Host -ForegroundColor Yellow "When prompted, enter the appropriate credentials... Warning: Authentication pop-up may be hidden under another window"
    Write-Host
    Connect-ExchangeOnline -ShowBanner:$false
    Connect-AzureAD
    Connect-MSOLService
    $StartHawk = Start-HawkTenantInvestigation -DomainName $TenantName -full
    Write-Host
    Write-Host "Hawk O365 Tenant based investigation is complete!" -ForegroundColor Green
    Write-Host
    Write-Host "Would you like to start a User based investigation?" -ForegroundColor Yellow
    Write-Host 
    $Answer = Read-Host "Type Y or N and press Enter."

    if ($Answer -eq "y") {
    Write-Host 
    Write-Host "Starting user based investigation..." -ForegroundColor Yellow
    $UPN = Read-Host "Enter the user's primary email address (UPN)"
    Start-HawkUserInvestigation -UserPrincipalName $UPN
    Write-Host 
    Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
    Write-Host
    Write-Host "Do you want to collect logs for another user?"
    $Answer = Read-Host "Type Y or N and press Enter."
    if ($Answer -eq "y") {
       $UPN = Read-Host "Enter the user's primary email address (UPN)"
       Start-HawkUserInvestigation -UserPrincipalName $UPN
       Write-Host 
       Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
       Write-Host
    Write-Host "Do you want to collect logs for another user?"
    $Answer = Read-Host "Type Y or N and press Enter."
    if ($Answer -eq "y") {
       $UPN = Read-Host "Enter the user's primary email address (UPN)"
       Start-HawkUserInvestigation -UserPrincipalName $UPN
       Write-Host 
       Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
       Write-Host
       Write-Host "Do you want to collect logs for another user?"
       $Answer = Read-Host "Type Y or N and press Enter."
       if ($Answer -eq "y") {
          $UPN = Read-Host "Enter the user's primary email address (UPN)"
          Start-HawkUserInvestigation -UserPrincipalName $UPN
          Write-Host 
          Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
          Write-Host
          Write-Host "Do you want to collect logs for another user?"
          $Answer = Read-Host "Type Y or N and press Enter."
          if ($Answer -eq "y") {
             $UPN = Read-Host "Enter the user's primary email address (UPN)"
             Start-HawkUserInvestigation -UserPrincipalName $UPN
             Write-Host 
             Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
             Write-Host
       Write-Host "Do you want to collect logs for another user?"
       $Answer = Read-Host "Type Y or N and press Enter."
       if ($Answer -eq "y") {
          $UPN = Read-Host "Enter the user's primary email address (UPN)"
          Start-HawkUserInvestigation -UserPrincipalName $UPN
          Write-Host 
          Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
          Write-Host
        Write-Host "Loading Investigation Detailed Report, Please Wait..."
        Write-Host
        Sleep -Seconds 2
        get-content -path c:\temp\Hawk\$TenantName\*\_Investigate.txt
       } 
          }
       }
    }
    }
    } else {
    Write-Host
    # Exit Hawk User Investigation Module
    Get-PSSession | Remove-PSSession
    Write-Host "Remote Powershell Session Closed Successfully" -ForegroundColor Green
    }
    }

if ($Choice -eq "2") {
    #Get the Username and ObjectID
    Connect-ExchangeOnline -ShowBanner:$false
    $UPN = Read-Host "Enter the user's primary email address (UPN)"
    Start-HawkUserInvestigation -UserPrincipalName $UPN
    Write-Host 
    Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
    Write-Host
    Write-Host "Do you want to collect logs for another user?"
    $Answer = Read-Host "Type Y or N and press Enter."
    if ($Answer -eq "y") {
       $UPN = Read-Host "Enter the user's primary email address (UPN)"
       Start-HawkUserInvestigation -UserPrincipalName $UPN
       Write-Host 
       Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
       Write-Host
    }
       Write-Host "Do you want to collect logs for another user?"
       if ($Answer -eq "y") {
       $Answer = Read-Host "Type Y or N and press Enter."
       $UPN = Read-Host "Enter the user's primary email address (UPN)"
       Start-HawkUserInvestigation -UserPrincipalName $UPN
       Write-Host 
       Write-Host "Do you want to collect logs for another user?"
       if ($Answer -eq "y") {
        $Answer = Read-Host "Type Y or N and press Enter."
        $UPN = Read-Host "Enter the user's primary email address (UPN)"
        Start-HawkUserInvestigation -UserPrincipalName $UPN
        Write-Host 
        Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
        Write-Host
        Write-Host "Do you want to collect logs for another user?"
       if ($Answer -eq "y") {
        $Answer = Read-Host "Type Y or N and press Enter."
        $UPN = Read-Host "Enter the user's primary email address (UPN)"
        Start-HawkUserInvestigation -UserPrincipalName $UPN
        Write-Host 
        Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
        Write-Host
        Write-Host "Do you want to collect logs for another user?"
       if ($Answer -eq "y") {
        $Answer = Read-Host "Type Y or N and press Enter."
        $UPN = Read-Host "Enter the user's primary email address (UPN)"
        Start-HawkUserInvestigation -UserPrincipalName $UPN
        Write-Host 
        Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
        Write-Host
        Write-Host "Do you want to collect logs for another user?"
       if ($Answer -eq "y") {
        $Answer = Read-Host "Type Y or N and press Enter."
        $UPN = Read-Host "Enter the user's primary email address (UPN)"
        Start-HawkUserInvestigation -UserPrincipalName $UPN
        Write-Host 
        Write-Host "Log collection for $UPN is complete!" -ForegroundColor Yellow
        Write-Host
        Write-Host "Loading Investigation Detailed Report, Please Wait..."
        Sleep -Seconds 2
        get-content -path c:\temp\Hawk\$TenantName\*\_Investigate.txt
       }
       }
    }
}   
        Write-Host
        Get-PSSession | Remove-PSSession
        Write-Host 
        Write-Host "Exiting Hawk User Investigation Module" -ForegroundColor Green
        }

}

if ($Choice -eq "3") {
Write-Host    
Write-Host "Exiting Hawk O365 Investigation Module" -ForegroundColor Green
}
#Stop-Transcript
Get-PSSession | Remove-PSSession | out-null
pause