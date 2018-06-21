
@{
    RootModule = 'PSModule.psm1'
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
        'Get-DellExpressServiceCode'
        'Get-TranslatedSID'
        'Mount-ADDrive'
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
    HelpInfoURI = 'https://github.com/AbelFox/SPMTools/blob/master/README.md'
    ModuleVersion = '0.7.5'
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
    ## 0.7.5
    * Fixed issue with Install-ExoModule that would cause Connect-ExchangeOnline to crash

    ## 0.7.4
    * Fixed error where Get-DellExpressServiceCode is not exported

    ## 0.7.3
    * Added Get-DellExpressServiceCode

    ## 0.7.2
    * Fixed issue with parameter validation on Remove-Company
    * Fixed issue with parameter validation on Get-Company
    * Fixed OnPrem SkypeHost issue in Set-Company 
    * Fixed OnPrem SkypeURI issue in Set-Company

    ## 0.7.1
    * Modifications to Mount-ADDrive's supporting code to increase perfromance
    * Changes to module core to streamline testing
    * Improved up Schema Version system
    * Modifications to Install-ExoModule to better account for issues
    * Fixed issue where Mount-ADDrive would fail to mount multiple drives if one existed

    ## 0.7.0
    * Added Schema Versioning system for the SPMT Configuration file
    * Added warning when Mount-ADDrive -Favorite is called but no companies are favorites
    * Fixed error where SkypeOnlineConnector imported twice
    * Fixed behavior around the SkypeOnlineConnector's DelayMS
    * Fixed issue with New-ADDrive where it fails to catch an exception

    ## 0.6.0
    * Fixed connection issue with Connect-ExchangeOnline when not using MFA
    * Changed parameter validation behavior for some cmdlets
    * Various fixes to Connect- cmdlets

    ## 0.5.3
    * Added -RunAtStartup parameter for Mount-ADDrive to simplify workflows
    * Fixed formatting issue with Get-Company

    ## 0.5.2
    * Fixed issue where Connect- cmdlets do not import their sessions into PowerShell
    
    ## 0.5.1
    * Changed Get-Company to allow user to get the actual configuration data
    
    ## 0.4.1
    * Added checks to New-ADDrive to make sure the active direcotry PSProvider before trying to use it
    * Changed output of Mount-ADDrive so it prints only Name and Server
    
    ## 0.4.0
    * Added the ability for module to get the Exchange PowerShell Online MFA Module programatically
    * Fixes to how Remove-Company works
    * Fixed error causing Connect-ExchangeOnPrem to fail.

    ## 0.3.2
    * Fixed further erros with Mount-ADDrive and New-ADDrive.
    
    ## 0.3.1
    * Fixed error in .psd1 that caused Mount-ADDrive not to be exported.
    
    ## 0.3.0
    * Change AD Drive Autoload behavior to Favorites. See Get-Help Mount-ADDrive for more information.
    * Added Mount-ADDrive to allow mounting of one or more ADDrives.

    ## 0.2.1
    * Changed the -Company parameter to -Name in Set-Company and Remove-Company.
    
    ## 0.2
    * Added documentation for Get-Help to all cmdlets.
    * Minor fixes
    
    ## 0.1
    * First Release
    * May be buggy, but shouldn't break anything as all cmdlets only connect to things.
'@
        }
    }
}