Function Read-SPMTConfiguration {
    [cmdletBinding()] 
    Param()

    $script:Config = Get-Content -Path $Script:ConfigLocation | ConvertFrom-Json
}