cls
#-------------------------------------------------------------------------------------------------------------------
#Set Execution Policy to Bypass
Set-ExecutionPolicy -Scope CurrentUser Bypass -ErrorAction SilentlyContinue -Force | out-null
#-------------------------------------------------------------------------------------------------------------------
Write-Output ''
Write-Output '--------------------------------------------------------------------------------'
Write-Output '--------------------------------------------------------------------------------'
Write-Host -ForegroundColor Red "                Starting MITS Office 365 License Export Tool"
Write-Output '--------------------------------------------------------------------------------'
Write-Output '--------------------------------------------------------------------------------'
Sleep -Seconds 2
Write-Host
#Create Temp Directory
New-Item -ItemType directory -Path C:\temp\ -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | out-null

#Start Transcript log of script activity
Start-Transcript -path c:\temp\LicenseTranscript.txt | out-null

#Powershell Module Pre-req check
Write-Host -Foregroundcolor Yellow "Checking for Required PowerShell Modules, Please Wait..."
Sleep -Seconds 2

#NuGet Powershell Module Check 
Sleep -Seconds 1 
# Check if the NuGet PowerShell module has already been loaded.
if ( ! ( Get-Module NuGet ) ) {
    # Check if the NuGet PowerShell module is installed.
    if ( Get-Module -ListAvailable -Name NuGet ) {
        # The NuGet PowerShell module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor White "NuGet PowerShell Module Detected, Loading Module..."
        Import-Module NuGet
    } else {
        Write-Host "Installing NuGet Module, Please Wait..."  
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | out-null
        Write-Host -ForegroundColor Green "NuGet PowerShell Module Installation Complete!"
    }
}

Sleep -Seconds 1 
# Check if the MSOnline PowerShell module has already been loaded.
if ( ! ( Get-Module MSOnline ) ) {
    # Check if the MSOnline PowerShell module is installed.
    if ( Get-Module -ListAvailable -Name MSOnline ) {
        # The MSOnline PowerShell module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor White "MSOnline PowerShell Module Detected, Loading Module..."
        Import-Module MSOnline
    } else {
        Write-Host "Installing MSOnline Module, Please Wait..."  
        Install-Module MSOnline -Force
        Write-Host "MSOnline Powershell Module Installation Complete!"
    }
}

Sleep -Seconds 1 
# Check if the ImportExcel PowerShell module has already been loaded.
if ( ! ( Get-Module ImportExcel ) ) {
    # Check if the ImportExcel PowerShell module is installed.
    if ( Get-Module -ListAvailable -Name ImportExcel ) {
        # The ImportExcel PowerShell module is not load and it is installed. This module
        # must be loaded for other operations performed by this script.
        Write-Host -ForegroundColor White "ImportExcel PowerShell Module Detected, Loading Module..."
        Import-Module ImportExcel
    } else {
        Write-Host "Installing ImportExcel Module, Please Wait..."  
        Install-Module ImportExcel -Force
        Write-Host -ForegroundColor Green "ImportExcel PowerShell Module Installed Successfully"
    }
}
Write-Host -ForegroundColor Green "                                  Done!"
Write-Output '--------------------------------------------------------------------------------'
Write-Host 
Write-Host -ForegroundColor White "Starting Authentication, Please Wait..." 
Write-Host -ForegroundColor Yellow "Warning: Office 365 authentication window may pop-up under the PowerShell window" 
Write-Host
Sleep -Seconds 2
#Check for existing session and connect to Exchange Online
try

{
    Get-MsolDomain -ErrorAction Stop > $null
}
catch 
{
    if ($cred -eq $null) {$cred = Connect-MsolService }
}

#Connect-MSOLService -Credential $Cred
#Import-Module MSOnline

Write-Output '--------------------------------------------------------------------------------'
Write-Host -ForegroundColor Yellow 'Exporting Office 365 License Report for all MITS customers, Please Wait...' 
Write-Output '--------------------------------------------------------------------------------'

Sleep -Seconds 2 

$clients = Get-MsolPartnerContract -All

