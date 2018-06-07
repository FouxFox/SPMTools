function Connect-SharepointOnline {
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
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($Tenant_ExchangeOnline)

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}	
    Begin {
        $Tenant = $PSBoundParameters.Tenant
        $ConnectionCredentials = Get-NamedStoredCredential -Target "O365_$Tenant" -TargetName $Tenant

        if($Mfa) {
		    $SPOSession = Connect-SPOService -Url "https://$Tenant-admin.sharepoint.com"
        }
        else {
            $SPOSession = Connect-SPOService -Url "https://$Tenant-admin.sharepoint.com" -Credential $ConnectionCredentials
        }

	    $null = Import-PSSession $SPOSession -AllowClobber -DisableNameChecking
    }
}