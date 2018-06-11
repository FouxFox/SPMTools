<#
.SYNOPSIS
Returns a list of company's from the SPMTools config file

.DESCRIPTION
Returns the list of entered companies in the Service Provider Management Tools config file.
Additional companies can be added with New-Company

.EXAMPLE
Get-Company

.NOTES


#>

Function Get-Company {
    [cmdletBinding()]
    Param()

    [Array]$Script:Config.Companies.Keys
}