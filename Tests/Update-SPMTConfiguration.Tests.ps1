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
            Companies = @{
                TestCompany = @{
                    O365 = @{

                    }
                }
            }
            SchemaVersion = 1
        }
        $TestCases = [ordered]@{
            #Test Case
            0 = @{
                Description = 'Upgrades from version 0 (No Office365)'
                Before = @{
                    Companies = @{}
                }
                After = @{
                    Companies = @{}
                    SchemaVersion = 2
                }
            }
            1 = @{
                Description = 'Upgrades from version 0 (Office365, No Sharepoint)'
                Before = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                            }
                        }
                    }
                }
                After = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                                SharePointOnlineUri = $false
                                ComplianceCenterUri = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
                                AzureADAuthorizationEndpointUri = 'https://login.windows.net/common'
                            }
                        }
                    }
                    SchemaVersion = 2
                }
            }
            2 = @{
                Description = 'Upgrades from version 0 (Office365, Sharepoint)'
                Before = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                                SharePointOnlineUri = 'Test'
                            }
                        }
                    }
                }
                After = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                                SharePointOnlineUri = 'Test'
                                ComplianceCenterUri = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
                                AzureADAuthorizationEndpointUri = 'https://login.windows.net/common'
                            }
                        }
                    }
                    SchemaVersion = 2
                }
            }
            3 = @{
                Description = 'Upgrades from version 1 (No Office365)'
                Before = @{
                    Companies = @{}
                    SchemaVersion = 1
                }
                After = @{
                    Companies = @{}
                    SchemaVersion = 2
                }
            }
            4 = @{
                Description = 'Upgrades from version 1 (Office365)'
                Before = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                            }
                        }
                    }
                    SchemaVersion = 1
                }
                After = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                                SharePointOnlineUri = $false
                                ComplianceCenterUri = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
                                AzureADAuthorizationEndpointUri = 'https://login.windows.net/common'
                            }
                        }
                    }
                    SchemaVersion = 2
                }
            }
            5 = @{
                Description = 'Upgrades from version 1 (Office365, Sharepoint)'
                Before = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                                SharePointOnlineUri = 'Test'
                            }
                        }
                    }
                    SchemaVersion = 1
                }
                After = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                                SharePointOnlineUri = 'Test'
                                ComplianceCenterUri = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
                                AzureADAuthorizationEndpointUri = 'https://login.windows.net/common'
                            }
                        }
                    }
                    SchemaVersion = 2
                }
            }
            6 = @{
                Description = 'Makes no changes to version 2'
                Before = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                                SharePointOnlineUri = $false
                                ComplianceCenterUri = $false
                                AzureADAuthorizationEndpointUri = $false
                            }
                        }
                    }
                    SchemaVersion = 2
                }
                After = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                                SharePointOnlineUri = $false
                                ComplianceCenterUri = $false
                                AzureADAuthorizationEndpointUri = $false
                            }
                        }
                    }
                    SchemaVersion = 2
                }
            }
        }

        Mock Write-SPMTConfiguration {}

        ForEach ($Case in $TestCases.Keys) {
            It "Case $($Case): $($TestCases[$Case].Description)" {
                $Script:Config = $TestCases[$Case].Before
                $ExpectedJson = ($TestCases[$Case].After | ConvertTo-JsonEx -Depth 10).Split("`n")
                Update-SPMTConfiguration
                $ActualJson = ($Script:Config | ConvertTo-JsonEx -Depth 10).Split("`n")
                $lineNo = 0
                While ($lineNo -lt $ExpectedJson.Count -or $lineNo -lt $ActualJson.Count) {
                    $ExpectedLine = ''
                    $ActualLine = ''
                    if($lineNo -lt $ExpectedJson.Count) {
                        $ExpectedLine = $ExpectedJson[$lineNo].Trim().Replace('"','')
                    }
                    if($lineNo -lt $ActualJson.Count) {
                        $ActualLine = $ActualJson[$lineNo].Trim().Replace('"','')
                    }
                    
                    $ActualLine | Should be $ExpectedLine
                    $lineNo++
                }
            }
        }
        It 'Calls Write-SPMTConfiguration after each change' {
            $Param =@{
                CommandName = 'Write-SPMTConfiguration'
                Exactly = $true
                Times = $TestCases.Count
            }
            Assert-MockCalled @Param
        }
    }
}

#Cleanup
$Env:SPMTools_TestMode = 0
Remove-Module SPMTools