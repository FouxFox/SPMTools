#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Connect-ExchangeOnline {
    InModuleScope SPMTools {
        $VersionTestObj = @{
            #ModuleVersion = Expected Schema
            '0.1.0' = 0
            '0.7.0' = 1
            '0.8.1' = 1
        }

        ForEach ($ver in $VersionTestObj.Keys) {
            It "Should return $($VersionTestObj[$ver])" {
                $SchemaVer = Get-SPMTSchemaVersion -Version $ver 
                $SchemaVer | Should be $VersionTestObj[$ver]
            }
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools