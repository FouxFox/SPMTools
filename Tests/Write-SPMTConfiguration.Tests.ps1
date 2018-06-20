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
        $Script:ConfigLocation = 'TestLocation'
        $Script:Config = 'TestValue'

        #Mocks
        Mock ConvertTo-Json { return 'Test Json' }
        Mock Out-File {}

        #Run statement
        Write-SPMTConfiguration

        #Tests
        It 'Converts it to an Json' {
            $Param = @{
                CommandName = 'ConvertTo-Json'
                Exactly = $true
                Times = 1
                ParameterFilter = {
                    $InputObject -eq 'TestValue'
                }
            }
            Assert-MockCalled @Param
        }
        It 'Writes it to the file' {
            $Param = @{
                CommandName = 'Out-File'
                Exactly = $true
                Times = 1
                ParameterFilter = {
                    $InputObject -eq 'Test Json' -and
                    $FilePath -eq 'TestLocation'
                }
            }
            Assert-MockCalled @Param
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools