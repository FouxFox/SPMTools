#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.New-Company {
    InModuleScope SPMTools {
        #Variables
        $Script:Config = @{Companies=@{}}

        #Mocks
        Mock Write-SPMTConfiguration {}

        #Run Statement
        New-Company -Name 'TestCompany'

        #Tests 
        It 'Builds the correct object' {
            $Script:Config.Companies.ContainsKey('TestCompany') | Should be $true
            $CompanyObj = $Script:Config.Companies.'TestCompany'
            $CompanyObj.Domain | Should be $false
            $CompanyObj.OnPremServices.ExchangeUri | Should be $false
            $CompanyObj.OnPremServices.SkypeUri | Should be $false
            $CompanyObj.OnPremServices.CredentialName | Should be $false
            $CompanyObj.O365 | Should be $false
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools