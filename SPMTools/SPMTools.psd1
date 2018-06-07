
@{
    RootModule = 'PSModule.psm1'
    ModuleVersion = '0.1'
    GUID = 'ea42ab42-d536-4815-bd5e-816844685bf0'
    Author = 'Matt Small'
    Copyright = '(c) Matt Small. All rights reserved.'
    Description = 'PowerShell module for Managed Service Providers with commands for simplifying day to day tasks.'
    PowerShellVersion = '3.0'
    FormatsToProcess = 'PSGet.Format.ps1xml'
    FunctionsToExport = @(
        'Connect-ExchangeOnline'
        'Connect-ExchangeOnPrem'
        'Connect-SharePointOnline'
        'Connect-SkypeOnline'
        'Connect-SkypeOnPrem'
        'Enable-AzureADMailbox'
        'Format-StoredName'
        'Get-TranslatedSID'
    )
    VariablesToExport = "*"
    AliasesToExport = @(
        'fs'
    )
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
                'Managed Service Provider'
                'Windows'
            )
            ProjectUri = 'https://github.com/AbelFox/SPMTools'
            LicenseUri = 'https://github.com/AbelFox/SPMTools/blob/master/LICENSE'
            IsPrerelease = $true
            ReleaseNotes = @'
    ## 0.1
    * Nothing Yet
'@
        }
    }
    
    HelpInfoURI = 'https://github.com/AbelFox/SPMTools/blob/master/README.md'
    }