#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Format-Sorted {
    InModuleScope SPMTools {
        Context 'Sort by defualt (Name)' {
            $FirstObj = [pscustomobject]@{
                Name = 'Bob'
                Age = 30
            }
            $SecondObj = [pscustomobject]@{
                Name = 'Amy'
                Age = 28
            }
            $Obj = @(
                $FirstObj
                $SecondObj
            )

            # Create Mocks
            Mock Sort-Object {
                Try {
                    Assert-MockCalled Sort-Object -Times 1 -Exactly
                    return $FirstObj
                }
                Catch {
                    return $SecondObj
                }
            }
            Mock Format-Table

            #Run Statement
            $obj | Format-Sorted

            #Tests
            It 'Calls all mocks' {
                $Param = @{
                    CommandName = 'Sort-Object'
                    Exactly = $true
                    Times = 2
                    ParameterFilter = {
                        $Property -eq 'Name'
                    }
                }
                Assert-MockCalled @Param

                $Param = @{
                    CommandName = 'Format-Table'
                    Exactly = $true
                    Times = 2
                    ParameterFilter = {
                        $Property -eq 'Name'
                    }
                }
                Assert-MockCalled @Param
            }
        }

        Context 'Sort by Other (with AutoSize)' {
            $FirstObj = [pscustomobject]@{
                Name = 'Bob'
                Age = 30
            }
            $SecondObj = [pscustomobject]@{
                Name = 'Amy'
                Age = 28
            }
            $Obj = @(
                $FirstObj
                $SecondObj
            )

            # Create Mocks
            Mock Sort-Object {
                Try {
                    Assert-MockCalled Sort-Object -Times 1 -Exactly
                    return $FirstObj
                }
                Catch {
                    return $SecondObj
                }
            }
            Mock Format-Table

            #Run Statement
            $obj | Format-Sorted -sortOn Age -AutoSize

            #Tests
            It 'Calls all mocks' {
                $Param = @{
                    CommandName = 'Sort-Object'
                    Exactly = $true
                    Times = 2
                    ParameterFilter = {
                        $Property -eq 'Age'
                    }
                }
                Assert-MockCalled @Param

                $Param = @{
                    CommandName = 'Format-Table'
                    Exactly = $true
                    Times = 2
                    ParameterFilter = {
                        $Property -eq 'Age' -and
                        $AutoSize -eq $true
                    }
                }
                Assert-MockCalled @Param
            }
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools