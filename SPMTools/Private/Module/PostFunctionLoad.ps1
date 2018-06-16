#Content here runs after all functions are loaded
if($Env:SPMTools_TestMode -ne 1) {
    $Script:ConfigLocation = "$($env:APPDATA)\.SPMTools\config.json"
    $script:Config = $null
    $FirstRun = $false

    $DefaultConfig = @{
        Companies = @{
        <#  
            Company = @{
                Domain = @{
                    PSDriveLetter = 'EX'
                    FQDN = 'example.com'
                    PreferedDomainController = $false -or 'DomainController.example.com'
                    Favorite = $true -or $false
                    CredentialName = 'StoredCredentialName' -or $false
                }
                OnPremServices =  @{
                    Exchange = @{
                        Uri = 'http://ExchangeServer.example.com/PowerShell/'
                    }
                    Skype = @{
                        Uri = 'https://SkypeFE.example.com/OCSPowerShell'
                    }
                    CredentialName = 'StoredCredentialName' -or $false
                }
                O365 = @{
                    Mfa = $true -or $false
                    ExchangeOnlineUri = 'https://outlook.office365.com/powershell-liveid/'
                    SkypeOnlineUri = https://online.lync.com/OCSPowerShell
                    CredentialName = 'StoredCredentialName'
                }
            } 
        #>
        }
        AzureSkuTable = @{
            'E1' = 'STANDARDPACK'
            'E3' = 'ENTERPRISEPACK'
            'E5' = 'ENTERPRISEPREMIUM'
        }
    }
        

    if (!(Test-Path -Path $Script:ConfigLocation)) {
        #Config file is missing, Write a new one.
        Try {
            New-Item -ItemType Directory -Path $Script:ConfigLocation.Replace('\config.json','')
            $Script:Config = $DefaultConfig
            Write-SPMTConfiguration
            $FirstRun = $true
        }
        Catch {
            Throw $_
        }
    }

    #Load Config File
    if ((Test-Path -Path $ConfigLocation)) {
        Try {
            Read-SPMTConfiguration
        }
        Catch {
            Throw $_
        }
    }
}


# Cleanup
$OnRemoveScript = {}
$ExecutionContext.SessionState.Module.OnRemove += $OnRemoveScript