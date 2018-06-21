#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Get-Company {
    BeforeAll {
        Import-Module "$PSScriptRoot\TestVariables.psm1"
        InitTestVariables
    }
    AfterAll {
        RemoveTestVariables
        Remove-Module TestVariables
    }
    InModuleScope SPMTools {
        Context 'All companies displayed' {
            #Variables
            $Script:Config = Copy-Object $DefaultConfig
            $Script:Config.Companies.$DefaultCompanyName2 = @{
                Domain = $false
                OnPremServices = @{
                    ExchangeUri = $false
                    SkypeUri = $false
                    CredentialName = $false
                }
                O365 = $false
            }
            $ExpectedOutput1 = [pscustomobject]@{
                Name = $DefaultCompanyName
                ActiveDirectory = 'SET'
                OnPremServices = 'SET'
                Office365 = 'SET'
            }
            $ExpectedOutput2 = [pscustomobject]@{
                Name = $DefaultCompanyName2
                ActiveDirectory = 'UNSET'
                OnPremServices = 'UNSET'
                Office365 = 'UNSET'
            }

            #Run Statement
            $Output = Get-Company

            #Tests
            It 'Output the proper Object for Company 1' {
                $Obj = $Output | Where-Object { $_.Name -eq $DefaultCompanyName}
                $Obj.Name | Should be $ExpectedOutput1.Name
                $Obj.ActiveDirectory | Should be $ExpectedOutput1.ActiveDirectory
                $Obj.OnPremServices | Should be $ExpectedOutput1.OnPremServices
                $Obj.Office365 | Should be $ExpectedOutput1.Office365
            }
            It 'Output the proper Object for Company 2' {
                $Obj = $Output | Where-Object { $_.Name -eq $DefaultCompanyName2}
                $Obj.Name | Should be $ExpectedOutput2.Name
                $Obj.ActiveDirectory | Should be $ExpectedOutput2.ActiveDirectory
                $Obj.OnPremServices | Should be $ExpectedOutput2.OnPremServices
                $Obj.Office365 | Should be $ExpectedOutput2.Office365
            }
        }

        Context 'Specific Company displayed (All items configured)' {
            #Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName

            $Script:Config.Companies.$CompanyName.Domain.PreferedDomainController = 'Test'
            $Script:Config.Companies.$CompanyName.Domain.Favorite = $true

            $TestObj = $Script:Config.Companies.$CompanyName

            $ExpectedOutput = [ordered]@{
                Name = $DefaultCompanyName
                DriveLetter = $TestObj.Domain.PSDriveLetter
                DomainFQDN = $TestObj.Domain.FQDN
                PreferedDC = $TestObj.Domain.PreferedDomainController
                FavoriteDrive = $TestObj.Domain.Favorite
                DomainAuthType = 'Stored'
                ExchangeUri = $TestObj.OnPremServices.ExchangeUri
                SkypeUri = $TestObj.OnPremServices.SkypeUri
                OnPremAuthType = 'Stored'
                MFAEnabled = $TestObj.O365.Mfa
                ExchangeOnlineUri = $TestObj.O365.ExchangeOnlineUri
                SkypeOnlineUri = $TestObj.O365.SkypeOnlineUri
                O365AuthType = 'Stored'
            }

            #Run Statement
            $Output = Get-Company -Name $CompanyName

            ForEach ($prop in $ExpectedOutput.Keys) {
                It "Returns the correct value for $prop" {
                    $Output.$prop | Should be $ExpectedOutput[$prop]
                }
            }
        }

        Context 'Specific Company displayed (Minimal items configured)' {
            #Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName

            $Script:Config.Companies.$CompanyName.Domain.CredentialName = $false
            $Script:Config.Companies.$CompanyName.OnPremServices.CredentialName = $false
            $Script:Config.Companies.$CompanyName.O365.CredentialName = $false

            $TestObj = $Script:Config.Companies.$CompanyName

            $ExpectedOutput = [ordered]@{
                Name = $DefaultCompanyName
                PreferedDC = ''
                FavoriteDrive = $TestObj.Domain.Favorite
                DomainAuthType = 'Integrated'
                OnPremAuthType = 'Integrated'
                MFAEnabled = $TestObj.O365.Mfa
                O365AuthType = 'Integrated'
            }

            #Run Statement
            $Output = Get-Company -Name $CompanyName

            ForEach ($prop in $ExpectedOutput.Keys) {
                It "Returns the correct value for $prop" {
                    $Output.$prop | Should be $ExpectedOutput[$prop]
                }
            }
        }

        Context 'Specific Company displayed (No items configured)' {
            #Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName

            $Script:Config.Companies.$CompanyName = @{
                Domain = $false
                OnPremServices = @{
                    ExchangeUri = $false
                    SkypeUri = $false
                    CredentialName = $false
                }
                O365 = $false
            }

            $TestObj = $Script:Config.Companies.$CompanyName

            $ExpectedOutput = [ordered]@{
                Name = $DefaultCompanyName
            }

            #Run Statement
            $Output = Get-Company -Name $CompanyName

            ForEach ($prop in $ExpectedOutput.Keys) {
                It "Returns the correct value for $prop" {
                    $Output.$prop | Should be $ExpectedOutput[$prop]
                }
            }
        }

        Context 'Specific Company displayed (Only Exchange configured)' {
            #Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName

            $Script:Config.Companies.$CompanyName = @{
                Domain = $false
                OnPremServices = @{
                    ExchangeUri = 'Test'
                    SkypeUri = $false
                    CredentialName = $false
                }
                O365 = $false
            }

            $TestObj = $Script:Config.Companies.$CompanyName

            $ExpectedOutput = [ordered]@{
                Name = $DefaultCompanyName
                ExchangeUri = $TestObj.OnPremServices.ExchangeUri
                OnPremAuthType = 'Integrated'
            }

            #Run Statement
            $Output = Get-Company -Name $CompanyName

            ForEach ($prop in $ExpectedOutput.Keys) {
                It "Returns the correct value for $prop" {
                    $Output.$prop | Should be $ExpectedOutput[$prop]
                }
            }
        }

        Context 'Specific Company displayed (Only Skype configured)' {
            #Variables
            $Script:Config = Copy-Object $DefaultConfig
            $CompanyName = $DefaultCompanyName

            $Script:Config.Companies.$CompanyName = @{
                Domain = $false
                OnPremServices = @{
                    ExchangeUri = $false
                    SkypeUri = 'Test'
                    CredentialName = $false
                }
                O365 = $false
            }

            $TestObj = $Script:Config.Companies.$CompanyName

            $ExpectedOutput = [ordered]@{
                Name = $DefaultCompanyName
                SkypeUri = $TestObj.OnPremServices.SkypeUri
                OnPremAuthType = 'Integrated'
            }

            #Run Statement
            $Output = Get-Company -Name $CompanyName

            ForEach ($prop in $ExpectedOutput.Keys) {
                It "Returns the correct value for $prop" {
                    $Output.$prop | Should be $ExpectedOutput[$prop]
                }
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

        Context "Error Handling (No Companies)" {
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