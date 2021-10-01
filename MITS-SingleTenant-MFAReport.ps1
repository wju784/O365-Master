<##################################################################################################
#
.SYNOPSIS
    This script will query the customer's tenant, output MFA Enabled/Disabled state to .csv 
    then leverage the Dashimo powershell module to create a light weight dashbord with the ability 
    to export the data from the report into multiple formats (.xlsx,.csv,.pdf)

.NOTES
    1. Initial .csv file is generated in c:\temp and is titled: MITS-O365User-MFA.csv
    2. Once export is complete, the content will then be imported into Dashimo to generate an html dashboard
    3. The dashboard allows sorting of data by Display Name, UPN, or MFA Status
    4. The Dashimo HTML dashboard is generated in c:\temp and is titled: MITS-UserMFA-Dashboard.html
.HOW-TO
    1. Run script, supply global admin credentials
    2. The script will query the tenant and output user accountsand the associated MFA status to .csv file
    3. The .csv is then ingested by Dashimo module to generate a light weight customizable HTML dashboard to check enforcement status
#>
###################################################################################################
Write-Host 
Write-Host 
Write-Host -ForeGroundColor Red Initiating Advance Managed IT O365 User MFA Dashboard
Write-Host 
Write-Host
Sleep -Seconds 3
#Create temp directory
if (-Not (Get-Item C:\Temp)) { New-Item -ItemType dir "C:\Temp" }
Write-Host -ForegroundColor Yellow Checking for required Modules...
#Install-PackageProvider -Name NuGet -Force /y 

If (Get-Module -ListAvailable -name NuGet) {
        Write-Host "NuGet Module Detected"
    }
    else {
        Write-Host "NuGet Module was not found"
        Write-Host "Installing NuGet Module..."
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201
    }

#Check for Microsoft Exchange Online Module and install if not found

If (Get-Module -ListAvailable -name MSOnline) {
        Write-Host "MSOnline Module Detected"
    }
    else {
        Write-Host "MSOnline Module was not found"
        Write-Host "Installing MSOnline Module..."
        Install-Module -Name MSOnline -RequiredVersion 1.1.183.17 -AllowClobber -WarningAction SilentlyContinue
    }

#Check for Dashimo Module and install if not found

If (Get-Module -ListAvailable -name Dashimo) {
        Write-Host "Dashimo Module Detected"
    }
    else {
        Write-Host "Dashimo Module was not found"
        Write-Host "Installing Dashimo Module..."
        Install-Module -Name Dashimo -AllowClobber
        Write-Host "Module prerequisite check is complete"
    }
Write-Host -ForegroundColor Yellow Checking Package Management Prerequisites
$testpms = powershell choco -v
if(-not($testpms)){
    Write-Output "Package Management System was not found, installing..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
else{
    Write-Output "Version $testpms is already installed" 
}

# or

if(test-path "C:\ProgramData\chocolatey\choco.exe"){

}
Write-Host -ForegroundColor Yellow "Starting Modern Authentication..."
Write-Host 

#Connect to Exchange Online
#Connect-ExchangeOnline -UserPrincipalName scoota-admin@lilscoota.onmicrosoft.com -ShowProgress $true

Connect-MsolService -Credential $Credential
Import-Module MsOnline -WarningAction SilentlyContinue -ErrorAction SilentlyContinue > $null

Write-Host -ForegroundColor Green Connected to Microsoft Exchange Online 
Write-Host
Write-Host -ForegroundColor Yellow Processing Customer Tenant - Please Wait...
Sleep -Seconds 1
Write-Host
Write-Host
#Process customer tenants for user account MFA settings
#Get-MsolUser -TenantId $customer.tenantid -all -ErrorAction SilentlyContinue | Select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | export-csv C:\temp\MITS-O365User-MFA.csv -NoTypeInformation -Append
Get-MsolUser -all -TenantId $_.TenantId.Guid | ? { ($_.UserType -ne “Guest”) -and ($_.isLicensed -eq “True”) } | select Name,DisplayName,UserPrincipalName,BlockCredential,Islicensed,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | export-csv C:\temp\MITS-O365User-MFA.csv -NoTypeInformation -Append




#Build Dashboard
Write-Host -ForegroundColor Green MITS Office 365 User MFA check is complete!
Write-Host
Write-Host
Write-Host -ForegroundColor Yellow Generating Dashboard Content...
Sleep -Seconds 1
$MITS = Import-Csv C:\temp\MITS-O365User-MFA.csv | Select DisplayName,UserPrincipalName,"MFA Status"

Dashboard -Name 'MITS - User MFA Status' -FilePath C:\temp\MITS-UserMFA-Dashboard.html -Show {
    Tab -Name 'Office 365 User MFA Status Report' { 
        Section -Name 'MFA Status for all users' {
            Table -DataTable $MITS -HideFooter {
    }}
}
}
Write-Host
Write-Host
Write-Host -ForegroundColor Magenta Bye Bye!
Sleep -Seconds 2
