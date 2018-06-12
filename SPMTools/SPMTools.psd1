
@{
    RootModule = 'PSModule.psm1'
    ModuleVersion = '0.2.1'
    GUID = 'ea42ab42-d536-4815-bd5e-816844685bf0'
    Author = 'Matt Small'
    Copyright = '(c) Matt Small. All rights reserved.'
    Description = @'
The Service Provider Management Tools module provides engineers with the ability to store connection information and use it quickly, eliminating the need to constantly retype passwords or maintain the same password across all companies serviced by the engineer to simplify the logon process.

Also packaged are helper cmdlets such as Format-Sorted to simplify '| sort Name | ft Name' to '| fs' and Get-TranslatedSID for quickly getting the NTAccount from a Security Identifier.

To Get started, add a new Company with New-Company and then set the required information with Set-Company.
'@
    PowerShellVersion = '3.0'
    #FormatsToProcess = ''
    FunctionsToExport = @(
        'Connect-ExchangeOnline'
        'Connect-ExchangeOnPrem'
        'Connect-SharePointOnline'
        'Connect-SkypeOnline'
        'Connect-SkypeOnPrem'
        'Format-Sorted'
        'Get-Company'
        'Get-TranslatedSID'
        'New-Company'
        'Remove-Company'
        'Set-Company'
    )
    VariablesToExport = "*"
    AliasesToExport = "*"
    FileList = @(
        'PSModule.psm1'
    )
    RequiredModules = @(
        @{
            ModuleName='CredentialManager'
            ModuleVersion='2.0'
        }
    )
    PrivateData = @{
        PSData = @{
            Tags = @(
                'ManagedServiceProvider'
                'Windows'
            )
            ProjectUri = 'https://github.com/AbelFox/SPMTools'
            LicenseUri = 'https://github.com/AbelFox/SPMTools/blob/master/LICENSE'
            IsPrerelease = $true
            ReleaseNotes = @'
    ## 0.2
    * Added documentation for Get-Help to all cmdlets.
    * Minor fixes
    
    ## 0.1
    * First Release
    * May be buggy, but shouldn't break anything as all cmdlets only connect to things.
'@
        }
    }
    
    HelpInfoURI = 'https://github.com/AbelFox/SPMTools/blob/master/README.md'
    }