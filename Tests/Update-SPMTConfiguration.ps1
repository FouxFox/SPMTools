#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Update-SPMTConfiguration {
    InModuleScope SPMTools {
        $ExpectedObject = @{
            SchemaVersion = 1
        }
        $TestConfigObj = @{
            #Schema Version = Result Object
            0 = @{}
            1 = @{
                SchemaVersion = 1
            }
        }

        Mock Write-SPMTConfiguration {}

        ForEach ($ver in $TestConfigObj.Keys) {
            It "Upgrades from version $ver" {
                $Script:Config = $TestConfigObj[$ver]
                Update-SPMTConfiguration
                $Script:Config.ToString() | Should be $ExpectedObject.ToString()
            }
        }
        It 'Calls Write-SPMTConfiguration after each change' {
            $Param =@{
                CommandName = 'Write-SPMTConfiguration'
                Exactly = $true
                Times = $TestConfigObj.Count
            }
            Assert-MockCalled @Param
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools