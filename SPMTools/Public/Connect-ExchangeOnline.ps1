function Connect-ExchangeOnline {
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
        [Switch]$NoMfa
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
		Remove-OldSessions -OnPremHosts $OpCo_ExchangeOnPrem -OnlineHost $EXOHost
        $Tenant = $PSBoundParameters.Tenant
        $ConnectionCredentials = Get-NamedStoredCredential -Target "O365_$Tenant" -TargetName $Tenant

        if($NoMfa) {
			$Param = @{
		        ConfigurationName = "Microsoft.Exchange"
		        ConnectionURI = "https://$EXOHost/powershell-liveid/"
		        Authentication = "Basic"
		        AllowRedirection = $true
		        Credential = $ConnectionCredentials
	        }
            $EXOSession = New-PSSession @Param
        }
        else {
            $LocalPath = $env:LOCALAPPDATA + "\Apps\2.0\"
            $DLLName = 'Microsoft.Exchange.Management.ExoPowershellModule.dll'
            Import-Module $((Get-ChildItem -Path $LocalPath -Filter $DLLName -Recurse).FullName | Where-Object { $_ -notmatch "_none_" } | Select-Object -First 1)
		    $EXOSession = New-ExoPSSession -UserPrincipalName $ConnectionCredentials.UserName
        }

	    $null = Import-PSSession $EXOSession -AllowClobber -DisableNameChecking
    }
}