Write-Host 
Write-Host 
Write-Host -ForeGroundColor Red Initiating Advance Managed IT Office 365 MFA Dashboard
Write-Host 
Write-Host
Sleep -Seconds 3
#Create temp directory
if (-Not (Get-Item C:\Temp)) { New-Item -ItemType dir "C:\Temp" }
Write-Host
Write-Host -ForegroundColor Yellow Checking for required Modules...
#Install-PackageProvider -Name NuGet -Force /y 

If (Get-Module -ListAvailable -name NuGet) {
        Write-Host "NuGet Module Detected"
    }
    else {
        Write-Host "NuGet Module was not found"
        Write-Host "Installing NuGet Module..."
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    }

#Check for Microsoft Exchange Online Module and install if not found

If (Get-Module -ListAvailable -name MSOnline) {
        Write-Host "MSOnline Module Detected"
    }
    else {
        Write-Host "MSOnline Module was not found"
        Write-Host "Installing MSOnline Module..."
        Install-Module -Name MSOnline -RequiredVersion 1.1.183.17 -AllowClobber -WarningAction SilentlyContinue -Force
    }

#Check for Dashimo Module and install if not found

If (Get-Module -ListAvailable -name Dashimo) {
        Write-Host "Dashimo Module Detected"
    }
    else {
        Write-Host "Dashimo Module was not found"
        Write-Host "Installing Dashimo Module..."
        Install-Module -Name Dashimo -Force -AllowClobber
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
#Connect to Exchange Online
Connect-MsolService -Credential $Credential
Import-Module MsOnline -WarningAction SilentlyContinue -ErrorAction SilentlyContinue > $null
Write-Host -ForegroundColor Green Connected to Microsoft Exchange Online
#Process customer tenants for GA accounts with MFA set to DISABLED (Requires Partner Delegated Admin Account Permission - ex: mitsdemo.com)
Write-Host
Write-Host -ForegroundColor Yellow Processing MITS Partner Tenants - Please Wait... 
$customers = Get-MsolPartnerContract -ErrorAction SilentlyContinue
$role = Get-MsolRole | Where-Object {$_.name -contains "Company Administrator"} -ErrorAction SilentlyContinue
foreach($customer in $customers){
     
    $users = Get-MsolUser -TenantId $customer.tenantid -all -ErrorAction SilentlyContinue
    $admins = Get-MsolRoleMember -TenantId $customer.tenantid -RoleObjectId $role.objectid -ErrorAction SilentlyContinue
 
    foreach($admin in $admins){
        $adminuser = $users | Where-Object {$_.userprincipalname -contains $admin.emailaddress}
        if($adminuser){
            if($adminuser.strongauthenticationrequirements.state -notcontains "Enforced" -and $adminuser.strongauthenticationrequirements.state -notcontains "Enabled"){
                Write-Host -ForegroundColor Red "MFA is disabled for $($adminuser.userprincipalname)"
                $adminuser | Add-Member TenantId $customer.tenantid
                $adminuser | Add-Member CustomerName $customer.name
                $adminuser | Select DisplayName,UserPrincipalName,@{N="MFA Status"; E={ if( $_.StrongAuthenticationRequirements.State -ne $null){ $_.StrongAuthenticationRequirements.State} else { "Disabled"}}} | export-csv C:\temp\MITS-PartnerTenantAdmin-GA-MFA_Status.csv -NoTypeInformation -Append
 
            }else{
                Write-Host "MFA is enabled for $($adminuser.userprincipalname)" -ForegroundColor Green
            }
        }
 
   }

}
#Build Dashboard
Write-Host -ForegroundColor Yellow MITS Office 365 Global Admin MFA check is complete!
Write-Host
Write-Host
Write-Host -ForegroundColor Yellow Generating dashboard content...
Write-Host -Foregroundcolor Yellow Filtering for Global Admin accounts with MFA Disabled...
$MITS = Import-Csv "C:\temp\MITS-PartnerTenantAdmin-GA-MFA_Status.csv" | Select DisplayName,UserPrincipalName,"MFA Status"

Dashboard -Name 'MITS - Global Admin MFA Status' -FilePath C:\temp\MITS-GA-MFA-Dashboard.html -Show {
    Tab -Name 'Office 365 GA MFA Status Report' { 
        Section -Name 'MITS O365 Global Admin Accounts with MFA Disabled' {
            Table -DataTable $MITS -HideFooter {
    }}
}
}
