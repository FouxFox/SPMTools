#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
<#
    There is no way to constuct a PSSession Object
    This creates problems when trying to return such and object
    from New-PSSession and Get-PSSession. To get around this
    limitation, another layer of mocking is injected before 
    Pester Mocks each of the commands. In this way, we can
    change some minor attributes of the function's parameters
    to suit our needs here.
#>
Describe SPMTools.Public.Connect-ExchangeOnline {
    BeforeAll {
        Import-Module "$PSScriptRoot\TestVariables.psm1"
        InitTestVariables
    }
    AfterAll {
        RemoveTestVariables
        Remove-Module TestVariables
    }

    InModuleScope SPMTools {

    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools