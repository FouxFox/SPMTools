#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Set-Company {
    BeforeAll {
        Import-Module "$PSScriptRoot\TestVariables.psm1"
        InitTestVariables
    }
    AfterAll {
        RemoveTestVariables
        Remove-Module TestVariables
    }

    InModuleScope SPMTools {
        Context 'AD Settings (All)' {
            #Variables
            $CompanyName = 'TestCompany'
            $TestCredential = $DefaultTestCredential
            $Script:Config = @{
                Companies = @{
                    $CompanyName = @{
                        Domain = $false
                        OnPremServices = @{
                            ExchangeUri = $false
                            SkypeUri = $false
                            CredentialName = $false
                        }
                        O365 = $false
                    }
                }
            }

            $ConfigArea = 'Domain'
            $ExpectedValues = [ordered]@{
                ADDriveName = @{
                    Use = $true
                    ConfigName = 'PSDriveLetter'
                    Val = 'EX'
                }
                ADFQDN = @{
                    Use = $true
                    ConfigName = 'FQDN'
                    Val = 'example.com'
                }
                ADPreferedDomainController = @{
                    Use = $true
                    ConfigName = 'PreferedDomainController'
                    Val = 'test.example.com'
                }
                ADFavorite = @{
                    Use = $true
                    ConfigName = 'Favorite'
                    Val = $true
                }
                ADCredential = @{
                    Use = $true
                    ConfigName = 'CredentialName'
                    Param = $TestCredential
                    Val = "AD_$CompanyName"
                }
            }

            #Mocks
            Mock New-StoredCredential {}
            Mock Write-SPMTConfiguration {}

            #Run Statement
            $Param = @{
                Name = $CompanyName
            }
            ForEach ($prop in $ExpectedValues.Keys) {
                if($ExpectedValues[$prop].Use) {
                    if($ExpectedValues[$prop].ContainsKey('Param')) {
                        $ValIdentifier = 'Param'
                    }
                    else {
                        $ValIdentifier = 'Val'
                    }
                    $Param.Add($prop,$ExpectedValues[$prop].$ValIdentifier)
                }
            }
            Set-Company @Param

            ForEach ($prop in $ExpectedValues.Keys) {
                It "Sets the proper value for $prop" {
                    $ConfigObj = $Script:Config.Companies.$CompanyName.$ConfigArea
                    $ConfigName = $ExpectedValues[$prop].ConfigName
                    $ConfigObj.$ConfigName | Should be $ExpectedValues[$prop].Val
                }
            }
            $CredentialVar = $ExpectedValues.Keys | Where-Object {$_.Contains('Credential')}
            if($ExpectedValues.$CredentialVar.Use) {
                It 'Stores the credentials' {
                    $Param = @{
                        CommandName = 'New-StoredCredential'
                        Exactly = $true
                        Times = 1
                        ParameterFilter = {
                            $Target -eq $ExpectedValues.$CredentialVar.Val  -and
                            $Persist -eq 'Enterprise' -and
                            $Credentials -eq $TestCredential
                        }
                    }
                    Assert-MockCalled @Param
                }
            }
            else {
                It 'Does not store credentials' {
                    Assert-MockCalled New-StoredCredential -Exactly -Times 0
                }
            }
            It 'Writes configuration to disk' {
                Assert-MockCalled Write-SPMTConfiguration -Exactly -Times 1
            }
        }

        Context 'AD Settings (Minimal)' {
            #Variables
            $CompanyName = 'TestCompany'
            $TestCredential = $DefaultTestCredential
            $Script:Config = @{
                Companies = @{
                    $CompanyName = @{
                        Domain = $false
                        OnPremServices = @{
                            ExchangeUri = $false
                            SkypeUri = $false
                            CredentialName = $false
                        }
                        O365 = $false
                    }
                }
            }

            $ConfigArea = 'Domain'
            $ExpectedValues = [ordered]@{
                ADDriveName = @{
                    Use = $true
                    ConfigName = 'PSDriveLetter'
                    Val = 'EX'
                }
                ADFQDN = @{
                    Use = $true
                    ConfigName = 'FQDN'
                    Val = 'example.com'
                }
                ADPreferedDomainController = @{
                    Use = $false
                    ConfigName = 'PreferedDomainController'
                    Val = $false
                }
                ADFavorite = @{
                    Use = $false
                    ConfigName = 'Favorite'
                    Val = $false
                }
                ADCredential = @{
                    Use = $false
                    ConfigName = 'CredentialName'
                    Param = $TestCredential
                    Val = $false
                }
            }

            #Mocks
            Mock New-StoredCredential {}
            Mock Write-SPMTConfiguration {}

            #Run Statement
            $Param = @{
                Name = $CompanyName
            }
            ForEach ($prop in $ExpectedValues.Keys) {
                if($ExpectedValues[$prop].Use) {
                    if($ExpectedValues[$prop].ContainsKey('Param')) {
                        $ValIdentifier = 'Param'
                    }
                    else {
                        $ValIdentifier = 'Val'
                    }
                    $Param.Add($prop,$ExpectedValues[$prop].$ValIdentifier)
                }
            }
            Set-Company @Param

            ForEach ($prop in $ExpectedValues.Keys) {
                It "Sets the proper value for $prop" {
                    $ConfigObj = $Script:Config.Companies.$CompanyName.$ConfigArea
                    $ConfigName = $ExpectedValues[$prop].ConfigName
                    $ConfigObj.$ConfigName | Should be $ExpectedValues[$prop].Val
                }
            }
            $CredentialVar = $ExpectedValues.Keys | Where-Object {$_.Contains('Credential')}
            if($ExpectedValues.$CredentialVar.Use) {
                It 'Stores the credentials' {
                    $Param = @{
                        CommandName = 'New-StoredCredential'
                        Exactly = $true
                        Times = 1
                        ParameterFilter = {
                            $Target -eq $ExpectedValues.$CredentialVar.Val  -and
                            $Persist -eq 'Enterprise' -and
                            $Credentials -eq $TestCredential
                        }
                    }
                    Assert-MockCalled @Param
                }
            }
            else {
                It 'Does not store credentials' {
                    Assert-MockCalled New-StoredCredential -Exactly -Times 0
                }
            }
        }

        Context 'OnPrem Settings (All)' {
            #Variables
            $CompanyName = 'TestCompany'
            $TestCredential = $DefaultTestCredential
            $Script:Config = @{
                Companies = @{
                    $CompanyName = @{
                        Domain = $false
                        OnPremServices = @{
                            ExchangeUri = $false
                            SkypeUri = $false
                            CredentialName = $false
                        }
                        O365 = $false
                    }
                }
            }

            $ConfigArea = 'OnPremServices'
            $ExpectedValues = [ordered]@{
                OnPremExchangeHost = @{
                    Use = $true
                    ConfigName = 'ExchangeUri'
                    Param = 'exchange.test.com'
                    Val = 'http://exchange.test.com/PowerShell/'
                }
                OnPremSkypeHost = @{
                    Use = $true
                    ConfigName = 'SkypeURI'
                    Param = 'skype.test.com'
                    Val = 'https://skype.test.com/OCSPowerShell/'
                }
                OnPremCredential = @{
                    Use = $true
                    ConfigName = 'CredentialName'
                    Param = $TestCredential
                    Val = "OnPrem_$CompanyName"
                }
            }

            #Mocks
            Mock New-StoredCredential {}
            Mock Write-SPMTConfiguration {}

            #Run Statement
            $Param = @{
                Name = $CompanyName
            }
            ForEach ($prop in $ExpectedValues.Keys) {
                if($ExpectedValues[$prop].Use) {
                    if($ExpectedValues[$prop].ContainsKey('Param')) {
                        $ValIdentifier = 'Param'
                    }
                    else {
                        $ValIdentifier = 'Val'
                    }
                    $Param.Add($prop,$ExpectedValues[$prop].$ValIdentifier)
                }
            }
            Set-Company @Param

            ForEach ($prop in $ExpectedValues.Keys) {
                It "Sets the proper value for $prop" {
                    $ConfigObj = $Script:Config.Companies.$CompanyName.$ConfigArea
                    $ConfigName = $ExpectedValues[$prop].ConfigName
                    $ConfigObj.$ConfigName | Should be $ExpectedValues[$prop].Val
                }
            }
            $CredentialVar = $ExpectedValues.Keys | Where-Object {$_.Contains('Credential')}
            if($ExpectedValues.$CredentialVar.Use) {
                It 'Stores the credentials' {
                    $Param = @{
                        CommandName = 'New-StoredCredential'
                        Exactly = $true
                        Times = 1
                        ParameterFilter = {
                            $Target -eq $ExpectedValues.$CredentialVar.Val  -and
                            $Persist -eq 'Enterprise' -and
                            $Credentials -eq $TestCredential
                        }
                    }
                    Assert-MockCalled @Param
                }
            }
            else {
                It 'Does not store credentials' {
                    Assert-MockCalled New-StoredCredential -Exactly -Times 0
                }
            }
            It 'Writes configuration to disk' {
                Assert-MockCalled Write-SPMTConfiguration -Exactly -Times 1
            }
        }

        Context 'OnPrem Settings (Alternate)' {
            #Variables
            $CompanyName = 'TestCompany'
            $TestCredential = $DefaultTestCredential
            $Script:Config = @{
                Companies = @{
                    $CompanyName = @{
                        Domain = $false
                        OnPremServices = @{
                            ExchangeUri = $false
                            SkypeUri = $false
                            CredentialName = $false
                        }
                        O365 = $false
                    }
                }
            }

            $ConfigArea = 'OnPremServices'
            $ExpectedValues = [ordered]@{
                OnPremExchangeUri = @{
                    Use = $true
                    ConfigName = 'ExchangeUri'
                    Param = 'exchange.test.com'
                    Val = 'exchange.test.com'
                }
                OnPremSkypeURI = @{
                    Use = $true
                    ConfigName = 'SkypeURI'
                    Param = 'skype.test.com'
                    Val = 'skype.test.com'
                }
                OnPremCredential = @{
                    Use = $false
                    ConfigName = 'CredentialName'
                    Param = $TestCredential
                    Val = $false
                }
            }

            #Mocks
            Mock New-StoredCredential {}
            Mock Write-SPMTConfiguration {}

            #Run Statement
            $Param = @{
                Name = $CompanyName
            }
            ForEach ($prop in $ExpectedValues.Keys) {
                if($ExpectedValues[$prop].Use) {
                    if($ExpectedValues[$prop].ContainsKey('Param')) {
                        $ValIdentifier = 'Param'
                    }
                    else {
                        $ValIdentifier = 'Val'
                    }
                    $Param.Add($prop,$ExpectedValues[$prop].$ValIdentifier)
                }
            }
            Set-Company @Param

            ForEach ($prop in $ExpectedValues.Keys) {
                It "Sets the proper value for $prop" {
                    $ConfigObj = $Script:Config.Companies.$CompanyName.$ConfigArea
                    $ConfigName = $ExpectedValues[$prop].ConfigName
                    $ConfigObj.$ConfigName | Should be $ExpectedValues[$prop].Val
                }
            }
            $CredentialVar = $ExpectedValues.Keys | Where-Object {$_.Contains('Credential')}
            if($ExpectedValues.$CredentialVar.Use) {
                It 'Stores the credentials' {
                    $Param = @{
                        CommandName = 'New-StoredCredential'
                        Exactly = $true
                        Times = 1
                        ParameterFilter = {
                            $Target -eq $ExpectedValues.$CredentialVar.Val  -and
                            $Persist -eq 'Enterprise' -and
                            $Credentials -eq $TestCredential
                        }
                    }
                    Assert-MockCalled @Param
                }
            }
            else {
                It 'Does not store credentials' {
                    Assert-MockCalled New-StoredCredential -Exactly -Times 0
                }
            }
            It 'Writes configuration to disk' {
                Assert-MockCalled Write-SPMTConfiguration -Exactly -Times 1
            }
        }

        Context 'O365 Settings (All)' {
            #Variables
            $CompanyName = 'TestCompany'
            $TestCredential = $DefaultTestCredential
            $Script:Config = @{
                Companies = @{
                    $CompanyName = @{
                        Domain = $false
                        OnPremServices = @{
                            ExchangeUri = $false
                            SkypeUri = $false
                            CredentialName = $false
                        }
                        O365 = $false
                    }
                }
            }

            $ConfigArea = 'O365'
            $ExpectedValues = [ordered]@{
                OnlineNoMFA = @{
                    Use = $true
                    ConfigName = 'Mfa'
                    Param = $true
                    Val = $false
                }
                OnlineExchangeURI = @{
                    Use = $true
                    ConfigName = 'ExchangeOnlineUri'
                    Val = 'Exchange.Office365.com'
                }
                OnlineSkypeURI = @{
                    Use = $true
                    ConfigName = 'SkypeOnlineUri'
                    Val = 'Skype.Office365.com'
                }
                OnlineSharePointURI = @{
                    Use = $true
                    ConfigName = 'SharePointOnlineUri'
                    Val = 'Yes.Sharepoint.com'
                }
                OnlineCredential = @{
                    Use = $true
                    ConfigName = 'CredentialName'
                    Param = $TestCredential
                    Val = "O365_$CompanyName"
                }
            }

            #Mocks
            Mock New-StoredCredential {}
            Mock Write-SPMTConfiguration {}

            #Run Statement
            $Param = @{
                Name = $CompanyName
            }
            ForEach ($prop in $ExpectedValues.Keys) {
                if($ExpectedValues[$prop].Use) {
                    if($ExpectedValues[$prop].ContainsKey('Param')) {
                        $ValIdentifier = 'Param'
                    }
                    else {
                        $ValIdentifier = 'Val'
                    }
                    $Param.Add($prop,$ExpectedValues[$prop].$ValIdentifier)
                }
            }
            Set-Company @Param

            ForEach ($prop in $ExpectedValues.Keys) {
                It "Sets the proper value for $prop" {
                    $ConfigObj = $Script:Config.Companies.$CompanyName.$ConfigArea
                    $ConfigName = $ExpectedValues[$prop].ConfigName
                    $ConfigObj.$ConfigName | Should be $ExpectedValues[$prop].Val
                }
            }
            $CredentialVar = $ExpectedValues.Keys | Where-Object {$_.Contains('Credential')}
            if($ExpectedValues.$CredentialVar.Use) {
                It 'Stores the credentials' {
                    $Param = @{
                        CommandName = 'New-StoredCredential'
                        Exactly = $true
                        Times = 1
                        ParameterFilter = {
                            $Target -eq $ExpectedValues.$CredentialVar.Val  -and
                            $Persist -eq 'Enterprise' -and
                            $Credentials -eq $TestCredential
                        }
                    }
                    Assert-MockCalled @Param
                }
            }
            else {
                It 'Does not store credentials' {
                    Assert-MockCalled New-StoredCredential -Exactly -Times 0
                }
            }
            It 'Writes configuration to disk' {
                Assert-MockCalled Write-SPMTConfiguration -Exactly -Times 1
            }
        }

        Context 'O365 Settings (Alternate)' {
            #Variables
            $CompanyName = 'TestCompany'
            $TestCredential = $DefaultTestCredential
            $Script:Config = @{
                Companies = @{
                    $CompanyName = @{
                        Domain = $false
                        OnPremServices = @{
                            ExchangeUri = $false
                            SkypeUri = $false
                            CredentialName = $false
                        }
                        O365 = $false
                    }
                }
            }

            $ConfigArea = 'O365'
            $ExpectedValues = [ordered]@{
                OnlineNoMFA = @{
                    Use = $true
                    ConfigName = 'Mfa'
                    Param = $false
                    Val = $true
                }
                OnlineExchangeURI = @{
                    Use = $false
                    ConfigName = 'ExchangeOnlineUri'
                    Val = 'https://outlook.office365.com/powershell-liveid'
                }
                OnlineSkypeURI = @{
                    Use = $false
                    ConfigName = 'SkypeOnlineUri'
                    Val = 'https://online.lync.com'
                }
                OnlineSharePointURI = @{
                    Use = $false
                    ConfigName = 'SharePointOnlineUri'
                    Val = $false
                }
                OnlineCredential = @{
                    Use = $true
                    ConfigName = 'CredentialName'
                    Param = $TestCredential
                    Val = "O365_$CompanyName"
                }
            }

            #Mocks
            Mock New-StoredCredential {}
            Mock Write-SPMTConfiguration {}

            #Run Statement
            $Param = @{
                Name = $CompanyName
            }
            ForEach ($prop in $ExpectedValues.Keys) {
                if($ExpectedValues[$prop].Use) {
                    if($ExpectedValues[$prop].ContainsKey('Param')) {
                        $ValIdentifier = 'Param'
                    }
                    else {
                        $ValIdentifier = 'Val'
                    }
                    $Param.Add($prop,$ExpectedValues[$prop].$ValIdentifier)
                }
            }
            Set-Company @Param

            ForEach ($prop in $ExpectedValues.Keys) {
                It "Sets the proper value for $prop" {
                    $ConfigObj = $Script:Config.Companies.$CompanyName.$ConfigArea
                    $ConfigName = $ExpectedValues[$prop].ConfigName
                    $ConfigObj.$ConfigName | Should be $ExpectedValues[$prop].Val
                }
            }
            $CredentialVar = $ExpectedValues.Keys | Where-Object {$_.Contains('Credential')}
            if($ExpectedValues.$CredentialVar.Use) {
                It 'Stores the credentials' {
                    $Param = @{
                        CommandName = 'New-StoredCredential'
                        Exactly = $true
                        Times = 1
                        ParameterFilter = {
                            $Target -eq $ExpectedValues.$CredentialVar.Val  -and
                            $Persist -eq 'Enterprise' -and
                            $Credentials -eq $TestCredential
                        }
                    }
                    Assert-MockCalled @Param
                }
            }
            else {
                It 'Does not store credentials' {
                    Assert-MockCalled New-StoredCredential -Exactly -Times 0
                }
            }
            It 'Writes configuration to disk' {
                Assert-MockCalled Write-SPMTConfiguration -Exactly -Times 1
            }
        }

        Context 'Removal of Credentials' {
            #Variables
            $CompanyName = 'TestCompany'
            $Script:Config = @{
                Companies = @{
                    $CompanyName = @{
                        Domain = @{
                            CredentialName = "AD_$CompanyName"
                        }
                        OnPremServices = @{
                            CredentialName = "AD_$CompanyName"
                        }
                        O365 = @{
                            CredentialName = "AD_$CompanyName"
                        }
                    }
                }
            }

            #Mocks
            Mock Remove-StoredCredential {}
            Mock Write-SPMTConfiguration {}

            #Run Statement
            $Param = @{
                Name = $CompanyName
                RemoveADCredential = $true
                RemoveOnPremCredential = $true
                RemoveOnlineCredential = $true
            }
            Set-Company @Param

            #Tests
            It 'Removes the AD Credentials' {
                $Param = @{
                    CommandName = 'Remove-StoredCredential'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Target -eq "AD_$CompanyName"
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Removes the OnPrem Credentials' {
                $Param = @{
                    CommandName = 'Remove-StoredCredential'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Target -eq "OnPrem_$CompanyName"
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Removes the O365 Credentials' {
                $Param = @{
                    CommandName = 'Remove-StoredCredential'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $Target -eq "O365_$CompanyName"
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Updates the configuration' {
                $CompanyObj = $Script:Config.Companies.$CompanyName
                $CompanyObj.Domain.CredentialName | Should be $false
                $CompanyObj.OnPremServices.CredentialName | Should be $false
                $CompanyObj.O365.CredentialName | Should be $false
            }
            It 'Writes configuration to disk' {
                Assert-MockCalled Write-SPMTConfiguration -Exactly -Times 1
            }
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools