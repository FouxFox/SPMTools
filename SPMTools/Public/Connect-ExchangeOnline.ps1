function Connect-ExchangeOnline {
	[cmdletbinding()]
    Param()
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
        #Clean conflicting sessions
        $OldSessions = Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange'}
        $OldSessions | Remove-PSSession

        $Company = $PSBoundParameters.Company
        $CompanyObj = $Script:Config.Companies.$Company
        $ConnectionCredentials = Get-StoredCredential -Target $CompanyObj.O365.ExchangeOnlineURI

        $EXOSession = $false
        if($CompanyObj.O365.Mfa) {
			$Param = @{
		        ConfigurationName = "Microsoft.Exchange"
		        ConnectionURI = $CompanyObl.O365.ExchangeOnlineURI
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

            $Tries = 0
            While (!$EXOSession -and $Tries -lt 3) {
                Try {
                    $EXOSession = New-ExoPSSession -UserPrincipalName $ConnectionCredentials.UserName
                }
                Catch [System.Management.Automation.Remoting.PSRemotingTransportException] {
                    #Sometimes when a session is broken, the EXOPowerShell Module will throw
                    #errors on reconnect. This safely ignores them and retries.
                    if(!$_.Exception.Source -eq 'Microsoft.Exchange.Management.ExoPowershellModule') {
                        Throw $_
                    }
                    $Tries++
                }
            }
        }

	    $null = Import-PSSession $EXOSession -AllowClobber -DisableNameChecking
    }
}