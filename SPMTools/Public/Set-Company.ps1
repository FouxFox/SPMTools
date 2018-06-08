#
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
        [Parameter(Mandatory=$true)] 
        [string]$Company,

	    [Parameter(Mandatory=$false)] 
        [string]$ADDriveName,

        [Parameter(Mandatory=$false)]
        [string]$ADFQDN,

        [Parameter(Mandatory=$false)]
        [string]$ADPreferedDomainController,

        [Parameter(Mandatory=$false)]
        [switch]$ADAutoConnect,

        [Parameter(Mandatory=$false)]
        [pscredential]$ADCredential,

        [Parameter(Mandatory=$false)]
        [string]$OnPremExchangeHost,

        [Parameter(Mandatory=$false)]
        [string]$OnPremExchangeURI,

        [Parameter(Mandatory=$false)]
        [string]$OnPremSkypeHost,

        [Parameter(Mandatory=$false)]
        [string]$OnPremSkypeURI,

        [Parameter(Mandatory=$false)]
        [pscredential]$OnPremCredential,

        [Parameter(Mandatory=$false)]
        [switch]$OnlineMFA,

        [Parameter(Mandatory=$false)]
        [string]$OnlineExchangeURI,

        [Parameter(Mandatory=$false)]
        [string]$OnlineSkypeURI,

        [Parameter(Mandatory=$false)]
        [pscredential]$OnlineCredential,

        [Parameter(Mandatory=$false)]
        [Switch]$RemoveADCredential,

        [Parameter(Mandatory=$false)]
        [switch]$RemoveOnPremCredential,

        [Parameter(Mandatory=$false)]
        [switch]$RemoveOnlineCredential
    )

    if(!$script:Config.Companies.ContainsKey($Company)) {
        Throw "Company not found. Please create one with New-Company"
    }

    $CompanyObj = $Script:Config.Companies[$Company]

    ## AD Settings
    if($ADDriveName) {
        $CompanyObj.Domain.PSDriveLetter = $ADDriveName
    }

    if($ADFQDN) {
        $CompanyObj.Domain.FQDN = $ADFQDN
    }

    if($ADPreferedDomainController) {
        $CompanyObj.Domain.PreferedDomainController = $ADPreferedDomainController
    }

    if($ADAutoConnect) {
        $CompanyObj.Domain.AutoConnect = $ADAutoConnect
    }

    if($ADCredential) {
        $Param = @{
			Target = "AD_$Company" 
			Persist = 'Enterprise' 
			Credentials = $ADCredential
		}
		$null = New-StoredCredential @Param
        $CompanyObj.Domain.CredentialName = "AD_$Company"
    }

    ## On-Prem Services Settings
    if($OnPremExchangeHost) {
        $Uri = "http://$OnPremExchangeHost/PowerShell/"
        $CompanyObj.OnPremServices.Exchange.URI = $Uri
    }
}