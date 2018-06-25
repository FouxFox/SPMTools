function Get-SPMTSchemaVersion {
    Param(
        [string]$Version
    )
    
    $SchemaVersionTable = @{
        '0.0.0' = 0
        '0.7.0' = 1
        '0.8.0' = 2
    }

    if($SchemaVersionTable.ContainsKey($Version)) {
        #For exact matches, skip the search
        return $SchemaVersionTable[$Version]
    }
    else {
        #Otherwise search
        $VersionList = $SchemaVersionTable.Keys | Sort-Object -Descending
        $VersionIndex = 0
        $VersionFound = $false
        While(!$VersionFound -and $VersionIndex -lt $VersionList.Count) {
            if($VersionList[$VersionIndex] -gt $Version) {
                $VersionIndex++
            }
            else {
                $VersionFound = $true
            }
        }

        return $SchemaVersionTable[$VersionList[$VersionIndex]]
    }
}