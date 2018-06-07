function Connect-LyncOnPrem {
    [cmdletbinding()]
    Param(
        [Parameter(
        Mandatory=$false,
        Position=2
        )]
        [Switch]$NewCredential
    )
    DynamicParam {
        $ParameterName = 'OpCo'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute([string[]]$OpCo_LyncOnPrem.Keys)

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}	
    Begin {
		Remove-OldSessions -OnPremHosts $OpCo_LyncOnPrem -OnlineHost $SBOHost
        $OpCo = $PSBoundParameters.OpCo
        $ConnectionCredentials = Get-NamedStoredCredential -Target "OPL_$OpCo" -TargetName "OnPrem Lync for $OpCo"

	    $Param = @{
		    ConnectionURI = "https://$($OpCo_LyncOnPrem[$OpCo])/OCSPowerShell"
		    Credential = $ConnectionCredentials
	    }
        
        $null = Import-PSSession (New-PSSession @Param) -AllowClobber -DisableNameChecking
	}
}