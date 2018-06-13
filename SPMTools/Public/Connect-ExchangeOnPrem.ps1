<#
.SYNOPSIS
Connects to On-Premise Exchange.

.DESCRIPTION
Connect-ExchangeOnPrem uses information provided in the profile of the company specified
to connect to the specifiec company's on-premise exchange server.

.PARAMETER Company
The company profile to use for connecting.
This parameter supports Tab-Completion.

.EXAMPLE
Connect-ExchangeOnPrem -Company ExampleServices


.NOTES


#>

function Connect-ExchangeOnPrem {
    [cmdletbinding()]
    Param()
    DynamicParam {
        $ParameterName = 'Company'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ValidateSet = $Script:Config.Companies.Keys | Where-Object {
            $Script:Config.Companies.$_.OnPremServices.ExchangeUri
        }

        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet)

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}	
    Begin {
        #Clean conflicting sessions
        $OldSessions = Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange'}
        $OldSessions | Remove-PSSession

        $Company = $PSBoundParameters.Company
        $CompanyObj = $Script:Config.Companies.$Company
        
	    $Param = @{
		    ConfigurationName = "Microsoft.Exchange"
		    ConnectionURI = $CompanyObj.OnPremServices.ExchangeUri
            Authentication = "Kerberos"
	    }
		if($CompanyObj.OnPremServices.CredentialName) {
            $Credential = Get-StoredCredential -Target $CompanyObj.OnPremServices.CredentialName
            $Param.Add('Credential',$Credential)
		}

        $EXOSession = $false
        $EXOSession = New-PSSession @Param

        if($EXOSession) {
            $null = Import-PSSession $EXOSession -AllowClobber -DisableNameChecking
        }
    }
}