$Sku = @{
    "O365_BUSINESS_ESSENTIALS"      = "Office 365 Business Essentials"
    "O365_BUSINESS_PREMIUM"      = "Office 365 Business Premium"
    "DESKLESSPACK"      = "Office 365 (Plan F1)"
    "DESKLESSWOFFPACK"      = "Office 365 (Plan K2)"
    "LITEPACK"      = "Office 365 Small Business"
    "LITEPACK_P2"    = "Office 365 Small Business Premium"
    "WACONEDRIVESTANDARD"    = "OneDrive for Busines (Plan 1)"
    "WACONEDRIVEENTERPRISE"    = "OneDrive for Business (Plan 2)"
    "POWERAPPS_PER_USER"  = "Power Apps (Per User Plan)"
    "EXCHANGESTANDARD"      = "Office 365 Exchange Online Only"
    "STANDARDPACK"      = "Enterprise Plan E1"
    "MIDSIZEPACK"    = "Office 365 Midsize Business"
    "STANDARDWOFFPACK"      = "Office 365 (Plan E2)"
    "ENTERPRISEPACK" = "Enterprise Plan E3"
    "ENTERPRISEPACKLRG"      = "Enterprise Plan E3"
    "ENTERPRISEWITHSCAL" = "Enterprise Plan E4"
    "STANDARDPACK_STUDENT"      = "Office 365 (Plan A1) for Students"
    "STANDARDWOFFPACKPACK_STUDENT"      = "Office 365 (Plan A2) for Students"
    "ENTERPRISEPACK_STUDENT" = "Office 365 (Plan A3) for Students"
    "ENTERPRISEWITHSCAL_STUDENT" = "Office 365 (Plan A4) for Students"
    "STANDARDPACK_FACULTY"      = "Office 365 (Plan A1) for Faculty"
    "STANDARDWOFFPACKPACK_FACULTY"      = "Office 365 (Plan A2) for Faculty"
    "ENTERPRISEPACK_FACULTY" = "Office 365 (Plan A3) for Faculty"
    "ENTERPRISEWITHSCAL_FACULTY" = "Office 365 (Plan A4) for Faculty"
    "ENTERPRISEPREMIUM_FACULTY"    = "Office 365 (Plan A5) for Faculty"
    "ENTERPRISEPREMIUM_STUDENT"    = "Office 365 (Plan A5) for Students"
    "DEVELOPERPACK"    = "Office 365 E3 Developer"
    "ENTERPRISEPACK_USGOV_DOD"    = "Office 365 E3 USGOV DOD"
    "ENTERPRISEPACK_USGOV_GCCHIGH"    = "Office 365 E3 USGOV GCCHIGH"
    "WIN10_PRO_ENT_SUB"    = "Windows 10 Enterprise E3"
    "WIN10_VDA_E5"    = "Windows 10 Enterprise E5"
    "ENTERPRISEPACK_B_PILOT" = "Office 365 (Enterprise Preview)"
    "STANDARD_B_PILOT"      = "Office 365 (Small Business Preview)"
    "VISIOCLIENT"      = "Visio Online (Plan 2)"
    "POWER_BI_ADDON" = "Office 365 Power BI Addon"
    "POWER_BI_INDIVIDUAL_USE"      = "Power BI Individual User"
    "POWER_BI_STANDALONE"      = "Power BI Stand Alone"
    "POWER_BI_STANDARD"      = "Power BI (Free)"
    "POWER_BI_PRO"    = "Power BI Pro"
    "PROJECTESSENTIALS"      = "Project Online Essentials"
    "PROJECTCLIENT"      = "Project for Office 365"
    "PROJECTONLINE_PLAN_1"      = "Project Online Premium (Without Project Client)"
    "PROJECTONLINE_PLAN_2"      = "Project Online with Project for Office 365"
    "SHAREPOINTSTANDARD"    = " SharePoint Online (Plan 1)"
    "SHAREPOINTENTERPRISE"    = "SharePoint Online (Plan 2)"
    "MCOIMP"    = "Skype for Business Online (Plan 1)"
    "MCOIMPSTANDARD"    = "Skype for Business Online (Plan 2)"
    "MCOPSTN2"    = " Skype for Business PSTN Domestic & International Calling"
    "MCOPSTN1"    = "Skype for Business PSTN Domestic Calling"
    "MCOPSTN5"    = "Skype for Business PSTN Domesitc Calling (120 Minutes)"
    "WINDOWS_STORE"    = "Windows Store for Business"
    "ProjectPremium" = "Project Online Premium"
    "ECAL_SERVICES"      = "ECAL"
    "EMS"      = "Enterprise Mobility Suite"
    "RIGHTSMANAGEMENT_ADHOC" = "Windows Azure Rights Management"
    "MCOMEETADV" = "Audio Conferencing"
    "SHAREPOINTSTORAGE"      = "SharePoint storage"
    "PLANNERSTANDALONE"      = "Planner Standalone"
    "BI_AZURE_P1"      = "Power BI Reporting and Analytics"
    "INTUNE_A"      = "Microsoft Intune"
    "M365EDU_A1"    = " Microsoft 365 A1"
    "M365EDU_A3_FACULTY"    = "Microsoft 365 A3 for Faculty"
    "M365EDU_A3_STUDENT"    = "Microsoft 365 A3 for Students"
    "M365EDU_A5_FACULTY"    = "Microsoft 365 A5 for Faculty"
    "M365EDU_A5_STUDENT"    = "Microsoft 365 A5 for Students"
    "PROJECTWORKMANAGEMENT"      = "Office 365 Planner Preview"
    "ATP_ENTERPRISE" = "Office 365 Advanced Threat Protection (Plan 1)"
    "EQUIVIO_ANALYTICS"      = "Office 365 Advanced eDiscovery"
    "AAD_BASIC"      = "Azure Active Directory Basic"
    "RMS_S_ENTERPRISE"      = "Azure Active Directory Rights Management"
    "AAD_PREMIUM"      = "Azure Active Directory Premium"
    "MFA_PREMIUM"      = "Azure Multi-Factor Authentication"
    "STANDARDPACK_GOV"      = "Microsoft Office 365 (Plan G1) for Government"
    "STANDARDWOFFPACK_GOV"      = "Microsoft Office 365 (Plan G2) for Government"
    "ENTERPRISEPACK_GOV" = "Microsoft Office 365 (Plan G3) for Government"
    "ENTERPRISEWITHSCAL_GOV" = "Microsoft Office 365 (Plan G4) for Government"
    "DESKLESSPACK_GOV"      = "Microsoft Office 365 (Plan K1) for Government"
    "ESKLESSWOFFPACK_GOV"      = "Microsoft Office 365 (Plan K2) for Government"
    "EXCHANGESTANDARD_GOV"      = "Microsoft Office 365 Exchange Online (Plan 1) only for Government"
    "EXCHANGEENTERPRISE_GOV" = "Microsoft Office 365 Exchange Online (Plan 2) only for Government"
    "SHAREPOINTDESKLESS_GOV" = "SharePoint Online Kiosk"
    "EXCHANGE_S_DESKLESS_GOV"      = "Exchange Kiosk"
    "RMS_S_ENTERPRISE_GOV"      = "Windows Azure Active Directory Rights Management"
    "OFFICESUBSCRIPTION_GOV" = "Office ProPlus"
    "MCOSTANDARD_GOV"      = "Lync Plan 2G"
    "SHAREPOINTWAC_GOV"      = "Office Online for Government"
    "SHAREPOINTENTERPRISE_GOV"      = "SharePoint Plan 2G"
    "EXCHANGE_S_ENTERPRISE_GOV"      = "Exchange Plan 2G"
    "EXCHANGE_S_ARCHIVE_ADDON_GOV"      = "Exchange Online Archiving"
    "EXCHANGE_S_DESKLESS"      = "Exchange Online Kiosk"
    "SHAREPOINTDESKLESS" = "SharePoint Online Kiosk"
    "SHAREPOINTWAC"      = "Office Online"
    "YAMMER_ENTERPRISE"      = "Yammer for the Starship Enterprise"
    "EXCHANGE_L_STANDARD"      = "Exchange Online (Plan 1)"
    "MCOLITE"      = "Lync Online (Plan 1)"
    "SHAREPOINTLITE" = "SharePoint Online (Plan 1)"
    "OFFICE_PRO_PLUS_SUBSCRIPTION_SMBIZ" = "Office ProPlus"
    "SMB_BUSINESS"    = "Microsoft 365 Apps for Business"
    "EXCHANGE_S_STANDARD_MIDMARKET"      = "Exchange Online (Plan 1)"
    "MCOSTANDARD_MIDMARKET"      = "Lync Online (Plan 1)"
    "SHAREPOINTENTERPRISE_MIDMARKET" = "SharePoint Online (Plan 1)"
    "OFFICESUBSCRIPTION" = "Microsoft 365 Apps for Enterprise"
    "YAMMER_MIDSIZE" = "Yammer"
    "DYN365_ENTERPRISE_PLAN1"      = "Dynamics 365 Customer Engagement Plan Enterprise Edition"
    "ENTERPRISEPREMIUM_NOPSTNCONF"      = "Office 365 E5 (without Audio Conferencing)"
    "ENTERPRISEPREMIUM"      = "Enterprise E5 (with Audio Conferencing)"
    "MCOSTANDARD"      = "Skype for Business Online Standalone Plan 2"
    "PROJECT_MADEIRA_PREVIEW_IW_SKU" = "Dynamics 365 for Financials for IWs"
    "STANDARDWOFFPACK_IW_STUDENT"      = "Office 365 Education for Students"
    "STANDARDWOFFPACK_IW_FACULTY"      = "Office 365 Education for Faculty"
    "EOP_ENTERPRISE_FACULTY" = "Exchange Online Protection for Faculty"
    "EXCHANGESTANDARD_STUDENT"      = "Exchange Online (Plan 1) for Students"
    "OFFICESUBSCRIPTION_STUDENT" = "Office ProPlus Student Benefit"
    "STANDARDWOFFPACK_FACULTY"      = "Office 365 Education E1 for Faculty"
    "STANDARDWOFFPACK_STUDENT"      = "Microsoft Office 365 (Plan A2) for Students"
    "DYN365_FINANCIALS_BUSINESS_SKU" = "Dynamics 365 for Financials Business Edition"
    "DYN365_FINANCIALS_TEAM_MEMBERS_SKU" = "Dynamics 365 for Team Members Business Edition"
    "FLOW_FREE"      = "Microsoft Flow Free"
    "MCOEV"      = "Microsoft 365 Phone System"
    "MCOEV_DOD"      = "Microsoft 365 Phone System For DOD"
    "MCOEV_FACULTY"      = "Microsoft 365 Phone System For Faculty"
    "MCOEV_GOV"      = "Microsoft 365 Phone System For GCC"
    "MCOEV_GCCHIGH"      = "Microsoft 365 Phone System For GCCHIGH"
    "MCOEVSMB_1"      = "Microsoft 365 Phone System For Small and Medium Business"
    "MCOEV_STUDENT"      = "Microsoft 365 Phone System For Students"
    "MCOEV_TELSTRA"      = "Microsoft 365 Phone System For Telstra"
    "MCOEV_MCOEV_USGOV_DOD"      = "Microsoft 365 Phone System For US GOV DOD"
    "MCOEV_USGOV_GCCHIGH"      = "Microsoft 365 Phone System For US GOV DOD HIGH"
    "WIN_DEF_ATP"      = "Microsoft Defender Advanced Threat Protection"
    "IDENTITY_THREAT_PROTECTION"    = "Microsoft 365 E5 Security"
    "IDENTITY_THREAT_PROTECTION_FOR_EMS_E5"    = "Microsoft 365 E5 Security for EMS E5"
    "IT_ACADEMY_AD"    = "Microsoft Imagine Academy"
    "TEAMS_FREE"    = "Microsoft Teams (Free)"
    "O365_BUSINESS"      = "Office 365 Business"
    "SPB"    = "Microsoft 365 Business Premium"
    "SPE_E3"    = " Microsoft 365 E3"
    "SPE_E5"    = " Microsoft 365 E5"
    "SPE_E3_USGOV_DOD"    = "Microsoft 365 E3 USGOV DOD"
    "SPE_E3_USGOV_GCCHIGH"    = "Microsoft 365 E3 USGOV GCCHIGH"
    "INFORMATION_PROTECTION_COMPLIANCE"    = "Microsoft 365 E5 Compliance"
    "M365_F1"    = "Microsoft 365 F1"
    "SPE_F1"    = "Microsoft 365 F3"
    "DYN365_ENTERPRISE_SALES"      = "Dynamics Office 365 Enterprise Sales"
    "RIGHTSMANAGEMENT"      = "Rights Management"
    "PROJECTPROFESSIONAL"      = "Project Online Professional"
    "VISIOONLINE_PLAN1"      = "Visio Online Plan 1"
    "EXCHANGEENTERPRISE" = "Exchange Online Plan 2"
    "DYN365_ENTERPRISE_P1_IW"      = "Dynamics 365 P1 Trial for Information Workers"
    "DYN365_ENTERPRISE_TEAM_MEMBERS" = "Dynamics 365 For Team Members Enterprise Edition"
    "CRMSTANDARD"      = "Microsoft Dynamics CRM Online"
    "CRMPLAN2"      = "Microsoft Dynamics CRM Online Basic"
    "EXCHANGEARCHIVE_ADDON"      = "Exchange Online Archiving For Exchange Online"
    "EXCHANGEDESKLESS"      = "Exchange Online Kiosk"
    "SPZA_IW"      = "App Connect"
}
 
$msolAccountSkuResults = @()
$msolAccountSkuCsv = "C:\temp\MITS-LicenseExport.csv"

ForEach ($client in $clients) {
 
$licenses = Get-MsolAccountSku -TenantId $client.TenantId
 
foreach ($license in $licenses){

 Write-Host "Resolving $License in SkuPartNumber Hash Table..." -ForegroundColor Yellow
 $LicenseItem = $License.accountskuid -split ":" | Select-Object -Last 1
 $TextLic = $Sku.Item("$LicenseItem")
 
$UnusedUnits = $license.ActiveUnits - $license.ConsumedUnits
 
$licenseProperties = @{
CompanyName = $client.Name
PrimaryDomain = $client.DefaultDomainName
AccountSkuId = $license.AccountSkuId
AccountName = $license.AccountName
SkuPartNumber = $Textlic
ActiveUnits = $license.ActiveUnits
WarningUnits = $license.WarningUnits
ConsumedUnits = $license.ConsumedUnits
UnusedUnits = $unusedUnits
}
 
Write-Host "$($License.AccountSkuId) for $($Client.Name) has $unusedUnits unused licenses" -ForegroundColor White
$msolAccountSkuResults += New-Object psobject -Property $licenseProperties
}
 
}
Write-Host 
Write-Output '--------------------------------------------------------------------------------'
Write-Host "Office 365 License Assignment Export Completed Successfully!" -ForegroundColor Green
Sleep -Seconds 1
Write-Output '--------------------------------------------------------------------------------'
Sleep -Seconds 1

#Excel installation check, if found export to .xlsx and open in excel, if not found export output to .csv in c:\temp directory
$a = test-path HKLM:SOFTWARE\Classes\Excel.Application
IF ($a -eq $true){
Write-Host "Loading Excel Report, Please Wait..."
Write-Host "               Done!" -ForegroundColor Green
$msolAccountSkuResults | Select-Object CompanyName,PrimaryDomain,AccountSkuId,SkuPartNumber,ActiveUnits,ConsumedUnits,UnusedUnits | Export-Excel -Now -path C:\Temp\MITS-LicenseExport.xlsx #| Export-Excel -Show -AutoSize -AutoFilter -Path C:\Temp\MITS-LicenseExport.xlsx 
}ELSE{
Write-Host "Microsoft Excel was not found, report data exported to: C:\Temp\MITS-LicenseExport.csv"
$msolAccountSkuResults | Select-Object CompanyName,PrimaryDomain,AccountSkuId,SkuPartNumber,ActiveUnits,ConsumedUnits,UnusedUnits | Export-Csv -notypeinformation -Encoding UTF8 -Path C:\Temp\MITS-LicenseExport.csv
Write-Host "Opening MITS-LicenseExport.csv in notepad, Please Wait..."
start notepad $msolAccountSkuCsv
}

#Exit Console Session
For ($i=100; $i -gt 0; $i--) {
    Start-Sleep -Milliseconds 30
    Write-Progress -Activity "O365 License Export Complete" -Status "Disconnecting PowerShell Session & Exiting Script..." -PercentComplete $i
}
Get-Pssession | Remove-PSSession
Stop-Transcript | out-null
Write-Host -ForegroundColor magenta "bye bye!"
Sleep -Seconds 1
