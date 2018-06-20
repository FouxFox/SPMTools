#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Read-SPMTConfiguration {
    InModuleScope SPMTools {
        #Variables
        $Script:ConfigLocation = "TestLocation"
        $SampleObject = [pscustomobject]@{
            Name = 'Test'
        }
        $SampleJson = $SampleObject | ConvertTo-Json

        #Mocks
        Mock Get-Content { return $SampleJson }
        Mock ConvertFrom-Json { return $SampleObject }
        Mock ConvertTo-HashTable { return 'TestValue' }

        #Run statement
        Read-SPMTConfiguration

        #Tests
        It 'Gets the settings file' {
            $Param = @{
                CommandName = 'Get-Content'
                Exactly = $true
                Times = 1
                ParameterFilter = {
                    $Path -eq "TestLocation"
                }
            }
            Assert-MockCalled @Param
        }
        It 'Converts it to an Object' {
            $Param = @{
                CommandName = 'ConvertFrom-Json'
                Exactly = $true
                Times = 1
                ParameterFilter = {
                    $InputObject -eq $SampleJson
                }
            }
            Assert-MockCalled @Param
        }
        It 'Converts it to a HashTable' {
            $Param = @{
                CommandName = 'ConvertTo-HashTable'
                Exactly = $true
                Times = 1
                ParameterFilter = {
                    $root -eq $SampleObject
                }
            }
            Assert-MockCalled @Param
        }
        It 'Stores it in the module config object' {
            $Script:Config | Should be 'TestValue'
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools