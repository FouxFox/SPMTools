Function Write-Configuration {
    [cmdletBinding()] 
    Param()

    $script:Config | ConvertTo-Json -Depth 5 | Out-File -FilePath $Script:ConfigLocation -Force -Confirm:$false
}