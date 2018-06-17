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
Describe SPMTools.Public.Connect-SharePointOnline {
    BeforeAll {
        Import-Module "$PSScriptRoot\TestVariables.psm1"
        InitTestVariables
    }
    AfterAll {
        RemoveTestVariables
        Remove-Module TestVariables
    }

    InModuleScope SPMTools {
        Context 'Without MFA (No URL Set)' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName
            $TestCredential = $DefaultTestCredential

            $Script:Config.Companies.$CompanyName.O365.Mfa = $false

            $SessionParameters = @{
                Url = 'https://example-admin.sharepoint.com'
                Credential = $TestCredential
            }

            #Mock Functions we cannot import natively
            function Connect-SPOService { Param(
                [string]$Url,
                [PSCredential]$Credential
            )}
            function Import-PSSession { Param(
                [string]$Session,
                [switch]$AllowClobber,
                [switch]$DisableNameChecking
            )}

            #Now Mock them
            Mock Get-StoredCredential { return $TestCredential }
            Mock Connect-SPOService { return 'TestSession' }
            Mock Import-PSSession { return @{Name='TestModule'} }
            Mock Import-Module { }

            #Run Statement
            Connect-SharePointOnline -Company $CompanyName

            #Tests
            It 'Gets credentials from the credential vault' {
                Assert-MockCalled Get-StoredCredential -ParameterFilter { $Target -eq "O365_$CompanyName" }
            }
            It "Creates a session with the proper parameters" {
                #New-PSSession Assertion
                $Param = @{
                    CommandName = 'Connect-SPOService'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {
                        $Url -eq $SessionParameters.Url
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

        Context 'With MFA (URL Specified)' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName
            $TestCredential = $DefaultTestCredential

            $Script:Config.Companies.$CompanyName.O365.SharePointUri = 'https://example.sharepoint.com'

            $SessionParameters = @{
                Url = 'https://example.sharepoint.com'
            }

            #Mock Functions we cannot import natively
            function Connect-SPOService { Param(
                [string]$Url,
                [PSCredential]$Credential
            )}
            function Import-PSSession { Param(
                [string]$Session,
                [switch]$AllowClobber,
                [switch]$DisableNameChecking
            )}

            #Now Mock them
            Mock Get-StoredCredential { return $TestCredential }
            Mock Connect-SPOService { return 'TestSession' }
            Mock Import-PSSession { return @{Name='TestModule'} }
            Mock Import-Module { }

            #Run Statement
            Connect-SharePointOnline -Company $CompanyName

            #Tests
            It "Creates a session with the proper parameters" {
                #New-PSSession Assertion
                $Param = @{
                    CommandName = 'Connect-SPOService'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {
                        $Url -eq $SessionParameters.Url
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
                { Connect-SharePointOnline -Company $CompanyName } | Should Throw

                $Param = @{
                    CommandName = 'ThrowError'
                    Times = 1
                    Exactly = $true
                }
                Assert-MockCalled @Param

            }
        }

        Context "Error Handling (No Companies support Office365)" {
            #Setup Variables
            $Script:Config = @{Companies = @{}}
            $CompanyName = $DefaultCompanyName

            #Now Mock them
            Mock ThrowError { Throw }

            #Tests
            It "Throws a custom error" {
                { Connect-SharePointOnline -Company $CompanyName } | Should Throw

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
                { Connect-SharePointOnline -Company 'InvalidCompany' } | Should Throw
            }
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools