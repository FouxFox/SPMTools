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
        $ParameterName = 'OpCo'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute([string[]]$OpCo_ExchangeOnPrem.Keys)

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}	
    Begin {
        Remove-OldSessions -OnPremHosts $OpCo_ExchangeOnPrem -OnlineHost $EXOHost
        $OpCo = $PSBoundParameters.OpCo

	    $Param = @{
		    ConfigurationName = "Microsoft.Exchange"
		    ConnectionURI = "http://$($OpCo_ExchangeOnPrem[$OpCo])/PowerShell/"
            Authentication = "Kerberos"
	    }
		
		if($UseStoredCredential) {
			$ConnectionCredentials = Get-NamedStoredCredential -Target "OPE_$OpCo" -TargetName "OnPrem Exchange for $OpCo"
			Credential = $ConnectionCredentials
		}

	    $null = Import-PSSession (New-PSSession @Param) -AllowClobber -DisableNameChecking
    }
}