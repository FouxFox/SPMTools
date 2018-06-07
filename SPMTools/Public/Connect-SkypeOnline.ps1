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
        $ParameterName = 'Tenant'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($Tenant_LyncOnline)

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}	
    Begin {
        Remove-OldSessions -OnPremHosts $OpCo_LyncOnPrem -OnlineHost $SBOHost
        $Tenant = $PSBoundParameters.Tenant
        $ConnectionCredentials = Get-NamedStoredCredential -Target "O365_$Tenant" -TargetName $Tenant

        if($Mfa) {
		    $SBOSession = New-CsOnlineSession -UserName $ConnectionCredentials.UserName
        }
        else {
            $SBOSession = New-CsOnlineSession -Credential $ConnectionCredentials
        }

	    $null = Import-PSSession $SBOSession -AllowClobber -DisableNameChecking
    }
}