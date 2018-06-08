Function Get-Company {
    [cmdletBinding()]
    Param()

    [Array]$Script:Config.Companies.Keys
}