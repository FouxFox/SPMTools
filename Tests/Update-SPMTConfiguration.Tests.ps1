#Testing Variables
$Script:ModulePath = "$PSScriptRoot\..\SPMTools"

# Test Mode must be set before testing
 $Env:SPMTools_TestMode = 1

#Functions
Import-Module $Script:ModulePath


#Test Suite
Describe SPMTools.Public.Update-SPMTConfiguration {
    InModuleScope SPMTools {
        #Master Variables
        $TargetSchemaVersion = 3
        #No Change Object
        $TargetObject = @{
            Companies = @{
                TestCompany = @{
                    O365 = @{
                        Mfa = $true
                        SharePointOnlineUri = $false
                        ComplianceCenterUri = $false
                        AzureADAuthorizationEndpointUri = $false
                        DirSync = $false
                    }
                }
            }
            SchemaVersion = $TargetSchemaVersion
        }

        $TestCases = [ordered]@{
            #Test Case
            0 = @{
                Description = "Makes no changes to version $TargetSchemaVersion"
                Before = $TargetObject
                After = $TargetObject
            }
            1 = @{
                Description = 'Upgrades from version 0 (No Office365)'
                Before = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = $false
                        }
                    }
                }
                After = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = $false
                        }
                    }
                    SchemaVersion = $TargetSchemaVersion
                }
            }
            2 = @{
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
                                DirSync = $false
                            }
                        }
                    }
                    SchemaVersion = $TargetSchemaVersion
                }
            }
            3 = @{
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
                                DirSync = $false
                            }
                        }
                    }
                    SchemaVersion = $TargetSchemaVersion
                }
            }
            4 = @{
                Description = 'Upgrades from version 1 (No Office365)'
                Before = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = $false
                        }
                    }
                    SchemaVersion = 1
                }
                After = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = $false
                        }
                    }
                    SchemaVersion = $TargetSchemaVersion
                }
            }
            5 = @{
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
                                DirSync = $false
                            }
                        }
                    }
                    SchemaVersion = $TargetSchemaVersion
                }
            }
            6 = @{
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
                                DirSync = $false
                            }
                        }
                    }
                    SchemaVersion = $TargetSchemaVersion
                }
            }
            7 = @{
                Description = 'Upgrades from version 2 (No Office365)'
                Before = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = $false
                        }
                    }
                    SchemaVersion = 2
                }
                After = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = $false
                        }
                    }
                    SchemaVersion = $TargetSchemaVersion
                }
            }
            8 = @{
                Description = 'Upgrades from version 2 (Office365, No DisSync)'
                Before = @{
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
                After = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                                SharePointOnlineUri = 'Test'
                                ComplianceCenterUri = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
                                AzureADAuthorizationEndpointUri = 'https://login.windows.net/common'
                                DirSync = $false
                            }
                        }
                    }
                    SchemaVersion = $TargetSchemaVersion
                }
            }
            9 = @{
                Description = 'Upgrades from version 2 (Office365, Old DisSync)'
                Before = @{
                    Companies = @{
                        TestCompany = @{
                            O365 = @{
                                Mfa = $true
                                SharePointOnlineUri = 'Test'
                                ComplianceCenterUri = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
                                AzureADAuthorizationEndpointUri = 'https://login.windows.net/common'
                                DirSyncHost = ''
                                DirSyncDC = ''
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
                                SharePointOnlineUri = 'Test'
                                ComplianceCenterUri = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
                                AzureADAuthorizationEndpointUri = 'https://login.windows.net/common'
                                DirSync = $false
                            }
                        }
                    }
                    SchemaVersion = $TargetSchemaVersion
                }
            }
        }

        Mock Write-SPMTConfiguration {}

        ForEach ($Case in $TestCases.Keys) {
            It "Case $($Case): $($TestCases[$Case].Description)" {             
                $Script:Config = $TestCases[$Case].Before
                $ExpectedJson = ($TestCases[$Case].After | ConvertTo-Json -Depth 10).Split("`n")
                Update-SPMTConfiguration
                $ActualJson = ($Script:Config | ConvertTo-Json -Depth 10).Split("`n")
                $lineNo = 0

                While ($lineNo -lt $ExpectedJson.Count -or $lineNo -lt $ActualJson.Count) {
                    $ExpectedLine = ''
                    $ActualLine = ''
                    if($lineNo -lt $ExpectedJson.Count) {
                        $ExpectedLine = $ExpectedJson[$lineNo].Trim().Replace('"','').Trim(',')
                    }
                    if($lineNo -lt $ActualJson.Count) {
                        $ActualLine = $ActualJson[$lineNo].Trim().Replace('"','').Trim(',')
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