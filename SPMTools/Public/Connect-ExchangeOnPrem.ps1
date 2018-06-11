function Connect-ExchangeOnPrem {
    [cmdletbinding()]
    Param(
		[Parameter(
        Mandatory=$false,
        Position=2
        )]
        [Switch]$UseStoredCredential,
        [Parameter(
        Mandatory=$false,
        Position=3
        )]
        [Switch]$NewCredential
    )
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
		    ConnectionURI = $CompanyObj.OnPremServices.Exchange.Uri
            Authentication = "Kerberos"
	    }
		if($CompanyObj.OnPremServices.CredentialName) {
            $Credential = Get-StoredCredential -Target $CompanyObj.OnPremServices.CredentialName
            $Param.Add('Credential',$Credential)
		}

        $EXOSession = New-PSSession @Param

        if($EXOSession) {
            $null = Import-PSSession $EXOSession -AllowClobber -DisableNameChecking
        }
    }
}