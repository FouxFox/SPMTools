function Connect-SkypeOnline {
	[cmdletbinding()]
    Param(
        [Parameter(
            Mandatory=$false,
            Position=2
        )]
        [Switch]$NewCredential,
        [Parameter(
            Mandatory=$false
        )]
        [Switch]$Mfa
    )
    DynamicParam {
        $ParameterName = 'Company'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ValidateSet = $Script:Config.Companies.Keys | Where-Object {
            $Script:Config.Companies.$_.O365
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
        #OldSessions stay because all commands prefaced by -CSOnline

        $Company = $PSBoundParameters.Company
        $CompanyObj = $Script:Config.Companies.$Company
        $ConnectionCredentials = Get-StoredCredential -Target $CompanyObj.O365.CredentialName

        $SBOSession = $false
        if($CompanyObj.O365.Mfa) {
		    $SBOSession = New-CsOnlineSession -UserName $ConnectionCredentials.UserName
        }
        else {
            $SBOSession = New-CsOnlineSession -Credential $ConnectionCredentials
        }

        if($SBOSession) {
            $null = Import-PSSession $SBOSession -AllowClobber -DisableNameChecking
        }
    }
}