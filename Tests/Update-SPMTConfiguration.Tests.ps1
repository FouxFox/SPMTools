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

        #For testing upgrade script
        function Compare-Configurations {
            param($ExpectedConfig,$ActualConfig)

            $ActualConfig.Keys | ForEach-Object {
                $Key = $_
                $ActualValue = $ActualConfig[$_]
                if($ExpectedConfig.ContainsKey($Key)) {
                    $ExpectedValue = $ExpectedConfig[$_]
                    if($ActualValue.GetType().Name -eq 'Hashtable') {
                        if($ExpectedValue.GetType().Name -eq 'Hashtable') {
                            Compare-Configurations $ExpectedValue $ActualValue
                        }
                        else {
                            "$($Key): <Hashtable>" | Should be "$($key): $ExpectedValue"
                        }
                    }
                    else {
                        if($ExpectedValue.GetType().Name -eq 'Hashtable') {
                            "$($key): $ActualValue" | Should be "$($Key): <Hashtable>"
                        }
                        else {
                            "$($key): $ActualValue" | Should be "$($Key): $ExpectedValue"
                        }
                    }
                }
                else {
                    $key | Should bein $ExpectedConfig.Keys
                }
            }
        }

        ForEach ($Case in $TestCases.Keys) {
            It "Case $($Case): $($TestCases[$Case].Description)" {             
                $Script:Config = $TestCases[$Case].Before
                $ExpectedConfig = $TestCases[$Case].After
                Update-SPMTConfiguration
                $ActualConfig = $Script:Config

                Compare-Configurations $ExpectedConfig $ActualConfig
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