function Connect-SkypeOnPrem {
    [cmdletbinding()]
    Param()
    DynamicParam {
        $ParameterName = 'Company'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ValidateSet = $Script:Config.Companies.Keys | Where-Object {
            $Script:Config.Companies.$_.OnPremServices.SkypeUri
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
        $Company = $PSBoundParameters.Company
        $CompanyObj = $Script:Config.Companies.$Company

	    $Param = @{
		    ConnectionURI = $CompanyObj.OnPremServices.SkypeUri
        }
        if($CompanyObj.OnPremServices.CredentialName) {
            $Credential = Get-StoredCredential -Target $CompanyObj.OnPremServices.CredentialName
            $Param.Add('Credential',$Credential)
        }
        
        $SBOSession = $false
        $SBOSession = New-PSSession @Param

        if($SBOSession) {
            $null = Import-PSSession $SBOSession -AllowClobber -DisableNameChecking
        }
	}
}