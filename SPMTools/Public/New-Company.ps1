<#
.SYNOPSIS
Enables a user's mailbox in Office365.


.DESCRIPTION
Enable-AzureADMailbox enables a remote mailbox for a user and licenses them.


.PARAMETER $UserPrincipalName 
The UserPrincipalName of the user to be enabled. 
Can be piped from Get-ADUser.


.PARAMETER $PrimarySuffix
The suffix of the users send from email.
This should be the part after the '@' sign without including the '@'.


.PARAMETER $AzureSku
The license tier for the user. 
This parameter supports tab-completion. Default is E1.


.EXAMPLE
Enable the O365 mailbox for Latisha.Example@example.com as an E3 Sku 
with a send from email of Larisha.Example@example.com
Enable-AzureADMailbox -UserPrincipalName Latisha.Example@example.com -AzureSku E3

.EXAMPLE
Enable the O365 mailbox for Person.Example@example.com as an E1 Sku 
with a send from email of Person.Example@gmail.com
Enable-AzureADMailbox -UserPrincipalName Person.Example@example.com -PrimarySuffix gmail.com

.NOTES
This command requires:
 - AzureAD Module
 - Connect- Cmdlets

#>
Function New-Company {
    [cmdletBinding()] 
    Param(
	    [Parameter(Mandatory=$True)] 
        [string]$CompanyName
    )

    #Variables
    $YesNoTable = @{
        y = $True
        n = $false
    }

    $CompanyObj = @{
        Domain = $false
        OnPremServices = @{
            Exchange = $false
            Skype = $false
        }
        O365 = $false
    }


    Write-Host "This Cmdlet will walk you through setting up a Company in SPMTools"


    #Service Selection Questions
    $Response = ''
    While ($Response.ToLower() -ne 'y' -or $Response.ToLower() -ne 'n') {
        $Response = Read-Host -Prompt "Does this Company have an AD Domain?`n[Y] Yes   [N] No:"
    }
    $CompanyObj.Domain = $YesNoTable[$Response.ToLower()]

    $Response = ''
    While ($Response.ToLower() -ne 'y' -or $Response.ToLower() -ne 'n') {
        $Response = Read-Host -Prompt "Does this Company have an On-Premise Exchange Server or Hybrid Server?`n[Y] Yes   [N] No:"
    }
    $CompanyObj.OnPremServices.Exchange = $YesNoTable[$Response.ToLower()]

    $Response = ''
    While ($Response.ToLower() -ne 'y' -or $Response.ToLower() -ne 'n') {
        $Response = Read-Host -Prompt "Does this Company have an On-Premise Skype Server?`n[Y] Yes   [N] No:"
    }
    $CompanyObj.OnPremServices.Skype = $YesNoTable[$Response.ToLower()]

    $Response = ''
    While ($Response.ToLower() -ne 'y' -or $Response.ToLower() -ne 'n') {
        $Response = Read-Host -Prompt "Does this Company use Office 365?`n[Y] Yes   [N] No:"
    }
    $CompanyObj.O365 = $YesNoTable[$Response.ToLower()]


    #ADDS Questions
    
}