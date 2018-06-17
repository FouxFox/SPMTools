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
        Context 'Without MFA' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName
            $TestCredential = $DefaultTestCredential

            $Script:Config.Companies.$CompanyName.O365.Mfa = $false
            $SessionParameters = @{
		        ConfigurationName = "Microsoft.Exchange"
		        ConnectionURI = $Script:Config.Companies.$CompanyName.O365.ExchangeOnlineUri
		        Authentication = "Basic"
		        AllowRedirection = $true
		        Credential = $TestCredential
            }


            #Mock Functions we cannot import natively
            function Get-PSSession { Param($a)}
            function New-PSSession { Param(
                [string]$ConfigurationName,
                [string]$ConnectionURI,
                [PSCredential]$Credential,
                [switch]$AllowRedirection,
                [string]$Authentication
            )}
            function Import-PSSession { Param(
                [string]$Session,
                [switch]$AllowClobber,
                [switch]$DisableNameChecking
            )}

            #Now Mock them
            Mock Get-PSSession { 
                return [pscustomobject]@{
                    ID = 10
                    ConfigurationName = 'Microsoft.Exchange'
                } 
            }
            Mock Remove-PSSession { }
            Mock Get-StoredCredential { return $TestCredential }
            Mock New-PSSession { return 'TestSession' }
            Mock Import-PSSession { return @{Name='TestModule'} }
            Mock Import-Module { }

            #Run Statement
            Connect-ExchangeOnline -Company $CompanyName

            #Tests
            It 'Removes Old Sessions' {
                Assert-MockCalled Get-PSSession -Times 1 -Exactly
                $Param = @{
                    CommandName = 'Remove-PSSession'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {
                        $ID -eq 10
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Gets credentials from the credential vault' {
                Assert-MockCalled Get-StoredCredential -ParameterFilter { $Target -eq "O365_$CompanyName" }
            }
            It "Creates a session with the proper parameters" {
                #New-PSSession Assertion
                $Param = @{
                    CommandName = 'New-PSSession'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {
                        $ConfigurationName -eq $SessionParameters.ConfigurationName -and
                        $ConnectionURI -eq $SessionParameters.ConnectionURI -and
                        $Credential -eq $SessionParameters.Credential -and
                        $AllowRedirection -eq $SessionParameters.AllowRedirection -and
                        $Authentication -eq $SessionParameters.Authentication
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

        Context 'With MFA (EXO Module not imported)' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName
            $TestCredential = $DefaultTestCredential

            #Mock Functions we cannot import nativly
            function New-EXOPSSession { Param($UserPrincipalName) }
            function Import-PSSession { Param($a) }

            #Now Mock them
            Mock Get-PSSession { }
            Mock Remove-PSSession { }
            Mock Get-StoredCredential { return $TestCredential }
            Mock Import-EXOModule { }
            Mock Import-PSSession { return @{Name='Test'} }
            Mock Import-Module { }
            Mock New-EXOPSSession { return 'Test' }
            Mock Get-Module {
                #Get-Module is called twice if the EXO DLL is not loaded
                #This allows the second call to react differently
                Try {
                    Assert-MockCalled Import-EXOModule -Times 1 -Exactly
                    return $true
                }
                Catch {
                    return $false
                }
            }

            #Run Statement
            Connect-ExchangeOnline -Company $CompanyName

            #Tests
            It 'Loads the EXO DLL' {
                Assert-MockCalled Get-Module -Times 2 -Exactly
                Assert-MockCalled Import-EXOModule -Times 1 -Exactly
            }
            It "Creates a session using New-ExoPSSession" {
                $Param = @{
                    CommandName = 'New-ExoPSSession'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {
                        $UserPrincipalName -eq $TestCredential.Username
                    }
                }
                Assert-MockCalled @Param
            }
        }

        Context 'With MFA (EXO Module Imported / Session Rebuild)' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName
            $TestCredential = $DefaultTestCredential

            #Mock Functions we cannot import nativly
            function New-EXOPSSession { Param($UserPrincipalName) }
            function Import-PSSession { Param($a) }

            #Now Mock them
            Mock Get-PSSession { }
            Mock Remove-PSSession { }
            Mock Get-StoredCredential { return $TestCredential }
            Mock Import-EXOModule { }
            Mock Import-PSSession { return @{Name='Test'} }
            Mock Import-Module { }
            Mock Get-Module { return $true }
            Mock New-EXOPSSession {
                #New-EXOPSSession is called twice if there is an issue
                #building the session the first time.
                #This allows the second call to react differently
                Try {
                    Assert-MockCalled New-EXOPSSession -Times 2 -Exactly
                    return 'test'
                }
                Catch {}
            }

            #Run Statement
            Connect-ExchangeOnline -Company $CompanyName

            #Tests
            It 'Does not reload the EXO DLL' {
                Assert-MockCalled Get-Module -Times 1 -Exactly
                Assert-MockCalled Import-EXOModule -Times 0 -Exactly
            }
            It "Creates a session using New-ExoPSSession" {
                $Param = @{
                    CommandName = 'New-ExoPSSession'
                    Times = 2
                    Exactly = $true
                    ParameterFilter = {
                        $UserPrincipalName -eq $TestCredential.Username
                    }
                }
                Assert-MockCalled @Param
            }
        }

        Context 'With MFA (Session rebuild fails)' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName
            $TestCredential = $DefaultTestCredential

            #Mock Functions we cannot import nativly
            function New-EXOPSSession { Param($UserPrincipalName) }
            function Import-PSSession { Param($a) }

            #Now Mock them
            Mock Get-PSSession { }
            Mock Remove-PSSession { }
            Mock Get-StoredCredential { return $TestCredential }
            Mock Import-PSSession { return @{Name='Test'} }
            Mock Import-Module { }
            Mock Get-Module { return $true }
            Mock New-EXOPSSession {
                #New-EXOPSSession is called twice if there is an issue
                #building the session the first time.
                #This allows the second call to react differently
                Try {
                    Assert-MockCalled New-EXOPSSession -Times 4 -Exactly
                    return 'test'
                }
                Catch {}
            }

            #Run Statement
            Connect-ExchangeOnline -Company $CompanyName

            #Tests
            It "Creates a session using New-ExoPSSession" {
                $Param = @{
                    CommandName = 'New-ExoPSSession'
                    Times = 3
                    Exactly = $true
                    ParameterFilter = {
                        $UserPrincipalName -eq $TestCredential.Username
                    }
                }
                Assert-MockCalled @Param
            }
        }

        Context 'With MFA (User cancels authentication)' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName
            $TestCredential = $DefaultTestCredential

            #Mock Functions we cannot import nativly
            function New-EXOPSSession { Param($UserPrincipalName) }
            function Import-PSSession { Param($a) }

            #Now Mock them
            Mock Get-PSSession { }
            Mock Remove-PSSession { }
            Mock Get-StoredCredential { return $TestCredential }
            Mock Get-Module { return $true }
            Mock New-EXOPSSession { Throw 'authentication_canceled: User Canceled Action' }
            Mock Write-Warning { }

            #Run Statement
            Connect-ExchangeOnline -Company $CompanyName

            #Tests
            It "Does not create a session" {
                $Param = @{
                    CommandName = 'New-ExoPSSession'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {
                        $UserPrincipalName -eq $TestCredential.Username
                    }
                }
                Assert-MockCalled @Param

            }
            It 'Writes a warning' {
                $Param = @{
                    CommandName = 'Write-Warning'
                    Times = 1
                    Exactly = $true
                    ParameterFilter = {
                        $Message -eq 'User cancelled authentication.'
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
                { Connect-ExchangeOnline -Company $CompanyName } | Should Throw

                $Param = @{
                    CommandName = 'ThrowError'
                    Times = 1
                    Exactly = $true
                }
                Assert-MockCalled @Param

            }
        }

        Context "Error Handling (No Companies support Office 365)" {
            #Setup Variables
            $Script:Config = @{Companies = @{}}
            $CompanyName = $DefaultCompanyName

            #Now Mock them
            Mock ThrowError { Throw }

            #Tests
            It "Throws a custom error" {
                { Connect-ExchangeOnline -Company $CompanyName } | Should Throw

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
                { Connect-ExchangeOnline -Company 'InvalidCompany' } | Should Throw
            }
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools
