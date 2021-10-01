cls

Write-Host
Write-Host -ForegroundColor Red Starting MITS External Forward Verification Tool
Write-Host
Sleep -Seconds 1

#Check for Microsoft Exchange Online Module and install if not found
Write-Host -ForegroundColor Yellow "Checking for required Modules..."
        If (Get-Module -ListAvailable -name MSOnline) {
            Write-Host "MSOnline Module Detected"
        }
        else {
            Write-Host "MSOnline Module was not found"
            Write-Host "Installing MSOnline Module..."
            Install-Module -Name MSOnline -AllowClobber -WarningAction SilentlyContinue -Force
            Write-Host "Exchange Online Module prerequisite check is complete"
        }

$credential = Get-Credential
Connect-MsolService -Credential $credential
$customers = Get-msolpartnercontract -All
foreach ($customer in $customers) {
 
    $InitialDomain = Get-MsolDomain -TenantId $customer.TenantId | Where-Object {$_.IsInitial -eq $true}
     
    Write-Host "Checking $($customer.Name)"
    $DelegatedOrgURL = "https://outlook.office365.com/powershell-liveid?DelegatedOrg=" + $InitialDomain.Name
    $s = New-PSSession -ConnectionUri $DelegatedOrgURL -Credential $credential -ConfigurationName Microsoft.Exchange -AllowRedirection
    Import-PSSession $s -CommandName Get-Mailbox, Get-InboxRule, Get-AcceptedDomain -AllowClobber
    $mailboxes = $null
    $mailboxes = Get-Mailbox -ResultSize Unlimited
    $domains = Get-AcceptedDomain
 
    foreach ($mailbox in $mailboxes) {
 
        $forwardingRules = $null
 
        Write-Host "Checking rules for $($mailbox.displayname) - $($mailbox.primarysmtpaddress)"
        $rules = get-inboxrule -Mailbox $mailbox.primarysmtpaddress
        $forwardingRules = $rules | Where-Object {$_.forwardto -or $_.forwardasattachmentto}
         
        foreach ($rule in $forwardingRules) {
            $recipients = @()
            $recipients = $rule.ForwardTo | Where-Object {$_ -match "SMTP"}
            $recipients += $rule.ForwardAsAttachmentTo | Where-Object {$_ -match "SMTP"}
            $externalRecipients = @()
 
            foreach ($recipient in $recipients) {
                $email = ($recipient -split "SMTP:")[1].Trim("]")
                $domain = ($email -split "@")[1]
 
                if ($domains.DomainName -notcontains $domain) {
                    $externalRecipients += $email
                }    
            }
 
            if ($externalRecipients) {
                $extRecString = $externalRecipients -join ", "
                Write-Host "$($rule.Name) forwards to $extRecString" -ForegroundColor Yellow
 
                $ruleHash = $null
                $ruleHash = [ordered]@{
                    Customer           = $customer.Name
                    TenantId           = $customer.TenantId
                    PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
                    DisplayName        = $mailbox.DisplayName
                    RuleId             = $rule.Identity
                    RuleName           = $rule.Name
                    RuleDescription    = $rule.Description
                    ExternalRecipients = $extRecString
                }
                $ruleObject = New-Object PSObject -Property $ruleHash
                $ruleObject | Export-Csv C:\temp\customerExternalRules.csv -NoTypeInformation -Append
            }
        }
    }
}