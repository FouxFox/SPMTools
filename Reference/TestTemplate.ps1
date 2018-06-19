#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
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