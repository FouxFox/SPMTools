<#
.SYNOPSIS
Returns a list of company's from the SPMTools config file

.DESCRIPTION
Returns the list of entered companies in the Service Provider Management Tools config file.
Additional companies can be added with New-Company

.PARAMETER Name
If Specified, returns all configuration information for the company's profile
Otherwise returns a list of companies.

.EXAMPLE
Get-Company

.EXAMPLE
Get-Company -Name AtlanticAviation

.NOTES


#>

Function Get-Company {
    [cmdletBinding(DefaultParameterSetName='All')]
    Param()
    DynamicParam {
        $ParameterName = 'Name'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $ParameterAttribute.ParameterSetName = 'Specific'
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
        if($PSCmdlet.ParameterSetName -eq 'All') {
            #List all companies and if their setting are set
            $Companies = $Script:Config.Companies

            ForEach ($Company in $Companies.Keys) {
                $CompanyObj = $Companies[$Company]

                $OutputObj = [pscustomobject]@{
                    Name = $Company
                    ActiveDirectory = 'UNSET'
                    OnPremServices  = 'UNSET'
                    Office365       = 'UNSET'
                }

                if($CompanyObj.Domain) {
                    $OutputObj.ActiveDirectory = 'SET'
                }
                
                $OnPremObj = $CompanyObj.OnPremServices
                if($OnPremObj.ExchangeUri -or $OnPremObj.SkypeURI) {
                    $OutputObj.OnPremServices = 'SET'
                }

                if($CompanyObj.O365) {
                    $OutputObj.Office365 = 'SET'
                }
                $OutputObj
            }
        }
    }
    Process {
        $Name = $PSBoundParameters.Name

        #Validation Error handling
        if(!$Script:Config.Companies.ContainsKey($Name)) {
            $message = "No companies have been set up. Please use the New-Company command to create one."
            $Param = @{
                ExceptionName = "System.ArgumentException"
                ExceptionMessage = $message
                ErrorId = "GetCompanyNoCompaniesAvailable" 
                CallerPSCmdlet = $PSCmdlet
                ErrorCategory = 'InvalidArgument'
            }
            ThrowError @Param
        }

        if($PSCmdlet.ParameterSetName -eq 'Specific') {
            $CompanyObj = $Script:Config.Companies.$Name
            $Output = [ordered]@{
                Name = $Name
            }

            #Domain Settings
            if($CompanyObj.Domain) {
                $DomainObj = $CompanyObj.Domain
                $Output.Add('DriveLetter',$DomainObj.PSDriveLetter)
                $Output.Add('DomainFQDN',$DomainObj.FQDN)

                if($DomainObj.PreferedDomainController) {
                    $Output.Add('PreferedDC',$DomainObj.PreferedDomainController)
                }
                else {
                    $Output.Add('PreferedDC','')
                }

                $Output.Add('FavoriteDrive',$DomainObj.Favorite)
                
                if($DomainObj.CredentialName) {
                    $Output.Add('DomainAuthType','Stored')
                }
                else {
                    $Output.Add('DomainAuthType','Integrated')
                }
            }

            #OnPremise Settings
            $OnPremObj = $CompanyObj.OnPremServices
            if(
                $OnPremObj.ExchangeURI -or
                $OnPremObj.SkypeURI
            ) {
                if($OnPremObj.ExchangeURI) {
                    $Output.Add('ExchangeURI',$OnPremObj.ExchangeURI)
                }
                if($OnPremObj.SkypeURI) {
                    $Output.Add('ExchangeURI',$OnPremObj.SkypeURI)
                }
                if($OnPremObj.CredentialName) {
                    $Output.Add('OnPremAuthType','Stored')
                }
                else {
                    $Output.Add('OnPremAuthType','Integrated')
                }
            }

            #O365 Settings
            if($CompanyObj.O365) {
                $O365Obj = $CompanyObj.O365
                $Output.Add('MFAEnabled',$O365Obj.Mfa)
                $Output.Add('ExchangeOnlineUri',$O365Obj.ExchangeOnlineUri)
                $Output.Add('SkypeOnlineUri',$O365Obj.SkypeOnlineUri)
                
                if($O365Obj.CredentialName) {
                    $Output.Add('O365AuthType','Stored')
                }
                else {
                    $Output.Add('O365AuthType','Integrated')
                }
            }

            [pscustomobject]$Output
        }
    }
}