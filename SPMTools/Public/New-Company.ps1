<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER

.EXAMPLE

.EXAMPLE

.NOTES


#>
Function New-Company {
    [cmdletBinding()] 
    Param(
	    [Parameter(Mandatory=$True)] 
        [string]$CompanyName
    )
    
    #Initial Variable
    $CompanyObj = @{
        Domain = $false
        OnPremServices = @{
            ExchangeUri = $false
            SkypeUri = $false
            CredentialName = $false
        }
        O365 = $false
    }

    $script:Config.Companies.Add($CompanyName,$CompanyObj)
    Write-SPMTConfiguration
}