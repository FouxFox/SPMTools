#Upgrades the configuration file with new schema changes
## CURRENT SCHEMA VERSION: 1
#Don't forget to update Schema Version in Get-SPMTSchemaVersion

function Update-SPMTConfiguration {
    [cmdletBinding()]
    Param()
    #Check if schema version is < 1
    if(!$Script:Config.ContainsKey('SchemaVersion')) {
        $Script:Config.Add('SchemaVersion','1')
    }
    if($Script:Config.SchemaVersion -eq 1) {
        $DefaultComplainceCenterUri = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
        $DefaultAzureADAuthUri = 'https://login.windows.net/common'
        ForEach ($CompanyName in $Script:Config.Companies.Keys) {
            if($Script:Config.Companies.$CompanyName.O365) {
                $O365Obj = $Script:Config.Companies.$CompanyName.O365
                if(!$O365Obj.ContainsKey('SharePointOnlineUri')) {
                    $O365Obj.Add('SharePointOnlineUri',$false) #Added because missing
                }
                if(!$O365Obj.ContainsKey('ComplianceCenterUri')) {
                    $O365Obj.Add('ComplianceCenterUri',$DefaultComplainceCenterUri)
                }
                if(!$O365Obj.ContainsKey('AzureADAuthorizationEndpointUri')) {
                    $O365Obj.Add('AzureADAuthorizationEndpointUri',$DefaultAzureADAuthUri)
                }
            }
        }
        $Script:Config.SchemaVersion = 2
    }
    if($Script:Config.SchemaVersion -eq 2) {
        #Reserved for future updates
    }

    Write-SPMTConfiguration
}