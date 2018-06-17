#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
<#
    There is no way to constuct a PSSession Object
    This creates problems when trying to return such and object
    from New-PSSession and Get-PSSession. To get around this
    limitation, another layer of mocking is injected before 
    Pester Mocks each of the commands. In this way, we can
    change some minor attributes of the function's parameters
    to suit our needs here.
#>
Describe 'SPMTools.Public.Connect-SkypeOnPrem' {
    BeforeAll {
        Import-Module "$PSScriptRoot\TestVariables.psm1"
        InitTestVariables
    }
    AfterAll {
        RemoveTestVariables
        Remove-Module TestVariables
    }

    InModuleScope SPMTools {
        Context 'Standard Connection (With Credentials)' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName
            $TestCredential = $DefaultTestCredential

            $SessionParameters = @{
		        ConfigurationName = "Microsoft.Exchange"
		        ConnectionURI = $Script:Config.Companies.$CompanyName.OnPremServices.SkypeUri
		        Authentication = "Kerberos"
		        Credential = $TestCredential
            }


             #Mock Functions we cannot import natively
             function New-PSSession { Param(
                 [string]$ConfigurationName,
                 [string]$ConnectionURI,
                 [PSCredential]$Credential,
                 [string]$Authentication
             )}
             function Import-PSSession { Param(
                 [string]$Session,
                 [switch]$AllowClobber,
                 [switch]$DisableNameChecking
             )}
 
             #Now Mock them
             Mock Get-StoredCredential { return $TestCredential }
             Mock New-PSSession { return 'TestSession' }
             Mock Import-PSSession { return @{Name='TestModule'} }
             Mock Import-Module { }
 
             #Run Statement
             Connect-SkypeOnPrem -Company $CompanyName
 
             #Tests
            It 'Gets credentials from the credential vault' {
                Assert-MockCalled Get-StoredCredential -ParameterFilter { $Target -eq "OnPrem_$CompanyName" }
            }
            It "Creates a session with the proper parameters" {
                #New-PSSession Assertion
                $Param = @{
                    CommandName = 'New-PSSession'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {
                        $ConnectionURI -eq $SessionParameters.ConnectionURI -and
                        $Credential -eq $SessionParameters.Credential
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Imports the session to the Global context' {
                #Import-PSSession Assertion
                $Param = @{
                    CommandName = 'Import-PSSession'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {
                        $Session -eq 'TestSession' -and
                        $AllowClobber -eq $true -and
                        $DisableNameChecking -eq $true
                    }
                }
                Assert-MockCalled @Param

                #Import-Module Assertion
                $Param = @{
                    CommandName = 'Import-Module'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {
                        $Name -eq 'TestModule' -and
                        $Scope -eq 'Global' -and
                        $DisableNameChecking -eq $true
                    }
                }
                Assert-MockCalled Import-Module -Times 1 -Exactly
            }
        }

        Context 'Standard Connection (With Credentials)' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName

            $Script:Config.Companies.$CompanyName.OnPremServices.CredentialName = $false
            $SessionParameters = @{
		        ConnectionURI = $Script:Config.Companies.$CompanyName.OnPremServices.SkypeUri
            }


             #Mock Functions we cannot import natively
             function New-PSSession { Param(
                 [string]$ConfigurationName,
                 [string]$ConnectionURI,
                 [PSCredential]$Credential,
                 [string]$Authentication
             )}
             function Import-PSSession { Param($a)}
 
             #Now Mock them
             Mock Get-PSSession { }
             Mock Remove-PSSession { }
             Mock New-PSSession { }
             Mock Import-PSSession { return @{Name='TestModule'} }
             Mock Import-Module { }
 
             #Run Statement
             Connect-SkypeOnPrem -Company $CompanyName
 
             #Tests
            It "Creates a session with the proper parameters" {
                #New-PSSession Assertion
                $Param = @{
                    CommandName = 'New-PSSession'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {
                        $ConfigurationName -eq $SessionParameters.ConfigurationName -and
                        $ConnectionURI -eq $SessionParameters.ConnectionURI -and
                        $Authentication -eq $SessionParameters.Authentication
                    }
                }
                Assert-MockCalled @Param
            }
        }

        Context "Error Handling (Company doesn't exist)" {
            #Setup Variables
            $Script:Config = @{Companies = @{}}
            $CompanyName = $DefaultCompanyName

            #Now Mock them
            Mock ThrowError { Throw }

            #Tests
            It "Throws a custom error" {
                { Connect-SkypeOnPrem -Company $CompanyName } | Should Throw

                $Param = @{
                    CommandName = 'ThrowError'
                    Times = 1
                    Exactly = $true
                }
                Assert-MockCalled @Param

            }
        }

        Context "Error Handling (No Companies support Skype OnPrem)" {
            #Setup Variables
            $Script:Config = @{Companies = @{}}
            $CompanyName = $DefaultCompanyName

            #Now Mock them
            Mock ThrowError { Throw }

            #Tests
            It "Throws a custom error" {
                { Connect-SkypeOnPrem -Company $CompanyName } | Should Throw

                $Param = @{
                    CommandName = 'ThrowError'
                    Times = 1
                    Exactly = $true
                }
                Assert-MockCalled @Param
            }
        }

        Context "Validate Set Handling (Company doesn't exist)" {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig

            #Tests
            It "Throws a validation set error" {
                { Connect-SkypeOnPrem -Company 'InvalidCompany' } | Should Throw
            }
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools