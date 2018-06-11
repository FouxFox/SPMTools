Function Read-SPMTConfiguration {
    [cmdletBinding()] 
    Param()

    $Obj = Get-Content -Path $Script:ConfigLocation | ConvertFrom-Json
    $script:Config = $obj | ConvertTo-HashTable

    <#
        For Testing:
        $obj = Get-Content -Path "$($env:APPDATA)\.SPMTools\config.json" | ConvertFrom-JSON
        $Config = $obj | ConvertTo-HashTable
    #>
}