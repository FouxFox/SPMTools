#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Read-SPMTConfiguration {
    InModuleScope SPMTools {
        Context 'Normal read' {
            #Variables
            $Script:ConfigLocation = "TestLocation"
            $Script:BackupConfigLocation = "BackupLocation"
            $SampleObject = [pscustomobject]@{
                Name = 'Test'
            }
            $SampleJson = $SampleObject | ConvertTo-Json

            #Mocks
            Mock Get-Content { return $SampleJson }
            Mock ConvertFrom-Json { return $SampleObject }
            Mock ConvertTo-HashTable { return 'TestValue' }
            Mock Write-SPMTConfiguration { }
            Mock Write-Verbose { }

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
            It 'Writes the configuration to the backup file' {
                $Param = @{
                    CommandName = 'Write-SPMTConfiguration'
                    Exactly = $true
                    Times = 1
                    ParameterFilter = {
                        $ConfigFilePath -eq 'BackupLocation'
                    }
                }
                Assert-MockCalled @Param
            }
            It 'Calls Write-Verbose' {
                $Param = @{
                    CommandName = 'Write-Verbose'
                    Exactly = $true
                    Times = 1
                }
                Assert-MockCalled @Param
            }
        }

        Context 'Bad read from Get-Content' {
            #Mocks
            Mock Get-Content { throw }     

            #Tests
            It 'Gets the settings file' {
                {Read-SPMTConfiguration} | Should Throw
            }
        }

        Context 'Bad Conversion from JSON' {
            #Mocks
            Mock Get-Content { return 'test' }
            Mock ConvertFrom-Json { throw }    

            #Tests
            It 'Gets the settings file' {
                {Read-SPMTConfiguration} | Should Throw
            }
        }

        Context 'Bad conversion to hash table' {
            #Mocks
            Mock Get-Content { return 'test' }
            Mock ConvertFrom-Json { return 'test' }
            Mock ConvertTo-HashTable { throw }       

            #Tests
            It 'Gets the settings file' {
                {Read-SPMTConfiguration} | Should Throw
            }
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools