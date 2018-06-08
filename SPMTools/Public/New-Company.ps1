<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER

.EXAMPLE

.EXAMPLE

.NOTES


#>
Function New-Company {
    [cmdletBinding()] 
    Param(
	    [Parameter(Mandatory=$True)] 
        [string]$CompanyName,

        [Parameter(Mandatory=$false)]
        [switch]$ADDS,

        [Parameter(Mandatory=$false)]
        [switch]$OnPremExchange,

        [Parameter(Mandatory=$false)]
        [switch]$OnPremSkype,

        [Parameter(Mandatory=$false)]
        [switch]$ExchangeOnline,

        [Parameter(Mandatory=$false)]
        [switch]$SkypeOnline
    )

    #Initial Variable
    $CompanyObj = @{
        Domain = $false
        OnPremServices = @{
            Exchange = $false
            Skype = $false
            CredentialName = $false
        }
        O365 = $false
    }

    if($ADDS) {
        $CompanyObj.Domain = @{
            PSDriveLetter = ''
            FQDN = ''
            PreferedDomainController = $false
            AutoConnect = $false
            CredentialName = $false
        }
    }

    if($OnPremExchange) {
        $CompanyObj.OnPremServices.Exchange = @{
            Uri = ''
        }
    }

    if($OnPremSkype) {
        $CompanyObj.OnPremServices.Skype = @{
            Uri = ''
        }
    }

    if($ExchangeOnline -or $SkypeOnline) {
        $CompanyObj.O365 = @{
            Mfa = $false
            ExchangeOnlineUri = $false
            SkypeOnlineUri = $false
            CredentialName = $false
        }
    }

    $script:Config.Companies.Add($CompanyName,$CompanyObj)
    Write-Configuration
}