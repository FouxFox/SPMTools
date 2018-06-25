<#
.SYNOPSIS
Connects to Office365's Security and Compliance Center.

.DESCRIPTION
Connect-ComplianceCenter uses information provided in the profile of the company specified
to connect to Exchange Online.

.PARAMETER Company
The company profile to use for connecting.
This parameter supports Tab-Completion.

.EXAMPLE
Connect-ComplianceCenter -Company ExampleServices


.NOTES


#>


function Connect-ComplianceCenter {
	[cmdletbinding()]
    Param()
    DynamicParam {
        $ParameterName = 'Company'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute

        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1

        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        
        $ValidateSet = $Script:Config.Companies.Keys | Where-Object {
            $Script:Config.Companies.$_.O365
        }
        if($ValidateSet.length -gt 0) {
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ValidateSet)
            $AttributeCollection.Add($ValidateSetAttribute)
        }
 
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
	}	
    Begin {
        $Company = $PSBoundParameters.Company
        
        #Validation Error handling
        if(
            !$Script:Config.Companies.ContainsKey($Company) -or
            !$Script:Config.Companies.$Company.O365
        ) {
            $message = "There is not a company profile available that supports this cmdlet. Please check your configuration and try again."
            $Param = @{
                ExceptionName = "System.ArgumentException"
                ExceptionMessage = $message
                ErrorId = "ExchangeOnlineNoCompaniesAvailable" 
                CallerPSCmdlet = $PSCmdlet
                ErrorCategory = 'InvalidArgument'
            }
            ThrowError @Param
        }

        #Clean conflicting sessions
        $OldSessions = Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange'}
        $OldSessions | Remove-PSSession

        
        $CompanyObj = $Script:Config.Companies.$Company
        $ConnectionCredentials = Get-StoredCredential -Target $CompanyObj.O365.CredentialName

        $CCSession = $false
        if($CompanyObj.O365.Mfa) {
            #Import Module if needed
            $EXOModuleName = 'Microsoft.Exchange.Management.ExoPowershellModule'
            $IsImported = Get-Module -Name $EXOModuleName
            if(!$IsImported) {
                Import-EXOModule
                $IsImported = Get-Module -Name $EXOModuleName
                if(!$IsImported) {
                    Throw "Exchange MFA Module could not be imported."
                }
            }
            
            $Tries = 0
            While (!$CCSession -and $Tries -lt 3) {
                Try {
                    Connect-IPPSSession -UserPrincipalName $ConnectionCredentials.UserName
                    $CCSession = $true
                    $Tries++
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
                    if($_.Exception.Message.Contains('authentication_canceled')) {
                        #I don't think we need an error when the user cancels the auth
                        Write-Warning "User cancelled authentication."
                    }
                    else {
                        Throw $_
                    }
                    $Tries = 3
                }
            }
        }
        else {
            #Build a session without MFA
            $Param = @{
		        ConfigurationName = "Microsoft.Exchange"
		        ConnectionURI = $CompanyObj.O365.ComplianceCenterUri
		        Authentication = "Basic"
		        AllowRedirection = $true
		        Credential = $ConnectionCredentials
	        }
            $CCSession = New-PSSession @Param
        }
        
        if(!$CompanyObj.O365.Mfa -and $CCSession) {
            $Param = @{
                Session = $CCSession
                AllowClobber = $true
                DisableNameChecking = $true
            }
            $null = Import-Module (Import-PSSession @Param) -Scope Global -DisableNameChecking
        }
    }
}