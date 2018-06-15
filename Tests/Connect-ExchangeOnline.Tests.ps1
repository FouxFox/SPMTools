#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

#Inital Setup
$Env:SPMTTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Tests
Describe SPMTools.Public.Connect-ExchangeOnline {
    BeforeAll {
        Import-Module "$PSScriptRoot\TestVariables.psm1"
        InitTestVariables
    }
    AfterAll {
        RemoveTestVariables
        Remove-Module TestVariables
    }

    InModuleScope SPMTools {     
        <#
        Purpose:         Converts the Configuration from JSON to a HashTable
        Action:          Read-SPMTConfiguration
        Expected Result: ConvertTo-HashTable is loaded into $Script:Config
        #>
        Context 'Using Default Configuration' {
            #Setup Variables
            $Script:Config = $DefaultConfig
            $CompanyName = $DefaultCompanyName
            $TestCredential = $DefaultTestCredential

            $Script:Config.Companies.$CompanyName.O365.Mfa = $false
            $SessionParameters = @{
		        ConfigurationName = "Microsoft.Exchange"
		        ConnectionURI = $Script:Config.Companies.$CompanyName.O365.ExchangeUri
		        Authentication = "Basic"
		        AllowRedirection = $true
		        Credential = $TestCredential
            }


            #Mock Methods
            #$mockSession = Microsoft.PowerShell.Core\New-PSSession -ComputerName localhost -ErrorAction Stop
            Mock Get-PSSession { }
            Mock Remove-PSSession { }
            Mock Get-StoredCredential { return $TestCredential }
            Mock New-PSSession { return 'Test' }
            Mock Import-PSSession { }

            #Run Function
            

            It 'Calls Import-PSSession' {
                { Connect-ExchangeOnline -Company $CompanyName } | Should Throw
            }

            It 'Removes Old Sessions' {
                Assert-MockCalled Get-PSSession
                #Currently can't mock a PSSession
                #Assert-MockCalled Remove-PSSession -ParameterFilter { $Session -eq $OldSessionObj }
            }
            It 'Gets credentials from the credential vault' {
                Assert-MockCalled Get-StoredCredential -ParameterFilter { $Target -eq "O365_$CompanyName" }
            }
            It "Creates a session with the proper parameters" {
                #ConfigurationName
                $Param = @{
                    CommandName = 'New-PSSession'
                    ParameterFilter = {
                        $ConfigurationName -eq $SessionParameters.ConfigurationName -and
                        $ConnectionURI -eq $SessionParameters.ConnectionURI
                        $Credential -eq $SessionParameters.Credential -and
                        $AllowRedirection -eq $SessionParameters.AllowRedirection -and
                        $Authentication -eq $SessionParameters.Authentication
                    }
                }
                Assert-MockCalled @Param
            }
        }
    }
}

#Cleanup
$Env:SPMTTools_TestMode = 0
Remove-Module SPMTools
