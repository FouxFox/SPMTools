function Get-SPMTSchemaVersion {
    Param(
        [string]$Version
    )
    
    $SchemaVersionTable = @{
        '0.7.0' = 1
    }

    $SchemaVersionTable[$Version]
}