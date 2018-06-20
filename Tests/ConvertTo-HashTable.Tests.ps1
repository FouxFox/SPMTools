#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.ConvertTo-HashTable {
    InModuleScope SPMTools {
        $TestObj = [pscustomobject]@{
            Level2 = [pscustomobject]@{
                Level3 = [pscustomobject]@{
                    Level4 = [pscustomobject]@{
                        Level5 = [pscustomobject]@{
                            Value = 1
                        }
                        Value = "test"
                    }
                    Value = 1.25
                }
                Value = 10
            }
            Value = @(1,2,3,4,5)
        }

        #Run Statement
        $OutputObj = $TestObj | ConvertTo-HashTable

        #Tests
        It 'Converts to 1 level' {
            $OutputObj.GetType().Name | Should be 'Hashtable'
        }
        It 'Converts to 2 levels' {
            $OutputObj.Level2.GetType().Name | Should be 'Hashtable'
        }
        It 'Converts to 3 levels' {
            $OutputObj.Level2.Level3.GetType().Name | Should be 'Hashtable'
        }
        It 'Converts to 4 levels' {
            $OutputObj.Level2.Level3.Level4.GetType().Name | Should be 'Hashtable'
        }
        It 'Converts to 5 levels' {
            $OutputObj.Level2.Level3.Level4.Level5.GetType().Name | Should be 'Hashtable'
        }
        It 'Retains values' {
            $OutputObj.Level2.Level3.Level4.Level5.Value | Should be 1
            $OutputObj.Level2.Level3.Level4.Value | Should be 'test'
            $OutputObj.Level2.Level3.Value | Should be 1.25
            $OutputObj.Level2.Value | Should be 10
            $OutputObj.Value | Should be @(1,2,3,4,5)
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools