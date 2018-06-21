#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Get-DellExpressServiceCode {
    InModuleScope SPMTools {
        $ServiceTag = '5RFDP01'
        $ExpressServiceCode = '125-423-316-01'
        $ExpectedObject = [pscustomobject]@{
            ServiceTag = $ServiceTag
            ExpressServiceCode = $ExpressServiceCode
        }

        #Run Statement
        $Output = Get-DellExpressServiceCode $ServiceTag

        It 'Converts Properly' {
            $Output.ServiceTag | Should be $ExpectedObject.ServiceTag
            $Output.ExpressServiceCode | Should be $ExpectedObject.ExpressServiceCode
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools