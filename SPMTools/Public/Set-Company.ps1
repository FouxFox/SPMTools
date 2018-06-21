<#
.SYNOPSIS
Sets values in a company's profile.

.DESCRIPTION
The Set-Company cmdlet sets values in a company's profiles. There are three sets of parameters that can be used.
 - Active Directory Settings
 - OnPremise Services Settings (Such as Exchange)
 - Office365 Settings

.PARAMETER Name
The Company name that was created with New-Company.

.PARAMETER ADDriveName
The drive letter to use with active directory drives. It is recomended to use between one and
four characters, but any number of characters can be used.

.PARAMETER ADFQDN
The full qualified domain name of the Active Directory Domain for this company.

.PARAMETER ADPreferedDomainController
If specified, SPMTools will use this domain controller for the AD drive.
If this parameter is not specified, the FQDN will be used.

.PARAMETER ADFavorite
Favorites allow Mount-ADDrive to only mount the most used AD drives.
Set this option to mark a Company's AD configuration as a favorite so it can be loaded
with Mount-ADDrive -Favorites

.PARAMETER ADCredential
A PSCredential Object containing the credentials for this company's AD domain.
If not spcified, implicit credentials will be used.

.PARAMETER OnPremExchangeHost
The Exchange server to connect to when using Connect-ExchangeOnPrem.
It is recomended that this host be one of these in order of most to least preffered:
 - The Hybrid Exchange Server (in O365 Hybrid Environments)
 - The Nearest Exchange Server
 - Any other Exchange Server
Please use FQDNs when possible.

.PARAMETER OnPremExchangeURI
In certain circumstances, the Exchange URI may be different than http://Host/Powershell.
In these circumstances, this parameter can be used to specify a separate URI to use when connecting.

.PARAMETER OnPremSkypeHost
The Skype Host to connect to. 
In almost all circumstances, this should be the full Qualified Front End Pool name.

.PARAMETER OnPremSkypeURI
In certain circumstances, the Skype URI may be different than http://Host/OCSPowershell.
In these circumstances, this parameter can be used to specify a separate URI to use when connecting.

.PARAMETER OnPremCredential
A PSCredential Object containing the credentials for this company's services.
If not spcified, implicit credentials will be used.

.PARAMETER OnlineNoMFA
If specified, Online commands will not use MFA when connecting.
It is generally recomended to enable MFA for all admin accounts.

.PARAMETER OnlineExchangeURI
In certain circumstances, the ExchangeOnline URI will be different from the default.
In these circumstances, this parameter can be used to specify a separate URI to use when connecting.

.PARAMETER OnlineSkypeURI
In certain circumstances, the SkypeOnline URI will be different from the default.
In these circumstances, this parameter can be used to specify a separate URI to use when connecting.

.PARAMETER OnlineSharePointURI
The SharePointOnline cmdlet uses a best effort approach to guess the tenant URL. If this fails,
use this parameter to specify the URL. It should look like:
https://{Tenant}-admin.sharepoint.com

.PARAMETER OnlineCredential
A PSCredential Object containing the credentials for this company's online services.
If not spcified, implicit credentials will be used.
This is required even when using MFA, as it will prefill the prompt

.PARAMETER RemoveADCredential
Specify this switch with -Company to remove AD credentials from the specified company.

.PARAMETER RemoveOnPremCredential
Specify this switch with -Company to remove OnPremise services credentials from the specified company.

.PARAMETER RemoveOnlineCredential
Specify this switch with -Company to remove Office365 credentials from the specified company.

.EXAMPLE
Set OnPremise settings for ExampleServices.

Set-Company -Company ExampleServices -ADDriveName ES -ADFQDN example.com -ADCredential example\username

.EXAMPLE
Set Exchange settings for ExampleServices.

Set-Company -Company ExampleServices -OnPremExchangeHost mail.example.com -OnPremCredential example\username

.EXAMPLE
Set Office365 settings for ExampleServices.

Set-Company -Company ExampleServices -OnlineCredential example\username

.EXAMPLE
Set cmdlets to connect without MFA

Set-Company -Company ExampleServices -OnlineCredential example\username -OnlineNoMFA

.NOTES
Company profiles are stored in %APPDATA%\.SPMTools
Credentials are stored securely in the Windows Credential Vault.

#>

Function Set-Company {
    [cmdletBinding()] 
    Param(
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
        [switch]$ADFavorite,

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
            Mandatory=$false
        )] 
        [string]$OnlineSharePointURI,

        [Parameter(
            ParameterSetName='Online',
            Mandatory=$true
        )] 
        [pscredential]$OnlineCredential,
        
        <#
        [Parameter(
            ParameterSetName='Online',
            Mandatory=$false
        )] 
        [string]$OnlineAzureUsageLocation,

        [Parameter(
            ParameterSetName='Online',
            Mandatory=$false
        )] 
        [string]$OnlineRemoteRoutingSuffix,

        [Parameter(
            ParameterSetName='Online',
            Mandatory=$false
        )] 
        [string]$OnlineDirSyncHost,

        [Parameter(
            ParameterSetName='Online',
            Mandatory=$false
        )] 
        [string]$OnlineDirSyncDC,
        #>

        # Removal Set
        [Parameter(Mandatory=$false)]
        [Switch]$RemoveADCredential,

        [Parameter(Mandatory=$false)]
        [switch]$RemoveOnPremCredential,

        [Parameter(Mandatory=$false)]
        [switch]$RemoveOnlineCredential
    )
    DynamicParam {
        $ParameterName = 'Name'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $ParameterAttribute.ValueFromPipeline = $true

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)

        $ValidateSet = $Script:Config.Companies.Keys
        if($ValidateSet.length -gt 0) {
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet)
            $AttributeCollection.Add($ValidateSetAttribute)
        }
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}
    Begin {
        $CompanyName = $PSBoundParameters.Name
        #Validation Error handling
        if(!$Script:Config.Companies.ContainsKey($CompanyName)) {
            $message = "No companies have been set up. Please use the New-Company command to create one."
            $Param = @{
                ExceptionName = "System.ArgumentException"
                ExceptionMessage = $message
                ErrorId = "SetCompanyNoCompaniesAvailable" 
                CallerPSCmdlet = $PSCmdlet
                ErrorCategory = 'InvalidArgument'
            }
            ThrowError @Param
        }

        $CompanyObj = $Script:Config.Companies.$CompanyName

        ## AD Settings
        if($PSCmdlet.ParameterSetName -eq 'AD') {
            # Inital Settings
            if(!$CompanyObj.Domain) {
                $CompanyObj.Domain = @{
                    PSDriveLetter = ''
                    FQDN = ''
                    PreferedDomainController = $false
                    Favorite = $false
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

            if($ADFavorite) {
                $CompanyObj.Domain.Favorite = $true
            }
            else {
                $CompanyObj.Domain.Favorite = $false
            }

            if($ADCredential) {
                $Param = @{
                    Target = "AD_$CompanyName" 
                    Persist = 'Enterprise' 
                    Credentials = $ADCredential
                }
                $null = New-StoredCredential @Param
                $CompanyObj.Domain.CredentialName = "AD_$CompanyName"
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
                $Uri = "https://$OnPremSkypeHost/OCSPowerShell/"
                $CompanyObj.OnPremServices.SkypeURI = $Uri
            }

            if($OnPremSkypeURI) {
                $CompanyObj.OnPremServices.SkypeURI = $OnPremSkypeURI
            }

            if($OnPremCredential) {
                $Param = @{
                    Target = "OnPrem_$CompanyName" 
                    Persist = 'Enterprise' 
                    Credentials = $OnPremCredential
                }
                $null = New-StoredCredential @Param
                $CompanyObj.OnPremServices.CredentialName = "OnPrem_$CompanyName"
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
                    AzureUsageLocation = $false
                    RemoteRoutingSuffix = $false
                    DirSyncHost = $false
                    DirSyncDC = $false
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
                    Target = "O365_$CompanyName" 
                    Persist = 'Enterprise' 
                    Credentials = $OnlineCredential
                }
                $null = New-StoredCredential @Param
                $CompanyObj.O365.CredentialName = "O365_$CompanyName"
            }
            <#
            if($OnlineAzureUsageLocation) {
                $CompanyObj.O365.AzureUsageLocation = $OnlineAzureUsageLocation
            }

            if($OnlineRemoteRoutingSuffix) {
                $CompanyObj.O365.RemoteRoutingSuffix = $OnlineRemoteRoutingSuffix
            }

            if($OnlineDirSyncHost) {
                $CompanyObj.O365.DirSyncHost = $OnlineDirSyncHost
            }

            if($OnlineDirSyncDC) {
                $CompanyObj.O365.DirSyncDC = $OnlineDirSyncDC
            }
            #>
        }

        ## Credential removal
        if($RemoveADCredential -and $CompanyObj.Domain) {
            Remove-StoredCredential -Target "AD_$CompanyName"
            $CompanyObj.Domain.CredentialName = $false
        }

        if($RemoveOnPremCredential -and $CompanyObj.OnPremServices.CredentialName) {
            Remove-StoredCredential -Target "OnPrem_$CompanyName"
            $CompanyObj.OnPremServices.CredentialName = $false
        }

        if($RemoveOnlineCredential -and $CompanyObj.O365) {
            Remove-StoredCredential -Target "O365_$CompanyName"
            $CompanyObj.O365.CredentialName = $false
        }

        $script:Config.Companies.$CompanyName = $CompanyObj
        Write-SPMTConfiguration
    }
}