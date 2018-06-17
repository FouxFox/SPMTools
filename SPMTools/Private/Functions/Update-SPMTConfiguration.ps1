#Upgrades the configuration file with new schema changes
## CURRENT SCHEMA VERSION: 1
#Don't forget to update Schema Version in Get-SPMTSchemaVersion

function Update-SPMTConfiguration {
    #Check if schema version is < 1
    if(!$Script:Config.ContainsKey('SchemaVersion')) {
        $Script:Config.Add('SchemaVersion','1')
    }
    if($Script:Config.SchemaVersion -eq 1) {
        #Reserved for future updates
    }

    Write-SPMTConfiguration
}