#Content here runs after all functions are loaded
if($Env:SPMTools_TestMode -ne 1) {
    $ModuleVersion = (Get-Module -ListAvailable SPMTools).Version
    $SchemaVersion = Get-SPMTSchemaVersion -Version $ModuleVersion
    $Script:ConfigLocation = "$($env:APPDATA)\.SPMTools\config.json"
    $script:Config = $null
    $FirstRun = $false

    $DefaultConfig = @{
        Companies = @{}
        AzureSkuTable = @{
            'E1' = 'STANDARDPACK'
            'E3' = 'ENTERPRISEPACK'
            'E5' = 'ENTERPRISEPREMIUM'
        }
        SchemaVersion = $SchemaVersion
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

    #Check if Schema version has changed
    $SchemaUpdateCondition = (
        !$Script:Config.ContainsKey('SchemaVersion') -or 
        $Script:Config.SchemaVersion -lt $SchemaVersion
    )
    if($SchemaUpdateCondition) {
        Update-SPMTConfiguration
    }
}


# Cleanup
$OnRemoveScript = {}
$ExecutionContext.SessionState.Module.OnRemove += $OnRemoveScript