
Function Set-Company {
    [cmdletBinding()] 
    Param(
        [Parameter(Mandatory=$true)] 
        [string]$Company,


        # AD Set
	    [Parameter(
            ParameterSetName='AD',
            Mandatory=$true
        )] 
        [string]$ADDriveName,

        [Parameter(
            ParameterSetName='AD',
            Mandatory=$true
        )] 
        [string]$ADFQDN,

        [Parameter(
            ParameterSetName='AD',
            Mandatory=$false
        )] 
        [string]$ADPreferedDomainController,

        [Parameter(
            ParameterSetName='AD',
            Mandatory=$false
        )] 
        [switch]$ADNoAutoConnect,

        [Parameter(
            ParameterSetName='AD',
            Mandatory=$false
        )] 
        [pscredential]$ADCredential,


        # OnPrem Set
        [Parameter(
            ParameterSetName='OnPrem',
            Mandatory=$false
        )] 
        [string]$OnPremExchangeHost,

        [Parameter(
            ParameterSetName='OnPrem',
            Mandatory=$false
        )] 
        [string]$OnPremExchangeURI,

        [Parameter(
            ParameterSetName='OnPrem',
            Mandatory=$false
        )] 
        [string]$OnPremSkypeHost,

        [Parameter(
            ParameterSetName='OnPrem',
            Mandatory=$false
        )] 
        [string]$OnPremSkypeURI,

        [Parameter(
            ParameterSetName='OnPrem',
            Mandatory=$false
        )] 
        [pscredential]$OnPremCredential,


        # Online Set
        [Parameter(
            ParameterSetName='Online',
            Mandatory=$false
        )] 
        [switch]$OnlineNoMFA,

        [Parameter(
            ParameterSetName='Online',
            Mandatory=$false
        )] 
        [string]$OnlineExchangeURI,

        [Parameter(
            ParameterSetName='Online',
            Mandatory=$false
        )] 
        [string]$OnlineSkypeURI,

        [Parameter(
            ParameterSetName='Online',
            Mandatory=$true
        )] 
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

    $CompanyObj = $Script:Config.Companies.$Company

    ## AD Settings
    if($PSCmdlet.ParameterSetName -eq 'AD') {
        # Inital Settings
        if(!$CompanyObj.Domain) {
            $CompanyObj.Domain = @{
                PSDriveLetter = ''
                FQDN = ''
                PreferedDomainController = $false
                AutoConnect = $true
                CredentialName = $false
            }
        }

        # Addition of Paramaters
        if($ADDriveName) {
            $CompanyObj.Domain.PSDriveLetter = $ADDriveName
        }

        if($ADFQDN) {
            $CompanyObj.Domain.FQDN = $ADFQDN
        }

        if($ADPreferedDomainController) {
            $CompanyObj.Domain.PreferedDomainController = $ADPreferedDomainController
        }

        if($ADNoAutoConnect) {
            $CompanyObj.Domain.AutoConnect = $false
        }
        else {
            $CompanyObj.Domain.AutoConnect = $true
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
    }

    ## On-Prem Services Settings
    if($PSCmdlet.ParameterSetName -eq 'OnPrem') {
        # OnPrem does not have inital settings as these are set
        # by New-Company

        # Addition of Paramaters
        if($OnPremExchangeHost) {
            $Uri = "http://$OnPremExchangeHost/PowerShell/"
            $CompanyObj.OnPremServices.ExchangeURI = $Uri
        }

        if($OnPremExchangeURI) {
            $CompanyObj.OnPremServices.ExchangeURI = $OnPremExchangeURI
        }

        if($OnPremSkypeHost) {
            $Uri = "http://$OnPremSkypeHost/PowerShell/"
            $CompanyObj.OnPremServices.SkypeURI = $Uri
        }

        if($OnPremSkypeURI) {
            $CompanyObj.OnPremServices.SkpyeURI = $OnPremSkypeURI
        }

        if($OnPremCredential) {
            $Param = @{
                Target = "OnPrem_$Company" 
                Persist = 'Enterprise' 
                Credentials = $OnPremCredential
            }
            $null = New-StoredCredential @Param
            $CompanyObj.OnPremServices.CredentialName = "OnPrem_$Company"
        }
    }

    ## Office365 Configuration
    if($PSCmdlet.ParameterSetName -eq 'Online') {
        # Initial Settings
        if(!$CompanyObj.O365) {
            $CompanyObj.O365 = @{
                Mfa = $false
                ExchangeOnlineUri = $false
                SkypeOnlineUri = $false
                CredentialName = $false
            }
        }

        # Addition of Paramaters
        if($OnlineNoMFA -eq $true) {
            $CompanyObj.O365.Mfa = $false
        }
        else {
            $CompanyObj.O365.Mfa = $true
        }

        if($OnlineExchangeURI) {
            $CompanyObj.O365.ExchangeOnlineUri = $OnlineExchangeURI
        }
        else {
            $CompanyObj.O365.ExchangeOnlineUri = 'https://outlook.office365.com/powershell-liveid'
        }

        if($OnlineSkypeURI) {
            $CompanyObj.O365.SkypeOnlineUri = $OnlineSkypeURI
        }
        else {
            # This default is not used due to New-CSOnlineSession
            $CompanyObj.O365.SkypeOnlineUri = 'https://online.lync.com'
        }

        if($OnlineSharePointURI) {
            $CompanyObj.O365.SharePointOnlineUri = $OnlineSharePointURI
        }
        else {
            # This tells Connect-SharePointOnline to use the logon name instead
            $CompanyObj.O365.SharePointOnlineUri = $false
        }

        if($OnlineCredential) {
            $Param = @{
                Target = "O365_$Company" 
                Persist = 'Enterprise' 
                Credentials = $OnlineCredential
            }
            $null = New-StoredCredential @Param
            $CompanyObj.O365.CredentialName = "O365_$Company"
        }
    }

    ## Credential removal
    if($RemoveADCredential) {
        Remove-StoredCredential -Target "AD_$Company"
        $CompanyObj.Domain.CredentialName = $false
    }

    if($RemoveOnPremCredential) {
        Remove-StoredCredential -Target "OnPrem_$Company"
        $CompanyObj.OnPremServices.CredentialName = $false
    }

    if($RemoveOnlineCredential) {
        Remove-StoredCredential -Target "O365_$Company"
        $CompanyObj.O365.CredentialName = $false
    }

    $script:Config.Companies.$Company = $CompanyObj
    Write-SPMTConfiguration
}