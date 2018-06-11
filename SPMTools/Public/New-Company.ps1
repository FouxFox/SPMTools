<#
.SYNOPSIS
Creates a company profile in the SPMTools module

.DESCRIPTION
The New-Company cmdlet creates a new company profile in Service Provider Management Tools that can then 
be populated with with information using Set-Company.

.PARAMETER CompanyName
The name of the company. This will be used in may cmdlets throughout SPMTools. It is recommended
that the comapny name contain no spaces and be short but descriptive.

.EXAMPLE
Create a company for Example Services, LLC.
New-Company -CompanyName ExampleServices

.NOTES
Company profiles are stored in %APPDATA%\.SPMTools

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