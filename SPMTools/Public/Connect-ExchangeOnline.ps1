<#
.SYNOPSIS
Connects to Office365's Exchange Online service.

.DESCRIPTION
Connect-ExchangeOnline uses information provided in the profile of the company specified
to connect to Exchange Online.

.PARAMETER Company
The company profile to use for connecting.
This parameter supports Tab-Completion.

.EXAMPLE
Connect-ExchangeOnline -Company ExampleServices


.NOTES


#>


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
        $ConnectionCredentials = Get-StoredCredential -Target $CompanyObj.O365.CredentialName

        $EXOSession = $false
        if($CompanyObj.O365.Mfa) {
            #Import Module if needed
            $EXOModuleName = 'Microsoft.Exchange.Management.ExoPowershellModule'
            $IsImported = Get-Module -Name $EXOModuleName
            if($IsImported) {
                Import-EXOModule
                $IsImported = Get-Module -Name $EXOModuleName
                if(!$IsImported) {
                    Write-Error "Exchange MFA Module could not be imported."
                }
            }
            
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
                Catch {
                    $Tries = 3
                }
            }
        }
        else {
            $Param = @{
		        ConfigurationName = "Microsoft.Exchange"
		        ConnectionURI = $CompanyObj.O365.ExchangeOnlineURI
		        Authentication = "Basic"
		        AllowRedirection = $true
		        Credential = $ConnectionCredentials
	        }
            $EXOSession = New-PSSession @Param
        }
        
        if($EXOSession) {
            $null = Import-PSSession $EXOSession -AllowClobber -DisableNameChecking
        }
    }
}