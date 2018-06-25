#Upgrades the configuration file with new schema changes
## CURRENT SCHEMA VERSION: 1
#Don't forget to update Schema Version in Get-SPMTSchemaVersion

function Update-SPMTConfiguration {
    #Check if schema version is < 1
    if(!$Script:Config.ContainsKey('SchemaVersion')) {
        $Script:Config.Add('SchemaVersion','1')
    }
    if($Script:Config.SchemaVersion -eq 1) {
        $DefaultComplainceCeterUri = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
        ForEach ($CompanyName in $Script:Config.Companies) {
            if(Script:Config.Companies.$CompanyName.O365) {
                $Script:Config.Companies.$CompanyName.O365.SharePointOnlineUri = $false #Added because missing
                $Script:Config.Companies.$CompanyName.O365.ComplianceCenterUri = $DefaultComplainceCeterUri
            }
        }
        $Script:Config.SchemaVersion = 2
    }
    if($Script:Config.SchemaVersion -eq 2) {
        #Reserved for future updates
    }

    Write-SPMTConfiguration
}