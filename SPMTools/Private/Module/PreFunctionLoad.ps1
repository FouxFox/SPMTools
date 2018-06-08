#Content here runs before functions are loaded.

$ConfigLocation = "$($env:APPDATA)\.SPMTools\config.json"
$SPMToolsConfig = $null
$FirstRun = $false

$DefaultConfig = @{
    Company = @(
    <#  Domain = @{
            PSDriveLetter = 'EX'
            FQDN = 'example.com'
            DomainController = $null -or 'DomainController.example.com'
            AutoConnect = $true -or $false
            CredentialName = 'StoredCredentialName' -or $false
        }
        OnPremServices =  @{
            Exchange = @{
                Uri = 'http://ExchangeServer.example.com/PowerShell/'
                CredentialName = 'StoredCredentialName' -or $false
            }
            Skype = @{
                Uri = 'https://SkypeFE.example.com/OCSPowerShell'
                CredentialName = 'StoredCredentialName' -or $false
            }
        }
        O365 = @{
            Mfa = $true -or $false
            ExchangeOnlineUri = 'https://outlook.office365.com/powershell-liveid/'
            SkypeOnlineUri = https://online.lync.com/OCSPowerShell
            CredentialName = 'StoredCredentialName'
        } #>
    )
    AzureSkuTable = @{
        'E1' = 'STANDARDPACK'
        'E3' = 'ENTERPRISEPACK'
        'E5' = 'ENTERPRISEPREMIUM'
    }
}
    

if (!(Test-Path -Path $ConfigLocation)) {
    #Config file is missing, Write a new one.
    Try {
        $DefaultConfig | ConvertTo-Json -Depth 5 | Out-File -FilePath $ConfigLocation -Force -Confirm:$false
        $FirstRun = $true
    }
    Catch {
        Throw $_
    }
}

#Load Config File
if ((Test-Path -Path $ConfigLocation)) {
    Try {
        $SPMToolsConfig = Get-Content -Path $ConfigLocation | ConvertFrom-Json 
    }
    Catch {
        Throw $_
    }
}