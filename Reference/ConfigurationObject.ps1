@{
    Companies = @{
        Company = @{
            Domain = $false -or @{
                PSDriveLetter = 'EX'
                FQDN = 'example.com'
                PreferedDomainController = $false -or 'DomainController.example.com'
                Favorite = $true -or $false
                CredentialName = 'StoredCredentialName' -or $false
            }
            OnPremServices = @{
                ExchangeUri = $false -or 'http://ExchangeServer.example.com/PowerShell/'
                SkypeUri = $false -or 'https://SkypeFE.example.com/OCSPowerShell'
                CredentialName = 'StoredCredentialName' -or $false
            }
            O365 = $false -or @{
                Mfa = $true -or $false
                ExchangeOnlineUri = 'https://outlook.office365.com/powershell-liveid/'
                SkypeOnlineUri = 'https://online.lync.com/OCSPowerShell'
                SharePointUri = 'https://<Tenant>-admin.sharepoint.com/'
                CredentialName = 'StoredCredentialName'
                DirSync = $false -or @{
                    Host = 'HostName'
                    ConfigurationName = $false -or 'Optional Session ConfigurationName'
                    PolicyType = 'Delta'
                }
            }
        } 
    }
    AzureSkuTable = @{
        'E1' = 'STANDARDPACK'
        'E3' = 'ENTERPRISEPACK'
        'E5' = 'ENTERPRISEPREMIUM'
    }
}