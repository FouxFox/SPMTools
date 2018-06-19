#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Mount-ADDrive {
    BeforeAll {
        Import-Module "$PSScriptRoot\TestVariables.psm1"
        InitTestVariables
    }
    AfterAll {
        RemoveTestVariables
        Remove-Module TestVariables
    }

    InModuleScope SPMTools {
        Context 'No Parameters' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            #Mocks
            Mock New-ADDrive { return 'Test' }

            #Run Statement
            Mount-ADDrive

            It 'Mounts Drives for all Companies' {
                Assert-MockCalled New-ADDrive -Exactly -Times 2
            }
            It 'Returns a list of connected domains' {
                #Can't Mock filter table. Need to output objects w/ formatting
            }
        }

        Context 'Favorites Only' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName
            $CompanyName2 = $DefaultCompanyName2
            $Companies = $Script:Config.Companies

            #Mocks
            Mock New-ADDrive { return 'Test' }
            Mock Write-Warning {}

            #Run Statement
            Mount-ADDrive -Favorites

            It 'Only mounts Drives for Favorite Companies' {
                $Param = @{
                    CommandName = 'New-ADDrive'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $InputObj -eq $Companies.$CompanyName2.Domain
                    }
                }
                Assert-MockCalled @Param

                $Param = @{
                    CommandName = 'New-ADDrive'
                    Exactly = $true
                    Times = 0
                    ParameterFilter = {
                        $InputObj -eq $Companies.$CompanyName.Domain
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Does not print a warning' {
                Assert-MockCalled Write-Warning -Exactly -Times 0
            }
            It 'Returns a list of connected domains' {
                #Can't Mock filter table. Need to output objects w/ formatting
            }
        }

        Context 'Single Company' {
            #Setup Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName
            $CompanyName2 = $DefaultCompanyName2
            $Companies = $Script:Config.Companies

            #Mocks
            Mock New-ADDrive { return 'Test' }
            Mock Write-Warning {}

            #Run Statement
            Mount-ADDrive -Company $CompanyName

            It 'Only mounts Drives for Specified Companies' {
                $Param = @{
                    CommandName = 'New-ADDrive'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $InputObj -eq $Companies.$CompanyName.Domain
                    }
                }
                Assert-MockCalled @Param

                $Param = @{
                    CommandName = 'New-ADDrive'
                    Exactly = $true
                    Times = 0
                    ParameterFilter = {
                        $InputObj -eq $Companies.$CompanyName2.Domain
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Returns a list of connected domains' {
                #Can't Mock filter table. Need to output objects w/ formatting
            }
        }

        Context 'Run at Startup (All)' {
            #Setup Variables
            $DesiredOutput = 'Mount-ADDrive'

            #Mocks
            Mock Out-File {}

            #Run Statement
            Mount-ADDrive -RunAtStartup -Confirm:$false

            It 'Adds the right command' {
                $Param = @{
                    CommandName = 'Out-File'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $InputObject -eq $DesiredOutput
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Uses the proper path and does not append' {
                $Param = @{
                    CommandName = 'Out-File'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Append -eq $true -and
                        $FilePath -eq $profile
                    }
                }
                Assert-MockCalled @Param
            }
        }

        Context 'Run at Startup (Favorites)' {
            #Setup Variables
            $DesiredOutput = 'Mount-ADDrive -Favorites'

            #Mocks
            Mock Out-File {}

            #Run Statement
            Mount-ADDrive -Favorites -RunAtStartup -Confirm:$false

            It 'Adds the right command' {
                $Param = @{
                    CommandName = 'Out-File'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $InputObject -eq $DesiredOutput
                    }
                }
                Assert-MockCalled @Param
            }
        }

        Context 'Run at Startup (Specific Company)' {
            #Setup Variables
            $CompanyName = $DefaultCompanyName
            $DesiredOutput = "Mount-ADDrive -Company $CompanyName"

            #Mocks
            Mock Out-File {}

            #Run Statement
            Mount-ADDrive -Company $CompanyName -RunAtStartup -Confirm:$false

            It 'Adds the right command' {
                $Param = @{
                    CommandName = 'Out-File'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $InputObject -eq $DesiredOutput
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
                { Mount-ADDrive -Company $CompanyName } | Should Throw

                $Param = @{
                    CommandName = 'ThrowError'
                    Times = 1
                    Exactly = $true
                }
                Assert-MockCalled @Param

            }
        }

        Context "Error Handling (No Companies support AD Drives)" {
            #Setup Variables
            $Script:Config = @{Companies = @{}}
            $CompanyName = $DefaultCompanyName

            #Now Mock them
            Mock ThrowError { Throw }

            #Tests
            It "Throws a custom error" {
                { Mount-ADDrive -Company $CompanyName } | Should Throw

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
                { Mount-ADDrive -Company 'InvalidCompany' } | Should Throw
            }
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools