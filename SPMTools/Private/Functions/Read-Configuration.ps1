Function Read-Configuration {
    [cmdletBinding()] 
    Param()

    $script:Config = Get-Content -Path $Script:ConfigLocation | ConvertFrom-Json
}