#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Remove-Company {
    BeforeAll {
        Import-Module "$PSScriptRoot\TestVariables.psm1"
        InitTestVariables
    }
    AfterAll {
        RemoveTestVariables
        Remove-Module TestVariables
    }

    InModuleScope SPMTools {
        Context 'Removing a company' {
            #Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName

            #Mocks
            Mock Set-Company {}
            Mock Write-SPMTConfiguration {}

            #Run Statement
            Remove-Company -Name $CompanyName

            #Tests
            It 'Removes all credentials' {
                $Param = @{
                    CommandName = 'Set-Company'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Name -eq $CompanyName -and
                        $RemoveADCredential -eq $true
                    }
                }
                Assert-MockCalled @Param
                $Param = @{
                    CommandName = 'Set-Company'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Name -eq $CompanyName -and
                        $RemoveOnPremCredential -eq $true
                    }
                }
                Assert-MockCalled @Param
                $Param = @{
                    CommandName = 'Set-Company'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Name -eq $CompanyName -and
                        $RemoveOnlineCredential -eq $true
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Remove the Company configuration' {
                $Script:Config.Companies.ContainsKey($CompanyName) | Should be $false
            }
            It 'Writes the configuration changes to disk' {
                Assert-MockCalled Write-SPMTConfiguration -Exactly -Times 1
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
                { Remove-Company -Name $CompanyName } | Should Throw

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
                { Remove-Company -Name 'InvalidCompany' } | Should Throw
            }
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools