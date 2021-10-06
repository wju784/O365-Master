<##################################################################################################
#
.SYNOPSIS
    The following links provide access to packaged & customized versions of multiple scripts that are used during the indicent response
    investigation process. The customized version is due to each tool having multiple powershell module dependicies prior to connecting
    to the tenant and extracting audit log data. 


.NOTES
    1. Logs extracted are in .csv file format and are generated in c:\temp 
    2. Once export is complete, the content will then be imported into Dashimo to generate an html dashboard
    3. The dashboard allows sorting of data by Display Name, UPN, or MFA Status
    4. The Dashimo HTML dashboard is generated in c:\temp and is titled: MITS-UserMFA-Dashboard.html
.HOW-TO
    1. Run script, supply global admin credentials
    2. The script will query the tenant and output user accountsand the associated MFA status to .csv file
    3. The .csv is then ingested by Dashimo module to generate a light weight customizable HTML dashboard to check enforcement status
#>
###################################################################################################

### Incident Response ###
# Hawk - User & Tenant Investigation Tool
Invoke-WebRequest 'https://raw.githubusercontent.com/wju784/O365-Master/main/MITS-HawkReview.ps1' -OutFile 'MITS-HawkReview.ps1' -UseBasicParsing; .\MITS-HawkReview.ps1

# Sparrow Log Collection Tool
Invoke-WebRequest 'https://raw.githubusercontent.com/wju784/O365-Master/main/MITS-Sparrow.ps1' -OutFile 'MITS-Sparrow.ps1' -UseBasicParsing; .\MITS-Sparrow.ps1

# CrowdStrike Cloud Reporting Tool
Invoke-WebRequest 'https://raw.githubusercontent.com/wju784/O365-Master/main/MITS-CRTReport.ps1' -OutFile 'MITS-CRTReport.ps1' -UseBasicParsing; .\MITS-CRTReport.ps1
###


### MFA Status Reports ###
# MITS Office 365 Partner Global Admin MFA Report
Invoke-WebRequest 'https://raw.githubusercontent.com/wju784/O365-Master/main/MITS-Partner-GA-MFA_Status.ps1' -OutFile 'MITS-Partner-GA-MFA_Status.ps1' -UseBasicParsing; .\MITS-Partner-GA-MFA_Status.ps1

# MITS Office 365 Partner Tenant MFA Report
Invoke-WebRequest 'Invoke-WebRequest 'https://raw.githubusercontent.com/wju784/O365-Master/main/MITS-PartnerTenant-MFAReport.ps1' -OutFile 'MITS-PartnerTenant-MFAReport.ps1' -UseBasicParsing; .\MITS-PartnerTenant-MFAReport.ps1

# MITS Office 365 Single Tenant MFA Report
Invoke-WebRequest 'https://raw.githubusercontent.com/wju784/O365-Master/main/MITS-SingleTenant-MFAReport.ps1' -OutFile 'MITS-SingleTenant-MFAReport.ps1' -UseBasicParsing; .\MITS-SingleTenant-MFAReport.ps1
###


### MITS Mailbox Tools ###
# MITS Office 365 License Export Tool
Invoke-WebRequest 'https://raw.githubusercontent.com/wju784/O365-Master/main/MITS-LicenseExport.ps1' -OutFile 'MITS-LicenseExport.ps1' -UseBasicParsing; .\MITS-LicenseExport.ps1

# MITS Partner Mailbox Forwarding Report
Invoke-WebRequest 'https://raw.githubusercontent.com/wju784/O365-Master/main/MITS-Partner-FWDCheck.ps1' -OutFile 'MITS-Partner-FWDCheck.ps1' -UseBasicParsing; .\MITS-Partner-FWDCheck.ps1

# MITS Mailbox Size Report
Invoke-WebRequest 'https://raw.githubusercontent.com/wju784/O365-Master/main/MITS-MailboxSizeReport.ps1' -OutFile 'MITS-MailboxSizeReport.ps1' -UseBasicParsing; .\MITS-MailboxSizeReport.ps1

# MITS SMTP Test Tool
Invoke-WebRequest 'https://raw.githubusercontent.com/wju784/O365-Master/main/MITS-SMTPTest.ps1' -OutFile 'MITS-SMTPTest.ps1' -UseBasicParsing; .\MITS-SMTPTest.ps1
