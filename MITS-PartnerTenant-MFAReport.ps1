<##################################################################################################
#
.SYNOPSIS
    This script will leverage Partner delegated administration to query each customer's tenant, output MFA Enabled/Disabled state to .csv 
    Dashimo powershell module is used to create a light weight dashbord with the ability to export to: .xlsx,.csv,.pdf

.NOTES
    1. Initial .csv file is generated in c:\temp and is titled: MITS-PartnerTenant-MFA.csv
    2. Once export is complete, the content will then be imported into Dashimo to generate an html dashboard
    3. The dashboard allows sorting of data by Display Name, UPN, or MFA Status
    4. The Dashimo HTML dashboard is generated in c:\temp and is titled: MITS-UserMFA-Dashboard.html
.HOW-TO
    1. Run script, supply global admin credentials
    2. The script will query the tenant and output user accountsand the associated MFA status to .csv file
    3. The .csv is then ingested by Dashimo module to generate a light weight customizable HTML dashboard to check enforcement status
#>
###################################################################################################
Clear
Write-Output '--------------------------------------------------------------------------------'
Write-Output '--------------------------------------------------------------------------------'
Write-Host -ForegroundColor Red "                Starting MITS Office 365 Partner Tenant MFA Status Report"
Write-Output '--------------------------------------------------------------------------------'
Write-Output '--------------------------------------------------------------------------------'
Write-Host
#Test Temp Directory
Test-Path -Path 'C:\Temp\' | out-null
[string]$TempPath = 'C:\temp\'
# Create folder if does not exist
if (!(Test-Path -Path $TempPath))
{
    $paramNewItem = @{
        Path      = $TempPAth
        ItemType  = 'Directory'
        Force     = $true
    }

    New-Item @paramNewItem
}
#Powershell Module Pre-req check
Write-Host -Foregroundcolor Yellow "Checking for Required PowerShell Modules, please wait..."
Sleep -Seconds 2

#NuGet Powershell Module Check 
Sleep -Seconds 1 
# Check if the NuGet PowerShell module has already been loaded.
if ( ! ( Get-Module NuGet ) ) {
    # Check if the NuGet PowerShell module is installed.
    if ( Get-Module -ListAvailable -Name NuGet ) {
        # The NuGet PowerShell module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor White "Loading the NuGet PowerShell module..."
        Import-Module NuGet
    } else {
        #Write-Host "Installing NuGet Module, please wait..."  
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | out-null
        #Write-Host -ForegroundColor Green "NuGet PowerShell Module installed successfully"
    }
}
Sleep -Seconds 1 
# Check if the MSOnline PowerShell module has already been loaded.
if ( ! ( Get-Module MSOnline ) ) {
    # Check if the MSOnline PowerShell module is installed.
    if ( Get-Module -ListAvailable -Name MSOnline ) {
        # The MSOnline PowerShell module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor White "Loading the MSOnline PowerShell module..."
        Import-Module MSOnline
    } else {
        Write-Host "Installing MSOnline Module, please wait..."  
        Install-Module MSOnline -Force 
        Write-Host -ForegroundColor Green "MSOnline PowerShell Module installed successfully"
    }
}
Sleep -Seconds 1 
# Check if the Dashimo PowerShell module has already been loaded.
if ( ! ( Get-Module Dashimo ) ) {
    # Check if the Dashimo PowerShell module is installed.
    if ( Get-Module -ListAvailable -Name Dashimo ) {
        # The Dashimo PowerShell module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor White "Loading the Dashimo PowerShell module..."
        Import-Module Dashimo
    } else {
        Write-Host "Installing Dashimo Module, please wait..."  
        Install-Module Dashimo -Force
        Write-Host -ForegroundColor Green "Dashimo PowerShell Module installed successfully"
    }
}

Write-Host -ForegroundColor White "Starting Authentication, Please Wait..." 
Write-Host -ForegroundColor Yellow "Warning: Office 365 authentication window may pop-up under the PowerShell window"
 try

{
    Get-MsolDomain -ErrorAction Stop > $null
}
catch 
{
    if ($cred -eq $null) {$cred = Connect-MsolService }
}


function User-MFA {
param()
$customers = Get-MsolPartnerContract -ErrorAction SilentlyContinue
foreach($customer in $customers){
     
    $users = Get-MsolUser -TenantId $customer.tenantid -all | where {$_.isLicensed -eq $true} -ErrorAction SilentlyContinue 
 
    foreach($user in $users){
          
            if($user.strongauthenticationrequirements.state -notcontains "Disabled" -and $user.strongauthenticationrequirements.state -notcontains "Enabled"){
                Write-Host "MFA is enabled for $($user.userprincipalname)" -ForegroundColor Green
                $user | Add-Member TenantId $customer.tenantid
                $user | Add-Member CustomerName $customer.name
                $user | Select CustomerName,DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} 
 
            }else{
                Write-Host "MFA is disabled for $($user.userprincipalname)" -ForegroundColor Red 
            }
        }
 
   } 
}
User-MFA | export-csv -path C:\temp\MITS-PartnerTenant-MFA.csv -NoTypeInformation -Append   #| Export-Excel -Now -Path c:\temp\MITS-UserMFA-Status.xlsx

Write-Host -ForegroundColor Yellow Generating dashboard content...
Sleep -Seconds 1
$MITS = Import-Csv C:\temp\MITS-PartnerTenant-MFA.csv | Select CustomerName,DisplayName,UserPrincipalName,"MFA Status"
#
Dashboard -Name 'MITS - Office 365 MFA Status ' -FilePath C:\temp\MITS-PartnerTenant-MFA.html -Show {
    Tab -Name 'Office 365 Partner Tenant MFA Status Report' { 
        Section -Name 'MFA Status for all Office 365 accounts - Partner Tenants' {
            Table -DataTable $MITS -HideFooter {
            
   }}
}
}
pause